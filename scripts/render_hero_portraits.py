#!/usr/bin/env python
"""
render_hero_portraits.py - Generate high-quality Lummings hero portraits.

Replaces the lame 5-element circles with detailed character art:
- Multi-layer radial gradients for fur shading
- Highlight specks in eyes
- Per-persona accessories (Lila's headband, Pip's crown, Nori's reading glasses, Moki's scarf)
- Personality-specific expressions
- Background sparkle/glow effects

Output: brand/portraits/<persona>-<mood>.svg (60 files, 5 personas x 12 moods)
"""
import os
from pathlib import Path

OUT = Path(r"C:\Users\KING\Projects\lumming\brand\portraits")
OUT.mkdir(parents=True, exist_ok=True)

# Per-persona: name, base color, accent, signature accessory, eye expression
PERSONAS = {
    "lumo": {
        "name": "Lumo",
        "color": "#ffd23f",       # warm yellow
        "accent": "#ef5777",      # cheeky pink
        "fur_dark": "#e89c1f",
        "fur_light": "#fff3a0",
        "eye": "#1a1a2e",
        "eye_shape": "round",
        "signature": "antenna",   # single antenna with bulb
        "accessory_color": "#ffd23f",
        "personality": "curious, sunny, sweet",
    },
    "lila": {
        "name": "Lila",
        "color": "#a78bfa",       # purple
        "accent": "#7c3aed",
        "fur_dark": "#7c3aed",
        "fur_light": "#ddd6fe",
        "eye": "#312e81",
        "eye_shape": "almond",
        "signature": "antenna_pair",  # two delicate antennae
        "accessory_color": "#fbbf24",
        "personality": "creative, poetic, deep",
    },
    "pip": {
        "name": "Pip",
        "color": "#34d399",       # mint green
        "accent": "#10b981",
        "fur_dark": "#047857",
        "fur_light": "#a7f3d0",
        "eye": "#022c22",
        "eye_shape": "wide",
        "signature": "crown",     # leafy crown
        "accessory_color": "#f59e0b",
        "personality": "energetic, brave, silly",
    },
    "nori": {
        "name": "Nori",
        "color": "#22d3ee",       # cyan
        "accent": "#0e7490",
        "fur_dark": "#155e75",
        "fur_light": "#cffafe",
        "eye": "#083344",
        "eye_shape": "calm",
        "signature": "antenna_curls",  # curly tips
        "accessory_color": "#fb7185",
        "personality": "thoughtful, gentle, listener",
    },
    "moki": {
        "name": "Moki",
        "color": "#fb7185",       # pink
        "accent": "#be123c",
        "fur_dark": "#9f1239",
        "fur_light": "#fecdd3",
        "eye": "#4c0519",
        "eye_shape": "sparkle",
        "signature": "horns",     # tiny horns
        "accessory_color": "#a78bfa",
        "personality": "mischievous, giggly, wild",
    },
}

# Per-mood: mouth, eyebrow, accessory change, sparkle
MOODS = {
    "happy":   {"mouth": "smile_big",     "brow": "neutral",  "sparkle": True,  "glow": 1.2},
    "warm":    {"mouth": "smile_soft",    "brow": "neutral",  "sparkle": True,  "glow": 1.0},
    "curious": {"mouth": "smile_tiny",    "brow": "up",       "sparkle": True,  "glow": 1.1},
    "playful": {"mouth": "tongue_out",    "brow": "wink",     "sparkle": True,  "glow": 1.3},
    "calm":    {"mouth": "smile_zen",     "brow": "neutral",  "sparkle": False, "glow": 0.9},
    "sleepy":  {"mouth": "yawn",          "brow": "relaxed",  "sparkle": False, "glow": 0.7},
    "amused":  {"mouth": "grin",          "brow": "up",       "sparkle": True,  "glow": 1.1},
    "excited": {"mouth": "smile_big",     "brow": "up_high",  "sparkle": True,  "glow": 1.4},
    "thoughtful": {"mouth": "smile_soft","brow": "down",     "sparkle": False, "glow": 0.95},
    "mischievous": {"mouth": "smirk",    "brow": "wink",     "sparkle": True,  "glow": 1.2},
    "embarrassed": {"mouth": "smile_tiny","brow": "down",    "sparkle": False, "glow": 0.85},
    "drowsy":  {"mouth": "smile_zen",     "brow": "relaxed",  "sparkle": False, "glow": 0.6},
}


