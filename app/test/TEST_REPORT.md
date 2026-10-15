# Lummings App — Pre-device Test Report

**Date:** 2026-10-16  
**Scope:** Business logic, adventure graph, source presence, static canon checks  
**Runner:** `python3 app/test/logic_feature_test.py` (+ adventure graph checker)

## Summary

| Suite | Result |
|-------|--------|
| Bond XP curve | PASS |
| Care Ritual (once/day, hug/story XP) | PASS |
| Soft miss hook (no punishment, +15 return) | PASS |
| Bond level-up → radiant + leveledUp flag | PASS |
| Adventure graph (links, reachability, 28 paths) | PASS |
| Safety First choice + essence teaching | PASS |
| All 5 crew speakers | PASS |
| Dart source files present | PASS |
| Canon Heartlights | PASS |
| **Total** | **66 PASS / 0 FAIL** |

## Bugs found & fixed before device test

1. **CareResult.leveledUp always false** — compared `level > level` (dead). Fixed with `levelBefore` / `didLevel`.  
2. **Radiant wiped on care** — after `_addXp` set `radiant`, code forced `glowing`. Fixed: keep radiant when leveled.  
3. **Adventure speaker crash risk** — unsafe cast; fixed with safe `firstWhere` + null.  
4. **Default `widget_test.dart`** — was counter template; replaced with real smoke suite.

## Features verified (logic)

1. Onboarding data model — first friend + optional parent PIN  
2. Heartlight phases — dimmed / caring / glowing / radiant  
3. Daily Care — hug 20 XP, story 25 XP, +1 shard, once per day  
4. Soft miss — dim after gap, return streak=1, +15 bonus, memory line  
5. Bond curve — `40 + 25L + 3L²`  
6. Adventure engine — 10 nodes, 28 paths, 2 endings, full crew  
7. Safety check choice present  
8. Essence/soul beat in `essence` node  
9. Nav shell — 5 destinations in code  
10. Parent PIN gate present  

## Not run in this sandbox (need local Flutter on your PC)

- `flutter test` full widget binding  
- `flutter run` on device/emulator  
- NFC/BLE plush  
- Live LLM Talk mode  

## How to re-run

```bash
# Logic suite (no Flutter required) — already green here
python3 app/test/logic_feature_test.py
python3 app/test/adventure_graph_check.py

# On your machine with Flutter
cd C:\Users\KING\projects\lumming\app
git pull
flutter pub get
flutter analyze
flutter test
flutter run
```
