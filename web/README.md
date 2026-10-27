# Bedtime web app

The Lummings bedtime app: stories, hugs, a bond that grows each night, recorded voices and a local parent gate.
It keeps everything in the browser. There is no account and no login.

```
cd web
npm install
npm run dev        # http://localhost:8080 (also reachable from a phone on the same network)
npm run typecheck
npm run lint
npm test
npm run build      # production build for Vercel
```

## What to know

- **Names:** Sprout and Luna are the public names. `lila` and `pip` only survive inside old saved data and persona file names.
- **Voices:** recordings live in `public/voices`. If a line has no recording, `src/lib/eleven-tts.server.ts` asks ElevenLabs for it from the server (set `ELEVENLABS_API_KEY` on the host). Only the friends' own authored lines go there, never anything a child types or says. The app never uses browser text-to-speech.
- **Microphone:** off by default. A grown-up can turn on "Talk" (browser speech recognition, which may send speech to the browser's speech service). `scripts/privacy-and-pwa.test.mjs` keeps this honest.
- **Nothing from other companies in the browser:** no remote scripts, fonts or trackers. Fonts are bundled from npm (`@fontsource-variable`). `scripts/privacy-and-pwa.test.mjs` fails if a third-party host appears in the source, apart from the one server voice file.
- **Home screen:** `public/manifest.webmanifest` and `public/icons/` (cropped from the locked Lumo portrait) make "Add to home screen" work.
- **Share cards:** set `VITE_SITE_URL` (for example `https://example.org`) at build time to add absolute `og:image` and `og:url` tags once the public address is decided.
- **Parent PIN:** four digits stored in the browser. It is a gentle gate, not strong security.
