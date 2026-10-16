"""Local, explicitly catalogued source media and a reversible creator shortlist."""
import json
import re
import sqlite3
from contextlib import closing
from pathlib import Path


class MediaLibrary:
    def __init__(self, root, database):
        self.root = Path(root).resolve()
        self.database = Path(database)
        self.items = {}
        path = self.root / 'data/creator/media-catalog.json'
        if path.is_file():
            for item in json.loads(path.read_text(encoding='utf-8'))['items']:
                if re.fullmatch(r'[a-zA-Z0-9_-]{8,80}', item['id']):
                    self.items[item['id']] = item

    def file(self, asset_id, preview=False):
        item = self.items.get(asset_id)
        if not item:
            return None
        source = item.get('preview' if preview else 'source', '')
        candidate = (self.root / source).resolve()
        allowed = ('data/creator/media-previews',) if preview else (
            'marketing/demo-assets', 'imagine_images/imagine_images', 'imagine_videos/imagine_videos')
        confined = any(candidate.is_relative_to((self.root / p).resolve()) for p in allowed)
        if not preview and candidate == self.root / 'lummings-heartlight-story.mp4':
            confined = True
        if not candidate.is_relative_to(self.root) or not confined or not candidate.is_file():
            return None
        if candidate.suffix.lower() not in ('.png', '.jpg', '.jpeg', '.webp', '.mp4'):
            return None
        return candidate

    def connect(self):
        self.database.parent.mkdir(parents=True, exist_ok=True)
        db = sqlite3.connect(self.database, timeout=10)
        db.execute('CREATE TABLE IF NOT EXISTS shortlist (asset_id TEXT PRIMARY KEY, selected INTEGER NOT NULL)')
        return db

    def listing(self):
        with closing(self.connect()) as db:
            selected = {row[0] for row in db.execute('SELECT asset_id FROM shortlist WHERE selected=1')}
        result = []
        for asset_id, item in self.items.items():
            available = self.file(asset_id) is not None
            result.append({**item, 'available': available, 'shortlisted': asset_id in selected,
                           'url': f'/api/v1/media/{asset_id}/file',
                           'previewUrl': f'/api/v1/media/{asset_id}/preview' if self.file(asset_id, True) else None})
        return result

    def shortlist(self, asset_id, body):
        if asset_id not in self.items:
            raise KeyError(asset_id)
        if not isinstance(body, dict) or set(body) != {'selected'} or type(body['selected']) is not bool:
            raise ValueError('Expected selected: true or false.')
        with closing(self.connect()) as db, db:
            db.execute('INSERT INTO shortlist VALUES (?,?) ON CONFLICT(asset_id) DO UPDATE SET selected=excluded.selected',
                       (asset_id, int(body['selected'])))
        return {'id': asset_id, 'shortlisted': body['selected']}


def serve_media(handler, path):
    """Bounded streaming with single HTTP byte ranges for native video seeking."""
    import mimetypes
    size = path.stat().st_size
    start, end, status = 0, size - 1, 200
    requested = handler.headers.get('Range')
    if requested:
        match = re.fullmatch(r'bytes=(\d*)-(\d*)', requested)
        try:
            if not match or not any(match.groups()):
                raise ValueError()
            first, last = match.groups()
            if first:
                start = int(first)
                end = min(int(last), size - 1) if last else size - 1
            else:
                count = int(last)
                if count <= 0:
                    raise ValueError()
                start = max(0, size - count)
            if not 0 <= start <= end < size:
                raise ValueError()
            status = 206
        except ValueError:
            handler.send_response(416)
            handler.send_header('Content-Range', f'bytes */{size}')
            handler.send_header('Content-Length', '0')
            handler.end_headers()
            return
    handler.send_response(status)
    handler.send_header('Content-Type', mimetypes.guess_type(path.name)[0] or 'application/octet-stream')
    handler.send_header('Content-Length', str(end - start + 1))
    handler.send_header('Accept-Ranges', 'bytes')
    handler.send_header('X-Content-Type-Options', 'nosniff')
    handler.send_header('Cache-Control', 'no-store')
    if status == 206:
        handler.send_header('Content-Range', f'bytes {start}-{end}/{size}')
    handler.end_headers()
    try:
        with path.open('rb') as stream:
            stream.seek(start)
            remaining = end - start + 1
            while remaining:
                block = stream.read(min(65536, remaining))
                if not block:
                    break
                handler.wfile.write(block)
                remaining -= len(block)
    except (BrokenPipeError, ConnectionResetError, ConnectionAbortedError):
        pass  # The user closed a preview or sought to another video position.
