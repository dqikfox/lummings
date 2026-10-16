# Delivery plan and acceptance gates

Status: proposed backlog, not completed engineering work. [Blueprint](README.md) · [contracts](CONTRACTS.md) · [sources](SOURCES.md).

## Sequence and effort

Assume one experienced full-stack developer with access to approved character art and part-time visual/content review. Estimates are engineering working days, exclude provider procurement/review delays, and are not calendar commitments. Some preparation overlaps; plan roughly 5–8 weeks for a tested local creative pilot. A public family service is a subsequent project.

| Stage | Effort | Deliverable | Exit gate |
|---|---:|---|---|
| 0. Freeze current baseline | 1–2 days | Backed-up local data, recorded dirty tree, registry/aliases, approved Lumo reference set | Current stories and saves still work; no silent character rename |
| 1. Instant character stage | 3–5 days | Lumo prepared states, three looks, Heartlight, undo and reduced motion | Fast local transitions and stable identity; no provider required |
| 2. Durable media backend | 4–6 days | Job DB, worker, cost reservations, profile ownership, provider adapter | Restart recovery, duplicate suppression and hard cap tests pass |
| 3. Reference image generation | 4–6 days | Approved prompt presets, image jobs, review and private gallery | Reference-conditioned output passes visual rubric |
| 4. Story clips | 3–5 days | Five-second image-to-video, playback/poster, owned downloads | Identity, playback and late-result controls pass |
| 5. Pilot hardening | 5–8 days | Budget controls, deletion, error UX, documentation and benchmark report | Gate checklist below passes; provider/data eligibility documented |
| Optional live avatar spike | 3–5 days after access | Creature test, interruption/ref update, latency/cost report | Explicit go/no-go; never blocks stages 1–5 |

## Implementable tickets

| ID | Task | Dependencies | Evidence of completion |
|---|---|---|---|
| AV-01 | Register public character IDs, aliases and reference hashes | None | Lumo ruby master confirmed; Luna/Lila and Sprout/Pip map once |
| AV-02 | Add `avatar-stage.js` with state/appearance separation | AV-01 | Idle/listening/thinking/speaking/celebrating plus static reduced-motion view |
| AV-03 | Produce and integrate three approved Lumo looks | AV-01 | Same proportions and markings; asset rights and metadata recorded |
| AV-04 | Add My Lumming look selection and undo | AV-02, AV-03 | Reload preserves active look; undo restores prior version |
| GEN-01 | Add separate media SQLite store and leased worker | None | Process restart recovers queued jobs; two workers cannot claim one job |
| GEN-02 | Add quotes, atomic spend reservations and global stop switch | GEN-01 | Concurrent requests cannot exceed cap; failures settle correctly |
| GEN-03 | Implement direct Pika or fal adapter after schema/account validation | GEN-01, GEN-02 | One synthetic image and one five-second clip verified end to end |
| GEN-04 | Compile bounded scene requests with master references | AV-01, GEN-03 | Unknown options rejected; no full memory transcript sent |
| GEN-05 | Validate/quarantine/review/save generated files | GEN-04 | Unsupported/corrupt/unsafe assets never enter child view |
| GEN-06 | Add Creative studio job cards, retry and reconnect | GEN-05 | Reload resumes status; cancel is honest about in-flight provider cost |
| GEN-07 | Add “Animate this” to accepted stills | GEN-05, GEN-06 | Separate quote/reservation; video points to exact source still |
| GEN-08 | Apply approved new portrait with version check | AV-04, GEN-05 | Older finishing job cannot override a newer user selection |
| OPS-01 | Implement scoped removal/erasure and backup retention rules | GEN-05 | Profile deletion prevents late-job resurrection and derived-reference reuse |
| OPS-02 | Reconcile README/privacy/release notes with actual local/cloud modes | GEN-03 | Claims match actual transmission and project storage behavior |
| OPS-03 | Run benchmark matrix and regression checks | All MVP tickets | Results include cost, latency, accepted-output rate and failures |

For the first paid benchmark, use developer-owned Lumo references and synthetic requests only. The provider account, funding and deployment steps are subsequent implementation actions, not work completed by this document.

## Benchmark matrix

Start with ten Lumo prompts: neutral greeting, explorer clothing, moon garden, rainy-day clothing, quiet library, joyful discovery, side view, hands holding a prop, changed lighting, and return to original outfit. Generate two image candidates per prompt. After image review, animate ten accepted stills once at five seconds/720p.

Then repeat a smaller smoke set for Luna, Sprout, Nori and Moki to detect models that preserve human faces but fail on creature anatomy. Expand to at least 100 representative jobs before treating a p95 latency figure as a useful operating estimate. Record cold/warm behavior and provider queue time separately.

Visual rubric: correct character and silhouette; stable face/eyes; retained defining colours and Heartlight; outfit matches request; no unintended extra limbs/fingers; scene suits the story; consistent style. Videos additionally need temporal stability and no disturbing morphs. Reviewer agreement matters; automated similarity is supporting evidence only.

Targets for the pilot: ≥90% first-pass character acceptance on the defined benchmark; no known unsafe or corrupt result displayed; duplicate user submissions incur no duplicate provider job; all charged attempts reconcile. These are goals requiring measurement, not claims of current quality.

## Functional and failure acceptance

- Existing five adventures and family persistence continue with media disabled.
- Changing character or profile during generation does not show the previous profile's result.
- Two concurrent “change look” jobs never auto-apply out of order.
- Double-click, browser reload and network retry reuse the same logical job.
- Worker restart between provider submit and local acknowledgement does not blindly charge again.
- Provider 401, 429, timeout, failed-job envelope and malformed result each produce a recoverable, bounded outcome.
- Queue status is meaningful; estimates never masquerade as measured progress.
- Cancellation removes unwanted output from the experience and still reconciles real cost.
- A failed moderation/identity review cannot be bypassed by direct asset URL or an old cache entry.
- Profile erasure tombstones pending jobs and removes references/derivatives under the stated retention policy.
- An old saved appearance can be restored without another paid generation.
- Keyboard navigation, captions/transcripts where relevant, reduced motion and readable error text work at phone sizes.
- Cloud creation disabled means no media-provider calls; existing local model choices remain separately labelled.

## Public release gates

Local success does not establish readiness for public families. Before hosting, add real family authentication, tenant isolation, private storage, secure session handling, provider suitability review, support/abuse handling and tested data lifecycle controls. Choose which settings an adult controls and make their enforcement match the deployment model.

Agree age range and distribution markets; confirm provider terms for that audience and media use. Review child-oriented privacy/content obligations with qualified support where needed. Do not migrate child transcripts or photographs simply to make an avatar feel more personal.

## Live avatar go/no-go

Proceed only with verified streaming access and commercial embedding terms. Test a nonhuman Lumo reference, mid-session wardrobe/reference change, speaking interruption, reconnection, 10-minute stability, lip-sync, reduced-motion fallback and per-minute cost under concurrency. Use synthetic/adult test audio. A staged research video or a generated talking-head clip does not satisfy this gate.

If access or quality fails, ship the prepared avatar + speech + asynchronous creation architecture. It already delivers changing characters and personalized image/video content while preserving a responsive app.
