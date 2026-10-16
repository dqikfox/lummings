# Implementation status — 16 October 2026

## 16 October 2026 — Pika.me-style avatar and generation gate

The product target is explicit in the [master blueprint](README.md): a recognizable Lumming changes into an approved look, makes a scene from its canonical references, and can animate an accepted result. The current app now has a first **Lummings-native creation and review workflow**. It adds durable image/video job records, immutable reference hashes, request-key idempotency, strict scene/wardrobe choices, a private generated-output directory, review states, and source-image hash lineage for animation. The new Character Studio lets the creator save local drafts, review available provider output, accept or reject a candidate, and start a video draft from an accepted still. Generated results never replace the active portrait.

The generation capability remains `false` in the current default local app. An optional server-side fal adapter now supports reference-conditioned Flux.2 image generation and Pika v2.2 image-to-video; it is constructed only when `LUMMINGS_MEDIA_PROVIDER=fal` and `FAL_KEY` are both set. It is never exposed with the key to the browser. Before a configured provider call, the server requires an unexpired, single-use, job-bound quote and explicit confirmation to send the canonical reference and prompt. The quote displays the model, USD amount and basis. The app was not configured for fal and no external request or spend was made.

These are model-list reference prices checked 16 October 2026: Flux.2 edit is priced by megapixels, so the adapter's 1 MP input plus 1 MP output quote is US$0.024; Pika v2.2 image-to-video is US$0.20 for 5 seconds at 720p. Actual billed cost may differ with provider accounting, retries or changed rates. The current flow has no workspace-wide spend cap or budget reservation. The adapter bounds outputs and allowed download hosts, and interrupted submissions are marked for manual provider-history checks rather than blind resubmission. No benchmark yet establishes character consistency, wardrobe quality, retention terms or live-avatar behavior. Wardrobe labels remain experimental, not approved character art.

Verification: `PYTHONPATH=src python -m pytest -q` — 71 passed, including persistence, idempotency, invalid reference/options, quarantined output, accept/reject, accepted-still-only animation, HTTP consent, fake-provider execution and asset retrieval. All 9 existing family/story JavaScript tests pass; app scripts parse and `git diff --check` passes. A separate temporary-database browser run saved a scene draft, reloaded the page and reopened the draft; the 390 × 844 viewport had no horizontal overflow. The app on port 8511 was restarted with the updated code and left on the new Studio screen. Checks exercise the provider seam without cloud credentials, upload or spend.

That first increment's next gate was to add workspace budget limits and cancellation/reconciliation; those are now covered below. Remaining gates are provider retention review, robust remote cancellation/status reconciliation, and a full responsive browser journey. Live-avatar streaming remains separate.

## 16 October 2026 — spend guard and recovery controls

The local paid-generation path remains off by default. The optional fal adapter requires a positive `LUMMINGS_MEDIA_DAILY_BUDGET_USD` limit, with quote consumption, reservation and queueing committed atomically. Queued cancellation and manual reconciliation of uncertain charges are implemented and tested. No live provider call or spend has occurred.

The opt-in media provider now requires `LUMMINGS_MEDIA_DAILY_BUDGET_USD` to be set above zero before quote issuance. Its default is zero. Quote consumption, a daily UTC budget reservation, and queueing happen in one SQLite transaction, so parallel requests cannot exceed the remaining cap. The UI shows the daily limit, reserved/used amount, remaining amount and each quote. Successful output settles the reserved quoted amount; uncertain failed submissions keep the reservation held until the user checks provider history and reconciles it as charged or not charged. The latter restores that amount to today's available budget.

A queued job can be cancelled before worker submission; the reservation is released and the worker's state transition prevents that job from being sent. Once provider submission starts, this local cancel path refuses to claim a cancellation succeeded. The app exposes explicit charge reconciliation for failed jobs with unresolved reservations. It does not yet send a fal cancellation request or automatically reconcile provider status after a restart; a running or interrupted provider job remains a manual provider-history check.

Verification: `PYTHONPATH=src python -m pytest -q` — 85 passed, 13 subtests passed; all 9 family/story JavaScript tests pass; app syntax, Python compilation and `git diff --check` pass. Coverage includes budget arithmetic and simultaneous reservation, zero-budget lockout, queued cancellation, success settlement, failed-charge reconciliation, provider-key non-disclosure, HTTP consent and fake-provider generation. The live app returned `mediaProviderConfigured: false`, `mediaGeneration: false`, `liveAvatar: false`, and a zero-dollar daily limit. Browser check confirmed `/#studio` opens Character Studio with the canonical portrait and disabled provider generation. No external job was created and no charge was incurred.

