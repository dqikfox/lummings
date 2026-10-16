# Family app implementation — 13 October 2026

Run from the repository root:

```powershell
python -m http.server 8512 --bind 127.0.0.1 --directory docs
```

App: http://127.0.0.1:8512/companion/

Parent-facing landing page: http://127.0.0.1:8512/companion/for-parents.html

## Delivered

- Updated character-led home, adventure library and companion selection using existing approved portraits.
- Five authored branching adventures with hints, skips, pause/back, explanations, completion and optional locally saved resume.
- Up to six nickname-based profiles, each with separate story state, discoveries, selected companion and creative notebook.
- Adult-handoff dashboard with actual completion counts, profile management, local-save opt-in, JSON export and data erasure.
- Larger reading text, reduced-motion/calm setting and per-visit break reminders checked at adventure entry and transitions. Reminders are dismissible, not parental enforcement or a background timer.
- Creative story prompts and a persistent notebook when saving is enabled, plus an off-screen family invention activity.
- Parent-facing promotional page and three adult-facing campaign concepts in `marketing/FAMILY_APP_CAMPAIGN.md`.

## Architecture and limits

`family-store.js` owns local persistence. `family-app.js` renders the main family views. `app.js` hosts the shared reader, powered by `story-engine.js`. `more-stories.js` adds four new stories to the existing Lumo story. The original fifteen-story read-together collection is preserved separately; it has not all been converted into interactive adventures.

No backend, payment system, authentication, cloud sync, live AI, or service-worker offline installation is included in this browser release. The adult handoff is explicitly not a security boundary. Optional data lives unencrypted in this origin's localStorage. Export produces JSON; import is not implemented. Clearing browser storage removes the saved family. Storage failures are reported in the footer; the current visit remains usable. Temporary drafts may be lost on reload.

This is a functional local browser release, not a claim that the broader commercial product and all future features are complete. No public deployment or ad purchase was performed.

## Validation

```powershell
node --test tests/story-engine.test.cjs tests/family-store.test.cjs
node --check docs/companion/app.js
node --check docs/companion/family-app.js
$env:PYTHONPATH = Join-Path (Get-Location) 'src'
python -m pytest -q
git diff --check
```

Nine JavaScript tests pass, covering every story branch, transition behavior, persistence opt-in, profile isolation, deletion, reset, and corrupt/denied storage.

Python regression suite: 45 passed, one existing failure in `test_canonical_names_and_legacy_aliases_keep_character_identity`; its expected legacy artwork title disagrees with current artwork. No Python code or tests were changed for this browser release.

Browser walkthrough confirms the home and dashboard render, Luna's route resumes at the exact step after reload, completion creates the correct discovery, and notebook content survives reload when saving is enabled. No browser console errors observed during that walkthrough. These checks do not constitute a full accessibility audit or a child-content pilot.
