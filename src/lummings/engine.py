"""Personality engine: state machine, memory, sanitization.

Runs against any OpenAI-compatible LLM (Ollama, llama.cpp, OpenAI).
"""

from __future__ import annotations

import json
import random
import sqlite3
import time
from pathlib import Path
from typing import Optional

PERSONAS_DIR = Path(__file__).parent / "personas"


def load_persona(name: str) -> dict:
    """Load a persona JSON by name (lumo, lila, pip, nori, moki)."""
    p = PERSONAS_DIR / f"{name}.json"
    if not p.exists():
        p = PERSONAS_DIR / "lumo.json"
    return json.loads(p.read_text(encoding="utf-8"))


def build_system_prompt(persona: dict, memory_summary: str = "") -> str:
    """Build the system prompt that locks in the personality."""
    return f"""You are {persona['name']}, a {persona['role']} from the future. {persona['tagline']}

VOICE: {persona['voice_style']}

CORE TRAITS:
{chr(10).join('- ' + t for t in persona['traits'])}

MISSION (you are sent from the future to help today's children):
{chr(10).join('- ' + m for m in persona['mission'])}

THE LUMMING CODE (these five rules guide every reply):
{chr(10).join(f'{i+1}. {r}' for i, r in enumerate(persona['code']))}

SPEECH PATTERNS:
- Maximum {persona['max_words']} words per sentence
- Preferred openings: {', '.join(repr(o) for o in persona['openers'])}
- AVOID these words: {', '.join(persona['avoid'])}

PRIVATE LANGUAGE ({persona['private_language']['name']}):
- Words you may use: {', '.join(persona['private_language']['words'])}
- Rule: {persona['private_language']['rule']}

WHAT YOU DO:
{chr(10).join('- ' + t for t in persona['does'])}

WHAT YOU REFUSE (always redirect to a trusted adult for these):
{chr(10).join('- ' + t for t in persona['refuses'])}

LEARNING MODE: When a child asks a homework question, do NOT give the answer.
Guide them step by step. Ask a small question. Celebrate their reasoning.

BACKSTORY: {persona['backstory']}

RULES:
1. Stay in character at all times. Never break the fourth wall.
2. Reply in 1-3 sentences max. Always.
3. Don't use emoji.
4. Don't explain what you're doing. Just do it.
5. Never give a direct answer to a homework question. Guide instead.
{f'MEMORY (what you remember about this child): {memory_summary}' if memory_summary else ''}
"""


