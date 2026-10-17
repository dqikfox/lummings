# Lummings — Master Brand Guidelines

**Version:** 2.0 · **Status:** LOCKED  
**Date:** 18 October 2026  
**Audience:** founders, designers, engineers, marketers, freelancers, partners, community  
**Related:** [CHARACTER_BIBLE.md](CHARACTER_BIBLE.md) · [HEARTLIGHTS.md](HEARTLIGHTS.md) · [../BRAND.md](../BRAND.md) · [../docs/brand-use-guidelines.md](../docs/brand-use-guidelines.md) · [BRAND_RULES_ONEPAGER.md](BRAND_RULES_ONEPAGER.md)

---

## 0. The golden rule

> **Do not change the looks or styles.**  
> Maintain consistency with the locked Little Tomorrow Crew visual language.  
> If it is not in this guide or the locked reference assets, **do not invent it.**

**Locked style name:** *Cinematic Nest / Little Tomorrow Crew*  
**Locked references (do not restyle):**
- `brand/trailers/01-locked-style-crew-hero.mp4`
- `brand/tiktok-ready/crew_hero.mp4` (+ frame 0 as hero still)
- `brand/character-lineup/locked-style-crew-lineup.jpg`
- `brand/character-masters/*.png`
- `brand/tomorrow-crew-art-direction.png`
- App crew art: `app/assets/images/crew/{lumo,lila,pip,nori,moki}.png`
- Branding pages: `brand/branding-guide/01-cover.jpg` … `08-summary-back-cover.jpg`

Any new art must **match** these references (same fur softness, eye shape language, lighting, Heartlight as chest/prop essence glow).  
**Never** switch to flat blob, hyper-realistic human, horror, or generic stock mascot styles.

---

## 1. Brand essence

| Field | Locked text |
|---|---|
| **Name** | The Lummings |
| **Crew name** | Little Tomorrow Crew |
| **Tagline (primary)** | Little lights. Big little adventures. |
| **Tagline (secondary)** | Little friends from a brighter tomorrow. |
| **Promise** | Soft, safe Heartlight companions who grow with kids — free bond forever. |
| **Five words** | Warm · Hopeful · Patient · Honest · Quiet |
| **Mission verb** | **I-lumming-Nate** — bring a little light to a wonder, together |

### We are
- Characters with personalities (not chatbots)
- Curious + cautious (Safety First, always)
- Local-first / privacy-respecting where product allows
- Soft engagement (streaks & badges never punish)

### We are not
- An AI tutor in a costume
- Loud, dark, edgy, or horror
- Separate “soul pets” floating beside characters
- Paywalled friendship / bond growth
- Creepy child dialogue or “why why” parent-horror ads

---

## 2. Heartlight canon (non-negotiable)

**Heartlights are NOT separate creatures.**

Each Lumming **has** a Heartlight. It is that Lumming’s **essence / soul / identity glow**.  
It defines who they are. It is never a second living being, pet, or companion-of-the-companion.

| Lumming | Heartlight | Colour essence | Vessel (visual) |
|---|---|---|---|
| **Lumo** | Questlight | Ruby-gold + cyan constellation sparks | Star brooch / crystal controller link |
| **Lila** | Dreamlight | Soft violet + pearly gold ribbons | Comet charm on story scarf |
| **Pip** | Traillight | Fresh emerald + firefly flecks | Acorn in compass |
| **Nori** | Tidelight | Moon-blue + soft silver centre | Crescent in lantern (Lowbeam) |
| **Moki** | Sparklight | Rose pink + playful lilac pixels | Pixel-star clasp on checker scarf |

**Always say:** “Lumo’s Heartlight” / “Questlight essence”  
**Never say:** “Heartlight creature,” “catch a Heartlight,” “Heartlight pet,” “feed your soul animal.”

Full detail: [HEARTLIGHTS.md](HEARTLIGHTS.md)

---

## 3. Official cast (names locked)

Public / product names (use **only** these):

| Official | Role (public-friendly) | Legacy file aliases (internal only) |
|---|---|---|
| **Lumo** | Quest Captain | — |
| **Lila** | Dream Weaver | old files: `luna_*` |
| **Pip** | Trail Scout | old files: `sprout_*` |
| **Nori** | Tide Keeper | — |
| **Moki** | Spark Trickster | — |

