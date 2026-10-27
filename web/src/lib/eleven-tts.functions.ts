import { createServerFn } from "@tanstack/react-start";

/**
 * Browser-callable entry point for the voice fallback. The handler runs on the server only; the
 * ElevenLabs call, the API key and the voice allow-list live in eleven-tts.server.ts.
 */
export const speakWithVoice = createServerFn({ method: "POST" })
  .validator((input: unknown) => {
    const data = input as { voiceId?: unknown; text?: unknown };
    if (typeof data?.voiceId !== "string" || typeof data?.text !== "string") throw new Error("Unknown voice");
    return { voiceId: data.voiceId, text: data.text };
  })
  .handler(async ({ data }) => {
    const { synthesize } = await import("./eleven-tts.server");
    return synthesize(data.voiceId, data.text);
  });
