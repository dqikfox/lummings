import { type CrewId, crewById } from "@/lib/crew";

const INTRO: Record<CrewId, string> = {
  lumo: "/voices/lumo.mp3",
  luna: "/voices/luna.mp3",
  sprout: "/voices/sprout.mp3",
  nori: "/voices/nori.mp3",
  moki: "/voices/moki.mp3",
};

/** Only lines that exist as a real take in the intro scenes. No synthetic voice. */
export const TOGETHER = "Let's quest together, growing together.";

const CLIPS: Record<string, string> = {
  "Player one, crew first. Let's illuminate together.": "/voices/lumo-quest.mp3",
  "Player one, crew first.": "/voices/lumo-crew.mp3",
  "Welcome to a world of stories.": "/voices/luna-welcome.mp3",
  "The trail is glowing. Perfect, let's check it.": "/voices/sprout-trail.mp3",
  "But why is the moon following us? When the questions never end, a little light answers with you.":
    "/voices/nori-moon.mp3",
  "Ta-da. The glitch gremlin arrives. Whoops, drumroll fail. Perfect chaos.": "/voices/moki-chaos.mp3",
  [TOGETHER]: "/voices/together.mp3",
};

export function clipFor(text: string, crew?: CrewId): string | undefined {
  if (!text) return undefined;
  return CLIPS[text] ?? (crew && text === crewById(crew).hello ? INTRO[crew] : undefined);
}

let current: HTMLAudioElement | null = null;

export function stopSpeak() {
  if (typeof window !== "undefined" && window.speechSynthesis) window.speechSynthesis.cancel();
  if (current) {
    current.pause();
    current.src = "";
    current = null;
  }
}

/** Plays a real intro-scene recording. Anything without a take stays quiet. */
export function speak(text: string, muted: boolean, crew?: CrewId) {
  if (muted || !text || typeof window === "undefined") return;
  stopSpeak();
  const src = clipFor(text, crew);
  if (!src) return;
  const audio = new Audio(src);
  current = audio;
  void audio.play().catch(() => {});
}

type Rec = {
  lang: string;
  start: () => void;
  stop: () => void;
  onresult: ((ev: Event) => void) | null;
  onerror: (() => void) | null;
  onend: (() => void) | null;
};

export function canListen(): boolean {
  if (typeof window === "undefined") return false;
  const w = window as unknown as { SpeechRecognition?: unknown; webkitSpeechRecognition?: unknown };
  return Boolean(w.SpeechRecognition || w.webkitSpeechRecognition);
}

export function listen(onText: (text: string) => void, onEnd: () => void): Rec | null {
  const w = window as unknown as {
    SpeechRecognition?: new () => Rec;
    webkitSpeechRecognition?: new () => Rec;
  };
  const SR = w.SpeechRecognition || w.webkitSpeechRecognition;
  if (!SR) return null;
  const rec = new SR();
  rec.lang = "en-AU";
  rec.onresult = (ev: Event) => {
    const event = ev as unknown as { results?: Array<Array<{ transcript?: string }>> };
    const text = event.results?.[0]?.[0]?.transcript ?? "";
    if (text) onText(text);
  };
  rec.onerror = () => onEnd();
  rec.onend = () => onEnd();
  try {
    rec.start();
  } catch {
    onEnd();
    return null;
  }
  return rec;
}

