# Lummings App — Pre-device Test Report

**Date:** 2026-10-16  
**Environment:** Grok sandbox (Flutter 3.24.5) + pure-Python logic mirror

## Executive verdict

**GREEN for device practice.** Core features work in code.

| Layer | Result |
|-------|--------|
| `flutter analyze` | **No issues found** |
| Dart feature suite | **18/18 PASS** |
| Widget smoke (onboarding, shell, HeartlightBar) | **4/4 PASS** |
| Widget unit (crew, PIN, care) | **3/3 PASS** |
| Bond XP unit | **1/1 PASS** |
| Python logic mirror | **66/66 PASS** |
| Adventure graph | **10 nodes, 28 paths, OK** |

## Features verified

| Feature | How verified |
|---------|----------------|
| Onboarding → pick friend → parent PIN → Home | Widget smoke |
| 5-tab shell (Home / Adventures / Collection / Care / Parent) | Widget smoke |
| HeartlightBar + LummingAvatar | Widget smoke |
| Crew canon (Lumo, Lila, Pip, Nori, Moki + 5 Heartlights) | Feature suite |
| Care ritual (hug 20 XP, story 25 XP, once/day) | Feature suite |
| Soft miss (+15 return, streak=1, no punishment) | Feature suite |
| Bond level-up / radiant / leveledUp | Feature suite + Care fix |
| Parent PIN gate | Feature suite |
| Adventure load + full path to ending + rewards | Feature suite + JSON graph |
| Safety First choice + essence teaching | Graph + feature suite |
| Essence ≠ separate creature (canon) | Models + adventure text |

## Bugs found & fixed this session

1. `CardThemeData` undefined on Flutter 3.24 → use `CardTheme`  
2. Stock counter `widget_test.dart` referenced `MyApp` → real tests  
3. Widget smoke hung on `pumpAndSettle` (infinite Heartlight pulse) → finite `pump` + disable GoogleFonts network  
4. Earlier: Care `leveledUp` dead + radiant wiped; adventure speaker crash  

## How to re-run on your PC

```powershell
cd C:\Users\KING\projects\lumming
git pull origin main
cd app
python ..\..\..\  # or:
python test/logic_feature_test.py
python test/adventure_graph_check.py
flutter pub get
flutter analyze
flutter test
flutter run
```

## Not covered here (device/Phase 1.1)

- Real device / emulator UI polish  
- NFC plush sync  
- Live LLM Talk  
- Production IAP  
