"""Opt-in fal queue adapter for reference-conditioned Lummings image/video jobs.

Never instantiated unless the operator explicitly selects fal and supplies a
server-side key. This module is only called after the user accepts a fresh quote
and confirms provider processing for that specific job.
"""
from __future__ import annotations

import base64
import hashlib
import json
import mimetypes
import re
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

from .media_jobs import PRICES

QUEUE_ROOT = "https://queue.fal.run"
ALLOWED_DOWNLOAD_HOSTS = {"storage.googleapis.com", "fal.media"}
MAX_OUTPUT_BYTES = 80 * 1024 * 1024

OUTFITS = {
    "heartlight-explorer": "a warm ochre explorer jacket with a stitched star map and a small Heartlight badge",
    "starlight-storyteller": "a deep violet storyteller cape with delicate constellation stitching and a paper-star satchel",
    "garden-inventor": "a soft sage maker apron with botanical pockets and tiny safe tinkering tools",
}
SCENES = {
    "observatory": "a cozy moon observatory with brass telescopes and a wide starry window",
    "moon-garden": "a gentle moon garden with glowing flowers and winding stepping stones",
    "cloud-kingdom": "a bright cloud kingdom with floating paths and soft sunrise colors",
    "undersea-library": "a peaceful undersea library with coral shelves and drifting bubbles",
}


class ProviderError(RuntimeError):
    pass


