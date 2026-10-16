# Research ledger and verification boundaries

Checked 13 October 2026. Public documentation was read through web retrieval and direct HTTPS reads of official Markdown. No provider authentication, paid generation, PikaStream session or Lummings runtime benchmark was performed.

## Primary external evidence

| Source | Observation used | Boundary |
|---|---|---|
| [Pika-Labs organization](https://github.com/Pika-Labs) | Public integrations, experiments and release repositories | Not evidence of complete platform or downloadable model weights |
| [Pika-Skills README](https://github.com/Pika-Labs/Pika-Skills) | Old developer-key API retired; skills declared nonfunctional | Old setup tutorials are not a supported implementation route |
| [Pika-Plugins README](https://github.com/Pika-Labs/Pika-Plugins) | Creative/identity tools exposed through MCP; Apache-2.0 integration code | README includes legacy developer-key guidance conflicting with retirement notice; authenticated operation not tested |
| [Plugin tool manifest](https://github.com/Pika-Labs/Pika-Plugins/blob/main/tools-manifest.json) | Generation, references, avatar setting and task management descriptions | Advertised tool schema, not a live tools/list response; account avatar creation can reject missing faces/already-set avatar |
| [Pika-Experiments](https://github.com/Pika-Labs/Pika-Experiments) | Generative UI experiment uses realtime conversation plus media tools | Prototype claims do not prove streaming video generation or production suitability |
| [PikaStream report](https://pika.art/blog/introducing-real-time-video-chat) | Streaming generation and mid-stream reference replacement; vendor-reported H100 performance | Neither measured locally nor verified accessible as an embedded commercial API |
| [Current Pika API index](https://dev.pika.art/llms.txt) | Media generation is asynchronous; documents server-side auth/catalogue/quotes | Streaming language-model endpoints mentioned separately do not imply streaming avatar video |
| [Pika 2.5 image-to-video specification](https://dev.pika.art/llms/pika/pika-2.5/image-to-video) | Direct media endpoint, input schema, job polling and settlement behavior | Read successfully through PowerShell HTTPS; web renderer rejected Markdown content type; no authenticated request made |
| [Pika API site](https://dev.pika.art/) | Membership plus metered usage and model catalogue | Marketing comparisons may drift; exact payload quote governs engineering budget |
| [fal Pika image-to-video](https://fal.ai/models/fal-ai/pika/v2.2/image-to-video) | 5s/720p $0.20; 5s/1080p $0.45 list prices | Prices checked, output quality/latency untested |
| [fal FLUX.2 editing](https://fal.ai/models/fal-ai/flux-2/edit) | Reference image editing; input/output megapixel pricing | Reference matching is a capability to benchmark, not a guarantee |
| [fal asynchronous inference](https://fal.ai/docs/documentation/model-apis/inference/queue) | Submit/poll/result/cancel lifecycle | Map provider states to our lifecycle; do not equate completion with approved output |

## Conflicts resolved in the recommendation

1. **Retired old API versus new API:** both are documented. Use the current creative API discovery/specification for queued media; do not reuse `dk_*` assumptions from older docs.
2. **Research streaming versus API streaming:** the PikaStream article describes continuous video, while the creative media API describes queued generation. Keep separate adapters and access gates.
3. **Plugin tool count drift:** organization description and current README disagree. Avoid hardcoding counts; discover actual capabilities after authentication.
4. **Creature versus human avatar:** preserve Lummings as fictional creatures. Do not depend on human-face identity extraction or photo onboarding.
5. **Current code versus release notes:** current local app includes project-backed SQLite storage. The earlier static/localStorage release note is historical, not the implementation baseline.
6. **Legacy character naming:** local engine has Luna/Lila and Sprout/Pip aliases; older brand text does not justify changing app IDs or duplicating profiles.

## Inspected local sources

- `README.md`, `docs/APP_DESIGN_PLAN.md`, `docs/companion/RELEASE_NOTES.md`: product intent and older delivery descriptions.
- `docs/companion/index.html`, `family-app.js`, `project-store.js`: current integration and persistence paths.
- `src/lummings/family_server.py`: local SQLite, snapshots, exports and request checks.
- `src/lummings/engine.py`, `server.py`, `artwork.py`: persona aliasing, experimental chat route and character visuals.
- `brand/CHARACTER_BIBLE.md`, `pyproject.toml`: creative direction and current Python project shape.

Existing modifications/untracked app files were observed before writing. This task adds only `docs/avatar-generation/`; it does not rewrite the app, original documents, databases or artwork.

## Questions to resolve at implementation time

| Question | Why it matters | How to answer |
|---|---|---|
| Which current Pika account/API agreement permits the intended family product? | Consumer access and downstream application rights differ | Review current provider terms and obtain written clarification if needed |
| Does a current PikaStream SDK support browser embedding and creature references? | Determines feasibility of true live generation | Verify current SDK/docs and run a synthetic character session |
| Which image provider best preserves the crew? | Prompt claims alone cannot establish identity quality | Run the visual benchmark and compare cost per accepted result |
| What is provider retention/deletion behavior for prompts, refs and outputs? | Determines truthful data disclosures and erasure | Verify agreement, configuration and deletion tests |
| Which master images and wearable layers are fully approved? | Determines identity anchors and instant transformations | Record hashes, rights and explicit art review |
| Is first deployment local-only or a hosted family service? | Changes authentication, storage and operational work | Default first engineering pilot to the current local app |
| What hardware is actually available for optional local inference? | Model/VRAM assumptions can be wrong | Run current identity/GPU/service diagnostics if that track is selected |

## Audit of this blueprint task

Read-only commands included `rg --files`, `git status --short`, targeted `Get-Content`, and `Invoke-WebRequest` to official GitHub/Pika sources. Source-file reads and provider-specification requests succeeded. An optional `Get-ChildItem` probe for ancestor AGENTS files returned exit 1 because one candidate did not exist; the two existing instruction files were then read successfully. The web Markdown renderer failed on two Pika Markdown URLs; direct HTTPS reads succeeded.

Artifact verification is limited to documentation links, required content and scoped file additions. No application regression result or measured provider performance is claimed.
