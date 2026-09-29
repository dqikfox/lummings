# Brand assets

## Wordmark
`wordmark/wordmark.svg` — the canonical "The Lummings" wordmark with the glowing i-dots.

## Portraits
`portraits/<persona>-<mood>.svg` — 5 personas × 12 moods = 60 SVG portraits.

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
python -m lummings.sprites brand/portraits
```
