# Lummings — Source of Truth

**This file is the single source of truth.**  
If anything else contradicts it, this file wins. Update this file first when names, looks, or rules change, then update every other document that references them.

**Last locked:** 19 October 2026  
**Status:** Production-ready. Do not regress.

---

## 1. Official names (locked)

**Lumo · Luna · Sprout · Nori · Moki**

| Official name | Role | Heartlight | Colour | Signature prop |
|---------------|------|------------|--------|----------------|
| **Lumo** | Hyperfixation Gremlin / Player one | Questlight | Ruby red | Crystal controller, rune hoodie |
| **Luna** | Spooky Poet | Dreamlight | Lilac | Ribbon scarf + comet pencil |
| **Sprout** | Speed Demon | Traillight | Green | Leaf ears, compass, big boots |
| **Nori** | Cosmic Weirdo | Tidelight | Blue | Crescent hood, lantern |
| **Moki** | Chaos Gremlin | Sparklight | Pink | Checker scarf, zigzag ear |

**Retired names (do not use in public or new work):** Luna, Sprout.

Internal code and some legacy filenames still use `lila` / `pip` as IDs. That is a compatibility mapping only. Public-facing text, marketing, and new docs must use Luna and Sprout.

---

## 2. Canonical art (locked — do not generate new character images)

Use **only** these production portraits (repo root):

| Character | File | Notes |
|-----------|------|-------|
| Lumo | `lumo-portrait.png` | Locked |
| Luna | `lila-portrait.png` | File name is legacy; this is Luna |
| Sprout | `pip-portrait.png` | File name is legacy; this is Sprout |
| Nori | `nori-portrait.png` | Locked |
| Moki | `moki-portrait.png` | Locked |
| Crew | `hero-screenshot.png` | Locked lineup |

Copies in `marketing/demo-assets/` and `app/assets/images/crew/` are the same looks.

**Rules:**
- Do not generate new character portraits with any model.
- Do not use older concept art, yellow Lumo, or any file that does not match the above.
- New supporting assets (expressions, scenes, icons) must match these silhouettes, colours, and props exactly.
- See `brand/VISUAL_LOCK.md` for the full visual rule set.

---

## 3. Supporting locked documents

| File | Purpose |
|------|---------|
| `brand/VISUAL_LOCK.md` | Hard ban on new character generations + file list |
| `brand/NAME_CANON.md` | Name lock |
| `brand/CHARACTER_BIBLE.md` | Full character bios |
| `brand/BRAND_GUIDELINES.md` | Master brand rules |
| `brand/BRAND_RULES_ONEPAGER.md` | One-page pin |
| `brand/HEARTLIGHTS.md` | Heartlight = essence, not a creature |

---

## 4. What every agent / contributor must do

1. Read this file before touching characters, names, or art.
2. If a name changes, search the entire repo for the old name and update every public document.
3. Never introduce a new character image without explicit approval and a replacement of one of the canonical files above.
4. Prefer existing SVGs in `docs/portraits/` and `app/assets/images/portraits/` for expressions.

---

**End of source of truth.**  
When in doubt: Lumo · Luna · Sprout · Nori · Moki. Use the locked portraits. Do not generate.
