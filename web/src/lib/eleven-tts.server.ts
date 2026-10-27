import { readFileSync } from "node:fs";

// Server only. Never import this from browser code; call `speakWithVoice` from eleven-tts.functions.ts instead.
const VOICES = new Set([
  "7VqZXEDC0ddU1b0F0jq9",
  "v62eofGuJeiHm0z2U3Hc",
  "ILlSg5Jt8r3V71f2WdL3",
  "eekTT2qA38B1zCMMefpZ",
  "Y2TS7tIZ7rATjbXnOgU5",
  "XzPT0rXcwuZbTnbHcb6R",
]);

function apiKey(): string {
  const fromEnv = process.env.ELEVENLABS_API_KEY?.trim();
  if (fromEnv) return fromEnv;
  return readFileSync("/workspace/.grok/eleven.key", "utf8").trim();
}

/** Turns one authored line into speech in an allow-listed voice. Returns base64 mp3. */
export async function synthesize(voiceId: string, rawText: string): Promise<{ audio: string }> {
  const text = rawText.replace(/\s+/g, " ").trim().slice(0, 1400);
  if (!VOICES.has(voiceId) || text.length < 1) throw new Error("Unknown voice");
  const res = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${voiceId}`, {
    method: "POST",
    headers: {
      "xi-api-key": apiKey(),
      "content-type": "application/json",
      accept: "audio/mpeg",
    },
    body: JSON.stringify({
      text,
      model_id: "eleven_multilingual_v2",
      voice_settings: { stability: 0.32, similarity_boost: 0.75, style: 0.72, use_speaker_boost: true },
    }),
  });
  if (!res.ok) throw new Error("Voice did not answer");
  const audio = Buffer.from(await res.arrayBuffer()).toString("base64");
  return { audio };
}
