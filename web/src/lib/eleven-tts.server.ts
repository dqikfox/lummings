import { readFileSync } from "node:fs";
import { createServerFn } from "@tanstack/react-start";

const VOICES = new Set([
  "7VqZXEDC0ddU1b0F0jq9",
  "v62eofGuJeiHm0z2U3Hc",
  "eekTT2qA38B1zCMMefpZ",
  "Y2TS7tIZ7rATjbXnOgU5",
  "XzPT0rXcwuZbTnbHcb6R",
]);

function apiKey(): string {
  const fromEnv = process.env.ELEVENLABS_API_KEY?.trim();
  if (fromEnv) return fromEnv;
  return readFileSync("/workspace/.grok/eleven.key", "utf8").trim();
}

export const speakWithVoice = createServerFn({ method: "POST" })
  .inputValidator((input: unknown) => {
    const data = input as { voiceId?: string; text?: string };
    const voiceId = data?.voiceId ?? "";
    const text = (data?.text ?? "").replace(/\s+/g, " ").trim().slice(0, 800);
    if (!VOICES.has(voiceId) || text.length < 1) throw new Error("Unknown voice");
    return { voiceId, text };
  })
  .handler(async ({ data }) => {
    const res = await fetch(`https://api.elevenlabs.io/v1/text-to-speech/${data.voiceId}`, {
      method: "POST",
      headers: {
        "xi-api-key": apiKey(),
        "content-type": "application/json",
        accept: "audio/mpeg",
      },
      body: JSON.stringify({
        text: data.text,
        model_id: "eleven_multilingual_v2",
        voice_settings: { stability: 0.5, similarity_boost: 0.8, style: 0.15, use_speaker_boost: true },
      }),
    });
    if (!res.ok) throw new Error("Voice did not answer");
    const audio = Buffer.from(await res.arrayBuffer()).toString("base64");
    return { audio };
  });
