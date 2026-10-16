# Quality, operations and economics

[Master blueprint](README.md) · Proposed targets, not current results.

## Quality gates

| Area | Target | Evidence |
|---|---|---|
| Immediate response | Local state/wardrobe feedback p95 under 150 ms | Target-device browser traces |
| Chat | Warm first text p95 under 3 s; cold separately reported | At least 100 representative turns per model/hardware |
| Interruption | Audio stops within 300 ms | Barge-in timestamps; stale segments never restart |
| Image identity | At least 90% accepted first candidates on 50-scene set | Human rubric, reviewer agreement, per-character breakdown |
| Video continuity | At least 85% accepted on 20 reviewed stills | Full playback plus first/middle/last-frame review |
| Jobs | No duplicate dispatch in defined crash/retry tests | Provider IDs, ledger and fault evidence |
| Isolation | No cross-profile/family record/event/media access | Direct URL, stream replay, cancellation/deletion tests |
| Render latency | Publish measured cold/warm/queue p50/p95 before SLA | Version, settings, hardware and sample size |
| Accessibility | Core journeys usable with keyboard/captions/zoom/calm mode | Manual task results; no blanket conformance claim |

Image set: neutral view, outfit, side view, prop, lighting, emotion, complex background, return to base and two-character composition. Score silhouette, face, palette, Heartlight, accessories, anatomy, intent and style separately. Video adds flicker, identity drift, speech sync and unintended morphs. Expand samples before treating tail latency as reliable. Preserve failure examples.

Educational explanations require checked facts and diagram labels. Test the distinction between fictional Heartlight powers and actual abilities; no claims of reading minds, diagnosing feelings or detecting real danger.

## Failure matrix

Offline provider, auth expiry, rate limits, wrong MIME, corrupt/oversized output, disk full, missing model/node, GPU contention/OOM, process death around submission, late output after cancel, duplicate turn, browser reconnect, competing appearance choices, profile switch, deletion during work, failed export and backup restore. Every case has bounded retry, honest user state and no unintended repeat spending or loss of accepted work.

Run existing Python and family JavaScript regressions during implementation; this document does not claim a currently passing Lummings suite. Add tests for meaningful contracts rather than code-mirroring snapshots.

## Audience and personalisation

Creator testing precedes family deployment. Confirm launch age, markets and adult-controlled features before enrolment. Provider/legal suitability review is a release task, not a compliance claim here.

Family defaults: fictional avatars, explicit preferences, private projects, finite sessions and easy exits. Avoid automatic sensitive fact extraction. Adult convenience gates are not authenticated security. Review prompts, references, outputs and tool actions; a persona prompt alone is not enforcement. Provide human review for uncertain media.

Chat, audio, photos, preferences and media have separate retention choices. Proposed pilot defaults: discard processed audio unless explicitly saved; purge failed temporary outputs after a documented debugging window; retain approved projects until removal; disclose backup expiry. Choose exact periods before launch, implement them, and verify deletion of derived summaries/cache. Avoid raw family prompts and secrets in routine logs.

## Economics

Use current operation-specific quotes, not historical list prices. Record provider/model, resolution, duration and reference inputs. Track USD provider charges separately from any AUD customer price; specify exchange-rate/date assumptions when converting.

Monthly variable cost = conversation tokens + ASR minutes + TTS usage + image attempts + video attempts/duration + live minutes + storage/egress + moderation. Local inference also consumes electricity, hardware capacity and loading time.

**Cost per accepted asset = total cost across attempts / accepted outputs.** Poor identity retention can make a cheap model expensive. Reserve the entire permitted retry budget atomically and stop when it is exhausted. Price product offerings only after measuring accepted-output cost and support burden; do not sell unbounded generation on unmeasured assumptions.

Illustrative workload, not a provider quote: 100 families × (40 images + 8 clips + 60 voice minutes/month) = 4,000 accepted images, 800 clips and 6,000 voice minutes. At assumed 80% image and 75% video acceptance, budget approximately 5,000 image attempts and 1,067 clip attempts. Multiply by measured unit costs and add operations/contingency. Continuous video gets a separate minutes/concurrency budget.

Single-GPU ideal render capacity = allocated seconds/day ÷ mean render seconds. An assumed 120-second render with eight reserved GPU hours gives 240 renders/day before loading/failures/chat/voice overhead. This is capacity arithmetic, not a benchmark. Configure queue limits using real measurements.

## Operating gates

Local: clear launch/stop/configuration, disk limits, queue inspection, orphan cleanup, backup/restore and diagnostics. Never unload unrelated model sessions to make a demo work.

Family pilot: content review, scoped data, deletion, device/accessibility checks, recoverable saves, adult feedback and a limited cohort. Never import Pixel personal data.

Hosted: authentication, origin/session controls, private object storage, tenant-scoped workers/events, rate limits, server-side secrets, dependency maintenance, incident contact and tested rollback. Trace IDs connect turns/runs/jobs/costs without publishing private prompt text. Monitor queue depth, errors, review rejection, cost per accepted output, disk pressure and worker health.

Live avatar: supported authenticated embedding, creature benchmark, barge-in, mid-call reference change, ten-minute stability, reconnect, per-minute cost and concurrency limits. A queued talking clip or research latency claim does not meet this gate. Failure leaves prepared/rigged presence plus voice and queued creation available.

## Product measures and risks

Measure successful first creation, independently finished projects, recognisability, revisiting saved work, adult clarity/trust and abandonment from latency/errors. Avoid targets rewarding emotional dependence or endless chat.

| Risk | Response |
|---|---|
| Identity drift | Reference packs, per-character review; never auto-promote generated masters |
| GPU stalls conversation | Owned scheduler, admission/queue and configured alternative capacity |
| Streaming unavailable | Time-box research and retain expressive-stage fallback |
| Demo mistaken for generation | Replace fake completion/progress with real job events |
| New work overwritten | Baseline manifest, dirty-tree inventory and additive migration |
| Retry costs escalate | Atomic reservations and bounded skill attempts |
| Family data leaks | Scope every asset/event/record and test before hosting |
| Endless scope | Complete M3 journey before broad productivity integrations |
