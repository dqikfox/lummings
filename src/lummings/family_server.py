"""Loopback-only family app; all persistent files live under the project root."""
from __future__ import annotations

import argparse
import hashlib
import json
import secrets
import sqlite3
import threading
from datetime import UTC, datetime
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_ROOT = PROJECT_ROOT / "data" / "family"
MAX_BODY = 1_000_000


def fresh():
    return {"version": 1, "active": "guest", "profiles": [{"id": "guest", "name": "Explorer", "character": "lumo", "progress": {}, "discoveries": [], "creations": [], "draft": ""}], "settings": {"large": False, "calm": False, "session": 20}, "saving": True}


def validate(data):
    if not isinstance(data, dict) or data.get("version") != 1:
        raise ValueError("Unsupported family data version")
    profiles = data.get("profiles")
    if not isinstance(profiles, list) or not 1 <= len(profiles) <= 6:
        raise ValueError("A family must have one to six profiles")
    ids = set()
    for p in profiles:
        if not isinstance(p, dict):
            raise ValueError("Invalid profile")  # noqa: TRY004 - caller maps ValueError and TypeError to HTTP 400
        for key, limit in [("id", 100), ("name", 24)]:
            if not isinstance(p.get(key), str) or not p[key].strip() or len(p[key]) > limit:
                raise ValueError("Invalid profile " + key)
        if p["id"] in ids:
            raise ValueError("Duplicate profile identity")
        ids.add(p["id"])
        if p.get("character") not in {"lumo", "luna", "sprout", "nori", "moki"}:
            raise ValueError("Unknown companion")
        if not isinstance(p.get("draft", ""), str) or len(p.get("draft", "")) > 2000:
            raise ValueError("Invalid notebook draft")
        progress = p.get("progress")
        if not isinstance(progress, dict) or len(progress) > 100:
            raise ValueError("Invalid progress")
        for state in progress.values():
            if not isinstance(state, dict) or not isinstance(state.get("nodeId"), str) or not isinstance(state.get("history"), list) or len(state["history"]) > 10000 or not all(isinstance(n, str) for n in state["history"]):
                raise ValueError("Invalid adventure state")
            if not all(type(state.get(k)) is bool for k in ("paused", "finished", "hint")):
                raise ValueError("Invalid adventure flags")
        for key, limit in [("discoveries", 100), ("creations", 50)]:
            if not isinstance(p.get(key), list) or len(p[key]) > limit:
                raise ValueError("Invalid " + key)
        for item in p["creations"]:
            if not isinstance(item, dict) or not isinstance(item.get("id"), (int, str)) or not isinstance(item.get("text"), str) or len(item["text"]) > 2000 or not isinstance(item.get("at"), str):
                raise ValueError("Invalid notebook story")
        for item in p["discoveries"]:
            if not isinstance(item, dict) or not isinstance(item.get("story"), str) or not isinstance(item.get("at"), str):
                raise ValueError("Invalid discovery")  # noqa: TRY004 - caller maps ValueError and TypeError to HTTP 400
    if data.get("active") not in ids:
        raise ValueError("Active profile is missing")
    settings = data.get("settings")
    if not isinstance(settings, dict) or any(type(settings.get(k)) is not bool for k in ("large", "calm")) or type(settings.get("session")) is not int or settings["session"] not in (0, 10, 20, 30):
        raise ValueError("Invalid reading settings")
    data["saving"] = True
    return data


class Conflict(Exception):
    pass