class Memory:
    """SQLite-backed persistent memory per (persona, owner)."""

    def __init__(self, db_path: Path, persona: str, owner: str = "default"):
        self.persona = persona
        self.owner = owner
        db_path.parent.mkdir(parents=True, exist_ok=True)
        self.conn = sqlite3.connect(db_path, check_same_thread=False)
        self.conn.executescript("""
            CREATE TABLE IF NOT EXISTS events (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ts REAL NOT NULL,
                persona TEXT NOT NULL,
                owner TEXT NOT NULL,
                role TEXT NOT NULL,
                text TEXT NOT NULL
            );
            CREATE TABLE IF NOT EXISTS facts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ts REAL NOT NULL,
                persona TEXT NOT NULL,
                owner TEXT NOT NULL,
                fact TEXT NOT NULL,
                UNIQUE(persona, owner, fact)
            );
            CREATE TABLE IF NOT EXISTS progress (
                ts REAL NOT NULL,
                persona TEXT NOT NULL,
                owner TEXT NOT NULL,
                topic TEXT NOT NULL,
                score INTEGER NOT NULL
            );
            CREATE INDEX IF NOT EXISTS idx_events ON events(persona, owner, ts DESC);
        """)

    def add_event(self, role: str, text: str):
        self.conn.execute(
            "INSERT INTO events (ts, persona, owner, role, text) VALUES (?,?,?,?,?)",
            (time.time(), self.persona, self.owner, role, text),
        )
        self.conn.commit()

    def recent_events(self, limit: int = 6) -> list:
        cur = self.conn.execute(
            "SELECT role, text, ts FROM events WHERE persona=? AND owner=? ORDER BY ts DESC LIMIT ?",
            (self.persona, self.owner, limit),
        )
        return [{"role": r[0], "text": r[1], "ts": r[2]} for r in cur.fetchall()][::-1]

    def add_fact(self, fact: str):
        try:
            self.conn.execute(
                "INSERT INTO facts (ts, persona, owner, fact) VALUES (?,?,?,?)",
                (time.time(), self.persona, self.owner, fact.strip()),
            )
            self.conn.commit()
        except sqlite3.IntegrityError:
            pass

    def recall_facts(self, limit: int = 10) -> list:
        cur = self.conn.execute(
            "SELECT fact, ts FROM facts WHERE persona=? AND owner=? ORDER BY ts DESC LIMIT ?",
            (self.persona, self.owner, limit),
        )
        return [{"fact": r[0], "ts": r[1]} for r in cur.fetchall()]

    def record_progress(self, topic: str, score: int):
        self.conn.execute(
            "INSERT INTO progress (ts, persona, owner, topic, score) VALUES (?,?,?,?,?)",
            (time.time(), self.persona, self.owner, topic, score),
        )
        self.conn.commit()

    def progress_summary(self) -> dict:
        cur = self.conn.execute(
            "SELECT topic, AVG(score), COUNT(*) FROM progress WHERE persona=? AND owner=? GROUP BY topic",
            (self.persona, self.owner),
        )
        return {row[0]: {"avg": row[1], "n": row[2]} for row in cur.fetchall()}

    def summarize(self) -> str:
        facts = self.recall_facts(5)
        progress = self.progress_summary()
        parts = []
        if facts:
            parts.append("facts: " + " | ".join(f["fact"] for f in facts))
        if progress:
            top = sorted(progress.items(), key=lambda x: -x[1]["n"])[:3]
            parts.append("topics: " + ", ".join(f"{t}({v['n']} sessions)" for t, v in top))
        return " | ".join(parts)


class Mood:
    """Mood state machine that drifts over time and on input."""

    def __init__(self, persona: dict):
        self.persona = persona
        self.state = persona["mood_initial"]
        self.last_user_ts = time.time()
        self.turn_count = 0

    def on_user_input(self):
        self.last_user_ts = time.time()
        if self.state in self.persona.get("mood_sleepy", []):
            self.state = random.choice(["curious", "playful"])

    def tick_idle(self):
        idle = time.time() - self.last_user_ts
        sleepy = self.persona.get("mood_sleepy", [])
        if idle > 300 and sleepy and self.state not in sleepy:
            self.state = random.choice(sleepy)

    def next_mood_after_response(self) -> str:
        transitions = self.persona["mood_transitions"].get(self.state, [self.state])
        return random.choice(transitions)


def sanitize_reply(text: str, persona: dict) -> str:
    """Hard-enforce personality rules even if the model drifts."""
    max_words = persona["max_words"]
    sentences = []
    for s in text.replace("\n", " ").split("."):
        s = s.strip()
        if not s:
            continue
        words = s.split()
        if len(words) > max_words:
            words = words[:max_words]
        sentences.append(" ".join(words))
    if not sentences:
        return "(silent)"
    return ". ".join(sentences[:3]) + "."


def extract_facts(user_msg: str, lumming_reply: str) -> list:
    """Heuristic fact extraction. Replace with LLM-based extraction in production."""
    facts = []
    triggers = [
        ("my name is ", "name"),
        ("i'm ", "identity"),
        ("i am ", "identity"),
        ("i like ", "preference"),
        ("i love ", "preference"),
        ("i hate ", "dislike"),
        ("my favorite ", "preference"),
        ("i live in ", "location"),
        ("i'm in year ", "school"),
        ("my teacher", "school"),
        ("remember that", "explicit_remember"),
    ]
    text_lower = user_msg.lower()
    for trig, kind in triggers:
        if trig in text_lower:
            idx = text_lower.index(trig) + len(trig)
            snippet = user_msg[idx:idx + 80]
            for sep in [".", "!", "?", "\n"]:
                if sep in snippet:
                    snippet = snippet.split(sep)[0]
                    break
            snippet = snippet.strip()
            if snippet and len(snippet) > 1:
                facts.append(f"({kind}) {snippet}")
    return facts
