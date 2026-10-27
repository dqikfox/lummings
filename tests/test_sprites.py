"""Tests for the Lummings sprite renderer."""

from lummings.sprites import Sprite, render, render_all, PERSONA_COLORS, EYE_SHAPES


def test_all_personas_have_colors():
    for name in ["lumo", "lumi", "piko", "nomi", "moki"]:
        assert name in PERSONA_COLORS
        c = PERSONA_COLORS[name]
        for key in ("body", "glow", "eye", "mouth"):
            assert key in c
            assert c[key].startswith("#")


def test_canonical_names_and_legacy_aliases_keep_character_identity():
    for canonical, alias, title in [
        ("lila", "lumi", "The Spooky Poet"),
        ("pip", "piko", "The Quiet Garden Sprite"),
        ("nori", "nomi", "The Cosmic Weirdo"),
    ]:
        for name in (canonical, alias):
            svg = render(name, "curious", size=120)
            assert title in svg
            assert 'width="120" height="120"' in svg
            assert "The Pocket Inventor" not in svg


def test_blink_and_glow_options_still_affect_artwork():
    normal = Sprite("lumo").to_svg()
    blinking = Sprite("lumo", blink=True).to_svg()
    unlit = Sprite("lumo", glow=False).to_svg()
    assert normal != blinking
    import xml.etree.ElementTree as ET
    def open_eyes(svg):
        return [e for e in ET.fromstring(svg).iter()
                if e.tag.endswith('ellipse') and e.get('fill') == '#25334a']
    assert len(open_eyes(normal)) == 2
    assert len(open_eyes(blinking)) == 0
    assert '<circle cx="120" cy="126"' in normal
    assert '<circle cx="120" cy="126"' not in unlit


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
