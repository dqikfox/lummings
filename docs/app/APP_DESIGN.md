# Lummings App Design Spec (v1.0)

**Tagline:** Little lights. Big little adventures. Lifelong bonds.  
**Style lock:** cinematic fluffy crew (Lumo, Luna, Sprout, Nori, Moki) — Heartlights are essence/soul, never separate creatures.  
**Target:** iOS + Android (Flutter recommended). Kids 5–10, parents 25–45.

## 1. Goals
- Daily emotional bond via Care Ritual + Heartlight
- Safety-first (COPPA / GDPR-K), parent dashboard default-on filters
- Physical plush NFC/BLE sync so plush “wakes” with the app
- Gentle retention (love, collection, soft FOMO) — no dark patterns

## 2. Navigation (bottom bar)
| Tab | Purpose |
|-----|---------|
| Home | Nest / active Lumming / Heartlight status |
| Adventures | Choice stories, Growing Together memory |
| Collection | Charms, Essence Shards, outfits |
| Care | Daily ritual (Hug / Talk / Story / Sync Plush) |
| Parent | PIN-gated dashboard |

## 3. Core screens (mockups in `brand/app-mockups/`)
| File | Screen |
|------|--------|
| 01-home-nest.jpg | Home |
| 02-care-heartlight-ritual.jpg | Care Ritual |
| 03-collection-charms.jpg | Collection |
| 04-adventures-growing-together.jpg | Adventures map |
| 05-parent-dashboard.jpg | Parent Dashboard |
| 06-onboarding-welcome.jpg | Onboarding 1 — Welcome |
| 07-onboarding-pick-friend.jpg | Onboarding 2 — Pick first Lumming |
| 08-onboarding-parent-safety.jpg | Onboarding 3 — Parent PIN + limits |
| 09-talk-mode.jpg | Talk / voice mode |

## 4. Onboarding flow
1. **Welcome** → Meet Your Crew  
2. **Pick first friend** → others unlock via bond growth  
3. **Parent & Safety** → PIN, screen-time slider, privacy + filters ON, optional Heartlight Plus trial  
4. Land on **Home Nest** with starter Lumming + first Care prompt

## 5. Heartlight state machine
```
Dimmed  --(daily care / return after miss)-->  Caring  -->  Glowing
                                                      |
                                                 Bond Level N
                                                      |
                                            Special LED pattern (plush)
```
- Miss day → soft “I missed you” dim (no punishment; bonus on return)
- XP from Care + Adventures → bond unlocks (voices, memories, LED)

## 6. Feature backlog

### MVP
- [ ] Home Nest + Heartlight bar
- [ ] Care Ritual (hug / talk / story)
- [ ] Bond levels + streak
- [ ] One branching adventure pack
- [ ] Collection inventory (free shards)
- [ ] Talk mode (moderated LLM + on-device TTS/STT)
- [ ] Parent PIN + screen-time + filters
- [ ] Heartlight Plus subscription + soft IAP
- [ ] NFC/BLE plush pair (prototype)

### Phase 2
- [ ] Seasonal story arcs
- [ ] Parent-approved friend codes / charm trade
- [ ] AR Heartlight view on plush
- [ ] Multi-child profiles
- [ ] Wearable keychain/bracelet sync

## 7. Monetization
| Item | Price |
|------|-------|
| Free | 1 starter Lumming, daily care, limited adventures |
| Heartlight Plus | $4.99/mo or $39.99/yr |
| Essence Shard packs | $0.99–$9.99 |
| Limited Charms | $2.99–$14.99 |
| Outfit packs | $1.99–$4.99 |

Core bond never paywalled.

## 8. Tech sketch
- **Client:** Flutter (iOS/Android), offline-first local DB
- **Backend:** Firebase/Supabase (auth, sync, functions)
- **AI:** on-device small model for latency + cloud LLM behind multi-layer moderation
- **Voice:** on-device STT/TTS; child-voice filtering
- **Plush:** NFC tag ID + BLE LED pattern stream
- **Compliance:** COPPA/GDPR-K, delete-within-24h, no third-party child trackers

## 9. User stories (MVP samples)
1. As a child, I open the app and see my Lumming’s Heartlight so I know how we are today.  
2. As a child, I complete Care once per day to brighten Heartlight and keep my streak.  
3. As a child, I talk to my Lumming and get a safe, in-character reply.  
4. As a child, I finish a short adventure and earn shards + bond XP.  
5. As a parent, I set a PIN and gentle time limit before my child plays.  
6. As a parent, I see bond levels and can delete all child data in one tap.  
7. As a child, when I hold my plush near the phone, its Heartlight LED matches the app.

## 10. Acceptance criteria (Care Ritual)
- Care available once per calendar day (local + server time)
- Completing Care raises Heartlight visual + +XP
- Missing 1+ days shows dim state + gentle miss message
- Return after miss restores glow + optional return bonus (not a penalty)
- Sync Plush updates LED within 3s when paired

## 11. Related docs
- `brand/HEARTLIGHTS.md` — Heartlight canon  
- `brand/CHARACTER_BIBLE.md` — crew  
- `brand/ASSETS_INDEX.md` — asset map  
- `BRAND.md` — palette / voice  

## 12. Next engineering steps
1. Figma UI kit from mockups  
2. Flutter shell + bottom nav + local Heartlight state  
3. Care + bond XP  
4. Adventure content pipeline (JSON stories)  
5. Moderated Talk mode  
6. Parent gate  
7. IAP / subscription  
8. Plush BLE/NFC prototype  

---
*Locked style · Safety First · Growing Together*

## 13. Flutter scaffold (v0.1) — shipped

Path: `app/`

- Heartlight state machine + bond XP + care streak (`HeartlightController`)
- Bottom nav shell + Home / Care / Adventures / Collection / Parent / Talk / Onboarding
- Adventure engine + **The Night Forest Awakens** (`assets/adventures/growing_together_001.json`)
- Local parent PIN gate
- Brand theme (Star Yellow / Dream Teal / Future Purple / Glow Pink)

```bash
cd app && flutter pub get && flutter run
```
