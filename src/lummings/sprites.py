"""Lummings sprite renderer — generates a SVG portrait for any (persona, mood).

Renders a rounded body + face with the persona's signature glow color.
Used for: device UI (1.5" TFT), marketing site, print collateral.
"""

from __future__ import annotations

import math
from dataclasses import dataclass


# ----------------------------------------------------------------------------
# Persona color palette (from BRAND.md §8)
# ----------------------------------------------------------------------------

PERSONA_COLORS = {
    "lumo": {"body": "#ed4054", "glow": "#ff697a", "eye": "#1a1f2e", "mouth": "#1a1f2e"},
    "lumi": {"body": "#bd93f9", "glow": "#a07bd6", "eye": "#1a1f2e", "mouth": "#1a1f2e"},
    "piko": {"body": "#50fa7b", "glow": "#3ddc66", "eye": "#1a1f2e", "mouth": "#1a1f2e"},
    "nomi": {"body": "#8be9fd", "glow": "#67c7d9", "eye": "#1a1f2e", "mouth": "#1a1f2e"},
    "moki": {"body": "#ff79c6", "glow": "#e35fa8", "eye": "#1a1f2e", "mouth": "#1a1f2e"},
}

# Canonical names retain compatibility with the original device aliases.
PERSONA_COLORS.update({"lila": PERSONA_COLORS["lumi"], "pip": PERSONA_COLORS["piko"], "nori": PERSONA_COLORS["nomi"]})


# ----------------------------------------------------------------------------
# Eye + mouth shapes per mood
# ----------------------------------------------------------------------------

EYE_SHAPES = {
    "curious":  {"type": "circle", "r": 9, "pupil_offset": (1.5, -1.5), "highlight": True},
    "excited":  {"type": "circle", "r": 9, "pupil_offset": (1.5, -1.5), "highlight": True, "sparkle": True},
    "playful":  {"type": "circle", "r": 9, "pupil_offset": (2, -2), "highlight": True, "wink": True},
    "calm":     {"type": "arc-up", "r": 9, "wider": True},
    "drowsy":   {"type": "arc-down", "r": 9},
    "tired":    {"type": "arc-down", "r": 8, "smaller": True},
    "watchful": {"type": "circle", "r": 8, "pupil_offset": (2, 0)},
    "embarrassed": {"type": "circle", "r": 8, "pupil_offset": (0, 2)},
    "distant":  {"type": "circle", "r": 8, "pupil_offset": (-2, 0)},
    "warm":     {"type": "circle", "r": 9, "pupil_offset": (0, -1), "highlight": True},
    "cryptic":  {"type": "circle", "r": 9, "pupil_offset": (2, 0)},
    "amused":   {"type": "arc-up", "r": 9, "wider": True},
}

MOUTH_SHAPES = {
    "curious":  "wide-smile",
    "excited":  "wide-smile",
    "playful":  "smirk",
    "calm":     "small-smile",
    "drowsy":   "small-O",
    "tired":    "frown",
    "watchful": "flat",
    "embarrassed": "zigzag",
    "distant":  "flat",
    "warm":     "wide-smile",
    "cryptic":  "smirk",
    "amused":   "wide-smile",
}


