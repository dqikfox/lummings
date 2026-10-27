import { createHash } from "node:crypto";
import { mkdir, writeFile } from "node:fs/promises";
import { ADVENTURES, CREW, STORIES, type CrewId } from "../src/lib/crew.ts";

const VOICE: Record<CrewId, string> = {
  lumo: "rex",
  luna: "ara",
  sprout: "eve",
  nori: "sal",
  moki: "aurora",
};

const PRIVACY = "Privacy is on, so the microphone stays quiet. The chips still hear you.";

function lines(): { text: string; voice: string }[] {
  const out: { text: string; voice: string }[] = [];
  const push = (text: string, id: CrewId) => {
    if (text) out.push({ text, voice: VOICE[id] });
  };
  for (const c of CREW) {
    push(c.line, c.id);
    push(c.hug, c.id);
    push(c.goodnight, c.id);
    push(c.moon, c.id);
    push(c.sleep, c.id);
    push(c.quest, c.id);
    push(c.kind, c.id);
  }
  for (const story of STORIES) {
    for (const beat of Object.values(story.beats)) push(beat.text, story.crew);
  }
  for (const adv of ADVENTURES) {
    const id = adv.crew ?? "lumo";
    push(adv.text, id);
    for (const choice of adv.choices) push(choice.end, id);
  }
  out.push({ text: PRIVACY, voice: "ara" });
  const seen = new Set<string>();
  return out.filter((row) => (seen.has(row.text) ? false : (seen.add(row.text), true)));
}

async function synth(text: string, voice: string, dest: string) {
  const key = process.env.XAI_API_KEY;
  if (!key) throw new Error("no key");
  for (let attempt = 0; attempt < 3; attempt++) {
    const res = await fetch("https://api.x.ai/v1/tts", {
      method: "POST",
      headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
      body: JSON.stringify({ text, voice_id: voice, language: "en" }),
    });
    if (res.ok) {
      await writeFile(dest, Buffer.from(await res.arrayBuffer()));
      return;
    }
    const err = await res.text();
    if (attempt === 2) throw new Error(`${res.status} ${err.slice(0, 200)} :: ${text.slice(0, 40)}`);
    await new Promise((r) => setTimeout(r, 800 * (attempt + 1)));
  }
}

const jobs = lines();
const dir = "/workspace/public/voices/lines";
await mkdir(dir, { recursive: true });
const map: Record<string, string> = {};
let cursor = 0;
async function worker() {
  for (;;) {
    const i = cursor++;
    if (i >= jobs.length) return;
    const job = jobs[i];
    const hash = createHash("sha1").update(job.text).digest("hex").slice(0, 12);
    const rel = `/voices/lines/${hash}.mp3`;
    await synth(job.text, job.voice, `/workspace/public${rel}`);
    map[job.text] = rel;
    console.log(`${i + 1}/${jobs.length} ${job.voice}`);
  }
}
await Promise.all(Array.from({ length: 4 }, () => worker()));
const body = `export const VOICE_LINES: Record<string, string> = ${JSON.stringify(map, null, 2)};\n`;
await writeFile("/workspace/src/lib/voice-lines.ts", body);
console.log(`wrote ${Object.keys(map).length} lines`);
