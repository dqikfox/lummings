# Lummings App — Feature Status

**Canon names:** Lumo · Luna · Sprout · Nori · Moki (`LummingId.luna` / `.sprout`)  
**Updated:** 18 Oct 2026

## Shipped (code in repo)

| Area | Status | Notes |
|---|---|---|
| Onboarding + parent PIN gate | ✅ | Choose friend, Heartlight essence copy |
| App shell + bottom nav | ✅ | Nest glass UI |
| Heartlight care (1×/day) | ✅ | XP, streak, soft miss |
| Bond levels + level-up dialog | ✅ | Free forever |
| Talk chips (offline) | ✅ | Safety language |
| Adventures (JSON graphs) | ✅ | 7 stories; Safety First |
| Daily Sparks quests | ✅ | Care / talk / adventure / collect |
| Charms + equip | ✅ | Collectibles, not required for bond |
| Nest Badges | ✅ | Soft achievements |
| Memory Journal | ✅ | Timeline of care/talk/adventure |
| StreakFlame | ✅ | Soft, no punishment |
| Bedtime Nest | ✅ | Nudge only, never locks |
| Heartlight Plus | ✅ | Cosmetics / early stories only |
| Parent screen + weekly digest | ✅ | PIN, soft windows |
| Festival soft hooks | ✅ | Optional claim |
| Crew art assets | ✅ | luna.png / sprout.png (+ legacy aliases) |

## Next build candidates (priority)

1. **Crew switcher polish** — Heartlight name chip under each friend on Home  
2. **Plush sync stub** — BLE/NFC placeholder for physical Heartlight charm  
3. **More adventure packs** — 3 per character mini-arcs  
4. **Export weekly digest** as shareable parent PDF/image  
5. **Offline voice intro** hooks for existing intro MP4s  
6. **Widget tests** green on CI (Flutter SDK path)

## Hard product rules (do not break)

- Heartlight = essence, never a pet creature  
- Bond growth never paywalled  
- Missed day never punishes  
- Official names only in UI  
- Soft safety first in every adventure
