import json
import tempfile
import threading
import unittest
import urllib.error
import urllib.request
from pathlib import Path

from lummings.http_app import make_server
from lummings.media_library import MediaLibrary


class MediaLibraryTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.source = self.root / 'imagine_videos/imagine_videos/sample.mp4'
        self.source.parent.mkdir(parents=True)
        self.source.write_bytes(bytes(range(100)))
        self.preview = self.root / 'data/creator/media-previews/sample.jpg'
        self.preview.parent.mkdir(parents=True)
        self.preview.write_bytes(b'preview')
        self.item = {'id':'video_test123', 'title':'Test clip', 'kind':'video', 'category':'video',
                     'source':self.source.relative_to(self.root).as_posix(),
                     'preview':self.preview.relative_to(self.root).as_posix(),
                     'width':10, 'height':10, 'bytes':100}
        (self.root / 'data/creator/media-catalog.json').write_text(json.dumps({'version':1,'items':[self.item]}))
        self.database = self.root / 'conversation.sqlite3'
        self.server = make_server(0, self.database, model_probe=lambda: set(), media_root=self.root)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()
        self.base = f'http://127.0.0.1:{self.server.server_port}'
        self.token = json.loads(self.request('/api/v1/capabilities')[1])['token']

    def tearDown(self):
        self.server.shutdown(); self.server.server_close(); self.thread.join(); self.temp.cleanup()

    def request(self, path, body=None, headers=None):
        h = {'Content-Type':'application/json','X-Lummings-Token':getattr(self,'token','')}
        h.update(headers or {})
        req = urllib.request.Request(self.base + path, data=json.dumps(body).encode() if body is not None else None, headers=h)
        try:
            response = urllib.request.urlopen(req)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            return response.status, response.read(), response.headers

    def test_listing_stream_and_preview(self):
        items = json.loads(self.request('/api/v1/media')[1])['items']
        self.assertEqual(len(items), 1)
        self.assertTrue(items[0]['available'])
        self.assertEqual(self.request(items[0]['url'])[1], bytes(range(100)))
        self.assertEqual(self.request(items[0]['previewUrl'])[1], b'preview')

    def test_byte_ranges_for_seeking(self):
        for value, expected, span in [('bytes=10-19',bytes(range(10,20)),'10-19'),
                                      ('bytes=98-',bytes([98,99]),'98-99'),
                                      ('bytes=-3',bytes([97,98,99]),'97-99'),
                                      ('bytes=98-1000',bytes([98,99]),'98-99')]:
            status, data, headers = self.request('/api/v1/media/video_test123/file',headers={'Range':value})
            self.assertEqual((status,data),(206,expected))
            self.assertEqual(headers['Content-Range'],f'bytes {span}/100')
        for value in ('bytes=100-', 'bytes=20-10', 'bytes=-0', 'bytes=-', 'bytes=0-1,3-4', 'nonsense'):
            self.assertEqual(self.request('/api/v1/media/video_test123/file',headers={'Range':value})[0],416)

    def test_shortlist_persists_and_is_reversible(self):
        route = '/api/v1/media/video_test123/shortlist'
        self.assertEqual(self.request(route,{'selected':True})[0],200)
        library = MediaLibrary(self.root,self.database.with_name('conversation-media.sqlite3'))
        self.assertTrue(library.listing()[0]['shortlisted'])
        self.assertEqual(self.request(route,{'selected':False})[0],200)
        self.assertFalse(library.listing()[0]['shortlisted'])
        self.assertEqual(self.source.read_bytes(),bytes(range(100)))
        self.assertFalse(self.database.exists())

    def test_shortlist_validation_and_access(self):
        route = '/api/v1/media/video_test123/shortlist'
        for body in ({}, [], {'selected':'true'}, {'selected':1}, {'selected':True,'source':'x'}):
            self.assertEqual(self.request(route,body)[0],400)
        self.assertEqual(self.request(route,{'selected':True},{'X-Lummings-Token':''})[0],403)
        self.assertEqual(self.request('/api/v1/media',headers={'Origin':'https://evil.example'})[0],403)
        self.assertEqual(self.request('/api/v1/media/unknown123/file')[0],404)
        self.assertEqual(self.request('/api/v1/media/unknown123/shortlist',{'selected':True})[0],404)

    def test_missing_source_and_path_escape(self):
        self.source.unlink()  # Disposable fixture only.
        self.assertFalse(json.loads(self.request('/api/v1/media')[1])['items'][0]['available'])
        self.assertEqual(self.request('/api/v1/media/video_test123/file')[0],404)
        library = MediaLibrary(self.root,self.root/'test.sqlite3')
        for source in ('../../secret.png', 'data/creator/private.png', str(Path(__file__).resolve())):
            library.items['video_test123']['source'] = source
            self.assertIsNone(library.file('video_test123'))
        self.assertEqual(self.request('/api/v1/media/%2e%2e/file')[0],404)
