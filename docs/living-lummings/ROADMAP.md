# Delivery roadmap

[Master blueprint](README.md) · Planning ranges, not commitments or measured progress.

Assume one experienced full-stack engineer with part-time art/animation and content review. Effort excludes account procurement, new training datasets and legal review. A small team can overlap art/provider/UI work, but dependency gates remain.

## Current implementation update — 16 October 2026

The first Lummings-native creation slice is implemented in the existing app. The local creator has persistent image/video job drafts, canonical-reference hash checks, idempotent request keys, private generated outputs, review/accept/reject, and accepted-still lineage for animation. The UI is in `docs/app/creator.js` and `creator.css`; the service is `src/lummings/media_jobs.py`. An optional server-side fal adapter supports Flux.2 reference-conditioned images and Pika v2.2 image-to-video. It stays off by default and requires explicit environment configuration, a fresh single-use job quote, and per-request consent. Tests use fake output only; no provider credentials, uploads or spend were used.

MEDIA-01 is **partially implemented**; durable states and safe restart handling exist, while worker leases, concurrent claims and provider reconciliation remain open. MEDIA-02 now includes fresh per-job quotes, explicit consent, a zero-by-default daily USD cap, atomic reservations, queued cancellation and manual reconciliation of uncertain charges. Automatic provider-status reconciliation and actual-cost settlement remain open. MEDIA-04/VIDEO-01 have coded adapters and job/review contracts, but no live provider run or identity benchmark. Wardrobe labels are experimental generation choices, not approved character art. See [implementation status](IMPLEMENTATION-STATUS.md).

Latest continuation adds an explicit daily UTC USD cap (`LUMMINGS_MEDIA_DAILY_BUDGET_USD`, default `0.000`), atomic quote/reservation/queue authorization, cancellation before provider submission, and manual reconciliation of failed jobs with uncertain charges. The app refuses to advertise paid generation as ready until a positive cap is configured. Worker leases, cancellation after remote submission, automatic provider status reconciliation, actual-cost settlement and retention review are still open.

## Milestones

| Milestone | Engineering effort | Exit evidence |
|---|---:|---|
| M0: preserve and repair baseline | 3–5 days | Latest app/portraits/API served correctly; real readiness; data backed up; adventures unchanged |
| M1: character presence | 5–8 days | Five identities registered; Lumo stage, three looks, undo and durable themes |
| M2: conversation and creation foundation | 8–12 days | Scoped chat, typed skills, isolated queue, events, budget/idempotency/recovery tests |
| M3: complete creative slice | 8–12 days | Reference-conditioned Lumo image, actual image-to-video, review, private gallery and resume |
| M4: voice and pilot hardening | 8–12 days | Playback/push-to-talk, interruption, captions, memory controls and pilot evidence |
| M5: crew and story production | 15–25 days | All five benchmarked; multi-shot stories/comics/stickers, narration, revisions and export bundles |
| M6: hosted family beta | 15–25 days | Authentication, private storage, tenancy, quotas, rollback, support and controlled access |
| R1: live-avatar research | 5–10 days, time-boxed | Supported access, creature quality and cost evidence; go/no-go |
| M7: live-avatar integration | 15–30 days after R1 passes | Transport, interruption/reconnect, concurrency/spend limits and operating tests |

M0–M4: **32–49 engineering days**, approximately 7–10 working weeks, plus external/art delays. M0–M6: **62–99 days**, approximately 13–20 weeks. R1/M7 add 20–40 days if feasible. Full hosted creative companions with live generation are a multi-month programme; the older 5–8-week estimate was for a narrower local pilot.

## First ten engineering days

Days 1–2: snapshot dirty tree including untracked files; database backup/restore rehearsal; asset inventory and app/model state. Days 3–5: routing, portraits, readiness and safe message rendering; real character reply using configured model profiles. Days 6–8: identities/reference hashes, stage and wardrobe persistence. Days 9–10: scoped sessions/media repository contracts and recovery tests. Carry incomplete acceptance work forward instead of declaring it complete on schedule.

## Implementable tickets

