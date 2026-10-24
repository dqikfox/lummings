# Lummings app: design and implementation plan

Planning baseline: 13 October 2026. Software first. Initial audience hypothesis: children aged 6–9 with adult-led setup. This is a proposed build specification, not a claim that the features already exist.

## Product direction

An illustrated companion world where a child chooses a small adventure, explores with a Lumming, and carries away a discovery. Lumo is the welcoming ruby-red mystical gamer captain. Luna, Sprout, Nori and Moki offer distinct ways to explore. Their Heartlights guide attention through the experience.

The first release centres on the fifteen authored Heartlight Adventures. This gives families a useful sample without a model download, account, microphone or unrestricted generated conversation. AI is a later, separately enabled enhancement, not a requirement for opening a story.

## Verified starting point

- `src/lummings/server.py`: loopback Python HTTP playground, `/persona/...` and `/chat`; per-character in-process state and default-owner SQLite memory. It accepts model/base URL in chat requests. It is a development server, not a deployable multi-family service.
- `src/lummings/engine.py`: persona prompts, moods, SQLite events/facts/progress and heuristic fact extraction. Profile isolation, inspect/edit/delete controls and explicit consent workflows are not implemented in the inspected handler.
- `docs/app/index.html`: existing visual prototype with simulated interactions, CDN styling, remote fonts, legacy colours/names and HTML-string rendering. Preserve it as a reference; do not treat it as a connected production app.
- `brand/INTERACTIVE_STORIES.md` and `docs/marketing/heartlight-adventures.html`: fifteen authored stories with optional interactions, explanations and grown-up notes.
- Artwork and persona assets already exist. Reuse them rather than creating another character style.

## Information architecture

Child navigation: **Home / Adventures / My Lumming / Discoveries**. A consistent adult-area entry sits separately in the header. Reader screens hide nonessential navigation and retain Back, Pause and Help. No public feed, direct messages, follower counts, advertisements or child purchases in the first release.

| Screen | Main purpose | Key elements and states |
|---|---|---|
| Welcome | Understand and try | Lumo, one sample adventure, separate adult setup; no child information required |
| Adult setup | Configure a shared device | Storage explanation, optional local profile, reading preferences; no exact birth date or school |
| Home | Start comfortably | Companion greeting, Continue if available, one featured quest, Explore all; explicit empty state |
| Adventures | Find a suitable experience | Character and topic filters, approximate duration, reading/listening availability, downloaded status |
| Story intro | Make a choice | Premise, skills explored, optional materials/adult participation, Start or Back |
| Story reader | Explore one manageable beat | Character art, short text, optional interaction, Hint, Explain, Skip, Pause; visible progress without timer |
| Story closing | Carry discovery into life | Reflection, optional save, share aloud with someone, another adventure or goodbye |
| My Lumming | Build familiarity | Character traits, Heartlight, explicit preferences, switch character; no affection meter |
| Discoveries | Revisit learning | Private saved discoveries and unfinished stories; edit/remove; no rankings or mastery claims |
| Grown-up area | Understand and control | Profiles, storage controls, memory review, content information, accessibility, help; billing only if introduced |

## Key journeys

### First visit

Landing page → Try Lumo → Constellation Gate intro → short story beat → optional multiplication strategy → explanation → closing. Adult setup is offered after the sample, before persistent profile storage. Do not collect marketing consent through the child's journey. A failed storage operation must leave the sample usable.

### Returning child

Adult-selected local profile → Home → Continue or choose a new adventure → optional save. Greeting references only approved preferences. Do not imply memory when none is available. A shared device must make the active profile obvious, and switching clears prior profile material from the view.

### Choosing a quiet experience

Adventures → Quiet stories filter → Nori story → optional noticing activity → skip or participate → choose support or close. No inferred emotional diagnosis or mandatory feelings questionnaire.

### Parent correcting memory

Adult area → active profile → approved preferences → edit/remove → confirmation → related views and future prompts reflect the change. Deletion also invalidates derived summaries and session context; test that removed facts do not reappear through old transcripts.

## Visual direction and interaction rules

Use a warm illustrated twilight world: deep indigo surroundings, cream reading surfaces, generous spacing and soft light accents. Keep illustrations outside the text block. Use existing campaign portraits for introductions and lightweight SVG portraits during stories.

Character accents: Lumo ruby `#ed4054`, Luna violet `#b59aff`, Sprout emerald `#57db91`, Nori moon-blue, Moki rose/lilac. Final colour pairs require contrast checks; accent colour alone never conveys meaning. Lumo's quiff, red fur and captain brooch must remain recognisable.

Heartlight UI states: welcoming, inviting choice, waiting, celebrating discovery and resting. Pair each with text or shape. Do not suggest it reads feelings or detects danger. Gentle, finite animation; reduced-motion mode uses static changes. No flashing, countdown pressure or punitive streaks.

