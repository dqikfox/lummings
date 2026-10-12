# Brand assets

## Character development

The [Little Tomorrow Crew character bible](CHARACTER_BIBLE.md) develops the five existing Lummings into a cast with distinct themes, silhouettes, flaws, rituals and relationships. [Structured creative profiles](character-development.json) support future art briefs; the runtime persona JSON files include the conversational identity.

Open the [visual character preview](../docs/marketing/tomorrow-crew.html) to compare the crew. It uses existing portraits and labels proposed visual designs and theme editions as concepts.

## Wordmark
`wordmark/wordmark.svg` — the canonical "The Lummings" wordmark with the glowing i-dots.

## Portraits
`portraits/<persona>-<mood>.svg` — 5 personas × 16 moods = 80 SVG portraits, synchronised to both website portrait directories.

Renders in any modern browser, including on-device (Pi Zero 2 W + 1.5" TFT).

## Colors
See [BRAND.md](../BRAND.md) §8 for the canonical palette:

| Color | Hex | Use |
|---|---|---|
| Star Yellow | #ffb86c | Primary accent — Lumo's curiosity |
| Dream Teal | #8be9fd | Secondary — calm, presence |
| Future Purple | #bd93f9 | Tertiary — code, mission |
| Warm White | #f8f8f2 | Background |
| Soft Black | #1a1f2e | Text on light |
| Glow Pink | #ff79c6 | Mood transitions |

Per-persona colors are in `src/lummings/sprites.py::PERSONA_COLORS`.

## Regenerate
```bash
python scripts/render_tomorrow_portraits.py
```

## Artwork refresh — 13 October 2026

- [Full artwork gallery](../docs/marketing/artwork-gallery.html): illustrated portraits, crew hero, three lifestyle scenes, app icon and all 80 vector expressions.
- `../marketing/demo-assets/`: the ten campaign PNG masters. Matching web copies live in `../docs/lead-magnet/assets/`.
- `../src/lummings/artwork.py`: shared vector artwork used by the runtime sprite renderer and export script.
- `../scripts/render_tomorrow_portraits.py`: exports 80 portraits to each of the three portrait folders and synchronises both landing pages' embedded character drawings.
- [Generation prompts](artwork-prompts-2026-10-13.json): built-in image generation prompt set and reference.
- `archive/marketing-images-before-2026-10-13.zip`: original campaign PNGs retained for recovery.

The illustrated scenes portray fictional characters and adventures. They are creative campaign illustrations, not photographs of manufactured toys. Theme-edition ideas in the character bible remain concepts.

## Heartlight canon

[Heartlights and growing together](HEARTLIGHTS.md) defines I-lumming-Nate, each special light, safety-first curiosity and the companion friendship journey. [Structured source](heartlights.json) matches the five runtime persona files.
