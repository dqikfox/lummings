"""Canon guard: names, Sprout personality and palette must agree across the repo."""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
PALETTE = json.loads((ROOT / "brand/colors/palette.json").read_text(encoding="utf-8"))
CANON = ["SOURCE_OF_TRUTH.md", "BRAND.md", "README.md", "brand/NAME_CANON.md", "brand/CHARACTER_BIBLE.md",
         "brand/BRAND_GUIDELINES.md", "brand/character-development.json", "src/lummings/personas/pip.json",
         "docs/index.html", "site/index.html", "docs/app/app.js", "docs/companion/content.js",
         "docs/marketing/character-codex.html", "docs/PARENT_QUICKSTART.md"]
PALETTE_FILES = ["docs/app/app.js", "docs/companion/content.js", "docs/marketing/character-codex.html",
                 "docs/marketing/heartlight-adventures.html", "brand/BRAND_RULES_ONEPAGER.md", "docs/app/index.html"]


def text(rel):
    return (ROOT / rel).read_text(encoding="utf-8")


def test_sprout_is_the_quiet_garden_sprite_everywhere():
    for rel in CANON:
        body = text(rel)
        assert "Speed Demon" not in body and "SPEED DEMON" not in body, rel
    for rel in ("SOURCE_OF_TRUTH.md", "brand/NAME_CANON.md", "BRAND.md", "brand/CHARACTER_BIBLE.md"):
        assert "Quiet Garden Sprite" in text(rel), rel


def test_sprout_runtime_persona_is_not_the_old_speedrunner():
    persona = json.loads(text("src/lummings/personas/pip.json"))
    blob = json.dumps(persona).lower()
    for old in ("rage-quit", "rage quits", "leaderboard", "three, two, one", "champ", "speedrun"):
        assert old not in blob, old
    assert persona["name"] == "Sprout"
    assert persona["character_identity"]["title"] == "The Quiet Garden Sprite"


def test_retired_names_line_names_the_retired_ones():
    sot = text("SOURCE_OF_TRUTH.md")
    line = next(ln for ln in sot.splitlines() if ln.startswith("**Retired names"))
    assert "Lila" in line and "Pip" in line and "Luna" not in line and "Sprout" not in line


def test_one_palette():
    hexes = {k: v["hex"].lower() for k, v in PALETTE.items() if isinstance(v, dict)}
    assert set(hexes) == {"lumo", "luna", "sprout", "nori", "moki"}
    retired = [h.lower() for h in PALETTE["retired_hexes"]]
    for rel in PALETTE_FILES:
        body = text(rel).lower()
        for h in retired:
            assert h not in body, f"{rel} still uses retired colour {h}"
    for rel in ("docs/app/app.js", "docs/companion/content.js", "docs/marketing/character-codex.html"):
        body = text(rel).lower()
        for name, h in hexes.items():
            assert h in body, f"{rel} is missing {name} {h}"


def test_public_character_names_are_official():
    from lummings.characters import registry
    shown = {c["name"]: c for c in registry(ROOT / "docs")}
    assert set(shown) == {"Lumo", "Luna", "Sprout", "Nori", "Moki"}
    assert shown["Sprout"]["role"] == "The Quiet Garden Sprite"
    assert shown["Sprout"]["color"].lower() == PALETTE["sprout"]["hex"].lower()
    assert shown["Luna"]["color"].lower() == PALETTE["luna"]["hex"].lower()


def test_web_app_sprout_is_the_quiet_garden_sprite():
    # Only Sprout is pinned: that is the owner's decision. The other roles in web/src/lib/crew.ts are
    # still being shaped (for example a brighter Luna), so they are tracked in ROADMAP.md, not enforced here.
    crew = text("web/src/lib/crew.ts")
    assert 'role: "Quiet Garden Sprite"' in crew
    assert "Speed Demon" not in crew



def test_sprout_training_data_teaches_the_quiet_sprout():
    rows = [json.loads(line) for line in text('src/lummings/dialogue/pip_sft.jsonl').splitlines() if line.strip()]
    assert len(rows) == 100
    assert 'Quiet Garden Sprite' in rows[0]['messages'][0]['content']
    old_voice = ('champ', 'rookie', 'bim!', 'bam!', 'highscore', 'gg!', 'speedrun', 'rage')
    for row in rows:
        reply = row['messages'][-1]['content'].lower()
        assert not any(w in reply for w in old_voice), reply