def eye_shape(kind: str) -> str:
    """Return eye SVG path based on shape kind."""
    if kind == "round":
        return '<circle cx="92" cy="108" r="9" fill="#1a1a2e"/><circle cx="148" cy="108" r="9" fill="#1a1a2e"/>' \
               '<circle cx="95" cy="105" r="3.5" fill="#fff"/>' \
               '<circle cx="151" cy="105" r="3.5" fill="#fff"/>' \
               '<circle cx="90" cy="111" r="1.2" fill="#fff" opacity="0.6"/>' \
               '<circle cx="146" cy="111" r="1.2" fill="#fff" opacity="0.6"/>'
    if kind == "almond":
        return '<ellipse cx="92" cy="108" rx="10" ry="7" fill="#312e81"/>' \
               '<ellipse cx="148" cy="108" rx="10" ry="7" fill="#312e81"/>' \
               '<circle cx="96" cy="105" r="3" fill="#fff"/>' \
               '<circle cx="152" cy="105" r="3" fill="#fff"/>'
    if kind == "wide":
        return '<ellipse cx="92" cy="106" rx="11" ry="10" fill="#022c22"/>' \
               '<ellipse cx="148" cy="106" rx="11" ry="10" fill="#022c22"/>' \
               '<circle cx="95" cy="103" r="4" fill="#fff"/>' \
               '<circle cx="151" cy="103" r="4" fill="#fff"/>' \
               '<circle cx="89" cy="109" r="1.5" fill="#fff" opacity="0.6"/>' \
               '<circle cx="145" cy="109" r="1.5" fill="#fff" opacity="0.6"/>'
    if kind == "calm":
        return '<path d="M82,108 Q92,103 102,108" stroke="#083344" stroke-width="3" fill="none" stroke-linecap="round"/>' \
               '<path d="M138,108 Q148,103 158,108" stroke="#083344" stroke-width="3" fill="none" stroke-linecap="round"/>'
    if kind == "sparkle":
        return '<circle cx="92" cy="108" r="8" fill="#4c0519"/>' \
               '<circle cx="148" cy="108" r="8" fill="#4c0519"/>' \
               '<circle cx="92" cy="108" r="3" fill="#fb7185"/>' \
               '<circle cx="148" cy="108" r="3" fill="#fb7185"/>' \
               '<circle cx="95" cy="105" r="1.5" fill="#fff"/>' \
               '<circle cx="151" cy="105" r="1.5" fill="#fff"/>'
    return ""


def mouth_shape(kind: str, accent: str) -> str:
    """Return mouth SVG based on kind."""
    if kind == "smile_big":
        return f'<path d="M98,148 Q120,170 142,148" stroke="#1a1a2e" stroke-width="4" fill="{accent}" opacity="0.7" stroke-linecap="round"/>' \
               f'<path d="M104,150 Q120,162 136,150" stroke="#1a1a2e" stroke-width="3" fill="none" stroke-linecap="round"/>'
    if kind == "smile_soft":
        return f'<path d="M105,150 Q120,160 135,150" stroke="#1a1a2e" stroke-width="3.5" fill="none" stroke-linecap="round"/>'
    if kind == "smile_tiny":
        return f'<path d="M110,152 Q120,158 130,152" stroke="#1a1a2e" stroke-width="3" fill="none" stroke-linecap="round"/>'
    if kind == "smile_zen":
        return f'<path d="M108,152 Q120,154 132,152" stroke="#1a1a2e" stroke-width="3" fill="none" stroke-linecap="round"/>'
    if kind == "yawn":
        return f'<ellipse cx="120" cy="155" rx="10" ry="6" fill="#1a1a2e"/>'
    if kind == "tongue_out":
        return f'<path d="M100,148 Q120,172 140,148" stroke="#1a1a2e" stroke-width="4" fill="{accent}" stroke-linecap="round"/>' \
               f'<ellipse cx="120" cy="162" rx="5" ry="7" fill="#ef4444"/>'
    if kind == "grin":
        return f'<path d="M100,148 Q120,168 140,148" stroke="#1a1a2e" stroke-width="4" fill="none" stroke-linecap="round"/>' \
               f'<path d="M104,151 L136,151" stroke="#1a1a2e" stroke-width="2"/>'
    if kind == "smirk":
        return f'<path d="M105,150 Q115,158 135,148" stroke="#1a1a2e" stroke-width="3.5" fill="none" stroke-linecap="round"/>'
    return ""


