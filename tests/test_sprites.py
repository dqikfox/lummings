"""Tests for the Lummings sprite renderer."""

from lummings.sprites import Sprite, render, render_all, PERSONA_COLORS, EYE_SHAPES


def test_all_personas_have_colors():
    for name in ["lumo", "lumi", "piko", "nomi", "moki"]:
        assert name in PERSONA_COLORS
        c = PERSONA_COLORS[name]
        for key in ("body", "glow", "eye", "mouth"):
            assert key in c
            assert c[key].startswith("#")


def test_sprite_renders_for_each_persona():
    for persona in PERSONA_COLORS:
        s = Sprite(persona=persona, mood="curious", size=240)
        svg = s.to_svg()
        assert svg.startswith("<svg")
        assert svg.endswith("</svg>")
        assert persona in svg


def test_sprite_renders_for_each_mood():
    for persona in ["lumo"]:
        for mood in EYE_SHAPES:
            svg = render(persona, mood, size=120)
            assert "<svg" in svg
            assert mood in svg or "arc" in svg.lower()


def test_invalid_persona_falls_back():
    s = Sprite(persona="nonexistent", mood="curious")
    # Should not crash; falls back to lumo
    svg = s.to_svg()
    assert svg.startswith("<svg")


def test_invalid_mood_falls_back_to_curious():
    s = Sprite(persona="lumo", mood="nonsensemood")
    svg = s.to_svg()
    # The mood should be normalized to "curious"
    assert "( o_o )?" in svg or "circle" in svg


def test_svg_is_valid_xml():
    """Sanity check: parse the output to confirm it's well-formed."""
    import xml.etree.ElementTree as ET
    svg = render("lumo", "excited", size=200)
    root = ET.fromstring(svg)
    assert root.tag.endswith("svg")


def test_render_all_creates_files(tmp_path):
    paths = render_all(str(tmp_path))
    assert len(paths) == len(PERSONA_COLORS) * len(EYE_SHAPES)
    for persona, mood, path in paths[:5]:
        from pathlib import Path
        assert Path(path).exists()
        assert Path(path).stat().st_size > 200  # non-trivial SVG
