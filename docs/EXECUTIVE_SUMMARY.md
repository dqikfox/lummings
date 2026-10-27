# The Lummings: Executive Summary

*Prepared 27 October 2026 from the repository's own documents and a hands-on audit. Claims the repository itself marks as unverified are labelled **concept**.*

## 1. What the Lummings are

**The Lummings** are five small characters "from a brighter tomorrow" who act as curious companions for children, with parents in the loop. Each child-facing moment is a short adventure: the child asks, the character listens, a **Heartlight** (the character's glowing "essence", never a separate creature) invites attention, and a discovery is remembered.

Brand line: **Little friends. Big discoveries.**

| Character | Role | Heartlight | Colour | Voice |
|---|---|---|---|---|
| **Lumo** | Hyperfixation Gremlin, crew leader ("Player one. Crew first.") | Questlight | Ruby `#ed4054` | Relaxed, witty gamer confidence |
| **Luna** | Spooky Poet | Dreamlight | Lilac `#b59aff` | Half-rhymes, dramatic pauses, whispers secrets |
| **Sprout** | Quiet Garden Sprite | Traillight | Emerald `#57db91` | Soft, unhurried, garden images, takes a breath before answering |
| **Nori** | Cosmic Weirdo | Tidelight | Moon blue `#75d8ef` | Slow, poetic, wondering |
| **Moki** | Chaos Gremlin | Sparklight | Rose `#ff83bd` | Silly made-up slang, switches to sincere when someone is upset |

**The promise:** a children's product that respects the child (no covert data collection), the parent (no dark patterns, no advertising) and childhood (characters, not tools). Characters never replace adults; for serious personal, safety or health matters they send the child to a parent, guardian or teacher.

## 2. Where the project stands today (verified in this audit)

| Area | State |
|---|---|
| Characters, art, lore, brand bible | Complete and now consistent: one name set, one Sprout, one colour palette (`brand/colors/palette.json`) |
| Python personality engine (`src/lummings`) | Working: five personas, SQLite memory, mood transitions, browser and terminal UI, API on :8511. **93 automated tests pass (also under Linux), lint clean, now run in CI**, including a new guard that fails if names, Sprout's personality or colours drift again |
| Family browser app (`docs/companion`) | Five authored adventures, parent dashboard, separate explorer profiles, optional local saving |
| Bedtime web app (`web/`) | Typecheck, lint, 9 tests and production build pass; 0 audit vulnerabilities; no third-party requests; login, database and fake paid tier removed. A small, near-launch slice of the project |
| Living Lummings creative companion (`docs/app`, gateway on :8511) | Baseline, media library, generation job queue, review workflow and spend guard built; paid generation off by default; live avatar is research only |
| Pixel studio (separate repo, :8520) | Working local character and media studio with local image/video generation; 59 tests pass; supervised service |
| Flutter mobile app (`app/`), Rust device runtime (`crates/`) | Present; not exercised in this audit |
| Voices | Five distinct ElevenLabs voices designed and saved (Lumo, Luna, Sprout, Nori, Moki); wired into the project's voice config. Live voice agents are **not yet connected** (see section 6) |
| Hardware | **Deferred.** Software-first decision, 13 Oct 2026 |

**Not demonstrated** (per the repository's own product plan): generated-response safety, speech quality in a noisy room, child usability, on-device inference, battery and charging claims, physical Heartlight controls.

## 3. Product and expected outcome

**The ecosystem.** The Lummings are delivered through several product lines on one shared foundation (character registry, voices, media jobs, parent controls): a **bedtime web app** (small, near launch), the **Living Lummings creative companion** (talk to a character, change its look, make images, films and stories; the flagship ambition, built on the Pixel studio), a **family companion** of authored adventures, and a **device** later if software shows sustained use. `ROADMAP.md` has the full plan.

**First release (recommended in the repo):** a parent-led early-access software experience led by **Lumo**, with the other four present in the world and introduced over time. Three modes: **Wonder** (questions), **Quest** (short guided activities), **Wind-down** (stories and reflection). One obvious parent setup, one optional daily invitation, no streak penalties.

**Target audience (hypothesis to validate):** parents of children aged **6-9** who enjoy stories, puzzles and asking questions together. Market to the adult purchaser; let the characters appeal to the child.

**Expected outcomes**
1. **Validated demand:** a four-week, parent-consented supervised pilot with **10-15 families** shows voluntary return, parent-rated usefulness and real willingness to pay.
2. **A deliverable offer:** supported devices, setup, data handling, support and refunds all work before any wider launch.
3. **Decision gate:** move toward hardware or a wider launch only if there is voluntary return, no unresolved critical safety issue, an acceptable support burden and viable economics. Numeric targets are to be set **before** recruiting.

## 4. Requirements

**Technical (current stack)**
- Python 3.11+, no runtime package dependencies (`pyproject.toml` lists none); `pytest` and `ruff` for development.
- An OpenAI-compatible inference endpoint. Default: Ollama at `127.0.0.1:11434` with `qwen2.5-3b-instruct`; Ollama models exist per character.
- Optional: Flutter (mobile app), Node/Vite (web app), Rust (device runtime, Raspberry Pi Zero 2 W as the longer-term concept).
- Voice: ElevenLabs (five saved voices; API key held by the owner). A second provider (xAI) script also exists.

**Product and safety (must exist before launch)**
- Adult setup, visible microphone state, limits, reliable help-seeking, no secret-keeping or exclusive-attachment pressure.
- Memory that is inspectable, editable and deletable, with separate child profiles.
- Review of generated responses, developmental suitability and privacy by qualified specialists.
- Public claims reconciled with measured behaviour; "local-only" explained precisely.

**Business and legal**
- Brand clearance for "Lummings" and all five names in intended markets (**not yet done**).
- Unit economics rebuilt from supplier quotes (the historical $149 price with $95 allocated cost is **not** a net margin).
- Pricing is a hypothesis: a paid starter adventure collection first; a subscription only if ongoing value and running costs justify it.

## 5. Plan

| Weeks | Focus |
|---|---|
| 1-2 | Choose the supported platform and one offer; audit public claims; build and measure one complete interaction |
| 3-4 | Voice and light prototype; adult controls; memory correction and deletion; specialist reviews; landing page and authored demo quest |
| 5-8 | Four-week family pilot; supplier and compliance quotes; test real price choices with parents |

Channel priority: parent and family-learning communities, small honest creator trials, one principal short-video channel, an adult opt-in email list. Paid acquisition waits for a working offer and attributable conversion.

## 6. Open items and decisions needed

1. **Live voice agents.** The five ElevenLabs agent IDs in `web/src/lib/eleven-agents.json` do not exist in the connected workspace. Decide: reconnect the workspace that owns them, or create five new agents on the saved voices.
2. **Lumo's label.** The brand bible says "Hyperfixation Gremlin"; marketing leads with "mystical gamer captain". Both are in use; pick one public label.
3. **Sprout's training data.** About 100 fine-tuning dialogue lines (`src/lummings/dialogue/pip_sft.jsonl`) and `scripts/build_sft_dialogues.py` still teach the old fast, gamer-slang Sprout. They should be regenerated before any fine-tuning run.
4. **Legacy IDs.** `lila` and `pip` remain as internal IDs in about 58 files (an intentional compatibility mapping). Decide whether to migrate them.
5. **Duplicate front ends.** `docs/`, `site/`, `web/` and the Flutter app each carry their own character tables; a single generated source is the next engineering step. A third naming scheme (`lumi`, `piko`, `nomi`) also survives inside `src/lummings/sprites.py`.
6. **Brand clearance, specialist safety review and the pilot** are the gating items for any public launch.

## 7. Risks

| Risk | Mitigation |
|---|---|
| Claims outrun evidence (battery, offline, app-store availability) | Label as concept until measured; audit before publishing |
| Child safety of generated replies | Specialist review, adult controls, authored content for the first release |
| Name or trademark conflict | Clearance before packaging or paid launch |
| Inconsistent characters across channels | Canon guard tests (added); one palette file; one source of truth |
| Over-building before demand is proven | Software-first; pilot gate before hardware |
