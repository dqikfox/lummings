# Living Lummings — master blueprint

15 October 2026 · Proposed build specification, not a statement of shipped capability.

## The product

A Lumming is a recognisable creative companion with its own character, voice and Heartlight. You talk with it, imagine together, change its appearance, create illustrations and films, and keep shared discoveries. Its core personality stays coherent while its interests and presentation adapt through explicitly remembered experiences.

The target is the Pika.me-style conversational creative experience expressed through the Lummings world: **a character that participates in making things, with creation happening inside the conversation.** It should feel responsive while high-quality media renders.

“Lumo, become a moon explorer. Let’s make a film about rescuing a lost star.” Lumo responds in character, offers a story choice, switches to an approved explorer look, builds a storyboard from registered artwork, creates a selected scene, animates it, narrates it and saves the result. You can interrupt, revise a shot, restore an earlier look or continue tomorrow.

## Authority and continuity

This is the current implementation-planning entry point for the latest user direction. It supersedes the sequencing and integration assumptions in older app/avatar plans where they conflict. Historical files remain intact. Proposed decisions here do not override subsequent user decisions or promote unapproved artwork into canon.

Priority: latest explicit user instructions → verified current working tree/runtime → current character and Heartlight canon → proposed decisions here → historical plans. Recheck uncommitted work before implementation. Never reset to a historical handoff or replace the current app with Pixel's robot interface.

- Lummings: `C:\Users\KING\projects\lumming`, inspected HEAD `b43886d`, polished app wired to character models.
- Pixel reference: `C:\Users\KING\projects\pixel`, inspected HEAD `647cb05`, designer and six themes over local conversation/GPU generation.
- Extend `docs/app/index.html` and the Lummings character service. Preserve `docs/companion/` as the authored adventure experience; share services later.
- Existing modified README/database and untracked app/blueprint files must be preserved. A clean Git checkout is not the full project baseline.

## Document map

Implementation has started: see [current build status](IMPLEMENTATION-STATUS.md) for completed baseline repairs, verification and remaining work.

| Document | Purpose |
|---|---|
| [Product experience](PRODUCT.md) | Characters, journeys, presence, skills and long-term ambition |
| [Architecture](ARCHITECTURE.md) | Modules, contracts, data, recovery and provider strategy |
| [Roadmap](ROADMAP.md) | Milestones, effort, ticket dependencies and acceptance |
| [Validation and economics](VALIDATION.md) | Quality gates, costs, operating controls and risks |
| [Evidence and decisions](EVIDENCE.md) | Current implementation, conflicts, sources and unknowns |
| [Baseline manifest](baseline.json) | Commits, selected source hashes and inherited working-tree state |

## Ambition in layers

1. **Alive:** distinctive conversation, expressive stage, character voice and interruption.
2. **Creative:** consistent images, reversible looks, clips, stickers, stories and narration.
3. **Personal:** reviewable preferences and shared discoveries without erasing character identity.
4. **Collaborative:** five characters contributing different strengths to user-directed projects.
5. **Continuous:** optional generated live video with reference changes during a call, after feasibility is proven.
6. **Extensible:** adult creator tools, reviewed skill packs, private cross-device projects and eventually a physical companion using the same services.

The first release proves conversation → creation → saved result. A gallery, emoji transformation or storyboard demonstration alone is not that product.

## First complete vertical slice

Lumo, real conversation, expressive stage, three approved looks, one reference-conditioned image operation, image-to-video from an accepted still, private gallery, cancel/retry/undo and reload recovery. Voice starts with explicit playback, progressing to interruptible push-to-talk. Continuous generated video has a separate research and integration milestone.

Start with a local creator pilot. Family deployment follows content, memory and ownership controls. Hosting adds authentication and operating gates. Ages 6–9 in the older plan remain an audience hypothesis, not a newly confirmed launch requirement.

Success means users complete satisfying creative projects with a recognisable companion, without handling model names or moving files manually. Every result can be reopened, revised and exported. The character makes room for people and time away; maximum time spent chatting is not the objective.
