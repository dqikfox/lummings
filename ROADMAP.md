# Roadmap

The thing to finish is the bedtime web app in `web/`. One address. A child opens it. A grown-up can put that same page on the home screen. Flutter, the docs companion, and the Python engine stay until the web app replaces what they do. They are not a second product to launch.

Hardware waits until a child uses the software often enough to justify a shell.

## Now

- Make `web/` the only app a parent is sent to. Point `site/` and the docs companion at it, or retire those pages.
- Record the missing lines (hug, goodnight, moon, sleep) in the five ElevenLabs voices and put the mp3s in `public/voices`. Until a file exists, the app stays silent. Do not turn browser speech back on.
- Connect each character to the agent id in `web/src/lib/eleven-agents.json`, or keep playback on the mp3s only. Do not do both in a way that surprises a parent.
- Strip the app-builder auth and preview scripts out of `web/` if they are not part of bedtime.
- Rename public copy that still says Lila or Pip. Keep the old ids only inside saved data and persona filenames.
- Run the web app on a phone: install to the home screen, hear an intro, open an origin story, hit the parent gate.

## Next

- One story path that is long enough to pay for: five origin nights, the night they became a crew, and a reason to come back tomorrow.
- Parent page that says what is stored (this browser only), how to wipe it, and that the microphone is off.
- Offline: portraits and the intro recordings available with no network.
- Drop the fake Heartlight Plus purchase. The bond is not a paid feature.
- One test that a parent can trust: no recording means no voice, rest stops play, and the bond survives a reload.

## Later

- A small device, if the software is actually used. `crates/` is only a stub until then.
- The Python engine becomes the on-device brain for that shell, not a fourth app.
- Shop, therapy, and school packs stay research notes in `AI_Toy_Distribution_Research/` until a family is paying for the bedtime app.

## Done

- Names locked: Lumo, Luna, Sprout, Nori, Moki.
- Portraits locked. Do not generate new ones.
- Intro recordings extracted into `public/voices`.
- Bedtime web app committed under `web/`, with portraits and voices also at `public/`.
- Side branches merged into `main`. Only `main` remains.
- ElevenLabs voices and agents created for the five characters. Ids are in `web/src/lib/eleven-agents.json`. They are not in the pages yet.