Next gate: add durable worker leases and provider status reconciliation, verify retention and data deletion terms, and complete a browser run through budget display, quote, fake submission, review, cancellation and reconciliation at desktop and phone sizes. Live-avatar streaming remains separate.

## 16 October 2026 — extracted media library

The current app now has a Library destination and a home-page entry for 49 catalogued assets: five current illustrated portraits, 29 extracted concepts, and 15 existing video clips. Search matches titles and filenames; filters show portraits, concepts, films or the local shortlist. Full-size image previews and native video controls include original source paths. Concepts and the alternate-cast video are labelled without changing character identity.

`scripts/catalog_creator_media.py` creates `data/creator/media-catalog.json` and lightweight previews. IDs derive from SHA-256 content hashes; duplicate bytes would share one item. Originals are referenced in place and remain unchanged. The catalog builder deliberately excludes embedded archive copies and temporary audio. Regenerate the catalog and restart the server after adding source files.

`src/lummings/media_library.py` confines serving to catalogued IDs in the selected source directories. The gateway supports bounded streaming and single HTTP byte ranges for video seeking. Unknown IDs, missing files and invalid ranges return explicit errors. Shortlist updates use the existing origin/host/token checks and persist in `data/creator/conversation-media.sqlite3`; removing a shortlist entry does not delete its source. This is still a single local creator workspace, not multi-family storage or authentication.

Validation: 63 Python tests pass, including byte-range boundaries, source confinement, unavailable files, shortlist persistence/removal and malformed writes. One initial full-suite run hit a Windows socket abort in an existing origin-rejection test; that test and the complete suite passed on rerun. JavaScript syntax and Git whitespace checks pass. Live browser checks covered category/search filters, full-size preview, shortlist persistence across reload, removal, and complete playback of the 10-second silent Heartlight story. Phone layout at 390 × 844 showed no horizontal overflow and no broken visible thumbnails. The synthetic shortlist choice was removed after verification. Legacy `lummings.sqlite` SHA-256 remains equal to the recovery baseline.

Video review remains limited: all 15 posters were inspected, 14 files have audio tracks, and no audio content was reviewed. Video 10 explicitly identifies the alternate cast/earlier names. [Poster inventory](extracted-assets/video-inventory.jpg). [Verified Library screen](library-mobile.jpg).

This increment provides a library for existing local source media. It does not implement generation jobs, provider calls, animated chat avatars, or approval of alternate designs. Next: scoped conversation/transcript recovery and the durable generation-job service in the existing roadmap.

## Artwork correction — supersedes SVG stage claims below

The user rejected the simplified SVG characters. The creator app now uses the five existing detailed illustrated PNG originals from `marketing/demo-assets`, served as byte-identical copies in `docs/assets/characters`. Feed, stage, chat, world and profile references are corrected. The registry identifies this set as `illustrated-2026-10-13`; tests enforce PNG paths, master-byte equality, and absence of SVG portrait paths in the app.

The expression selector is hidden because matching illustrated expression variants do not exist yet. Thinking never substitutes an SVG. Saved appearance history remains intact and atmosphere changes remain available. Previous claims below about an approved SVG stage and its screenshot are historical and superseded by this correction. See [current artwork contract](../app/ARTWORK.md).

## M0 baseline repair delivered

- Latest `docs/app` served on loopback port 8511, with portrait and app-script routes.
- Added `/api/v1/capabilities`: installed character-model availability, creator mode, and honest unavailable media/live-avatar flags. Reachability is not a quality or latency guarantee.
- Browser uses same-origin requests and a per-process mutation token; server rejects foreign origins/hosts, invalid request bodies, traversal and client-supplied upstream URLs.
- Extracted the existing inline app script into `docs/app/app.js`; retained the current visual interface.
- Chat retains failed/offline drafts, blocks duplicate in-flight sends, ignores stale replies after switching character, and renders replies as text.
- Real thinking/ready status replaces the permanent listening label. Existing visual demonstrations are labelled temporary previews; unsupported mood sensing claims removed.
- New creator conversations use `data/creator/conversation.sqlite3`, ignored by Git. Existing legacy and family data are not migrated. No automatic fact extraction added to this creator gateway.
- `Start-Lummings.ps1` launches the local app. Optional server-controlled `LUMMINGS_OLLAMA_URL` selects its Ollama-compatible backend.