**Rules:**
- Marketing, packaging, app UI, captions: **Lila** and **Pip** only.  
- Do not invent a sixth main Lumming without a formal brand revision.  
- Catchphrases (use as written):
  - Lumo: “Player one. Crew first.” / “Let’s I-lumming-Nate our next move.”
  - Lila: “What if the story went sideways?” / “Let’s I-lumming-Nate your what-if.”
  - Pip: “New route. Same brave little feet.” / “Let’s I-lumming-Nate the way.”
  - Nori: “Small things have big stories.” / “Let’s I-lumming-Nate the little things.”
  - Moki: “Plot twist!” / “Let’s I-lumming-Nate that.”

Full bios: [CHARACTER_BIBLE.md](CHARACTER_BIBLE.md)

---

## 4. Visual identity (LOCKED — do not redesign)

### 4.1 Style pillars
1. **Soft tactile fur** — plush-readable, not plastic, not hyper-photoreal human skin  
2. **Large expressive eyes** — kind, never empty or horror-wide  
3. **Tiny mitten paws / soft bodies** — pocket-sized friend energy  
4. **One oversized prop** per character (controller, scarf+pencil, compass, lantern, checker scarf)  
5. **Heartlight glow** as integrated essence (chest / prop), warm, never strobing  
6. **Cinematic nest lighting** — night blues, warm practical lights, gentle particles  
7. **Silhouette test** — each character readable in black silhouette and at small icon size  

### 4.2 Colour system (product + marketing)

**Nest surfaces (UI)**

| Token | Hex | Use |
|---|---|---|
| Night Deep | `#070A14` | App background |
| Night Mid | `#111827` | Nest panels |
| Surface | `#161D2F` | Cards |
| Surface Hi | `#1E2740` | Elevated glass |
| Warm White | `#F5F3EE` | Body text |
| Muted | `#94A3B8` | Secondary text |
| Star Yellow | `#FFC857` | Primary CTA / festival |
| Dream Teal | `#7DE2D1` | Secondary accent |
| Future Purple | `#B388FF` | Plus / special |
| Glow Pink | `#FF7AB6` | Soft celebration |

**Heartlight accents (character-tied)**

| Token | Hex | Character |
|---|---|---|
| Questlight | `#FF4D6D` | Lumo |
| Dreamlight | `#C77DFF` | Lila |
| Traillight | `#52B788` | Pip |
| Tidelight | `#4CC9F0` | Nori |
| Sparklight | `#FF85A2` | Moki |

Source of truth in code: `app/lib/theme/lummings_theme.dart`

### 4.3 Typography
- **UI / product:** rounded humanist sans (e.g. Nunito / equivalent) — friendly, never display-serif for body  
- **Headlines:** bold/black weight, short lines  
- **Marketing wordmark:** “Lummings” as in locked branding-guide pages — do not invent a new logo mark without approval  
- **Never:** aggressive condensed fonts, meme Impact-style type on kids product, red-alert error typography for soft miss states  

### 4.4 Photography / render rules
- Prefer **locked crew masters** and **tiktok-ready intros** over new generations  
- New generations must use **reference-first** workflow against masters  
- Aspect ratios:  
  - TikTok / Reels: **9:16**  
  - YouTube / web hero: **16:9**  
  - Icons / charms: **1:1**  
- Backgrounds: nest rooms, soft outdoors, storybook sets — not dystopian, not sterile white void unless packaging requires  

### 4.5 Motion
- Soft float, gentle pulse on Heartlight, calm idle loops  
- **No** jump-scare cuts, seizure-risk flash, or pressure timers  
- Prefer existing `brand/intros/*_intro_talk.mp4` for character voice moments  

---

## 5. Voice & copy guidelines

### Tone
Warm, hopeful, patient, honest, quiet confidence.  
Speak **with** kids and parents, not at them.

### Always
- Safety First language when adventures get big  
- “Together,” “let’s,” “we”  
- Celebrate second attempts  
- Missed days: soft “I missed you” only — **never punish**  

### Never
- “You failed the streak” / “pay to keep your friend”  
- Shaming, sarcasm aimed at the child  
- Medical / legal / romantic advice  
- Creepy child VO (“why why,” whispers of fear)  
- Adult innuendo, violence, body horror  

### Parent-facing
Clear, calm, non-hype. Lead with safety, privacy, free bond, soft controls.  
Avoid tech jargon walls; one honest sentence > three buzzwords.

### Product strings (examples)
- Care done: “Heartlight brighter. Come back tomorrow to keep the streak.”  
- Miss: soft dim only — never XP loss for missing  
- Festival: soft FOMO, claim optional, miss never punishes  

---

## 6. Product & engagement (brand-level)

