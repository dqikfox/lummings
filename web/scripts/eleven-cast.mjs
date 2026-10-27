/**
 * Cast the crew with voices from the user's ElevenLabs account.
 * Resolves voice ids by name against GET /v1/voices. Never guesses an id.
 *
 *   ELEVENLABS_API_KEY=sk_... node scripts/eleven-cast.mjs
 *
 * Writes public/voices/el/*.mp3 and src/lib/eleven-lines.json
 */
import { mkdir, writeFile } from "node:fs/promises";
import { CREW } from "../src/lib/crew.ts";

const CAST = {
  sprout: "Lily",
  luna: "Bella",
  lumo: "Charlie",
  nori: "Matilda",
  moki: "River",
};

const SLOTS = ["hug", "goodnight", "sleep", "moon", "kind"];

const key = process.env.ELEVENLABS_API_KEY;
if (!key) {
  console.error("No ELEVENLABS_API_KEY in this sandbox. It lives on THRONE, not here.");
  process.exit(2);
}

const listed = await fetch("https://api.elevenlabs.io/v1/voices", {
  headers: { "xi-api-key": key },
});
if (!listed.ok) {
  console.error("Voice list failed", listed.status, await listed.text());
  process.exit(1);
}
const { voices } = await listed.json();
const byName = new Map(voices.map((v) => [v.name.toLowerCase(), v.voice_id]));

const resolved = {};
for (const [id, name] of Object.entries(CAST)) {
  const voiceId = byName.get(name.toLowerCase());
  if (!voiceId) {
    console.error(`No voice named ${name}. Account has: ${voices.map((v) => v.name).sort().join(", ")}`);
    process.exit(1);
  }
  resolved[id] = { name, voiceId };
}

await mkdir("public/voices/el", { recursive: true });
const lines = {};

for (const friend of CREW) {
  const voice = resolved[friend.id];
  for (const slot of SLOTS) {
    const text = friend[slot];
    if (!text) continue;
    const file = `${friend.id}-${slot}.mp3`;
    const res = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voice.voiceId}`, {
      method: "POST",
      headers: {
        "xi-api-key": key,
        "content-type": "application/json",
        accept: "audio/mpeg",
      },
      body: JSON.stringify({
        text,
        model_id: "eleven_multilingual_v2",
        voice_settings: { stability: 0.45, similarity_boost: 0.75, style: 0.15, use_speaker_boost: true },
      }),
    });
    if (!res.ok) {
      console.error(friend.name, slot, res.status, await res.text());
      process.exit(1);
    }
    await writeFile(`public/voices/el/${file}`, Buffer.from(await res.arrayBuffer()));
    lines[text] = `/voices/el/${file}`;
    console.log(friend.name, slot, voice.name);
  }
}

await writeFile("src/lib/eleven-lines.json", JSON.stringify({ cast: resolved, lines }, null, 2));
console.log("wrote", Object.keys(lines).length, "lines");
