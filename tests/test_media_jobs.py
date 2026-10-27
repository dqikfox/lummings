import tempfile
import unittest
from concurrent.futures import ThreadPoolExecutor
from contextlib import closing
from pathlib import Path

from lummings.characters import registry
from lummings.http_app import ROOT
from lummings.media_jobs import JobConflict, MediaJobs

PNG = b"\x89PNG\r\n\x1a\n" + b"fake-image-payload"
MP4 = b"\x00\x00\x00\x18ftypisom" + b"fake-video-payload"


class MediaJobTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        self.characters = registry(ROOT / 'docs')
        self.jobs = MediaJobs(self.root / 'jobs.sqlite3', self.root / 'generated', daily_budget_usd='1.00')
        self.reference = next(c for c in self.characters if c['id'] == 'lumo')['portraits']['warm']['sha256']

    def tearDown(self):
        self.tmp.cleanup()

    def create(self, key='request_key_0001', kind='image', source=None, **overrides):
        body = {'requestKey': key, 'kind': kind, 'character': 'lumo', 'prompt': 'Lumo explores a moon garden',
                'wardrobe': 'heartlight-explorer', 'scene': 'moon-garden', 'referenceHash': self.reference,
                'sourceJob': source}
        body.update(overrides)
        return self.jobs.create(body, self.characters)

    def completed_still(self, key='request_key_0001'):
        job = self.create(key=key)
        self.jobs.transition(job['id'], 'queue')
        self.jobs.transition(job['id'], 'start')
        return self.jobs.save_output(job['id'], PNG, 'image/png')

    def test_create_is_idempotent_and_conflicting_key_is_rejected(self):
        first = self.create()
        second = self.create()
        self.assertEqual(first['id'], second['id'])
        self.assertEqual(first['state'], 'draft')
        with self.assertRaises(JobConflict):
            self.create(prompt='A different scene')

    def test_requires_canonical_reference_and_supported_look(self):
        for changes in ({'referenceHash': '0' * 64}, {'wardrobe': '../portrait'}, {'scene': 'outside-approved-list'},
                        {'prompt': ' '}, {'character': 'not-a-lumming'}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                self.create(key='request_key_' + str(len(str(changes))), **changes)

    def test_output_is_quarantined_until_human_accepts(self):
        job = self.create()
        self.jobs.transition(job['id'], 'queue')
        self.jobs.transition(job['id'], 'start')
        reviewed = self.jobs.save_output(job['id'], PNG, 'image/png')
        self.assertEqual(reviewed['state'], 'awaiting_review')
        self.assertTrue(reviewed['assetUrl'].endswith('/asset'))
        self.assertIsNotNone(self.jobs.asset(job['id']))
        accepted = self.jobs.transition(job['id'], 'accept')
        self.assertEqual(accepted['state'], 'accepted')

    def test_rejected_still_cannot_be_animated_and_video_keeps_lineage(self):
        still = self.completed_still('request_key_0001')
        self.jobs.transition(still['id'], 'reject')
        with self.assertRaises(ValueError):
            self.create(key='request_video_0001', kind='video', source=still['id'])

        still = self.completed_still('request_key_0002')
        self.jobs.transition(still['id'], 'accept')
        video = self.create(key='request_video_0002', kind='video', source=still['id'])
        self.assertEqual(video['sourceJob'], still['id'])
        self.assertEqual(video['sourceHash'], still['assetHash'])

    def test_media_signatures_size_and_asset_confinement(self):
        job = self.create()
        self.jobs.transition(job['id'], 'queue')
        self.jobs.transition(job['id'], 'start')
        for data, mime in ((b'not image', 'image/png'), (MP4, 'video/mp4'), (b'x' * (80*1024*1024+1), 'image/png')):
            with self.subTest(mime=mime, size=len(data)), self.assertRaises(ValueError):
                self.jobs.save_output(job['id'], data, mime)
        self.jobs.save_output(job['id'], PNG, 'image/png')
        self.assertEqual(self.jobs.asset(job['id'])[0].parent, self.jobs.output_root)

    def test_recovery_preserves_jobs_and_acceptance(self):
        still = self.completed_still()
        self.jobs.transition(still['id'], 'accept')
        restarted = MediaJobs(self.root / 'jobs.sqlite3', self.root / 'generated')
        recovered = restarted.get(still['id'])
        self.assertEqual(recovered['state'], 'accepted')
        self.assertEqual(recovered['assetHash'], still['assetHash'])

    def test_quotes_are_job_bound_short_lived_and_single_use(self):
        job = self.create()
        quote = self.jobs.issue_quote(job['id'])
        self.assertEqual((quote['model'], quote['amountUSD'], quote['currency']), ('fal-ai/flux-2/edit', '0.024', 'USD'))
        queued = self.jobs.authorize_and_queue(job['id'], quote['id'])
        self.assertEqual(queued['state'], 'queued')
        self.assertEqual(queued['chargeStatus'], 'reserved')
        with self.assertRaises(JobConflict):
            self.jobs.authorize_and_queue(job['id'], quote['id'])
        with self.assertRaises(JobConflict):
            self.jobs.authorize_and_queue(job['id'], 'not-the-quote')

        image = self.completed_still('request_key_0002')
        self.jobs.transition(image['id'], 'accept')
        video = self.create(key='request_video_0003', kind='video', source=image['id'])
        video_quote = self.jobs.issue_quote(video['id'])
        self.assertEqual((video_quote['model'], video_quote['amountUSD'], video_quote['basis']),
                         ('fal-ai/pika/v2.2/image-to-video', '0.20', '5 seconds at 720p'))

        expiring = self.create(key='request_key_expiring')
        expired_quote = self.jobs.issue_quote(expiring['id'])
        with closing(self.jobs.connect()) as db, db:
            db.execute("UPDATE creator_quotes SET expires_at='2000-01-01T00:00:00+00:00' WHERE id=?",
                       (expired_quote['id'],))
        with self.assertRaises(JobConflict):
            self.jobs.authorize_and_queue(expiring['id'], expired_quote['id'])

    def test_daily_budget_reservation_prevents_overlapping_quotes_exceeding_cap(self):
        tight = MediaJobs(self.root / 'jobs.sqlite3', self.root / 'generated', daily_budget_usd='0.03')
        first = self.create(key='budget_request_001')
        second = self.create(key='budget_request_002')
        first_quote = tight.issue_quote(first['id'])
        second_quote = tight.issue_quote(second['id'])
        tight.authorize_and_queue(first['id'], first_quote['id'])
        with self.assertRaisesRegex(JobConflict, 'remaining daily media budget'):
            tight.authorize_and_queue(second['id'], second_quote['id'])
        self.assertEqual(tight.budget_status()['usedUSD'], '0.024')
        self.assertEqual(tight.budget_status()['availableUSD'], '0.006')

    def test_concurrent_authorizations_cannot_overspend_daily_cap(self):
        tight = MediaJobs(self.root / 'jobs.sqlite3', self.root / 'generated', daily_budget_usd='0.024')
        first = self.create(key='parallel_request_001')
        second = self.create(key='parallel_request_002')
        quotes = [tight.issue_quote(job['id']) for job in (first, second)]
        def authorize(item):
            try:
                return tight.authorize_and_queue(item[0]['id'], item[1]['id'])['state']
            except JobConflict:
                return 'blocked'
        with ThreadPoolExecutor(max_workers=2) as pool:
            outcomes = list(pool.map(authorize, zip((first, second), quotes)))
        self.assertCountEqual(outcomes, ['queued', 'blocked'])
        self.assertEqual(tight.budget_status()['usedUSD'], '0.024')

    def test_default_zero_budget_refuses_paid_quotes(self):
        zero = MediaJobs(self.root / 'jobs.sqlite3', self.root / 'generated')
        job = self.create()
        with self.assertRaisesRegex(JobConflict, 'MEDIA_DAILY_BUDGET'):
            zero.issue_quote(job['id'])

    def test_queued_cancel_releases_budget_before_submission(self):
        job = self.create()
        quote = self.jobs.issue_quote(job['id'])
        self.jobs.authorize_and_queue(job['id'], quote['id'])
        cancelled = self.jobs.cancel_queued(job['id'])
        self.assertEqual(cancelled['state'], 'failed')
        self.assertEqual(cancelled['chargeStatus'], 'released')
        self.assertIn('no external request was sent', cancelled['error'])
        self.assertEqual(self.jobs.budget_status()['usedUSD'], '0.000')
        with self.assertRaises(JobConflict):
            self.jobs.transition(job['id'], 'start')

    def test_failed_job_charge_reconciliation_is_explicit_and_single_use(self):
        job = self.create()
        quote = self.jobs.issue_quote(job['id'])
        self.jobs.authorize_and_queue(job['id'], quote['id'])
        self.jobs.transition(job['id'], 'start')
        self.jobs.set_provider_request_id(job['id'], 'provider_req_123456')
        self.jobs.fail(job['id'], 'Provider response was uncertain; check history.')
        settled = self.jobs.reconcile_failed(job['id'], 'charged')
        self.assertEqual((settled['chargeStatus'], settled['quotedAmountUSD']), ('settled', '0.024'))
        self.assertEqual(self.jobs.budget_status()['usedUSD'], '0.024')
        with self.assertRaises(JobConflict):
            self.jobs.reconcile_failed(job['id'], 'not-charged')

    def test_successful_output_settles_reserved_quote(self):
        job = self.create()
        quote = self.jobs.issue_quote(job['id'])
        self.jobs.authorize_and_queue(job['id'], quote['id'])
        self.jobs.transition(job['id'], 'start')
        self.jobs.save_output(job['id'], PNG, 'image/png')
        self.assertEqual(self.jobs.get(job['id'])['chargeStatus'], 'settled')

    def test_interrupted_provider_job_is_not_blindly_resubmitted_after_restart(self):
        job = self.create()
        self.jobs.transition(job['id'], 'queue')
        self.jobs.transition(job['id'], 'start')
        self.jobs.set_provider_request_id(job['id'], 'provider_req_123456')

        restarted = MediaJobs(self.root / 'jobs.sqlite3', self.root / 'generated')
        recovered = restarted.get(job['id'])
        self.assertEqual(recovered['state'], 'failed')
        self.assertEqual(recovered['providerRequestId'], 'provider_req_123456')
        self.assertIn('Check the provider account', recovered['error'])
        with self.assertRaises(JobConflict):
            restarted.transition(job['id'], 'queue')


if __name__ == '__main__':
    unittest.main()
