# Lummings family app

The current browser release includes five interactive adventures, local family profiles, a parent dashboard, optional saved progress, creative notebooks, and a parent-facing landing page. See [current release notes](RELEASE_NOTES.md) for run commands, validation, and limitations.

The notes below describe the earlier first slice and are retained as implementation history. Their statements about visit-only storage no longer describe the optional local-save mode.

# Lummings companion: first working slice

## Game-style design update

The app now features a twilight starfield, floating character stage, animated Heartlight, three working destination portals, selectable character showcase and five-stage quest indicator. Lumo's constellation scenes include an optional 24-star counting board with independent toggles and an announced count. The board resets when leaving its scene; adventure progress still lasts only for this page visit. The Story Grove and Moonlit Lookout open the authored storybook; they are not additional game engines.

Verified in the browser: Starfall portal, individual star counting, selecting Luna and its story link, and home/reader layouts at phone width without horizontal overflow. Reduced-motion CSS disables animation and transitions. Captures: `game-home-preview.png` and `game-quest-preview.png`.

Open `index.html` directly, or serve the repository's docs folder and visit `/companion/`. No build, dependency install, account or model required. Runtime dependencies are local scripts, CSS and existing artwork.

Includes Home, Adventures, the five-character crew, visit-only Discoveries and grown-up information. Constellation Gate is a complete authored adventure with three distinct explanation branches, optional practice with specific feedback, hints, back, pause/resume, reflection skip and completion. The other fourteen stories remain linked in the read-together collection.

Storage: JavaScript memory only; closing or reloading clears progress. No analytics, microphone, model calls or persistent profile storage. Hosting may independently log requests. Persistent profiles and actual AI are future work.

Implementation: `content.js` contains the character registry and versioned story graph; `story-engine.js` validates destinations and ending reachability and implements transitions; `app.js` renders text using DOM text content. Classic local scripts allow direct-file use without a fetch server.

Verification commands from repository root:

```powershell
node --test tests/story-engine.test.cjs
node --check docs/companion/app.js
$env:PYTHONPATH = (Join-Path (Get-Location) 'src')
python -m pytest -q
git diff --check
```

Browser walkthrough verified story start, hint reveal, pause/resume, split strategy, explanation, mistaken-answer feedback, reflection skip, completion and discovery summary. Full mobile/screen-reader testing remains outstanding. `preview.png` records the actual desktop home screen.
