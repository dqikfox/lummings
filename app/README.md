# Lummings App (Flutter)

> Little lights. Big little adventures. Lifelong bonds.

Mobile companion for the Little Tomorrow Crew — **Lumo, Lila, Pip, Nori, Moki**.  
Each Lumming carries a **Heartlight** (essence/soul, not a separate creature).

## Quick start

```bash
cd app
flutter pub get
flutter run
```

## What's in v0.1 scaffold

| Area | Status |
|------|--------|
| Bottom nav (Home / Adventures / Collection / Care / Parent) | ✅ |
| Heartlight state machine (dimmed → caring → glowing + bond XP) | ✅ |
| Daily Care Ritual | ✅ |
| Growing Together adventure engine + first story pack | ✅ |
| Parent PIN gate (local) | ✅ shell |
| Talk mode UI | ✅ shell |
| Onboarding flow | ✅ shell |
| NFC/BLE plush | 🔜 Phase 1.1 |
| Cloud LLM + moderation | 🔜 Phase 1.1 |

## Design canon

- Heartlights = essence, never separate creatures  
- Safety First · I-lumming-Nate · Growing Together  
- Locked visual style: cinematic fluffy crew  
- See `../docs/app/APP_DESIGN.md` and `../brand/HEARTLIGHTS.md`

## Adventure content

Stories live in `assets/adventures/*.json`.  
First pack: **The Night Forest Awakens** (`growing_together_001.json`).

## Project layout

```
lib/
  main.dart
  app.dart
  theme/lummings_theme.dart
  models/          # Lumming, Heartlight, Bond, Adventure
  state/           # HeartlightController, AdventureController, ParentController
  screens/         # Home, Care, Adventures, Collection, Parent, Talk, Onboarding
  widgets/         # HeartlightBar, LummingAvatar, CareButton, ...
  data/            # seed personas
assets/adventures/ # JSON story packs
```
