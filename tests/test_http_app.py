import json
import os
import sqlite3
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
from contextlib import closing
from pathlib import Path
from unittest.mock import patch

from lummings.http_app import make_server


class GatewayTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.calls = []
        self.models = {'lummings-lumo'}
        def generate(*args, **kwargs):
            self.calls.append((args, kwargs))
            return {'ok': True, 'content': 'Let us imagine a moon garden.'}
        self.db = Path(self.temp.name) / 'chat.sqlite3'
        self.server = make_server(0, self.db, model_probe=lambda: self.models, chat_fn=generate,
                                  jobs_root=Path(self.temp.name) / 'generated')
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base = f'http://127.0.0.1:{self.server.server_port}'
        self.token = json.loads(self.request('/api/v1/capabilities')[1])['token']

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.temp.cleanup()

    def request(self, path, body=None, headers=None):
        h = {'Content-Type': 'application/json', 'X-Lummings-Token': self.token if hasattr(self, 'token') else ''}
        h.update(headers or {})
        req = urllib.request.Request(self.base + path, data=json.dumps(body).encode() if body is not None else None, headers=h)
        try:
            response = urllib.request.urlopen(req)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            return response.status, response.read(), response.headers

    def test_polished_app_and_portraits(self):
        status, data, _ = self.request('/')
        self.assertEqual(status, 200)
        self.assertIn(b'/app/app.js', data)
        for name in ('lumo', 'lila', 'pip', 'nori', 'moki'):
            status, data, headers = self.request(f'/assets/portraits/{name}-warm.svg')
            self.assertEqual(status, 200)
            self.assertIn('image/svg+xml', headers['Content-Type'])
        self.assertEqual(self.request('/app/app.js')[0], 200)

    def test_site_mount_prefix_serves_the_same_app(self):
        # Pages link to /lummings/app/...; the local gateway must serve those paths too.
        status, data, _ = self.request('/lummings/')
        self.assertEqual(status, 200)
        self.assertIn(b'/lummings/app/app.js', data)
        for asset in ('app.js', 'stage.js', 'creator.js', 'library.js', 'stage.css', 'library.css', 'creator.css'):
            self.assertEqual(self.request(f'/lummings/app/{asset}')[0], 200, asset)
        self.assertEqual(self.request('/lummings/../lummings.sqlite')[0], 404)

    def test_private_files_and_traversal_unavailable(self):
        for path in ('/lummings.sqlite', '/assets/%2e%2e/%2e%2e/lummings.sqlite', '/app/../../README.md'):
            self.assertEqual(self.request(path)[0], 404)

    def test_origin_host_and_token(self):
        self.assertEqual(self.request('/', headers={'Host': 'evil.example'})[0], 403)
        body = {'persona': 'lumo', 'message': 'Hi'}
        self.assertEqual(self.request('/chat', body, {'Origin': 'https://evil.example'})[0], 403)
        self.assertEqual(self.request('/chat', body, {'X-Lummings-Token': ''})[0], 403)
        self.assertFalse(self.calls)

    def test_model_readiness_and_offline_no_writes(self):
        data = json.loads(self.request('/api/v1/capabilities')[1])
        self.assertTrue(data['characters']['lumo']['available'])
        self.assertFalse(data['characters']['pip']['available'])
        self.assertFalse(data['mediaGeneration'])
        self.assertEqual(self.request('/chat', {'persona': 'pip', 'message': 'Hi'})[0], 503)
        self.assertFalse(self.db.exists())

    def test_fal_adapter_requires_explicit_server_opt_in_and_never_exposes_key(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        with patch.dict(os.environ, {'LUMMINGS_MEDIA_PROVIDER': 'fal', 'FAL_KEY': 'test_only_dummy_key',
                                    'LUMMINGS_MEDIA_DAILY_BUDGET_USD': '1.000'}):
            self.server = make_server(0, self.db, model_probe=lambda: set(), jobs_root=Path(self.temp.name) / 'generated')
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base = f'http://127.0.0.1:{self.server.server_port}'
        capabilities = self.request('/api/v1/capabilities')[1]
        data = json.loads(capabilities)
        self.assertTrue(data['mediaGeneration'])
        self.assertEqual(data['mediaPricing']['video']['model'], 'fal-ai/pika/v2.2/image-to-video')
        self.assertNotIn(b'test_only_dummy_key', capabilities)

    def test_exact_routes_and_input_validation(self):
        self.assertEqual(self.request('/chatty', {})[0], 404)
        for body in ([], {'persona': '../x', 'message': 'hi'}, {'persona': 1, 'message': 'hi'},
                     {'persona': 'lumo', 'message': 'x'*4001},
                     {'persona': 'lumo', 'message': 'hi', 'base_url': 'http://evil.example'}):
            self.assertEqual(self.request('/chat', body)[0], 400)
        self.assertEqual(self.request('/persona/unknown')[0], 404)

    def test_chat_single_current_turn_and_creator_namespace(self):
        for message in ('first', 'second'):
            self.assertEqual(self.request('/chat', {'persona': 'lumo', 'message': message})[0], 200)
        args, kwargs = self.calls[-1]
        self.assertEqual(args[1], 'lummings-lumo')
        self.assertEqual(sum(m['content'] == 'second' for m in kwargs['history']), 0)
        with closing(sqlite3.connect(self.db)) as db:
            self.assertEqual(db.execute('SELECT COUNT(*) FROM events').fetchone()[0], 4)
            self.assertEqual(db.execute('SELECT DISTINCT owner FROM events').fetchall(), [('creator',)])

    def test_registry_assets_and_aliases(self):
        characters = json.loads(self.request('/api/v1/characters')[1])['characters']
        self.assertEqual(len(characters), 5)
        import hashlib
        for character in characters:
            self.assertEqual(character['artworkVersion'], 'illustrated-2026-10-13')
            self.assertFalse(character['expressionVariants'])
            for portrait in character['portraits'].values():
                self.assertTrue(portrait['url'].endswith('-portrait.png'))
                status, data, _ = self.request(portrait['url'])
                self.assertEqual(status, 200)
                self.assertEqual(hashlib.sha256(data).hexdigest(), portrait['sha256'])
                master = Path(__file__).resolve().parents[1] / 'marketing/demo-assets' / f"{character['id']}-portrait.png"
                self.assertEqual(data, master.read_bytes())
        for path in ('/', '/app/app.js', '/app/stage.js'):
            self.assertNotIn(b'/assets/portraits/', self.request(path)[1])
        self.assertEqual(json.loads(self.request('/api/v1/characters/luna/appearance')[1])['character'], 'lila')
        self.assertEqual(self.request('/api/v1/characters/unknown/appearance')[0], 404)

    def test_appearance_save_conflict_undo_and_isolation(self):
        route = '/api/v1/characters/lumo/appearance'
        body = {'expectedRevision': 0, 'expression': 'playful', 'backdrop': 'garden'}
        status, data, _ = self.request(route, body)
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(data)['revision'], 1)
        self.assertEqual(self.request(route, body)[0], 409)
        self.assertEqual(json.loads(self.request('/api/v1/characters/pip/appearance')[1])['revision'], 0)
        status, data, _ = self.request(route + '/undo', {'expectedRevision': 1})
        self.assertEqual(status, 200)
        restored = json.loads(data)
        self.assertEqual((restored['expression'], restored['revision'], restored['canUndo']), ('warm', 2, False))
        self.assertEqual(self.request(route + '/undo', {'expectedRevision': 2})[0], 400)
        self.assertFalse(self.db.exists())

    def test_appearance_validation_and_token(self):
        route = '/api/v1/characters/lumo/appearance'
        for body in ([], {}, {'expectedRevision': True, 'expression': 'warm', 'backdrop': 'garden'},
                     {'expectedRevision': 0, 'expression': '../evil', 'backdrop': 'garden'},
                     {'expectedRevision': 0, 'expression': [], 'backdrop': 'garden'},
                     {'expectedRevision': 0, 'expression': 'warm', 'backdrop': 'garden', 'color': 'blue'}):
            self.assertEqual(self.request(route, body)[0], 400)
        self.assertEqual(self.request(route, {}, {'X-Lummings-Token': ''})[0], 403)

    def test_appearance_survives_server_restart(self):
        route = '/api/v1/characters/nori/appearance'
        self.request(route, {'expectedRevision': 0, 'expression': 'sleepy', 'backdrop': 'dreamscape'})
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.server = make_server(0, self.db, model_probe=lambda: set())
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base = f'http://127.0.0.1:{self.server.server_port}'
        saved = json.loads(self.request(route)[1])
        self.assertEqual((saved['expression'], saved['backdrop'], saved['revision']), ('sleepy', 'dreamscape', 1))

    def test_simultaneous_appearance_writes_have_one_winner(self):
        from concurrent.futures import ThreadPoolExecutor
        route = '/api/v1/characters/lila/appearance'
        def save(expression):
            return self.request(route, {'expectedRevision': 0, 'expression': expression, 'backdrop': 'garden'})[0]
        with ThreadPoolExecutor(max_workers=2) as pool:
            self.assertEqual(sorted(pool.map(save, ['playful', 'excited'])), [200, 409])

    def test_multiple_undo_steps_keep_monotonic_revisions(self):
        route = '/api/v1/characters/moki/appearance'
        for revision, expression in enumerate(['playful', 'excited']):
            self.request(route, {'expectedRevision': revision, 'expression': expression, 'backdrop': 'garden'})
        first = json.loads(self.request(route + '/undo', {'expectedRevision': 2})[1])
        second = json.loads(self.request(route + '/undo', {'expectedRevision': 3})[1])
        self.assertEqual((first['expression'], first['revision']), ('playful', 3))
        self.assertEqual((second['expression'], second['revision'], second['canUndo']), ('warm', 4, False))

    def test_creator_job_requires_canonical_reference_and_external_confirmation(self):
        character = json.loads(self.request('/api/v1/characters')[1])['characters'][0]
        body = {'requestKey': 'http_request_0001', 'kind': 'image', 'character': 'lumo',
                'prompt': 'Lumo explores a moon garden', 'wardrobe': 'heartlight-explorer',
                'scene': 'moon-garden', 'referenceHash': character['portraits']['warm']['sha256'], 'sourceJob': None}
        status, data, _ = self.request('/api/v1/creator/jobs', body)
        self.assertEqual(status, 201)
        job = json.loads(data)
        self.assertEqual(job['state'], 'draft')
        self.assertEqual(self.request(f"/api/v1/creator/jobs/{job['id']}/generate", {})[0], 400)
        self.assertEqual(self.request(f"/api/v1/creator/jobs/{job['id']}/generate", {'confirmExternalProcessing': True, 'quoteId': 'not-a-quote'})[0], 503)
        self.assertEqual(json.loads(self.request(f"/api/v1/creator/jobs/{job['id']}")[1])['state'], 'draft')
        self.assertEqual(self.request('/api/v1/creator/jobs', {**body, 'requestKey': 'http_request_0002', 'referenceHash': '0' * 64})[0], 400)

    def test_injected_provider_generation_review_and_asset_route(self):
        output = b'\x89PNG\r\n\x1a\nprovider-test-image'
        calls = []
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        with patch.dict(os.environ, {'LUMMINGS_MEDIA_DAILY_BUDGET_USD': '1.000'}):
            self.server = make_server(0, self.db, model_probe=lambda: self.models,
                                      jobs_root=Path(self.temp.name) / 'generated',
                                      media_provider=lambda job: (calls.append(job) or (output, 'image/png')))
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base = f'http://127.0.0.1:{self.server.server_port}'
        self.token = json.loads(self.request('/api/v1/capabilities')[1])['token']
        self.assertTrue(json.loads(self.request('/api/v1/capabilities')[1])['mediaGeneration'])
        character = json.loads(self.request('/api/v1/characters')[1])['characters'][0]
        body = {'requestKey': 'provider_request_0001', 'kind': 'image', 'character': 'lumo',
                'prompt': 'Lumo explores a moon garden', 'wardrobe': 'heartlight-explorer',
                'scene': 'moon-garden', 'referenceHash': character['portraits']['warm']['sha256'], 'sourceJob': None}
        job = json.loads(self.request('/api/v1/creator/jobs', body)[1])
        quote_status, quote_data, _ = self.request(f"/api/v1/creator/jobs/{job['id']}/quote", {})
        quote = json.loads(quote_data)
        self.assertEqual(quote_status, 201)
        self.assertEqual((quote['model'], quote['amountUSD'], quote['currency']), ('fal-ai/flux-2/edit', '0.024', 'USD'))
        status, data, _ = self.request(f"/api/v1/creator/jobs/{job['id']}/generate", {'confirmExternalProcessing': True, 'quoteId': quote['id']})
        self.assertEqual(status, 202)
        import time
        for _ in range(100):
            current = json.loads(self.request(f"/api/v1/creator/jobs/{job['id']}")[1])
            if current['state'] == 'awaiting_review':
                break
            time.sleep(.01)
        self.assertEqual(current['state'], 'awaiting_review')
        self.assertEqual(len(calls), 1)
        status, data, headers = self.request(current['assetUrl'])
        self.assertEqual((status, data, headers['Content-Type']), (200, output, 'image/png'))
        accepted = json.loads(self.request(f"/api/v1/creator/jobs/{job['id']}/review", {'decision': 'accept'})[1])
        self.assertEqual(accepted['state'], 'accepted')
        self.assertEqual(self.request(f"/api/v1/creator/jobs/{job['id']}/review", {'decision': 'accept'})[0], 409)
        self.assertEqual(self.request(f"/api/v1/creator/jobs/{job['id']}/generate", {'confirmExternalProcessing': True, 'quoteId': quote['id']})[0], 409)

    def test_uncertain_provider_failure_holds_budget_until_history_reconciliation(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        def uncertain(_job):
            raise TimeoutError('synthetic uncertain submission')
        with patch.dict(os.environ, {'LUMMINGS_MEDIA_DAILY_BUDGET_USD': '1.000'}):
            self.server = make_server(0, self.db, model_probe=lambda: self.models,
                                      jobs_root=Path(self.temp.name) / 'generated', media_provider=uncertain)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base = f'http://127.0.0.1:{self.server.server_port}'
        self.token = json.loads(self.request('/api/v1/capabilities')[1])['token']
        character = json.loads(self.request('/api/v1/characters')[1])['characters'][0]
        body = {'requestKey': 'uncertain_request_001', 'kind': 'image', 'character': 'lumo',
                'prompt': 'Lumo explores a moon garden', 'wardrobe': 'heartlight-explorer',
                'scene': 'moon-garden', 'referenceHash': character['portraits']['warm']['sha256'], 'sourceJob': None}
        job = json.loads(self.request('/api/v1/creator/jobs', body)[1])
        quote = json.loads(self.request(f"/api/v1/creator/jobs/{job['id']}/quote", {})[1])
        self.assertEqual(self.request(f"/api/v1/creator/jobs/{job['id']}/generate",
                                      {'confirmExternalProcessing': True, 'quoteId': quote['id']})[0], 202)
        import time
        for _ in range(100):
            current = json.loads(self.request(f"/api/v1/creator/jobs/{job['id']}")[1])
            if current['state'] == 'failed':
                break
            time.sleep(.01)
        self.assertEqual((current['state'], current['chargeStatus']), ('failed', 'reserved'))
        self.assertEqual(json.loads(self.request('/api/v1/capabilities')[1])['mediaBudget']['availableUSD'], '0.976')
        status, data, _ = self.request(f"/api/v1/creator/jobs/{job['id']}/reconcile", {'decision': 'not-charged'})
        self.assertEqual(status, 200)
        self.assertEqual(json.loads(data)['chargeStatus'], 'released')
        self.assertEqual(json.loads(self.request('/api/v1/capabilities')[1])['mediaBudget']['availableUSD'], '1.000')


if __name__ == '__main__':
    unittest.main()