@dataclass
class Sprite:
    persona: str
    mood: str = "curious"
    size: int = 240
    blink: bool = False
    glow: bool = True

    def to_svg(self) -> str:
        from .artwork import MOODS, render as render_artwork
        aliases = {"lumi": "lila", "piko": "pip", "nomi": "nori", "luna": "lila", "sprout": "pip"}
        name = aliases.get(self.persona, self.persona)
        if name not in ("lumo", "lila", "pip", "nori", "moki"):
            self.persona = name = "lumo"
        if self.mood not in MOODS:
            self.mood = "curious"
        svg = render_artwork(name, self.mood, blink=self.blink, glow=self.glow)
        svg = svg.replace('<svg ', f'<svg data-persona="{self.persona}" ', 1)
        svg = svg.replace('width="240" height="240"', f'width="{self.size}" height="{self.size}"')
        if self.persona in aliases:
            svg = svg.replace(f'aria-label="{name.title()}', f'aria-label="{self.persona} / {name.title()}')
        return svg

    def _eyes(self, x_offset, y, c) -> str:
        cx = self.size // 2  # body center x
        shape = EYE_SHAPES[self.mood]
        size_factor = 0.6 if shape.get("smaller") else 1.0
        r = int(shape["r"] * size_factor)
        # arc eyes — paths use absolute coords (cx already factored in)
        if shape["type"] == "arc-up":
            wider = 1.4 if shape.get("wider") else 1.0
            rx = int(r * wider)
            return (
                f'<path d="M{cx-x_offset-rx},{y} Q{cx-x_offset},{y-r*1.2} {cx-x_offset+rx},{y}" '
                f'stroke="{c["eye"]}" stroke-width="2.5" fill="none" stroke-linecap="round"/>'
                f'<path d="M{cx+x_offset-rx},{y} Q{cx+x_offset},{y-r*1.2} {cx+x_offset+rx},{y}" '
                f'stroke="{c["eye"]}" stroke-width="2.5" fill="none" stroke-linecap="round"/>'
            )
        if shape["type"] == "arc-down":
            return (
                f'<path d="M{cx-x_offset-r},{y} Q{cx-x_offset},{y+r*0.8} {cx-x_offset+r},{y}" '
                f'stroke="{c["eye"]}" stroke-width="2.5" fill="none" stroke-linecap="round"/>'
                f'<path d="M{cx+x_offset-r},{y} Q{cx+x_offset},{y+r*0.8} {cx+x_offset+r},{y}" '
                f'stroke="{c["eye"]}" stroke-width="2.5" fill="none" stroke-linecap="round"/>'
            )
        # circle eyes — absolute coords (cx + offset)
        highlight = ""
        if shape.get("highlight"):
            highlight = (
                f'<circle cx="{cx-x_offset-1}" cy="{y-2}" r="1.4" fill="#fff"/>'
                f'<circle cx="{cx+x_offset-1}" cy="{y-2}" r="1.4" fill="#fff"/>'
            )
        sparkle = ""
        if shape.get("sparkle"):
            sparkle = (
                f'<g transform="translate({cx+x_offset+int(r*0.7)},{y-int(r*1.2)})" fill="#ffb86c">'
                f'<path d="M0,-3 L1,-1 L3,0 L1,1 L0,3 L-1,1 L-3,0 L-1,-1 Z"/></g>'
            )
        # pupil offset
        dx, dy = shape.get("pupil_offset", (0, 0))
        return (
            f'<circle cx="{cx-x_offset+dx}" cy="{y+dy}" r="{r}" fill="{c["eye"]}"/>'
            f'<circle cx="{cx+x_offset+dx}" cy="{y+dy}" r="{r}" fill="{c["eye"]}"/>'
            f'{highlight}{sparkle}'
        )

    def _mouth(self, cx, y, c) -> str:
        shape = MOUTH_SHAPES.get(self.mood, "neutral")
        stroke = c["mouth"]
        sw = 3.5
        if shape == "wide-smile":
            return (
                f'<path d="M{cx-16},{y} Q{cx},{y+14} {cx+16},{y}" '
                f'stroke="{stroke}" stroke-width="{sw}" fill="none" stroke-linecap="round"/>'
            )
        if shape == "small-smile":
            return (
                f'<path d="M{cx-10},{y} Q{cx},{y+6} {cx+10},{y}" '
                f'stroke="{stroke}" stroke-width="{sw}" fill="none" stroke-linecap="round"/>'
            )
        if shape == "small-O":
            return (
                f'<ellipse cx="{cx}" cy="{y}" rx="4" ry="5" fill="{stroke}"/>'
            )
        if shape == "smirk":
            return (
                f'<path d="M{cx-10},{y} Q{cx},{y+7} {cx+14},{y-2}" '
                f'stroke="{stroke}" stroke-width="{sw}" fill="none" stroke-linecap="round"/>'
            )
        if shape == "frown":
            return (
                f'<path d="M{cx-12},{y} Q{cx},{y-9} {cx+12},{y}" '
                f'stroke="{stroke}" stroke-width="{sw}" fill="none" stroke-linecap="round"/>'
            )
        if shape == "zigzag":
            return (
                f'<path d="M{cx-10},{y-3} L{cx-5},{y+3} L{cx},{y-3} L{cx+5},{y+3} L{cx+10},{y-3}" '
                f'stroke="{stroke}" stroke-width="{sw}" fill="none" stroke-linecap="round" stroke-linejoin="round"/>'
            )
        # neutral / flat
        return (
            f'<path d="M{cx-10},{y} L{cx+10},{y}" '
            f'stroke="{stroke}" stroke-width="{sw}" stroke-linecap="round"/>'
        )


def render(persona: str, mood: str = "curious", size: int = 240) -> str:
    """Convenience: return SVG string for (persona, mood)."""
    return Sprite(persona=persona, mood=mood, size=size).to_svg()


def render_all(out_dir: str) -> list:
    """Render a grid of all personas × moods. Returns list of (persona, mood, path)."""
    import os
    from pathlib import Path
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    paths = []
    for persona in PERSONA_COLORS:
        for mood in EYE_SHAPES:
            svg = render(persona, mood, size=240)
            p = out / f"{persona}-{mood}.svg"
            p.write_text(svg, encoding="utf-8")
            paths.append((persona, mood, str(p)))
    return paths


if __name__ == "__main__":
    import sys
    out = sys.argv[1] if len(sys.argv) > 1 else "brand/portraits"
    paths = render_all(out)
    print(f"Rendered {len(paths)} sprites to {out}")