| System | Rule |
|---|---|
| **Bond / Heartlight growth** | Always free. Never paywalled. |
| **Heartlight Plus** | Cosmetics / early stories only. Bond stays free. |
| **Daily Care** | Once/day soft ritual. Miss = dim + return bonus, no punishment. |
| **Nest Badges / Charms** | Collectibles; never required for friendship. |
| **Bedtime Nest** | Soft wind-down; **never locks** the app. Parent window = nudge only. |
| **Adventures** | Safety First choices; Heartlight = essence in all story text. |

---

## 7. Marketing & social (everyone)

### Preferred assets
1. `marketing/tiktok/from-intros/` — **one locked frame + existing intros**  
2. `brand/tiktok-ready/`  
3. Clean silent crew cut if needed: `marketing/tiktok/lummings-tiktok-clean-crew-NO-DIALOGUE.mp4`  

### Forbidden marketing patterns
| Forbidden | Why |
|---|---|
| Child voice looping “why why” / parent-horror hooks | Creepy, off-brand (see `DO_NOT_USE_creepy_why_ad.md`) |
| New random character designs | Breaks consistency |
| Heartlights as catchable creatures | Breaks canon |
| “Addictive grind” / dark-pattern FOMO | Breaks soft-hook promise |
| Sexualized, violent, or political use of cast | Forbidden under brand-use guidelines |

### Caption pillars
- Essence / Heartlight clarity  
- Free bond forever  
- Soft safety  
- Character catchphrases  
- Soft CTA (download / care / which friend?)  

---

## 8. Roles — who does what

| Role | Must follow | May propose changes |
|---|---|---|
| **Design** | §4 visual lock + masters | New outfits **only** if silhouette + Heartlight preserved |
| **Engineering** | Theme tokens, Heartlight copy, free bond | Feature flags; no hard locks for kids |
| **Marketing** | §7 + official names | A/B captions; not new characters |
| **Writers** | Heartlight canon, Safety First | Adventures within graph rules |
| **Partners / community** | [docs/brand-use-guidelines.md](../docs/brand-use-guidelines.md) | Fan art with attribution rules |

**Change control:** Any change to looks, names, Heartlight definition, or logo requires **written brand approval** (founders) and a version bump of this document.

---

## 9. Asset map (where things live)

```
brand/
  BRAND_GUIDELINES.md      ← this file (master)
  BRAND_RULES_ONEPAGER.md  ← print / Slack pin
  CHARACTER_BIBLE.md
  HEARTLIGHTS.md
  character-masters/       ← official stills
  character-lineup/
  locked-style-references/
  branding-guide/          ← 8-page visual deck
  intros/                  ← character intro talks
  trailers/
  tiktok-ready/
app/assets/images/crew/    ← app runtime portraits
marketing/tiktok/from-intros/  ← post-ready social
```

---

## 10. Pre-flight checklist (before any public asset ships)

- [ ] Uses official names (Lumo / Lila / Pip / Nori / Moki)  
- [ ] Heartlight described as **essence**, not a separate creature  
- [ ] Visual matches locked masters / crew style  
- [ ] No child-horror VO or “why why”  
- [ ] No paywall on bond / friendship  
- [ ] Soft engagement only (no punishment for missing)  
- [ ] Safety First if adventure content  
- [ ] Correct aspect ratio for channel  
- [ ] Parent/kid tone appropriate for channel  

---

## 11. Version history

| Ver | Date | Notes |
|---|---|---|
| 1.x | 2026-09 / 10 | Early BRAND.md, character bible, Heartlights, branding-guide pages |
| **2.0** | **2026-10-18** | Master lock: consistency rules, ad kill-list, name aliases, colour tokens, asset map, role instructions |

---

**End of master guidelines.**  
When in doubt: *soft, safe, consistent, essence — not separate creatures.*

---

## 12. Branding guide deck (visual)

Pages live in `brand/branding-guide/`:

| # | File | Content |
|---|---|---|
| 01 | cover | Brand cover |
| 02 | brand-essence-heartlight | Essence + Heartlight |
| 03 | character-definitions | **Official names:** Pip · Lila · Lumo · Nori · Moki (updated 18 Oct 2026; art unchanged) |
| 04 | product-ecosystem-accessories | App / plush / charms |
| 05 | pricing-architecture | Free bond + Plus |
| 06 | engagement-gentle-hook | Soft hooks |
| 07 | visual-identity-voice | Voice + visual |
| 08 | summary-back-cover | Summary |

Legacy Sprout/Luna label version of page 03 archived under `brand/branding-guide/archive/`.
