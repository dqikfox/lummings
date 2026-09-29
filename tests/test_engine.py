"""Unit tests for the Lummings personality engine."""

import json
from pathlib import Path
from unittest.mock import patch

from lummings.engine import (
    load_persona, build_system_prompt, sanitize_reply, extract_facts, Memory, Mood,
)


def test_load_persona_lumo():
    p = load_persona("lumo")
    assert p["name"] == "Lumo"
    assert "curious" in p["traits"] or any("curious" in t.lower() for t in p["traits"])


def test_load_persona_all_five():
    for name in ["lumo", "lumi", "piko", "nomi", "moki"]:
        p = load_persona(name)
        assert p["name"][0].isupper()
        assert "max_words" in p
        assert "mission" in p
        assert "code" in p
        assert len(p["code"]) == 5  # The Lumming Code is always 5 rules


def test_build_system_prompt_contains_key_sections():
    p = load_persona("lumo")
    s = build_system_prompt(p)
    assert "Lumo" in s
    assert "STAY CURIOUS" in s
    assert "PROTECT YOUR WORLD" in s
    assert "lumospeak" in s
    assert "LEARNING MODE" in s


def test_sanitize_reply_enforces_max_words():
    p = load_persona("lumo")
    long = "one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen"
    out = sanitize_reply(long, p)
    for sentence in out.split("."):
        words = sentence.strip().split()
        if words:
            assert len(words) <= p["max_words"]


def test_sanitize_reply_caps_at_three_sentences():
    p = load_persona("lumo")
    s = "one. two. three. four. five."
    out = sanitize_reply(s, p)
    assert len([x for x in out.split(".") if x.strip()]) <= 3


def test_extract_facts_names():
    facts = extract_facts("hi, my name is alex", "hello alex")
    assert any("name" in f for f in facts)


def test_extract_facts_preferences():
    facts = extract_facts("i love dinosaurs", "cool!")
    assert any("preference" in f for f in facts)


def test_memory_persists_across_instances(tmp_path):
    db = tmp_path / "test.sqlite"
    m1 = Memory(db, "lumo", owner="alex")
    m1.add_fact("(name) alex")
    m1.add_event("user", "hello")
    m1.add_event("assistant", "hi alex")
    m2 = Memory(db, "lumo", owner="alex")
    facts = m2.recall_facts()
    assert any("alex" in f["fact"] for f in facts)
    events = m2.recent_events()
    assert len(events) == 2


def test_memory_isolates_per_persona(tmp_path):
    db = tmp_path / "test.sqlite"
    m1 = Memory(db, "lumo")
    m1.add_fact("lumo fact")
    m2 = Memory(db, "piko")
    facts = m2.recall_facts()
    assert not any("lumo" in f["fact"] for f in facts)


def test_mood_transitions():
    p = load_persona("lumo")
    m = Mood(p)
    assert m.state == p["mood_initial"]
    # After on_user_input, mood should be valid
    m.on_user_input()
    assert m.state in p["mood_transitions"]


def test_all_personas_have_valid_mood_graph():
    for name in ["lumo", "lumi", "piko", "nomi", "moki"]:
        p = load_persona(name)
        initial = p["mood_initial"]
        assert initial in p["mood_transitions"], f"{name}: initial mood '{initial}' not in transitions"


def test_avoid_lists_no_overlap_with_openers():
    for name in ["lumo", "lumi", "piko", "nomi", "moki"]:
        p = load_persona(name)
        for word in p["avoid"]:
            assert word.lower() not in [o.lower().strip("!?.,") for o in p["openers"]], \
                f"{name}: '{word}' is both avoided and used as opener"
