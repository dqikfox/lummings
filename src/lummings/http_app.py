"""Local creator application gateway. Family authentication is a later milestone."""
from __future__ import annotations

import json
import mimetypes
import os
import secrets
import threading
import time
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlsplit

from .characters import AppearanceStore, Conflict, registry
from .cli import chat
from .engine import (
    CHARACTER_MODELS,
    PERSONA_ALIASES,
    Memory,
    Mood,
    build_runtime_prompt,
    load_persona,
    sanitize_reply,
)
from .media_jobs import PRICES, JobConflict, MediaJobs
from .media_library import MediaLibrary, serve_media

ROOT = Path(__file__).resolve().parents[2]


def probe_models(base_url):
    try:
        endpoint = base_url.rstrip('/').removesuffix('/v1') + '/api/tags'
        with urllib.request.urlopen(endpoint, timeout=2) as response:
            data = json.load(response)
        return {item['name'].removesuffix(':latest') for item in data['models']}
    except (OSError, ValueError, KeyError, TypeError):
        return None


def make_server(port=8511, db_path=None, base_url='http://127.0.0.1:11434/v1',
                model_probe=None, chat_fn=None, docs_root=None, media_root=None, jobs_root=None,
                media_provider=None):
    docs = Path(docs_root or ROOT / 'docs').resolve()
    database = Path(db_path or ROOT / 'data/creator/conversation.sqlite3')
    appearances = AppearanceStore(database.with_name(database.stem + '-appearances.sqlite3'))
    characters = registry(docs)
    media = MediaLibrary(media_root or ROOT, database.with_name(database.stem + '-media.sqlite3'))
    generated_root = Path(jobs_root or ROOT / 'data/creator/generated')
    jobs = MediaJobs(database.with_name(database.stem + '-jobs.sqlite3'), generated_root,
                     os.environ.get('LUMMINGS_MEDIA_DAILY_BUDGET_USD', '0.00'))
    if media_provider is None and os.environ.get('LUMMINGS_MEDIA_PROVIDER', '').lower() == 'fal' and os.environ.get('FAL_KEY'):
        from .fal_media_provider import FalMediaProvider
        media_provider = FalMediaProvider(os.environ['FAL_KEY'], docs, jobs)
    probe = model_probe or (lambda: probe_models(base_url))
    generate = chat_fn or chat
    token = secrets.token_urlsafe(32)
    lock = threading.RLock()
    status_lock = threading.Lock()
    states = {}
    cache = {'at': 0, 'models': None}

    def capabilities():
        with status_lock:
            if time.monotonic() - cache['at'] > 3:
                cache['models'] = probe()
                cache['at'] = time.monotonic()
            models = cache['models']
        return {'mode': 'local-creator', 'token': token,
                'modelServiceReachable': models is not None,
                'characters': {name: {'model': model, 'available': models is not None and model in models}
                               for name, model in CHARACTER_MODELS.items()},
                'mediaProviderConfigured': media_provider is not None,
                'mediaGeneration': media_provider is not None and jobs.daily_budget_usd > 0,
                'mediaPricing': PRICES if media_provider is not None else {}, 'mediaBudget': jobs.budget_status(),
                'liveAvatar': False}

    def run_media_job(job_id):
        """Run an explicitly confirmed provider call off the request thread."""
        try:
            job = jobs.transition(job_id, 'start')
            output = (media_provider.generate(job, on_submitted=lambda request_id: jobs.set_provider_request_id(job_id, request_id))
                      if hasattr(media_provider, 'generate') else media_provider(job))
            if not isinstance(output, tuple) or len(output) != 2:
                raise ValueError('Media provider returned an invalid result.')
            jobs.save_output(job_id, output[0], output[1])
        except Exception:  # noqa: BLE001 - boundary: any provider failure must fail the job, never kill the worker
            try:
                current = jobs.get(job_id)
                if current and current['state'] in ('queued', 'running'):
                    jobs.fail(job_id, 'Provider job did not finish. Check provider history before creating a replacement request.'
                              if current.get('providerRequestId') else
                              'Provider submission status is uncertain. Check provider history before creating a replacement request.')
            except (JobConflict, ValueError):
                pass

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *args):
            pass

        def respond(self, status, payload, mime='application/json; charset=utf-8'):
            content = payload if isinstance(payload, bytes) else json.dumps(payload).encode()
            self.send_response(status)
            self.send_header('Content-Type', mime)
            self.send_header('Content-Length', str(len(content)))
            self.send_header('Cache-Control', 'no-store')
            self.send_header('X-Content-Type-Options', 'nosniff')
            self.end_headers()
            self.wfile.write(content)

        def allowed(self, mutation=False):
            hosts = {f'127.0.0.1:{self.server.server_port}', f'localhost:{self.server.server_port}'}
            if self.headers.get('Host') not in hosts:
                self.respond(403, {'error': 'Invalid host.'})
                return False
            origin = self.headers.get('Origin')
            if origin and origin not in {'http://' + h for h in hosts}:
                self.respond(403, {'error': 'Invalid origin.'})
                return False
            if mutation and not secrets.compare_digest(self.headers.get('X-Lummings-Token', ''), token):
                self.respond(403, {'error': 'Refresh the app before sending.'})
                return False
            return True

        def do_GET(self):
            if not self.allowed():
                return
            route = unquote(urlsplit(self.path).path)
            # The public site lives under /lummings/; accept the same prefix locally so one set of page links works in both.
            if route == '/lummings' or route.startswith('/lummings/'):
                route = route[len('/lummings'):] or '/'
            if route == '/api/v1/capabilities':
                return self.respond(200, capabilities())
            if route == '/api/v1/characters':
                return self.respond(200, {'characters': characters})
            parts = route.strip('/').split('/')
            if route == '/api/v1/media':
                return self.respond(200, {'items': media.listing()})
            if route == '/api/v1/creator/jobs':
                return self.respond(200, {'jobs': jobs.list(), 'generationAvailable': False,
                                           'message': 'Reference generation is not configured yet.'})
            if len(parts) == 6 and parts[:3] == ['api', 'v1', 'creator'] and parts[3] == 'jobs' and parts[5] == 'asset':
                asset = jobs.asset(parts[4])
                if not asset:
                    return self.respond(404, {'error': 'Generated asset unavailable.'})
                return serve_media(self, asset[0])
            if len(parts) == 5 and parts[:3] == ['api', 'v1', 'creator'] and parts[3] == 'jobs':
                job = jobs.get(parts[4])
                return self.respond(200, job) if job else self.respond(404, {'error': 'Unknown creator job.'})
            if len(parts) == 5 and parts[:3] == ['api', 'v1', 'media'] and parts[4] in ('file', 'preview'):
                path = media.file(parts[3], preview=parts[4] == 'preview')
                if path is None:
                    return self.respond(404, {'error': 'Source media unavailable.'})
                return serve_media(self, path)
            if len(parts) == 5 and parts[:3] == ['api', 'v1', 'characters'] and parts[4] == 'appearance':
                try:
                    return self.respond(200, appearances.get(parts[3]))
                except KeyError:
                    return self.respond(404, {'error': 'Unknown character.'})
            if route.startswith('/persona/'):
                name = route.removeprefix('/persona/')
                name = PERSONA_ALIASES.get(name, name)
                if name not in CHARACTER_MODELS:
                    return self.respond(404, {'error': 'Unknown character.'})
                return self.respond(200, load_persona(name))
            if route in ('/', '/ui', '/app/', '/app/index.html'):
                candidate = docs / 'app/index.html'
            elif route.startswith(('/assets/', '/app/')):
                candidate = (docs / route.lstrip('/')).resolve()
                if not any(candidate.is_relative_to(docs / part) for part in ('assets', 'app')):
                    return self.respond(404, {'error': 'Not found.'})
            else:
                return self.respond(404, {'error': 'Not found.'})
            if not candidate.is_file() or candidate.suffix not in {'.html', '.js', '.css', '.svg', '.png', '.jpg', '.webp', '.woff2'}:
                return self.respond(404, {'error': 'App asset not found.'})
            return self.respond(200, candidate.read_bytes(), mimetypes.guess_type(candidate.name)[0] or 'application/octet-stream')

        def do_POST(self):
            if not self.allowed(mutation=True):
                return
            route = urlsplit(self.path).path
            parts = route.strip('/').split('/')
            appearance_route = (len(parts) in (5, 6) and parts[:3] == ['api', 'v1', 'characters']
                                and parts[4] == 'appearance' and (len(parts) == 5 or parts[5] == 'undo'))
            shortlist_route = len(parts) == 5 and parts[:3] == ['api', 'v1', 'media'] and parts[4] == 'shortlist'
            creator_job_route = route == '/api/v1/creator/jobs'
            creator_review_route = len(parts) == 6 and parts[:4] == ['api', 'v1', 'creator', 'jobs'] and parts[5] == 'review'
            creator_generate_route = len(parts) == 6 and parts[:4] == ['api', 'v1', 'creator', 'jobs'] and parts[5] == 'generate'
            creator_quote_route = len(parts) == 6 and parts[:4] == ['api', 'v1', 'creator', 'jobs'] and parts[5] == 'quote'
            creator_cancel_route = len(parts) == 6 and parts[:4] == ['api', 'v1', 'creator', 'jobs'] and parts[5] == 'cancel'
            creator_reconcile_route = len(parts) == 6 and parts[:4] == ['api', 'v1', 'creator', 'jobs'] and parts[5] == 'reconcile'
            if route != '/chat' and not appearance_route and not shortlist_route and not creator_job_route and not creator_review_route and not creator_generate_route and not creator_quote_route and not creator_cancel_route and not creator_reconcile_route:
                return self.respond(404, {'error': 'Not found.'})
            try:
                if self.headers.get_content_type() != 'application/json':
                    return self.respond(415, {'error': 'Expected JSON.'})
                length = int(self.headers.get('Content-Length', '0'))
                if not 0 < length <= 16384:
                    return self.respond(413, {'error': 'Request size must be 1–16384 bytes.'})
                body = json.loads(self.rfile.read(length))
                if creator_job_route:
                    try:
                        return self.respond(201, jobs.create(body, characters))
                    except JobConflict as error:
                        return self.respond(409, {'error': str(error)})
                    except (ValueError, TypeError, KeyError) as error:
                        return self.respond(400, {'error': str(error)})
                if creator_generate_route:
                    if not isinstance(body, dict) or set(body) != {'confirmExternalProcessing', 'quoteId'} or body['confirmExternalProcessing'] is not True or not isinstance(body['quoteId'], str):
                        return self.respond(400, {'error': 'Confirm that the canonical reference and prompt may be sent to the configured provider.'})
                    if media_provider is None:
                        return self.respond(503, {'error': 'No media provider is configured. Nothing was sent and no job was queued.'})
                    job = jobs.get(parts[4])
                    if not job:
                        return self.respond(404, {'error': 'Unknown creator job.'})
                    try:
                        queued = jobs.authorize_and_queue(parts[4], body['quoteId'])
                        if queued is None:
                            return self.respond(404, {'error': 'Unknown creator job.'})
                    except JobConflict as error:
                        return self.respond(409, {'error': str(error)})
                    threading.Thread(target=run_media_job, args=(parts[4],), daemon=True).start()
                    return self.respond(202, queued)
                if creator_quote_route:
                    if not isinstance(body, dict) or body:
                        return self.respond(400, {'error': 'Quote request must be an empty JSON object.'})
                    if media_provider is None:
                        return self.respond(503, {'error': 'No media provider is configured. No quote is available.'})
                    try:
                        quote = jobs.issue_quote(parts[4])
                        return self.respond(404, {'error': 'Unknown creator job.'}) if quote is None else self.respond(201, quote)
                    except JobConflict as error:
                        return self.respond(409, {'error': str(error)})
                if creator_cancel_route:
                    if not isinstance(body, dict) or body:
                        return self.respond(400, {'error': 'Cancellation request must be an empty JSON object.'})
                    try:
                        result = jobs.cancel_queued(parts[4])
                        return self.respond(404, {'error': 'Unknown creator job.'}) if result is None else self.respond(200, result)
                    except JobConflict as error:
                        return self.respond(409, {'error': str(error)})
                if creator_reconcile_route:
                    if not isinstance(body, dict) or set(body) != {'decision'}:
                        return self.respond(400, {'error': 'Choose charged or not-charged after checking provider history.'})
                    try:
                        result = jobs.reconcile_failed(parts[4], body['decision'])
                        return self.respond(404, {'error': 'Unknown creator job.'}) if result is None else self.respond(200, result)
                    except (JobConflict, ValueError) as error:
                        return self.respond(409, {'error': str(error)})
                if creator_review_route:
                    if not isinstance(body, dict) or set(body) != {'decision'} or body['decision'] not in ('accept', 'reject'):
                        return self.respond(400, {'error': 'Choose accept or reject.'})
                    try:
                        result = jobs.transition(parts[4], body['decision'])
                        return self.respond(404, {'error': 'Unknown creator job.'}) if result is None else self.respond(200, result)
                    except JobConflict as error:
                        return self.respond(409, {'error': str(error)})
                if shortlist_route:
                    try:
                        return self.respond(200, media.shortlist(parts[3], body))
                    except KeyError:
                        return self.respond(404, {'error': 'Unknown media.'})
                    except ValueError as error:
                        return self.respond(400, {'error': str(error)})
                if appearance_route:
                    try:
                        result = appearances.change(parts[3], body, undo=len(parts) == 6)
                        return self.respond(200, result)
                    except KeyError:
                        return self.respond(404, {'error': 'Unknown character.'})
                    except Conflict as error:
                        return self.respond(409, {'error': str(error), 'appearance': appearances.get(parts[3])})
                    except (ValueError, TypeError) as error:
                        return self.respond(400, {'error': str(error)})
                if not isinstance(body, dict) or set(body) - {'persona', 'message'}:
                    raise ValueError('Expected persona and message only.')
                name, message = body.get('persona'), body.get('message')
                if not isinstance(name, str) or not isinstance(message, str):
                    raise ValueError('Character and message must be text.')  # noqa: TRY004 - caller maps ValueError and TypeError to HTTP 400
                name = PERSONA_ALIASES.get(name.lower(), name.lower())
                if name not in CHARACTER_MODELS or not 1 <= len(message.strip()) <= 4000:
                    raise ValueError('Choose a known character and a message of 1–4000 characters.')
            except (ValueError, TypeError):
                return self.respond(400, {'error': 'Invalid chat request.'})
            if not capabilities()['characters'][name]['available']:
                return self.respond(503, {'error': 'This character model is offline or not installed. Your message has not been saved.'})
            # Serialize legacy SQLite/mood access until scoped sessions replace it.
            with lock:
                persona = load_persona(name)
                if name not in states:
                    states[name] = {'memory': Memory(database, name, owner='creator'), 'mood': Mood(persona)}
                memory, mood = states[name]['memory'], states[name]['mood']
                history = [{'role': item['role'], 'content': item['text']} for item in memory.recent_events(6)]
                context = build_runtime_prompt(persona, memory_summary=memory.summarize(), mood=mood.state)
                result = generate(base_url, CHARACTER_MODELS[name], '', context + '\n\n' + message.strip(), history=history)
                if not result.get('ok') or not isinstance(result.get('content'), str) or not result['content'].strip():
                    return self.respond(502, {'error': 'The character model could not reply. Your draft is retained; try again.'})
                reply = sanitize_reply(result['content'], persona)
                memory.add_event('user', message.strip())
                memory.add_event('assistant', reply)
                mood.on_user_input()
                mood.state = mood.next_mood_after_response()
                return self.respond(200, {'reply': reply, 'mood': mood.state})

    class Server(ThreadingHTTPServer):
        def server_close(self):
            super().server_close()
            with lock:
                for state in states.values():
                    state['memory'].conn.close()

    return Server(('127.0.0.1', port), Handler)
