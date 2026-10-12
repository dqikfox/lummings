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