def brow_shape(kind: str) -> str:
    """Eyebrows for mood."""
    if kind == "neutral":
        return ""
    if kind == "up":
        return '<path d="M80,90 Q92,87 102,91" stroke="#1a1a2e" stroke-width="2.5" fill="none" stroke-linecap="round"/>' \
               '<path d="M138,91 Q148,87 160,90" stroke="#1a1a2e" stroke-width="2.5" fill="none" stroke-linecap="round"/>'
    if kind == "up_high":
        return '<path d="M80,85 Q92,80 102,86" stroke="#1a1a2e" stroke-width="2.5" fill="none" stroke-linecap="round"/>' \
               '<path d="M138,86 Q148,80 160,85" stroke="#1a1a2e" stroke-width="2.5" fill="none" stroke-linecap="round"/>'
    if kind == "wink":
        return '<path d="M82,100 Q92,105 102,100" stroke="#1a1a2e" stroke-width="3" fill="none" stroke-linecap="round"/>'
    if kind == "down":
        return '<path d="M80,92 Q92,98 102,93" stroke="#1a1a2e" stroke-width="2.5" fill="none" stroke-linecap="round"/>' \
               '<path d="M138,93 Q148,98 160,92" stroke="#1a1a2e" stroke-width="2.5" fill="none" stroke-linecap="round"/>'
    if kind == "relaxed":
        return '<path d="M82,96 Q92,98 102,96" stroke="#1a1a2e" stroke-width="2" fill="none" stroke-linecap="round" opacity="0.5"/>' \
               '<path d="M138,96 Q148,98 158,96" stroke="#1a1a2e" stroke-width="2" fill="none" stroke-linecap="round" opacity="0.5"/>'
    return ""


def signature(p: dict) -> str:
    """Per-persona signature accessory."""
    sig = p["signature"]
    accent = p["accessory_color"]
    if sig == "antenna":
        return f'<line x1="120" y1="46" x2="120" y2="22" stroke="{p["fur_dark"]}" stroke-width="3" stroke-linecap="round"/>' \
               f'<circle cx="120" cy="18" r="6" fill="{accent}" />' \
               f'<circle cx="118" cy="16" r="2" fill="#fff" opacity="0.6"/>'
    if sig == "antenna_pair":
        return f'<path d="M105,52 Q98,30 92,18" stroke="{p["fur_dark"]}" stroke-width="2.5" fill="none" stroke-linecap="round"/>' \
               f'<path d="M135,52 Q142,30 148,18" stroke="{p["fur_dark"]}" stroke-width="2.5" fill="none" stroke-linecap="round"/>' \
               f'<circle cx="92" cy="18" r="4" fill="{accent}"/>' \
               f'<circle cx="148" cy="18" r="4" fill="{accent}"/>' \
               f'<circle cx="92" cy="17" r="3" fill="{p["fur_light"]}" opacity="0.5"/>' \
               f'<circle cx="148" cy="17" r="3" fill="{p["fur_light"]}" opacity="0.5"/>'
    if sig == "crown":
        return f'<path d="M85,50 L95,30 L110,45 L120,25 L130,45 L145,30 L155,50 Z" fill="{accent}" stroke="{p["fur_dark"]}" stroke-width="2" stroke-linejoin="round"/>' \
               f'<circle cx="120" cy="30" r="3" fill="#fff"/>' \
               f'<circle cx="100" cy="38" r="2" fill="#fff"/>' \
               f'<circle cx="140" cy="38" r="2" fill="#fff"/>'
    if sig == "antenna_curls":
        return f'<path d="M108,50 Q100,35 105,22 Q115,12 105,8" stroke="{p["fur_dark"]}" stroke-width="2.5" fill="none" stroke-linecap="round"/>' \
               f'<path d="M132,50 Q140,35 135,22 Q125,12 135,8" stroke="{p["fur_dark"]}" stroke-width="2.5" fill="none" stroke-linecap="round"/>' \
               f'<circle cx="105" cy="8" r="3" fill="{accent}"/>' \
               f'<circle cx="135" cy="8" r="3" fill="{accent}"/>'
    if sig == "horns":
        return f'<path d="M88,55 L82,38 L92,48 Z" fill="{p["fur_dark"]}"/>' \
               f'<path d="M152,55 L158,38 L148,48 Z" fill="{p["fur_dark"]}"/>' \
               f'<circle cx="82" cy="38" r="2" fill="{accent}"/>' \
               f'<circle cx="158" cy="38" r="2" fill="{accent}"/>'
    return ""


