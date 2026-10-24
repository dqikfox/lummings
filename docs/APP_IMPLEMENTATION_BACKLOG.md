# Lummings implementation backlog

Companion to APP_DESIGN_PLAN.md. Hardware deferred.

Implementation update: a first authored vertical slice now exists at `docs/companion/index.html`. APP-01 has a browser character registry with legacy aliases, APP-02 has structured Lumo content and a runtime graph validator, APP-03 has the responsive app shell, and APP-04 has a working player. Full accessibility/device verification and schema formalisation remain open. APP-05 onward remain planned. Progress and discoveries currently last only for the open page.

| ID | Work item | Depends on | Acceptance evidence |
|---|---|---|---|
| APP-01 | Shared public character registry and design tokens | — | Lumo/Luna/Sprout/Nori/Moki names, correct art/Heartlights; old IDs map through one adapter |
| APP-02 | Story schema, validator and one structured Lumo story | — | Valid references, optional skip, explanation, reachable ending; malformed content rejected |
| APP-03 | Responsive shell, Home and Adventures | APP-01 | Keyboard and narrow-screen navigation; truthful empty/loading states |
| APP-04 | Deterministic player, hints, skips, branch feedback and closing | APP-02, APP-03 | Every path in Constellation Gate exercised; double clicks do not skip nodes |
| APP-05 | Storage abstraction with memory-only and IndexedDB implementations | APP-04 | Sample makes no persistent writes; consented resume works; denied storage handled |
| APP-06 | Adult setup, local profile selection and reset | APP-05 | Active profile visible, data isolated, deletion confirmed; limitations explained |
| APP-07 | Convert remaining fourteen stories and review content | APP-02, APP-04 | All content validated and reviewed; story text/source traceable |
| APP-08 | Reading settings, accessibility and reduced motion | APP-03, APP-04 | 200% zoom, keyboard/screen-reader trials, contrast and target-size checks |
| APP-09 | Optional discoveries and explicit approved preferences | APP-06 | Inspect/edit/delete; no inferred sensitive facts; removed data absent after reload |
| APP-10 | Versioned offline story distribution | APP-05, APP-07 | Downloaded content works offline; update/version recovery; no private-response caching |
| APP-11 | Curated read-aloud pilot | APP-07, APP-08 | Captions/text available, explicit playback, stop on navigation, missing audio fallback |
| APP-12 | Family pilot and adult feedback flow | APP-06, APP-07, APP-08 | Setup/activation/return observations; feedback permission recorded; no child identifiers in marketing |
| APP-13 | Architecture decision for paid offer/optional AI | APP-12 | Cost, privacy, support and buyer evidence documented before implementation |
| APP-14 | Hardened profile-scoped AI service | APP-13 | Server-owned endpoints/models, access checks, quotas, memory lifecycle, behavioural evaluation |

Recommended next implementation: APP-01 through APP-04 as one vertical slice. Complete and evaluate a real story experience before adding accounts, subscriptions or live AI.