class FalMediaProvider:
    def __init__(self, key, docs_root, jobs, request=None, sleep=time.sleep, clock=time.monotonic,
                 poll_seconds=2, max_wait_seconds=1200):
        if not isinstance(key, str) or not key.strip():
            raise ValueError("A fal API key is required.")
        self._key = key.strip()
        self.docs_root = Path(docs_root).resolve()
        self.jobs = jobs
        self._request = request or urllib.request.urlopen
        self._sleep = sleep
        self._clock = clock
        self.poll_seconds = poll_seconds
        self.max_wait_seconds = max_wait_seconds

    @staticmethod
    def _data_uri(path):
        mime = mimetypes.guess_type(path.name)[0]
        if mime not in ("image/png", "image/jpeg"):
            raise ProviderError("Reference media must be a PNG or JPEG file.")
        data = path.read_bytes()
        if not data or len(data) > 12 * 1024 * 1024:
            raise ProviderError("Reference media is empty or too large.")
        if (mime == "image/png" and not data.startswith(b"\x89PNG\r\n\x1a\n")) or (mime == "image/jpeg" and not data.startswith(b"\xff\xd8\xff")):
            raise ProviderError("Reference media signature is invalid.")
        return f"data:{mime};base64," + base64.b64encode(data).decode("ascii")

    def _reference(self, job):
        if job["kind"] == "image":
            path = (self.docs_root / "assets/characters" / f"{job['character']}-portrait.png").resolve()
            if not path.is_relative_to(self.docs_root / "assets/characters") or not path.is_file():
                raise ProviderError("Approved character reference is unavailable.")
            if hashlib.sha256(path.read_bytes()).hexdigest() != job["referenceHash"]:
                raise ProviderError("Approved character reference changed; refresh the studio before generating.")
            return self._data_uri(path)
        source = self.jobs.get(job.get("sourceJob"))
        source_file = self.jobs.asset(job.get("sourceJob"))
        if not source or source["state"] != "accepted" or source["kind"] != "image" or not source_file:
            raise ProviderError("Video generation needs an available, accepted still.")
        if source["character"] != job["character"] or source["assetHash"] != job.get("sourceHash"):
            raise ProviderError("Accepted still lineage changed; create a new animation draft.")
        return self._data_uri(source_file[0])

    @staticmethod
    def _prompt(job):
        outfit, scene = OUTFITS[job["wardrobe"]], SCENES[job["scene"]]
        if job["kind"] == "video":
            return (f"Animate the exact accepted illustration gently: {job['prompt']}. Keep the same character, "
                    "outfit, composition and storybook art throughout. Add subtle expressive motion and a slow "
                    "camera drift. No dialogue, text, logos, morphing, new characters or identity changes.")
        return (f"Use the attached approved {job['character'].title()} illustration as the strict identity and "
                "art-style reference. Preserve the same recognizable face, silhouette, species, proportions, "
                "signature features and palette. Change only the outfit, pose and setting. Dress the character in "
                f"{outfit}. Place them in {scene}. Scene direction: {job['prompt']}. Create one warm, detailed "
                "illustrated children's-book image, not chibi or photorealistic. No text, watermark, extra limbs, "
                "or changes to the character's identity.")

    def _json_request(self, url, method="GET", body=None):
        parsed = urllib.parse.urlsplit(url)
        if parsed.scheme != "https" or parsed.hostname != "queue.fal.run" or parsed.username or parsed.password:
            raise ProviderError("Provider queue URL failed validation.")
        headers = {"Authorization": f"Key {self._key}", "Accept": "application/json"}
        data = None
        if body is not None:
            headers["Content-Type"] = "application/json"
            data = json.dumps(body, separators=(",", ":")).encode()
        request = urllib.request.Request(url, data=data, headers=headers, method=method)
        try:
            with self._request(request, timeout=45) as response:
                raw = response.read(2 * 1024 * 1024 + 1)
                if len(raw) > 2 * 1024 * 1024:
                    raise ProviderError("Provider response was too large.")
                return json.loads(raw)
        except (OSError, urllib.error.URLError, json.JSONDecodeError) as error:
            raise ProviderError("Provider request failed; inspect job status before retrying.") from error

    @staticmethod
    def _download_url(url):
        parsed = urllib.parse.urlsplit(url)
        host = (parsed.hostname or "").lower()
        allowed = host in ALLOWED_DOWNLOAD_HOSTS or host.endswith(".fal.media")
        if parsed.scheme != "https" or not allowed or parsed.username or parsed.password or parsed.port not in (None, 443):
            raise ProviderError("Provider output URL failed validation.")

    def _download(self, url, expected_kind):
        self._download_url(url)
        request = urllib.request.Request(url, headers={"Accept": "image/png,image/jpeg,video/mp4"})
        # Reject redirects so a provider-returned URL cannot redirect the local
        # gateway to an unrelated host or private network address.
        opener = urllib.request.build_opener(_NoRedirect())
        try:
            with opener.open(request, timeout=60) as response:
                mime = response.headers.get_content_type()
                data = response.read(MAX_OUTPUT_BYTES + 1)
        except (OSError, urllib.error.URLError) as error:
            raise ProviderError("Provider output could not be downloaded.") from error
        if len(data) > MAX_OUTPUT_BYTES or not data:
            raise ProviderError("Provider output was empty or exceeded the 80 MB limit.")
        if expected_kind == "image" and mime not in ("image/png", "image/jpeg"):
            raise ProviderError("Image provider returned an unsupported media type.")
        if expected_kind == "video" and mime != "video/mp4":
            raise ProviderError("Video provider returned an unsupported media type.")
        return data, mime

    def generate(self, job, on_submitted):
        model = PRICES[job["kind"]]["model"]
        reference = self._reference(job)
        prompt = self._prompt(job)
        if job["kind"] == "image":
            inputs = {"prompt": prompt, "image_urls": [reference], "image_size": {"width": 1024, "height": 1024},
                      "num_images": 1, "output_format": "png", "enable_safety_checker": True}
        else:
            inputs = {"image_url": reference, "prompt": prompt, "resolution": "720p", "duration": 5}
        response = self._json_request(f"{QUEUE_ROOT}/{model}", "POST", inputs)
        request_id = response.get("request_id")
        if not isinstance(request_id, str) or not re.fullmatch(r"[A-Za-z0-9_-]{8,100}", request_id):
            raise ProviderError("Provider did not return a valid request identifier.")
        # Persist immediately. On a restart, queued/running work is never blindly
        # resubmitted; an operator can inspect this provider ID and billing record.
        on_submitted(request_id)
        status_url = f"{QUEUE_ROOT}/{model}/requests/{request_id}/status"
        result_url = f"{QUEUE_ROOT}/{model}/requests/{request_id}"
        deadline = self._clock() + self.max_wait_seconds
        while self._clock() < deadline:
            status = self._json_request(status_url)
            state = status.get("status")
            if state == "COMPLETED":
                result = self._json_request(result_url)
                if job["kind"] == "image":
                    files = result.get("images") or []
                    output_url = files[0].get("url") if files and isinstance(files[0], dict) else None
                else:
                    output = result.get("video")
                    output_url = output.get("url") if isinstance(output, dict) else None
                if not isinstance(output_url, str):
                    raise ProviderError("Provider completed without a media result.")
                return self._download(output_url, job["kind"])
            if state in ("FAILED", "CANCELLED"):
                raise ProviderError("Provider reported that the generation did not complete.")
            if state not in ("IN_QUEUE", "IN_PROGRESS"):
                raise ProviderError("Provider returned an unknown job state.")
            self._sleep(self.poll_seconds)
        raise ProviderError("Provider job timed out. Check provider history before creating a replacement request.")


class _NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, fp, code, message, headers, newurl):
        raise urllib.error.HTTPError(request.full_url, code, "Provider output redirects are blocked", headers, fp)
