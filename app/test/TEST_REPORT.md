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
| Bond level-up → radiant | PASS |
| Adventure graph (links, reachability, 28 paths) | PASS |
| Safety First choice + essence teaching | PASS |
| All 5 crew speakers | PASS |
| Dart source files present | PASS |
| Canon Heartlights | PASS |
| **Total** | **66 PASS / 0 FAIL** |

## Features verified (logic)

1. **Onboarding data model** — first friend + optional parent PIN  
2. **Heartlight phases** — dimmed / caring / glowing / radiant  
3. **Daily Care** — hug 20 XP, story 25 XP, +1 shard, once per day  
4. **Soft miss** — dim after gap, return streak=1, +15 bonus, memory line  
5. **Bond curve** — `40 + 25L + 3L²`  
6. **Adventure engine** — 10 nodes, 28 paths, 2 endings, full crew  
7. **Safety check** choice present  
8. **Essence/soul** beat in `essence` node  
9. **Nav shell** — 5 destinations in code  
10. **Parent PIN** gate present  

## Not run in this sandbox (need local Flutter)

- `flutter test` widget goldens / full binding  
- `flutter run` on device/emulator  
- NFC/BLE plush  
- Live LLM Talk mode  

## How to re-run

```bash
# Logic suite (no Flutter required)
python3 app/test/logic_feature_test.py
python3 app/test/adventure_graph_check.py

# On your machine with Flutter
cd app
flutter pub get
flutter test
flutter analyze
```
