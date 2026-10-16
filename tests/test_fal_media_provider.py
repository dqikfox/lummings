import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from lummings.characters import registry
from lummings.fal_media_provider import FalMediaProvider, ProviderError
from lummings.http_app import ROOT
from lummings.media_jobs import JobConflict, MediaJobs


PNG = b"\x89PNG\r\n\x1a\nprovider-fixture"


class FalProviderTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.characters = registry(ROOT / 'docs')
        self.jobs = MediaJobs(self.root / 'jobs.sqlite3', self.root / 'generated', daily_budget_usd='1.000')
        self.character = next(c for c in self.characters if c['id'] == 'lumo')
        self.provider = FalMediaProvider('test-key-never-sent', ROOT / 'docs', self.jobs,
                                         sleep=lambda _: None, poll_seconds=0, max_wait_seconds=50)

    def tearDown(self):
        self.tmp.cleanup()

    def create(self, key='fal_job_key_0001', kind='image', source=None):
        return self.jobs.create({'requestKey': key, 'kind': kind, 'character': 'lumo',
                                 'prompt': 'Lumo follows glowing seeds', 'wardrobe': 'heartlight-explorer',
                                 'scene': 'moon-garden', 'referenceHash': self.character['portraits']['warm']['sha256'],
                                 'sourceJob': source}, self.characters)

    def running(self, job):
        self.jobs.transition(job['id'], 'queue')
        return self.jobs.transition(job['id'], 'start')

    def test_image_request_reuses_hash_pinned_art_and_returns_one_mocked_result(self):
        job = self.running(self.create())
        submitted, payloads = [], []
        responses = iter([
            {'request_id': 'a1b2c3d4-1234'}, {'status': 'IN_QUEUE'}, {'status': 'COMPLETED'},
            {'images': [{'url': 'https://v3.fal.media/files/example.png'}]},
        ])
        def json_request(url, method='GET', body=None):
            payloads.append((url, method, body))
            return next(responses)
        with patch.object(self.provider, '_json_request', side_effect=json_request), \
             patch.object(self.provider, '_download', return_value=(PNG, 'image/png')) as download:
            result = self.provider.generate(job, submitted.append)
        self.assertEqual(result, (PNG, 'image/png'))
        self.assertEqual(submitted, ['a1b2c3d4-1234'])
        self.assertEqual(payloads[0][0], 'https://queue.fal.run/fal-ai/flux-2/edit')
        sent = payloads[0][2]
        self.assertTrue(sent['image_urls'][0].startswith('data:image/png;base64,'))
        self.assertIn('strict identity', sent['prompt'])
        self.assertEqual((sent['image_size'], sent['num_images'], sent['enable_safety_checker']),
                         ({'width': 1024, 'height': 1024}, 1, True))
        self.assertEqual(download.call_args.args, ('https://v3.fal.media/files/example.png', 'image'))

    def test_animation_requires_accepted_same_character_still_and_uses_fixed_720p_quote(self):
        still = self.create()
        self.running(still)
        self.jobs.save_output(still['id'], PNG, 'image/png')
        self.jobs.transition(still['id'], 'accept')
        video_draft = self.create(key='fal_video_key_0001', kind='video', source=still['id'])
        self.assertEqual(self.jobs.issue_quote(video_draft['id'])['amountUSD'], '0.20')
        video = self.running(video_draft)
        submitted = []
        responses = iter([{'request_id': 'z9y8x7w6'}, {'status': 'COMPLETED'},
                          {'video': {'url': 'https://storage.googleapis.com/falserverless/out.mp4'}}])
        seen = []
        with patch.object(self.provider, '_json_request', side_effect=lambda *a, **kw: (seen.append((a, kw)) or next(responses))), \
             patch.object(self.provider, '_download', return_value=(b'video', 'video/mp4')):
            result = self.provider.generate(video, submitted.append)
        self.assertEqual(result, (b'video', 'video/mp4'))
        sent = seen[0][0][2]
        self.assertEqual((sent['resolution'], sent['duration']), ('720p', 5))
        self.assertTrue(sent['image_url'].startswith('data:image/png;base64,'))
        self.assertEqual(submitted, ['z9y8x7w6'])

    def test_reference_hash_change_and_unsafe_output_urls_are_rejected(self):
        job = self.running(self.create())
        changed = {**job, 'referenceHash': '0' * 64}
        with self.assertRaises(ProviderError):
            self.provider._reference(changed)
        for url in ('http://fal.media/output.png', 'https://127.0.0.1/output.png',
                    'https://evil.example/output.png', 'https://user@fal.media/output.png',
                    'https://fal.media:444/output.png'):
            with self.subTest(url=url), self.assertRaises(ProviderError):
                self.provider._download_url(url)
        self.provider._download_url('https://v3.fal.media/files/image.png')
        self.provider._download_url('https://storage.googleapis.com/falserverless/image.png')

    def test_provider_request_uses_server_key_without_reflecting_it(self):
        captured = {}

        class FakeResponse:
            def __enter__(self): return self
            def __exit__(self, *args): return None
            def read(self, limit): return b'{"status":"IN_QUEUE"}'

        def request(req, timeout):
            captured['url'] = req.full_url
            captured['authorization'] = req.get_header('Authorization')
            captured['timeout'] = timeout
            return FakeResponse()

        provider = FalMediaProvider('unit-secret-key', ROOT / 'docs', self.jobs, request=request)
        result = provider._json_request('https://queue.fal.run/fal-ai/flux-2/edit/requests/12345678/status')
        self.assertEqual(result, {'status': 'IN_QUEUE'})
        self.assertEqual(captured['authorization'], 'Key unit-secret-key')
        with self.assertRaises(ProviderError):
            provider._json_request('https://169.254.169.254/latest/meta-data')


if __name__ == '__main__':
    unittest.main()
