"""Canonical creator registry and append-only appearance revisions."""
import hashlib
import sqlite3
from contextlib import closing
from pathlib import Path

from .artwork import PROFILES
from .engine import PERSONA_ALIASES

EXPRESSIONS = ('warm', 'curious', 'playful', 'excited', 'sleepy')
BACKDROPS = ('observatory', 'garden', 'dreamscape')
HEARTLIGHTS = dict(zip(('lumo', 'lila', 'pip', 'nori', 'moki'),
                      ('Questlight', 'Dreamlight', 'Traillight', 'Tidelight', 'Sparklight')))
DEFAULT = {'expression': 'warm', 'backdrop': 'observatory'}


def canonical(name):
    name = PERSONA_ALIASES.get(name.lower(), name.lower())
    if name not in PROFILES:
        raise KeyError(name)
    return name


def registry(docs):
    return [{'id': name, 'name': profile.get('display_name', name.title()),
             'role': profile['title'], 'color': profile['color'], 'heartlight': HEARTLIGHTS[name],
             'expressions': ['warm'], 'artworkVersion': 'illustrated-2026-10-13', 'expressionVariants': False, 'backdrops': list(BACKDROPS),
             'portraits': {expression: {
                 'url': f'/assets/characters/{name}-portrait.png',
                 'sha256': hashlib.sha256((Path(docs) / 'assets/characters' / f'{name}-portrait.png').read_bytes()).hexdigest()
             } for expression in ('warm',)}} for name, profile in PROFILES.items()]


class Conflict(Exception):
    pass


class AppearanceStore:
    def __init__(self, path):
        self.path = Path(path)

    def connect(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        db = sqlite3.connect(self.path, timeout=10)
        db.row_factory = sqlite3.Row
        db.execute('''CREATE TABLE IF NOT EXISTS appearances (
            character TEXT NOT NULL, revision INTEGER NOT NULL,
            expression TEXT NOT NULL, backdrop TEXT NOT NULL,
            parent INTEGER NOT NULL, action TEXT NOT NULL,
            created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY(character, revision))''')
        return db

    def current(self, db, name):
        row = db.execute('SELECT * FROM appearances WHERE character=? ORDER BY revision DESC LIMIT 1', (name,)).fetchone()
        return dict(row) if row else {'character': name, 'revision': 0, 'parent': 0, **DEFAULT}

    @staticmethod
    def public(row):
        return {key: row[key] for key in ('character', 'revision', 'expression', 'backdrop')} | {'canUndo': row['parent'] != row['revision'] and row['revision'] > 0 and row.get('action') != 'undo-empty'}

    def get(self, name):
        name = canonical(name)
        with closing(self.connect()) as db:
            return self.public(self.current(db, name))

    def change(self, name, body, undo=False):
        name = canonical(name)
        keys = {'expectedRevision'} if undo else {'expectedRevision', 'expression', 'backdrop'}
        if not isinstance(body, dict) or set(body) != keys or type(body.get('expectedRevision')) is not int or body['expectedRevision'] < 0:
            raise ValueError('Invalid appearance request.')
        if not undo and (body['expression'] not in EXPRESSIONS or body['backdrop'] not in BACKDROPS):
            raise ValueError('Choose an available expression and backdrop.')
        with closing(self.connect()) as db, db:
            db.execute('BEGIN IMMEDIATE')
            current = self.current(db, name)
            if current['revision'] != body['expectedRevision']:
                raise Conflict('Appearance changed elsewhere. Latest saved look loaded; try again.')
            if undo:
                if not self.public(current)['canUndo']:
                    raise ValueError('No earlier appearance to restore.')
                parent = current['parent']
                target = dict(db.execute('SELECT * FROM appearances WHERE character=? AND revision=?', (name, parent)).fetchone()) if parent else {'revision': 0, 'parent': 0, **DEFAULT}
                expression, backdrop = target['expression'], target['backdrop']
                parent = target['parent']
                action = 'undo' if target['revision'] and target.get('action') != 'undo-empty' else 'undo-empty'
            else:
                expression, backdrop = body['expression'], body['backdrop']
                if (expression, backdrop) == (current['expression'], current['backdrop']):
                    return self.public(current)
                parent, action = current['revision'], 'save'
            db.execute('INSERT INTO appearances(character,revision,expression,backdrop,parent,action) VALUES(?,?,?,?,?,?)',
                       (name, current['revision'] + 1, expression, backdrop, parent, action))
            return self.public(self.current(db, name))
