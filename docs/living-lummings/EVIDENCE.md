# Evidence and decisions

[Master blueprint](README.md) · Inspected 15 October 2026, Australia/Sydney.

## User direction

The supplied conversation asks for Pika.me-style changing avatars and on-demand image/video creation, expanded to creative agents and skills. Pixel was requested as a separate proving ground. Latest instructions require the newest version, no reversion, preparation inside the Lummings repository, inspection before changes, and a full blueprint. The current implementation update below supersedes the earlier planning-only scope: a Lummings-native creator job/review flow and opt-in provider adapter are now coded. No paid provider run or deployment is claimed.

## Verified local findings

| Finding | Evidence and limit |
|---|---|
| Newer app connected to character API | HEAD b43886d, docs/app/index.html and server.py; source verified |
| Five dedicated model mappings | engine.py and modelfiles; installed availability not proven |
| App path one parent too high | Computed path points outside lumming to projects/docs/app/index.html, absent |
| Portrait routes not served | Current do_GET only handles app and persona reads |
| HEAD/no-cors availability probe | App source; does not establish successful chat readiness |
| Transformations/scenery simulated | Timed SVG/emoji updates; no media generation requests |
| API chat bypasses demo creative routing | sendMessage branches inspected |
| Unsafe HTML interpolation | appendMessage/templates need safe text rendering |
| Separate family app/storage code | companion files, project-store and family_server; retain separately |
| Servers/model availability | No listeners on 8511/8512; Ollama unreachable on 11434 in this session; transient observation |
| Latest Pixel baseline | 647cb05 includes designer over chat/local generation; source verified |
| Pixel generation not reference-conditioned | Empty latent workflow; gen jobs have no source image input |
| Pixel designer needs fixes | Six themes vs three server options; generated avatar not persisted by Enter; errors swallowed |
| Existing user work | Modified README/database and untracked companion/blueprint files; baseline records this |

These establish source presence and specific gaps, not complete runtime correctness. No fresh GPU generation or Lummings behavioural suite was run for this document.

## Reconciling older instructions

- APP_DESIGN_PLAN prioritised authored-only release and described docs/app as disconnected. The later commit connects chat; current user direction makes creative AI central. Preserve authored stories while updating sequencing.
- The old avatar blueprint selected docs/companion as the main integration surface. Use newer docs/app for creative companions and shared services for the separate adventure app.
- Current canonical names are Luna/Sprout; older Lila/Pip IDs require compatibility, not duplicate characters or destructive renaming.
- HEARTLIGHTS.md governs light names where older character descriptions disagree.
- README's static startup, model details and blanket local/cloud statements require implementation-time reconciliation. Do not use them to infer current runtime health or silently constrain optional cloud design.

## External evidence refreshed

1. [Official Pika plugin repository](https://github.com/Pika-Labs/Pika-Plugins) documents MCP, skills and plugin surfaces. Summary and README tool counts disagree; no count is an architectural dependency. Actual authenticated tools and downstream embedding rights remain unverified.
2. [Pika real-time video article](https://pika.art/blog/introducing-real-time-video-chat) describes audio-conditioned streaming and mid-stream reference changes. This supports a research direction; it does not prove our access, creature quality or operating latency.
3. [Official LTX-Video repository](https://github.com/Lightricks/LTX-Video) documents image-conditioned workflows. Upstream options are not evidence that Pixel's installed checkpoint/graph preserves Lummings; benchmark exact versions.
4. Current adapter targets use [fal Flux.2 edit pricing and API](https://fal.ai/models/fal-ai/flux-2/edit) and [fal Pika v2.2 image-to-video pricing and API](https://fal.ai/models/fal-ai/pika/v2.2/image-to-video). On 16 October 2026, listed example pricing is US$0.012 per MP for Flux input and output (US$0.024 for 1 MP each) and US$0.20 for a 5-second 720p Pika v2.2 clip. These are provider list prices, not a guarantee of final charges. Adapter code was exercised with fakes only; no provider credential, upload or paid request was used.
5. [fal asynchronous queue documentation](https://fal.ai/docs/documentation/model-apis/inference/queue) documents durable queued requests, cancellation via the queue API, and the caveat that an in-progress request may still complete after cancellation is accepted. The local adapter currently does not call the cancellation endpoint; the app only promises cancellation before provider submission and requires manual charge reconciliation for uncertain failures.

No provider performance figure or old price is a Lummings guarantee. No authentication, paid generation, download or provider installation was performed for planning.

## Architecture decisions

| Decision | Reason | Revisit condition |
|---|---|---|
| Extend current app, retain companion | Preserve work and latest direction | Measured UI constraints justify an explicit migration |
| Own identity and memory | Provider independence and coherent characters | Never silently hand canonical ownership to a consumer account |
| Modular API + worker | Fits current Python baseline and isolates long jobs | Measured scale needs independent services |
| Reference-conditioned media | Text naming alone cannot preserve identity | A benchmark proves a better controlled approach |
| Prepared presence + queued creation | Responsive companion during rendering | Live adapter passes its own gate |
| Explicit memories/project scope | Recoverable personalisation and intentional sharing | Separately approved use case needs more data |
| Pixel as source material | Reuse engineering without copying branding/data/defects | Stable contracts justify a shared package |

## Open decisions by milestone

M1: approved reference packs, wardrobe artwork and voice rights. M2: measured GPU/VRAM, owned workload policy and model choice. M3: provider/account, local quality tradeoffs and budget. M4: target age/markets and family mode. M6: hosting/support responsibility and pricing. R1: actual supported streaming integration. Working assumptions are local creator pilot first and cloud only by explicit configuration; unknowns do not block baseline repair.

## Audit scope

Added a new planning package and linked it from the older avatar blueprint. Existing app code, artwork, database, models and Pixel remain untouched. Selected hashes are continuity checks, not backups. All schedules, thresholds and new architecture are proposals unless labelled verified above.
