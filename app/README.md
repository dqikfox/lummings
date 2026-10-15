# Lummings Flutter App

Companion app for the **Little Tomorrow Crew** — Heartlight essence, Care rituals, Charms, Adventures, offline Talk, Parent safety.

## Features (Phase 0)

| Area | Status |
|------|--------|
| Onboarding + parent PIN | ✅ |
| Heartlight Nest (Home) | ✅ |
| Daily Care (hug / talk / story) | ✅ |
| Soft miss hook (no punishment) | ✅ |
| Adventures (2 packs) | ✅ Night Forest · Kind Mix-Up |
| Collection & Charm shop (shards) | ✅ |
| Offline Talk (moderated chips) | ✅ |
| Parent dashboard + memories | ✅ |
| Live voice LLM Talk | Phase 1.1 |
| NFC plush sync | Phase 1.1 |

## Run

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run
```

Logic tests without Flutter:

```bash
python3 test/logic_feature_test.py
python3 test/adventure_graph_check.py
```

## Architecture

- `lib/state/heartlight_controller.dart` — bond XP, care, charms, talk rewards
- `lib/state/adventure_controller.dart` — branching story engine
- `lib/models/` — Lumming, Heartlight phase, Charm, Adventure
- `lib/data/talk_replies.dart` — offline Safety-First replies per persona
- `assets/adventures/*.json` — story packs

**Canon:** Heartlights are each Lumming's essence/soul — never separate creatures.
