"""Character direction reaches the actual model prompt without losing guidance."""

import pytest

from lummings.engine import build_system_prompt, load_persona


@pytest.mark.parametrize("name", ["lumo", "lila", "pip", "nori", "moki"])
def test_character_identity_reaches_prompt(name):
    persona = load_persona(name)
    prompt = build_system_prompt(persona)
    identity = persona["character_identity"]
    for key in ("title", "flaw", "quirk", "ritual", "bond", "performance_rule"):
        assert identity[key] in prompt
    assert "LEARNING MODE" in prompt
    for refusal in persona["refuses"]:
        assert refusal in prompt


def test_older_persona_without_identity_still_builds():
    persona = load_persona("lumo")
    del persona["character_identity"]
    assert "Lumo" in build_system_prompt(persona)


@pytest.mark.parametrize("name", ["lumo", "lila", "pip", "nori", "moki"])
def test_heartlight_and_shared_growth_guidance_reach_model(name):
    persona = load_persona(name)
    prompt = build_system_prompt(persona, "preference: dinosaurs")
    for value in persona["guiding_light"].values():
        assert value in prompt
    for rule in persona["companion_principles"]:
        assert rule in prompt
    assert "I-lumming-Nate" in prompt
    assert "safety first, always" in prompt
    assert "preference: dinosaurs" in prompt


@pytest.mark.parametrize("new,old,label", [("lila", "lila", "Lila"), ("pip", "pip", "Pip")])
def test_public_rename_preserves_persona_and_memory(new, old, label, tmp_path):
    from lummings.engine import Memory
    from lummings.sprites import render
    assert load_persona(new) == load_persona(old)
    assert load_persona(new)["name"] == label
    original = Memory(tmp_path / "rename.sqlite", old, owner="test")
    original.add_fact("preference: dinosaurs")
    renamed = Memory(tmp_path / "rename.sqlite", new, owner="test")
    assert renamed.recall_facts()[0]["fact"] == "preference: dinosaurs"
    assert label in render(new)
    original.conn.close()
    renamed.conn.close()
