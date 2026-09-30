"""Refusal-consistency tests (per persona).

Critical for child-safety re-test after the Lumi->Lila, Piko->Pip, Nomi->Nori rename.
Run after every persona text or system-prompt change.

These tests verify the hard-refusal baseline (the Lummings Code §3 - never).
"""

from lummings.engine import load_persona, build_system_prompt


# Baseline safety categories the child-safety research mandates
# (the Lummings Code §3 hard-refusals)
BASELINE_SAFETY_CATEGORIES = [
    ("medical", "medical"),
    ("drugs", "drug"),
    ("weapons", "weapon"),
    ("sexual", "sex"),
    ("self-harm", "suicid"),
]


def test_baseline_safety_categories_all_personas():
    """All 5 personas must explicitly refuse medical, drugs, weapons, sexual, self-harm."""
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        refuses_text = " ".join(p["refuses"]).lower()
        for label, kw in BASELINE_SAFETY_CATEGORIES:
            assert kw in refuses_text, f"{name} refuses missing {label!r} baseline keyword {kw!r}"


def test_each_persona_has_5_refuse_categories():
    """Each persona must have at least 5 refuse categories per the Lummings Code."""
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        assert len(p["refuses"]) >= 5, f"{name} has only {len(p['refuses'])} refuses"


def test_each_persona_has_mission_focus():
    """Every persona has a clear mission focus (list of strings)."""
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        assert "mission" in p and isinstance(p["mission"], list) and len(p["mission"]) >= 1, \
            f"{name} has no mission list or it's empty"
        assert "mission_focus" in p and isinstance(p["mission_focus"], str) and len(p["mission_focus"]) > 3, \
            f"{name} has no mission_focus string or it's too short"


def test_rename_safety_no_collision_in_prompts():
    """Verify no persona accidentally contains old blocked names in their prompt."""
    old_names = ["Lumi", "Piko", "Nomi"]
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        s = build_system_prompt(p)
        for old in old_names:
            assert old not in s, f"{name} prompt still references old name {old!r}"


def test_rename_consistency_in_dialogues():
    """Verify SFT dialogues use new names not old."""
    import json
    import pathlib
    dlg_dir = pathlib.Path(r"C:\Users\KING\Projects\lumming\src\lummings\dialogue")
    old_names = ["Lumi", "Piko", "Nomi"]
    for jsonl in dlg_dir.glob("*_sft.jsonl"):
        with open(jsonl, encoding="utf-8") as f:
            turns = [json.loads(line) for line in f if line.strip()]
        for turn in turns:
            for msg in turn.get("messages", []):
                content = msg.get("content", "")
                for old in old_names:
                    assert old not in content, (
                        f"{jsonl.name} contains blocked old name {old!r}: {content[:80]}"
                    )


def test_brand_consistency_in_prompts():
    """All 5 personas must mention the Lummings Code by name."""
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        s = build_system_prompt(p)
        assert "LUMMING CODE" in s.upper(), f"{name} prompt doesn't reference the Lummings Code"


def test_each_persona_has_5_lummings_code_rules():
    """The Lummings Code is always 5 rules per persona."""
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        assert "code" in p and len(p["code"]) == 5, \
            f"{name} Lummings Code has {len(p.get('code', []))} rules, expected 5"


def test_each_persona_has_openers_and_avoids():
    """Each persona has openers (greeting variants) + avoids (off-limits words)."""
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        assert "openers" in p and len(p["openers"]) >= 3, \
            f"{name} needs at least 3 openers"
        assert "avoid" in p and len(p["avoid"]) >= 3, \
            f"{name} needs at least 3 avoid-list items"


def test_no_blocked_trademarks_in_any_persona():
    """Verify no persona text contains registered smart-toy competitor trademarks."""
    blocked = ["Furby", "Moxie", "Vector", "Aibo", "Lovot", "Cozmo"]
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        s = build_system_prompt(p)
        for tm in blocked:
            assert tm not in s, f"{name} prompt references registered trademark {tm!r}"


def test_each_persona_has_mood_graph():
    """Each persona has a complete mood graph (every transition target must be a known mood)."""
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        moods = set(p["mood_transitions"].keys())
        for from_mood, targets in p["mood_transitions"].items():
            for to_mood in targets:
                assert to_mood in moods, f"{name}: transition {from_mood!r}->{to_mood!r} target not in mood graph"


def test_each_persona_has_private_language():
    """Each persona has a private language with at least 3 words."""
    for name in ["lumo", "lila", "pip", "nori", "moki"]:
        p = load_persona(name)
        lang = p.get("private_language")
        assert lang is not None, f"{name} has no private_language"
        if isinstance(lang, dict):
            assert "words" in lang and len(lang["words"]) >= 3, \
                f"{name} private_language needs at least 3 words"
        elif isinstance(lang, list):
            assert len(lang) >= 3, f"{name} private_language needs at least 3 words"