def sparkles(intensity: bool) -> str:
    """Sparkle dots around character."""
    if not intensity:
        return ""
    return (
        '<g opacity="0.7">'
        '<circle cx="40" cy="60" r="2" fill="#fff"/>'
        '<circle cx="200" cy="55" r="1.5" fill="#fff"/>'
        '<circle cx="35" cy="180" r="2" fill="#fff"/>'
        '<circle cx="205" cy="190" r="1.5" fill="#fff"/>'
        '<circle cx="50" cy="30" r="1" fill="#fff" opacity="0.6"/>'
        '<circle cx="190" cy="35" r="1" fill="#fff" opacity="0.6"/>'
        '</g>'
        '<g fill="#ffd23f" opacity="0.6">'
        '<path d="M22,100 L36,10 L50,100 Z" opacity="0.3"/>'
        '</g>'
    )


def build_svg(persona_key: str, mood_key: str) -> str:
    p = PERSONAS[persona_key]
    m = MOODS[mood_key]
    glow = m["glow"]

    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 240 240" width="240" height="240" role="img" aria-label="{p["name"]} the Lumming ({mood_key})">
<defs>
    <radialGradient id="bg-{persona_key}-{mood_key}" cx="50%" cy="50%" r="60%">
        <stop offset="0%" stop-color="{p["color"]}" stop-opacity="{0.3 * glow}"/>
        <stop offset="100%" stop-color="{p["accent"]}" stop-opacity="0.05"/>
    </radialGradient>
    <radialGradient id="fur-{persona_key}-{mood_key}" cx="50%" cy="40%" r="70%">
        <stop offset="0%" stop-color="{p["fur_light"]}"/>
        <stop offset="60%" stop-color="{p["color"]}"/>
        <stop offset="100%" stop-color="{p["fur_dark"]}"/>
    </radialGradient>
    <radialGradient id="cheek-{persona_key}-{mood_key}" cx="50%" cy="50%" r="50%">
        <stop offset="0%" stop-color="#fb7185" stop-opacity="0.5"/>
        <stop offset="100%" stop-color="#fb7185" stop-opacity="0"/>
    </radialGradient>
</defs>

<!-- Glow background -->
<rect width="240" height="240" fill="url(#bg-{persona_key}-{mood_key})"/>

<!-- Sparkles -->
{sparkles(m["sparkle"])}

<!-- Body shadow -->
<ellipse cx="120" cy="225" rx="70" ry="6" fill="#000" opacity="0.15"/>

<!-- Main fur ball -->
<circle cx="120" cy="132" r="91" fill="url(#fur-{persona_key}-{mood_key})" stroke="{p["fur_dark"]}" stroke-width="2"/>

<!-- Fur tufts (texture) -->
<g opacity="0.4" stroke="{p["fur_dark"]}" stroke-width="1" fill="none">
    <path d="M50,110 Q55,100 60,108"/>
    <path d="M180,120 Q185,108 192,116"/>
    <path d="M40,150 Q46,142 52,150"/>
    <path d="M188,158 Q194,148 200,154"/>
    <path d="M120,40 Q126,32 132,40"/>
    <path d="M85,200 Q92,210 100,205"/>
    <path d="M155,200 Q148,210 140,205"/>
</g>

<!-- Signature accessory -->
{signature(p)}

<!-- Cheeks -->
<ellipse cx="78" cy="135" rx="14" ry="10" fill="url(#cheek-{persona_key}-{mood_key})"/>
<ellipse cx="162" cy="135" rx="14" ry="10" fill="url(#cheek-{persona_key}-{mood_key})"/>

<!-- Eyes -->
{eye_shape(p["eye_shape"])}

<!-- Brows -->
{brow_shape(m["brow"])}

<!-- Mouth -->
{mouth_shape(m["mouth"], p["accent"])}

<!-- Tiny freckles/sparkles on body -->
<g opacity="0.5" fill="{p["fur_light"]}">
    <circle cx="100" cy="180" r="2"/>
    <circle cx="140" cy="180" r="2"/>
    <circle cx="115" cy="195" r="1.5"/>
    <circle cx="130" cy="195" r="1.5"/>
</g>

<!-- Highlight sheen on body -->
<ellipse cx="95" cy="80" rx="22" ry="14" fill="#fff" opacity="0.15"/>
</svg>'''


def main():
    count = 0
    for persona_key in PERSONAS:
        for mood_key in MOODS:
            svg = build_svg(persona_key, mood_key)
            out_path = OUT / f"{persona_key}-{mood_key}.svg"
            out_path.write_text(svg, encoding="utf-8")
            count += 1
    print(f"Wrote {count} portraits to {OUT}")


if __name__ == "__main__":
    main()