class FamilyRepository:
    def __init__(self, directory=DATA_ROOT):
        self.directory = Path(directory).resolve()
        self.directory.mkdir(parents=True, exist_ok=True)
        self.path = self.directory / "family.sqlite3"
        self.lock = threading.RLock()
        for name in ("backups", "exports", "migrations"):
            (self.directory / name).mkdir(exist_ok=True)
        with self.connect() as db:
            db.execute("CREATE TABLE IF NOT EXISTS family (id INTEGER PRIMARY KEY CHECK(id=1), revision INTEGER NOT NULL, payload TEXT NOT NULL)")
            db.execute("CREATE TABLE IF NOT EXISTS migrations (digest TEXT PRIMARY KEY)")
            db.execute("INSERT OR IGNORE INTO family VALUES (1, 0, ?)", (json.dumps(fresh()),))
        # Fail closed on corrupted persisted data rather than silently replacing it.
        validate(self.read()["data"])

    def connect(self):
        return sqlite3.connect(self.path, timeout=10)

    def read(self):
        with self.lock, self.connect() as db:
            revision, payload = db.execute("SELECT revision,payload FROM family WHERE id=1").fetchone()
            return {"revision": revision, "data": json.loads(payload), "directory": str(self.directory)}

    def _snapshot(self, revision, payload):
        path = self.directory / "backups" / f"revision-{revision:08d}.json"
        if not path.exists():
            with path.open("x", encoding="utf-8") as stream:
                stream.write(payload)

    def write(self, data, revision):
        payload = json.dumps(validate(data), ensure_ascii=False)
        with self.lock, self.connect() as db:
            db.execute("BEGIN IMMEDIATE")
            previous, old = db.execute("SELECT revision,payload FROM family WHERE id=1").fetchone()
            if type(revision) is not int or revision != previous:
                raise Conflict("Another window saved newer data. Reload before making more changes; your pending work is still in this page.")
            self._snapshot(previous, old)
            db.execute("UPDATE family SET revision=?,payload=? WHERE id=1", (previous + 1, payload))
        return self.read()

    def migrate(self, legacy):
        validate(legacy)
        payload = json.dumps(legacy, sort_keys=True, ensure_ascii=False)
        digest = hashlib.sha256(payload.encode()).hexdigest()
        with self.lock, self.connect() as db:
            db.execute("BEGIN IMMEDIATE")
            if db.execute("SELECT 1 FROM migrations WHERE digest=?", (digest,)).fetchone():
                return self.read()
            revision, old = db.execute("SELECT revision,payload FROM family WHERE id=1").fetchone()
            current = json.loads(old)
            if revision == 0:
                current = legacy
            else:
                if len(current["profiles"]) + len(legacy["profiles"]) > 6:
                    raise ValueError("Browser import would exceed six profiles. Browser data is preserved; export or remove an unused server profile first.")
                for p in legacy["profiles"]:
                    p["id"] = digest[:16] + "-" + p["id"]
                    current["profiles"].append(p)
            validate(current)
            self._snapshot(revision, old)
            archive = self.directory / "migrations" / f"browser-{digest}.json"
            if not archive.exists():
                archive.write_text(payload, encoding="utf-8")
            db.execute("UPDATE family SET revision=?,payload=? WHERE id=1", (revision + 1, json.dumps(current, ensure_ascii=False)))
            db.execute("INSERT INTO migrations VALUES (?)", (digest,))
        return self.read()

    def export(self, data=None):
        with self.lock:
            payload = validate(data) if data is not None else self.read()["data"]
            stamp = datetime.now(UTC).strftime("%Y%m%dT%H%M%S%fZ")
            path = self.directory / "exports" / f"family-{stamp}.json"
            with path.open("x", encoding="utf-8") as stream:
                json.dump(payload, stream, indent=2, ensure_ascii=False)
            return str(path)


class FamilyHTTPServer(ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, address, repository, docs=PROJECT_ROOT / "docs"):
        self.repository = repository
        self.docs = Path(docs).resolve()
        self.token = secrets.token_urlsafe(32)
        super().__init__(address, FamilyHandler)


class FamilyHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(args[2].docs), **kwargs)

    def log_message(self, format, *args):
        # Request URLs may contain private input. Keep request data out of logs.
        pass

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "no-referrer")
        self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'self'")
        super().end_headers()

    def json_response(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def trusted(self):
        allowed = {f"127.0.0.1:{self.server.server_port}", f"localhost:{self.server.server_port}"}
        if self.headers.get("Host") not in allowed:
            self.json_response(403, {"error": "Invalid local host"})
            return False
        origin = self.headers.get("Origin")
        if origin and origin != "http://" + self.headers["Host"]:
            self.json_response(403, {"error": "Cross-origin requests are not allowed"})
            return False
        return True

    def do_GET(self):
        if not self.trusted():
            return
        route = urlsplit(self.path).path
        if route == "/api/family":
            self.json_response(200, {**self.server.repository.read(), "token": self.server.token})
        elif route.startswith("/api/"):
            self.json_response(404, {"error": "Unknown endpoint"})
        else:
            target = (self.server.docs / unquote(route).lstrip("/")).resolve()
            if not target.is_relative_to(self.server.docs) or (target.is_dir() and not (target / "index.html").is_file()):
                self.json_response(404, {"error": "Not found"})
                return
            super().do_GET()

    def do_HEAD(self):
        self.send_error(405)

    def do_POST(self):
        if not self.trusted():
            return
        if not secrets.compare_digest(self.headers.get("X-Lummings-Token", ""), self.server.token):
            self.json_response(403, {"error": "Reload the app to reconnect to the local server"})
            return
        try:
            size = int(self.headers.get("Content-Length", "0"))
            if not 0 < size <= MAX_BODY or self.headers.get_content_type() != "application/json":
                raise ValueError("Expected JSON body under 1 MB")
            body = json.loads(self.rfile.read(size))
            if not isinstance(body, dict):
                raise ValueError("Expected an object")  # noqa: TRY004 - caller maps ValueError and TypeError to HTTP 400
            route = urlsplit(self.path).path
            if route == "/api/family":
                result = self.server.repository.write(body.get("data"), body.get("revision"))
            elif route == "/api/family/migrate":
                result = self.server.repository.migrate(body.get("data"))
            elif route == "/api/family/export":
                result = {"path": self.server.repository.export(body.get("data"))}
            else:
                self.json_response(404, {"error": "Unknown endpoint"})
                return
            self.json_response(200, result)
        except Conflict as exc:
            self.json_response(409, {"error": str(exc)})
        except (ValueError, TypeError, KeyError) as exc:
            self.json_response(400, {"error": str(exc)})
        except (OSError, sqlite3.Error):
            self.json_response(500, {"error": "Could not write project data. Check disk space and file permissions; keep this page open."})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8512)
    args = parser.parse_args()
    repository = FamilyRepository()
    server = FamilyHTTPServer(("127.0.0.1", args.port), repository)
    print(f"Lummings: http://127.0.0.1:{args.port}/companion/", flush=True)
    print(f"Family data: {repository.path}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