## Evidence

52 Python tests passed, including six gateway tests covering current app/portraits, private-path denial, host/origin/token checks, model readiness, validation and conversation storage. Nine family/story JavaScript tests passed. JS syntax and Python compilation passed.

Updated old sprite test expectations from retired Storyweaver/Moon-Tide Guardian labels to the current Spooky Poet/Cosmic Weirdo canon; artwork was unchanged.

Live browser confirmed the newer app and real Lumo response to a synthetic lost-star quest prompt. All five character models were discovered at that check; only Lumo inference was exercised live. The model took substantial cold-start time; no latency target is claimed.

Recovery snapshot: `C:\Users\KING\AppData\Local\Lummings\recovery\20261015-122443`. Includes tracked/untracked non-ignored project files and a SQLite backup. ZIP integrity, selected file restoration and restored database integrity passed. Original database hash matched the pre-change snapshot after testing.

## Limits / next milestone

This remains a single local creator workspace, not family-authenticated conversation. Creator dialogue is retained per character; current UI does not yet reload the transcript. Client timeout/cancellation, scoped sessions, stream events and full preference controls belong to CHAT milestones.

The app still uses external styling/fonts and has older preview features. CDN bundling, fuller accessibility, identity registry and persistent wardrobe are next work. No generated images/video, live generated avatars, voice, cloud credentials, model installation or public deployment were added here. Existing authored family app remains separate.

## Character studio increment delivered

The current creator app now has a five-character selector and expressive stage, using the existing canonical SVG artwork. The gateway supplies names, roles, canonical colours, Heartlight names, permitted expressions/backdrops, and SHA-256 hashes for 25 portrait references. Existing aliases resolve to canonical identities. Assets were not replaced.

Five authored expressions (warm, curious, playful, excited, sleepy) and three CSS atmospheres (observatory, garden, dreamscape) are selectable. Preview is explicit; Save look persists a character-specific revision. Undo appends a new revision and restores the preceding look. Compare-and-swap revision checks return HTTP 409 on stale writes, and the browser loads the current saved choice with an explanatory message. No-op saves do not create revisions.

Appearance history is separate from conversation and legacy data: `data/creator/conversation-appearances.sqlite3`. This remains one local creator scope; the schema is not a multi-family authorization boundary. All writes use the existing host/origin/token checks and exact option validation.

The stage has gentle float animation, reduced-motion CSS, canonical Heartlight labels, and a temporary curious expression during chat work. This is authored SVG presentation, not generated video or lip sync. The UI also retains per-character unfinished drafts and visible transcripts while switching within the current page. These browser buffers do not survive a page reload; server conversation history retrieval is still future work.

Fixed an existing closed Create overlay that intercepted navigation. Desktop discovery cards now form a three-column grid, the app has a readable maximum width, and appearance controls wrap on phones. A 390 × 844 browser check confirmed controls, portrait, composer and navigation fit without horizontal overflow.

### Verification

- 58 Python tests passed, including registry reference hashes, aliases, malformed options, token rejection, per-character isolation, repeated undo, monotonic revisions, simultaneous save conflict and server restart persistence.
- Nine existing family/story JavaScript tests passed; both app scripts pass Node syntax checks; Git whitespace checks pass.
- Live browser: saved Lumo playful/garden at revision 1, switched to Nori's independent default, returned to Lumo with the unfinished draft intact, reloaded and recovered the saved look, then used Undo to restore warm/observatory at revision 2. Synthetic draft cleared after the test.
- Screenshot: [mobile studio](studio-mobile.jpg).

### Remaining acceptance work

CHAR-01 is implemented for the 25 references consumed by this creator stage; reconciliation of every duplicate asset directory remains open. CHAR-02 is implemented for local creator expression/atmosphere choices. CHAR-03 is partial: expressive stage exists, but three approved wardrobe looks have not been authored or approved. Do not relabel atmospheres as outfits or mark all M1 work complete.

Next: scoped sessions and transcript reload (CHAT-02), then the media repository and job lifecycle (MEDIA-01/02). Complete wardrobe art acceptance before claiming a full wardrobe milestone. Preserve the current app and recovery baseline.
