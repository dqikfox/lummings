"""Durable, review-gated creative jobs for the local Lummings creator app.

This module owns generated assets separately from approved character references.
Provider execution is deliberately injected so the lifecycle can be tested without
network access, credentials, or spend.
"""
from __future__ import annotations

import hashlib
import re
import sqlite3
import uuid
from contextlib import closing
from datetime import datetime, timezone
from decimal import Decimal, InvalidOperation
from pathlib import Path

from .characters import canonical

JOB_ID = re.compile(r"^[a-f0-9-]{36}$")
MAX_PROMPT = 800
WARDROBES = ("heartlight-explorer", "starlight-storyteller", "garden-inventor")
SCENES = ("observatory", "moon-garden", "cloud-kingdom", "undersea-library")
PRICES = {
    "image": {"model": "fal-ai/flux-2/edit", "amountUSD": "0.024", "basis": "1 MP reference input + 1 MP output"},
    "video": {"model": "fal-ai/pika/v2.2/image-to-video", "amountUSD": "0.20", "basis": "5 seconds at 720p"},
}


class JobConflict(Exception):
    pass


class MediaJobs:
    """SQLite-backed job lifecycle and private generated-asset directory."""

    def __init__(self, database, output_root, daily_budget_usd="0.00"):
        self.database = Path(database)
        self.output_root = Path(output_root).resolve()
        self.output_root.mkdir(parents=True, exist_ok=True)
        try:
            self.daily_budget_usd = Decimal(str(daily_budget_usd)).quantize(Decimal("0.001"))
        except (InvalidOperation, ValueError):
            raise ValueError("Daily media budget must be a non-negative USD amount.") from None
        if not self.daily_budget_usd.is_finite() or self.daily_budget_usd < 0:
            raise ValueError("Daily media budget must be a non-negative USD amount.")
        with closing(self.connect()) as db, db:
            db.executescript("""
                CREATE TABLE IF NOT EXISTS creator_jobs (
                    id TEXT PRIMARY KEY, request_key TEXT UNIQUE NOT NULL,
                    kind TEXT NOT NULL CHECK(kind IN ('image','video')),
                    character TEXT NOT NULL, prompt TEXT NOT NULL,
                    wardrobe TEXT NOT NULL, scene TEXT NOT NULL,
                    source_job TEXT, source_hash TEXT, reference_hash TEXT NOT NULL,
                    state TEXT NOT NULL CHECK(state IN ('draft','queued','running','awaiting_review','accepted','rejected','failed')),
                    asset_name TEXT, asset_mime TEXT, asset_hash TEXT,
                    provider_request_id TEXT, error TEXT,
                    created_at TEXT NOT NULL, updated_at TEXT NOT NULL
                );
                CREATE INDEX IF NOT EXISTS creator_jobs_created ON creator_jobs(created_at DESC);
                CREATE TABLE IF NOT EXISTS creator_quotes (
                    id TEXT PRIMARY KEY, job_id TEXT NOT NULL,
                    model TEXT NOT NULL, amount_usd TEXT NOT NULL, basis TEXT NOT NULL,
                    expires_at TEXT NOT NULL, consumed_at TEXT
                );
                CREATE TABLE IF NOT EXISTS creator_budget_reservations (
                    id TEXT PRIMARY KEY, job_id TEXT NOT NULL UNIQUE, quote_id TEXT NOT NULL UNIQUE,
                    amount_usd TEXT NOT NULL, budget_day TEXT NOT NULL,
                    status TEXT NOT NULL CHECK(status IN ('reserved','settled','released')),
                    created_at TEXT NOT NULL, resolved_at TEXT
                );
                CREATE INDEX IF NOT EXISTS creator_budget_day_status ON creator_budget_reservations(budget_day,status);
            """)
            # A queued/running call may already have reached a billable provider.
            # Never auto-resubmit it after a process restart.
            db.execute("UPDATE creator_jobs SET state='failed', error='Interrupted while a provider job may be processing. Check the provider account before trying again.', updated_at=? WHERE state IN ('queued','running')",
                       (self._now(),))

    def connect(self):
        self.database.parent.mkdir(parents=True, exist_ok=True)
        db = sqlite3.connect(self.database, timeout=15)
        db.row_factory = sqlite3.Row
        return db

    @staticmethod
    def _now():
        return datetime.now(timezone.utc).isoformat(timespec="seconds")

    @staticmethod
    def _public(row):
        source = dict(row)
        result = {"id": source["id"], "requestKey": source["request_key"], "kind": source["kind"],
                  "character": source["character"], "prompt": source["prompt"], "wardrobe": source["wardrobe"],
                  "scene": source["scene"], "sourceJob": source["source_job"], "sourceHash": source["source_hash"],
                  "referenceHash": source["reference_hash"], "state": source["state"], "assetMime": source["asset_mime"],
                  "assetHash": source["asset_hash"], "providerRequestId": source["provider_request_id"],
                  "error": source["error"], "createdAt": source["created_at"], "updatedAt": source["updated_at"]}
        if source.get("quoted_amount_usd") is not None:
            result["quotedAmountUSD"] = source["quoted_amount_usd"]
            result["chargeStatus"] = source["charge_status"]
        if source.get("asset_name"):
            result["assetUrl"] = f"/api/v1/creator/jobs/{result['id']}/asset"
        return result

    def list(self):
        with closing(self.connect()) as db:
            return [self._public(row) for row in db.execute("""SELECT j.*,r.amount_usd AS quoted_amount_usd,
                r.status AS charge_status FROM creator_jobs j LEFT JOIN creator_budget_reservations r ON r.job_id=j.id
                ORDER BY j.created_at DESC""")]

    def get(self, job_id):
        if not isinstance(job_id, str) or not JOB_ID.fullmatch(job_id):
            return None
        with closing(self.connect()) as db:
            row = db.execute("""SELECT j.*,r.amount_usd AS quoted_amount_usd,r.status AS charge_status
                FROM creator_jobs j LEFT JOIN creator_budget_reservations r ON r.job_id=j.id WHERE j.id=?""", (job_id,)).fetchone()
        return self._public(row) if row else None

    def create(self, body, characters):
        expected = {"requestKey", "kind", "character", "prompt", "wardrobe", "scene", "referenceHash", "sourceJob"}
        if not isinstance(body, dict) or set(body) != expected:
            raise ValueError("Invalid creation request.")
        request_key = body["requestKey"]
        if not isinstance(request_key, str) or not re.fullmatch(r"[A-Za-z0-9_-]{12,80}", request_key):
            raise ValueError("A unique request key is required.")
        if body["kind"] not in ("image", "video"):
            raise ValueError("Choose image or video.")
        try:
            name = canonical(body["character"])
        except (AttributeError, KeyError):
            raise ValueError("Choose a known Lumming.") from None
        if not isinstance(body["prompt"], str) or not 1 <= len(body["prompt"].strip()) <= MAX_PROMPT:
            raise ValueError(f"Describe the scene in 1-{MAX_PROMPT} characters.")
        if body["wardrobe"] not in WARDROBES or body["scene"] not in SCENES:
            raise ValueError("Choose an available outfit and setting.")
        character = next((item for item in characters if item["id"] == name), None)
        if not character or not isinstance(body["referenceHash"], str) or body["referenceHash"] != character["portraits"]["warm"]["sha256"]:
            raise ValueError("Canonical character reference does not match the approved artwork.")
        source_job = body["sourceJob"]
        if body["kind"] == "image" and source_job is not None:
            raise ValueError("An image job cannot have a source video job.")
        if body["kind"] == "video":
            if not isinstance(source_job, str):
                raise ValueError("Animation requires an accepted still image.")
            source = self.get(source_job)
            if not source or source["kind"] != "image" or source["state"] != "accepted" or not source.get("assetHash"):
                raise ValueError("Only an accepted still can be animated.")
            if source["character"] != name:
                raise ValueError("The accepted still belongs to a different Lumming.")
        now, job_id = self._now(), str(uuid.uuid4())
        with closing(self.connect()) as db, db:
            existing = db.execute("SELECT * FROM creator_jobs WHERE request_key=?", (request_key,)).fetchone()
            if existing:
                row = self._public(existing)
                if (row["kind"], row["character"], row["prompt"], row["wardrobe"], row["scene"], row["sourceJob"], row["referenceHash"]) != (
                        body["kind"], name, body["prompt"].strip(), body["wardrobe"], body["scene"], source_job, body["referenceHash"]):
                    raise JobConflict("Request key was already used for different content.")
                return row
            source_hash = self.get(source_job)["assetHash"] if source_job else None
            db.execute("""INSERT INTO creator_jobs
                (id,request_key,kind,character,prompt,wardrobe,scene,source_job,source_hash,reference_hash,state,created_at,updated_at)
                VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)""",
                (job_id, request_key, body["kind"], name, body["prompt"].strip(), body["wardrobe"], body["scene"], source_job,
                 source_hash, body["referenceHash"], "draft", now, now))
            return self._public(db.execute("SELECT * FROM creator_jobs WHERE id=?", (job_id,)).fetchone())

    def transition(self, job_id, action, expected_state=None):
        actions = {"queue": ("draft", "queued"), "start": ("queued", "running"),
                   "review": ("running", "awaiting_review"), "accept": ("awaiting_review", "accepted"),
                   "reject": ("awaiting_review", "rejected"), "fail": (("queued", "running"), "failed")}
        if action not in actions:
            raise ValueError("Unknown job action.")
        before, after = actions[action]
        with closing(self.connect()) as db, db:
            db.execute("BEGIN IMMEDIATE")
            row = db.execute("SELECT * FROM creator_jobs WHERE id=?", (job_id,)).fetchone()
            if not row:
                return None
            allowed = (before,) if isinstance(before, str) else before
            if row["state"] not in allowed or (expected_state and row["state"] != expected_state):
                raise JobConflict(f"Cannot {action} a job in {row['state']} state.")
            db.execute("UPDATE creator_jobs SET state=?, updated_at=? WHERE id=?", (after, self._now(), job_id))
            return self._public(db.execute("SELECT * FROM creator_jobs WHERE id=?", (job_id,)).fetchone())

    def set_provider_request_id(self, job_id, request_id):
        if not isinstance(request_id, str) or not re.fullmatch(r"[A-Za-z0-9_-]{8,100}", request_id):
            raise ValueError("Provider request identifier is invalid.")
        with closing(self.connect()) as db, db:
            cursor = db.execute("UPDATE creator_jobs SET provider_request_id=?, updated_at=? WHERE id=? AND state='running'",
                                (request_id, self._now(), job_id))
            if cursor.rowcount != 1:
                raise JobConflict("Job no longer accepts provider request details.")

    def fail(self, job_id, message):
        if not isinstance(message, str) or not message:
            message = "Provider job did not complete. Check provider history before starting another request."
        with closing(self.connect()) as db, db:
            db.execute("UPDATE creator_jobs SET state='failed', error=?, updated_at=? WHERE id=? AND state IN ('queued','running')",
                       (message[:500], self._now(), job_id))
            row = db.execute("SELECT * FROM creator_jobs WHERE id=?", (job_id,)).fetchone()
            return self._public(row) if row else None

    def issue_quote(self, job_id):
        job = self.get(job_id)
        if not job:
            return None
        if job["state"] != "draft":
            raise JobConflict("A quote can only be issued for a draft job.")
        if self.daily_budget_usd <= 0:
            raise JobConflict("Set LUMMINGS_MEDIA_DAILY_BUDGET_USD above 0 to enable paid media quotes.")
        price = PRICES[job["kind"]]
        budget = self.budget_status()
        amount = Decimal(price["amountUSD"])
        if amount > Decimal(budget["availableUSD"]):
            raise JobConflict("This request exceeds the remaining daily media budget.")
        now = datetime.now(timezone.utc)
        expires = datetime.fromtimestamp(now.timestamp() + 300, timezone.utc)
        quote = {"id": str(uuid.uuid4()), "jobId": job_id, **price,
                 "currency": "USD", "expiresAt": expires.isoformat(timespec="seconds"),
                 "dailyBudgetUSD": budget["dailyLimitUSD"],
                 "remainingAfterUSD": str(Decimal(budget["availableUSD"]) - amount)}
        with closing(self.connect()) as db, db:
            db.execute("INSERT INTO creator_quotes(id,job_id,model,amount_usd,basis,expires_at) VALUES(?,?,?,?,?,?)",
                       (quote["id"], job_id, quote["model"], quote["amountUSD"], quote["basis"], quote["expiresAt"]))
        return quote

    def budget_status(self):
        day = datetime.now(timezone.utc).date().isoformat()
        with closing(self.connect()) as db:
            rows = db.execute("SELECT amount_usd FROM creator_budget_reservations WHERE budget_day=? AND status IN ('reserved','settled')", (day,)).fetchall()
        used = sum((Decimal(row["amount_usd"]) for row in rows), Decimal("0"))
        available = max(Decimal("0"), self.daily_budget_usd - used)
        return {"currency": "USD", "timezone": "UTC", "dailyLimitUSD": f"{self.daily_budget_usd:.3f}",
                "usedUSD": f"{used:.3f}", "availableUSD": f"{available:.3f}"}

    def authorize_and_queue(self, job_id, quote_id):
        now = self._now()
        budget_day = datetime.now(timezone.utc).date().isoformat()
        with closing(self.connect()) as db, db:
            db.execute("BEGIN IMMEDIATE")
            job = db.execute("SELECT * FROM creator_jobs WHERE id=?", (job_id,)).fetchone()
            if not job:
                return None
            if job["state"] != "draft":
                raise JobConflict(f"Cannot queue a job in {job['state']} state.")
            quote = db.execute("SELECT * FROM creator_quotes WHERE id=? AND job_id=?", (quote_id, job_id)).fetchone()
            if not quote or quote["consumed_at"] or quote["expires_at"] <= now:
                raise JobConflict("The quote is missing, expired or already used. Request a fresh quote.")
            used = sum((Decimal(row[0]) for row in db.execute("SELECT amount_usd FROM creator_budget_reservations WHERE budget_day=? AND status IN ('reserved','settled')", (budget_day,))), Decimal("0"))
            amount = Decimal(quote["amount_usd"])
            if amount > self.daily_budget_usd - used:
                raise JobConflict("This request exceeds the remaining daily media budget.")
            db.execute("INSERT INTO creator_budget_reservations(id,job_id,quote_id,amount_usd,budget_day,status,created_at) VALUES(?,?,?,?,?,'reserved',?)",
                       (str(uuid.uuid4()), job_id, quote_id, quote["amount_usd"], budget_day, now))
            db.execute("UPDATE creator_quotes SET consumed_at=? WHERE id=?", (now, quote_id))
            db.execute("UPDATE creator_jobs SET state='queued', updated_at=? WHERE id=? AND state='draft'", (now, job_id))
            return self._public(db.execute("""SELECT j.*,r.amount_usd AS quoted_amount_usd,r.status AS charge_status
                FROM creator_jobs j JOIN creator_budget_reservations r ON r.job_id=j.id WHERE j.id=?""", (job_id,)).fetchone())

    def cancel_queued(self, job_id):
        now = self._now()
        with closing(self.connect()) as db, db:
            db.execute("BEGIN IMMEDIATE")
            row = db.execute("SELECT * FROM creator_jobs WHERE id=?", (job_id,)).fetchone()
            if not row:
                return None
            if row["state"] != "queued":
                raise JobConflict("Only a queued job can be cancelled here. Once provider submission starts, check provider history and reconcile its charge.")
            db.execute("UPDATE creator_jobs SET state='failed', error='Cancelled before provider submission; no external request was sent.', updated_at=? WHERE id=? AND state='queued'", (now, job_id))
            db.execute("UPDATE creator_budget_reservations SET status='released', resolved_at=? WHERE job_id=? AND status='reserved'", (now, job_id))
            return self._public(db.execute("""SELECT j.*,r.amount_usd AS quoted_amount_usd,r.status AS charge_status
                FROM creator_jobs j LEFT JOIN creator_budget_reservations r ON r.job_id=j.id WHERE j.id=?""", (job_id,)).fetchone())

    def reconcile_failed(self, job_id, decision):
        if decision not in ("charged", "not-charged"):
            raise ValueError("Choose charged or not-charged after checking provider history.")
        now = self._now()
        status = "settled" if decision == "charged" else "released"
        with closing(self.connect()) as db, db:
            db.execute("BEGIN IMMEDIATE")
            row = db.execute("SELECT state FROM creator_jobs WHERE id=?", (job_id,)).fetchone()
            if not row:
                return None
            if row["state"] != "failed":
                raise JobConflict("Only a failed job can be reconciled.")
            changed = db.execute("UPDATE creator_budget_reservations SET status=?, resolved_at=? WHERE job_id=? AND status='reserved'", (status, now, job_id))
            if changed.rowcount != 1:
                raise JobConflict("This job has no unresolved reserved charge.")
            return self._public(db.execute("""SELECT j.*,r.amount_usd AS quoted_amount_usd,r.status AS charge_status
                FROM creator_jobs j JOIN creator_budget_reservations r ON r.job_id=j.id WHERE j.id=?""", (job_id,)).fetchone())

    def save_output(self, job_id, data, mime):
        row = self.get(job_id)
        if not row or row["state"] != "running":
            raise JobConflict("Only a running job can receive provider output.")
        signatures = {"image/png": (b"\x89PNG\r\n\x1a\n", ".png"),
                      "image/jpeg": (b"\xff\xd8\xff", ".jpg"),
                      "video/mp4": (b"", ".mp4")}
        if mime not in signatures or not isinstance(data, bytes) or not data or len(data) > 80 * 1024 * 1024:
            raise ValueError("Unsupported or oversized generated media.")
        if (row["kind"] == "image") != mime.startswith("image/"):
            raise ValueError("Output type does not match this job.")
        signature, suffix = signatures[mime]
        if signature and not data.startswith(signature):
            raise ValueError("Generated media signature does not match its type.")
        if mime == "video/mp4" and (len(data) < 12 or data[4:8] != b"ftyp"):
            raise ValueError("Generated video is not a valid MP4 container.")
        digest = hashlib.sha256(data).hexdigest()
        name = f"{job_id}{suffix}"
        target = (self.output_root / name).resolve()
        if not target.is_relative_to(self.output_root):
            raise ValueError("Generated media path is invalid.")
        target.write_bytes(data)
        with closing(self.connect()) as db, db:
            db.execute("UPDATE creator_jobs SET asset_name=?, asset_mime=?, asset_hash=?, state='awaiting_review', updated_at=? WHERE id=? AND state='running'",
                       (name, mime, digest, self._now(), job_id))
            changed = db.execute("SELECT * FROM creator_jobs WHERE id=?", (job_id,)).fetchone()
            if changed["state"] != "awaiting_review":
                target.unlink(missing_ok=True)
                raise JobConflict("Job changed while output was being saved.")
            db.execute("UPDATE creator_budget_reservations SET status='settled', resolved_at=? WHERE job_id=? AND status='reserved'",
                       (self._now(), job_id))
            return self._public(changed)

    def asset(self, job_id):
        row = self.get(job_id)
        if not row or not row.get("assetUrl"):
            return None
        with closing(self.connect()) as db:
            stored = db.execute("SELECT asset_name,asset_mime FROM creator_jobs WHERE id=?", (job_id,)).fetchone()
        candidate = (self.output_root / stored["asset_name"]).resolve()
        if not candidate.is_relative_to(self.output_root) or not candidate.is_file():
            return None
        return candidate, stored["asset_mime"]