| ID | Task | Dependencies | Acceptance evidence |
|---|---|---|---|
| BASE-01 | Snapshot files and back up private DBs | — | Restore into temporary location; no private data enters Git |
| BASE-02 | Fix app root and portrait/static routes | BASE-01 | Latest `/` and `/ui`; required portraits; traversal rejected |
| BASE-03 | Replace HEAD/no-cors probe and hardcoded API origin | BASE-02 | Real capability response; honest offline state |
| BASE-04 | Remove HTML interpolation of user/model text; validate requests | BASE-02 | Injection strings display as text; sizes/routes/origins tested |
| CHAR-01 | Five-character registry, aliases and references | BASE-01 | Duplicate assets reconciled; canon names/colours/Heartlights |
| CHAR-02 | Appearance versions, allowed options and undo | CHAR-01 | UI/server options agree; reload and save-error behaviour verified |
| CHAR-03 | Lumo stage and three approved looks | CHAR-02 | Real activity states; reduced motion/keyboard work |
| CHAT-01 | Server-controlled models and readiness | BASE-03 | Installed model verified; explicit fallback; no client upstream URL |
| CHAT-02 | Profile/session memory isolation | CHAT-01 | Switching clears context; no default-owner crossover |
| CHAT-03 | Streamed turns and interruption | CHAT-02 | Stale responses cannot speak/update stage |
| MEDIA-01 | Separate store, lineage and leases | BASE-01 | Restart and concurrent-claim tests; family snapshots unaffected |
| MEDIA-02 | Budgets, idempotency, uncertain submission | MEDIA-01 | No duplicate billable retry or reservation race |
| MEDIA-03 | Configurable local provider/GPU scheduler | MEDIA-01 | Missing node/OOM/timeout/cancel tests; unrelated workloads untouched |
| MEDIA-04 | Reference-conditioned image benchmark | CHAR-01, MEDIA-02/03 | Real reference input; identity acceptance gate |
| MEDIA-05 | Quarantine/review/private access/deletion | MEDIA-01 | Unapproved, foreign and deleted assets inaccessible |
| SKILL-01 | Typed planner and bounded executor | CHAT-02, MEDIA-02 | Intended skill dispatch; unknown tools/call expansion rejected |
| UX-01 | Inline run cards and durable gallery | MEDIA-05, SKILL-01 | Resume original run after reload; truthful phases/cancel/errors |
| VIDEO-01 | Animate accepted still | MEDIA-04/05, UX-01 | Exact source lineage; no text-only substitution |
| PILOT-01 | Complete Lumo journey | CHAR-03, VIDEO-01 | Talk → look → image → clip → save → restart → reopen |
| VOICE-01 | Character speech playback/transcript | CHAT-03 | Voice rights, stop behaviour and explicit playback |
| VOICE-02 | Push-to-talk and barge-in | VOICE-01 | Permission, cancel, partial transcription, measured interruption |
| MEMORY-01 | Preference review/edit/delete | CHAT-02 | Removed data absent from next context and summaries |
| STORY-01 | Storyboard and continuity sheet | PILOT-01 | Shot edits retain accepted assets; character/appearance pinned |
| STORY-02 | Timeline/narration/captions/export | STORY-01, VOICE-01 | Export plays; manifest restores full project |
| CREW-01 | Five-character tests and project collaboration | STORY-01 | Distinct looks/voices; bounded turns and explicit sharing |
| FAMILY-01 | Family mode and content controls | MEMORY-01, PILOT-01 | Review, adult controls and human-handoff scenarios |
| HOST-01 | Authentication and private hosted storage | FAMILY-01 | Cross-family denial; scoped events/media; secrets and quotas |
| HOST-02 | Monitoring/recovery/release operations | HOST-01 | Restore/rollback and provider-outage drills |
| LIVE-01 | Streaming access/creature spike | CHAR-01 | Supported route and ten-minute test, or documented no-go |
| LIVE-02 | Generated stage product integration | LIVE-01, VOICE-02, HOST-02 | Reconnect, appearance revision, interruption and spend limits |

## First milestone demonstration

Start from the documented repository launch command. The browser receives the current polished app rather than the embedded older playground. Five portraits load. Readiness reflects actual reachable models. A real character reply appears, or an honest offline state preserves the draft. Restart leaves pre-existing family/persona records unchanged. This repairs the current baseline; it does not redesign it.

## Dependencies and delivery rules

Critical path: BASE → CHAR/CHAT/MEDIA → SKILL → reference image → reviewed clip → voice/pilot → hosted family service. Run R1 independently with synthetic developer inputs if access exists. Do not let speculative streaming work block M0–M4.

Each milestone records source baseline, changed files, runnable demo, tests, limitations and next gate. Pin dependencies/model/workflow versions and keep a representative regression corpus. Begin from current working state and inventory inherited changes; never reset/clean away uncommitted work. Migrations are additive, versioned, backed up and rehearsed on copies. Feature flags keep incomplete generated work out of family sessions.

## Expansion after evidence

Reusable style packs, adult creator tools, private cross-device projects, offline stories, classroom packs, character-specific tuning and richer rigs follow measured demand. A physical Heartlight companion is a separate hardware programme consuming the same identity/voice/project services. Creator marketplaces require rights review and moderation; neither is a dependency for the first experience.