Phone: single column and labelled bottom navigation. Tablet: illustration beside reading surface where space permits. Desktop: centred reading width, not stretched paragraphs. Support 320px layouts, browser zoom, keyboard navigation, screen readers and large text. Prefer touch controls around 48px as a design target. Aim for WCAG 2.2 AA; verify rather than claim conformance. Restore focus on view changes, announce answer feedback without revealing answers early, and keep focus visible. See https://www.w3.org/TR/wcag/.

## Features and sequencing

| Priority | Feature | Implementation approach | Done when |
|---|---|---|---|
| P0 | Story catalogue and reader | Validated JSON content plus deterministic player; all 15 stories discoverable | Branches, hints, explanations, skips and endings work with keyboard/touch |
| P0 | Character identity | Shared registry with canonical public IDs and legacy alias mapping | All five display correct names, colours, art and Heartlights |
| P0 | Optional interactions | Choice, reveal, reflection and accessible text alternatives | Every activity can be skipped; incorrect choices receive kind, useful feedback |
| P0 | Local preferences and resume | IndexedDB behind a storage adapter, opt-in from adult setup | Reload resumes opted-in profiles; private/no-storage mode remains usable |
| P0 | Adult controls | Clear device-local boundaries, inspect/delete/reset, reading settings | Confirmation, recovery from failed writes and profile isolation verified |
| P0 | Accessibility and error states | Semantic UI, reduced motion, zoom, focus management | Manual keyboard/screen-reader checks and task trials pass |
| P1 | Installable/offline story app | Manifest and versioned service-worker cache of public assets | Previously downloaded stories work offline; unavailable ones clearly labelled |
| P1 | Read-aloud | Curated audio with text transcript and explicit play/stop | No autoplay, playback stops on exit; missing audio leaves text usable |
| P1 | Discovery scrapbook | Optional structured notes, no raw chat required | Edit/delete and export work; child controls whether to save |
| P2 | Bounded AI questions | Separate backend, adult opt-in, limited story context and tool access | Privacy/architecture decision, behavioural testing and operating-cost review complete |
| P2 | Optional speech input | Push-to-talk, explicit permission and retention explanation | Stop/cancel/retry reliable; no always-on microphone; text always available |
| Later | Accounts, sync, paid packs | Introduce only for demonstrated family need | Access control, deletion, restoration, billing/support validated |

## Proposed technical architecture

Build a new versioned app alongside existing pages under `web/` (source) and `docs/companion/` (static distribution). Recommended first stack: TypeScript, native HTML/CSS components and a lightweight build tool; add a UI framework only when the team benefits from it. This is a recommendation, not an installed dependency decision. Avoid runtime CDN dependencies; bundle fonts/assets locally with verified rights.

Keep four boundaries: presentation; deterministic story state; storage adapter; optional AI adapter. The story engine must run with both storage and AI disabled. First stories are shipped with the app; the static host needs no chat backend.

Proposed source folders:

```text
web/src/app/             routing, layouts, startup and error handling
web/src/characters/      registry, portraits and Heartlight states
web/src/stories/         schema, catalogue, player and validation
web/src/storage/         IndexedDB adapter, migrations and reset/export
web/src/parent/          settings and profile controls
web/src/ai/              disabled-by-default adapter for later release
content/stories/         reviewed JSON adventure files
content/schema/          story schema and content metadata
```

PWA caching provides offline authored content, not offline model inference. Service workers require HTTPS or a trustworthy local development origin. Cache public story/assets only; never cache private API responses or chat. Version content, remove obsolete caches, expose update availability and preserve unfinished stories against their saved content version. Browser storage can be cleared or unavailable: communicate that saves are device-local and provide export where useful. Reference: https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers.

## Content model and player

Each story includes `id`, `version`, `characterId`, title, summary, suggested age band, estimated minutes, topics, required adult participation, review status, start node and nodes. Nodes have unique IDs, type, text, optional choices, hint, explanation, next IDs and accessible labels. Types initially: narration, choice, reflection and closing. Reflection is transient unless an explicit save is chosen.

Persist `profileId`, `storyId`, `contentVersion`, `currentNodeId` and minimal completed-node metadata after a deliberate transition. Do not persist every keystroke. The player handles select, hint, explain, skip, back, pause, resume and finish; a single state reducer prevents double transitions. Random choice ordering is unnecessary initially. No auto-grading of open feelings or creative writing.

Schema validation checks required fields, valid public characters, all destinations, a reachable closing, skips for activities and no accidental dead ends. Content review separately checks educational accuracy, tone and potentially unsafe activities. A schema passing is not a safety verdict.

Sample structured interaction:

```json
{
  "id": "gate-strategy",
  "type": "choice",
  "text": "Four constellations. Six stars in each. Which route shall we try?",
  "choices": [
    {"id": "count", "label": "Count in sixes", "next": "count-explanation"},
    {"id": "split", "label": "Split six into five and one", "next": "split-explanation"}
  ],
  "skipNext": "gate-explanation",
  "hint": "Imagine one group first, then another."
}
```

The branch nodes, hint and explanation must actually be authored. Do not label identical copy as meaningful branching. Start by converting one Lumo story end to end, then convert the remaining fourteen using that tested format.

## Profiles, memory and data boundaries

Offer anonymous sample use. Persistent device-local profiles are adult opt-in; use nickname/avatar and broad reading preference, not school, precise birthday or location. Local profiles organise data; they are not authentication against someone controlling the device/browser. An adult PIN is a convenience gate and must not be described as secure age verification. If shared-device privacy requires stronger protection, design authentication or encryption before storing sensitive material.

Personalisation begins with explicit harmless preferences, such as dinosaurs or quiet stories, plus an adult/child reviewable approval state. Do not infer emotional vulnerabilities, diagnoses or a fixed ability score. Keep core character traits stable; change topics, pacing and language complexity. No silent cross-character or cross-profile memory sharing.

Stage 1 stores only optional resume/settings locally. Stage 2 adds optional discoveries/preferences. Define retention and deletion for each store and export. Avoid raw transcript storage by default. Email subscriptions belong to an adult marketing system separate from story profiles. Storage failures, deletion, private browsing and multiple-tab changes need explicit handling.

## Later AI integration and API boundaries

Keep current Python engine for experiments while building an authenticated, profile-scoped service separately before public AI access. Do not expose the current loopback handler to the internet. Remove request-controlled upstream base URLs/models in public service; use a server-controlled allowlist. Never embed provider credentials in browser code. Validate request sizes/types, use exact routes, enforce timeouts/quotas, sanitise errors and render text as text rather than HTML. Scope conversation state by authenticated family, profile, character and session; the existing default-owner state is insufficient.

Proposed APIs, not implemented:

- `GET /v1/catalogue`: public reviewed content metadata; no profile data.
- `POST /v1/sessions`: authorised profile and character, explicit conversation mode.
- `POST /v1/sessions/{id}/messages`: message plus bounded story context; profile ownership checked server-side.
- `GET/PATCH/DELETE /v1/profiles/{id}/memories/{memoryId}`: explicit ownership and correction/deletion lifecycle.
- `DELETE /v1/profiles/{id}`: remove active context and derived/private data according to disclosed retention.

First AI pilot: optional follow-up questions within reviewed learning topics, with no open web browsing, purchasing, public messaging or automatic personal-fact extraction. Restrict tools and context in code, review outputs, prepare factual/error fallbacks and trusted-adult redirection, and test realistic adversarial scenarios. System prompts and word sanitisation alone are insufficient. Cloud AI, local runtime and on-device browser AI have different feasibility/privacy implications; do not promise all simultaneously. Default first-release decision is authored-only.

## Validation and release gates

1. Reader: complete one story, choose either branch, skip, pause, reload and finish without lost state or unwanted storage.
2. Data: profile A cannot display B's data; deletion removes saved records and derived references; imports are validated if introduced.
3. Accessibility: touch, keyboard, zoom, reduced motion, screen reader and optional audio all preserve the full story.
4. Resilience: storage denied, network absent, old content version and asset failure all offer a clear next step.
5. Content: an adult reviewer checks every story for factual accuracy and suitability; families can flag a problem from a grown-up flow.
6. Pilot: observe parent setup and child choice without coaching; collect agreed adult feedback and aggregate activity only under a disclosed plan. No unapproved tracking.
7. Public AI: separate access-control, prompt-injection, inappropriate-content, misinformation, memory-isolation and latency/cost validation before enabling it.

## Build sequence

- Milestone A: consolidate character registry, design tokens, screen layouts and story schema. Deliver a reviewable design reference and one validated story JSON.
- Milestone B: complete one Lumo story in a new reader with real choices, hints and closing. No account/backend dependence.
- Milestone C: import all fifteen; add catalogue, parent-led local preferences and optional resume; verify deletion/accessibility.
- Milestone D: add reviewed offline packaging and optional read-aloud; run a supervised family pilot. Publish only truthful supported-device and capability claims.
- Milestone E: choose commercial and AI architecture from measured demand, costs and specialist review; then implement the chosen option.

Launch connection: marketing sends families directly to the sample. A useful completed discovery is the first value milestone. Optional adult early access follows it. Paid offers belong in adult space and never condition friendship, breaks or memory retention on payment.

## Open decisions

Validate age band, primary launch device/browser matrix, initial audio production approach, adult-control strength and whether a paid authored collection has standalone value. These do not block an authored browser prototype. Hosted AI and account sync remain later decisions; no dependency install, external publication or backend deployment is authorised by this planning artifact alone.
