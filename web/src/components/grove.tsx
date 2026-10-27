import { useEffect, useRef, useState, type ReactNode } from "react";
import {
  BookOpen,
  Compass,
  Flame,
  Heart,
  House,
  Lock,
  Mic,
  MicOff,
  Moon,
  Shield,
  Sparkles,
  Star,
} from "lucide-react";
import {
  ADVENTURES,
  CHARMS,
  CREW,
  type CrewId,
  answerFor,
  bondLevel,
  crewById,
  formatClock,
  formatSpan,
  originFor,
  roster,
  storiesFor,
  todayKey,
  type Play,
} from "@/lib/crew";
import { limitSeconds, resting, setComplete, useLumm, type CareKind, type View } from "@/lib/store";
import { listen, speak, stopSpeak, TOGETHER } from "@/lib/voice";

const NAV: { id: View; label: string; icon: typeof House }[] = [
  { id: "home", label: "Home", icon: House },
  { id: "adventures", label: "Play", icon: Compass },
  { id: "collection", label: "Stars", icon: Star },
  { id: "care", label: "Night", icon: Moon },
  { id: "parent", label: "Grown-up", icon: Shield },
];

const AFTER: Record<CrewId, string> = {
  sprout: "Sprout adds one more line, very small. The trail will still be here in the morning, and so will you.",
  luna: "Luna draws a tiny star in the margin. “This page is extra. The story was already yours.”",
  lumo: "Lumo saves the game without a score. “Player one. Crew first. That was the whole quest.”",
  nori: "Nori lowers the lantern. “One more quiet page, then the moon keeps the watch.”",
  moki: "Moki whispers, “Plot twist. The extra page is just a friend staying a little longer.”",
};

const CARE: { kind: CareKind; title: string; text: string }[] = [
  { kind: "tuck", title: "Tuck in", text: "A blanket, a breath, and the light turned low." },
  { kind: "quiet", title: "Quiet minute", text: "Sit together. No quest. Just company." },
  { kind: "lantern", title: "Lantern low", text: "Leave a small light for the night to see by." },
];

export function Grove() {
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let live = true;
    void Promise.resolve(useLumm.persist.rehydrate()).finally(() => {
      if (!live) return;
      const s = useLumm.getState();
      if (s.onboarded && s.primary && s.active) {
        if (s.view === "welcome" || s.view === "safety" || s.view === "pick") {
          useLumm.setState({ view: "home" });
        }
      } else if (s.onboarded) {
        useLumm.setState({ onboarded: false, view: "welcome", primary: null, active: null });
      }
      setReady(true);
    });
    return () => {
      live = false;
    };
  }, []);

  useEffect(() => {
    if (!ready) return;
    const id = window.setInterval(() => {
      if (document.visibilityState === "visible") useLumm.getState().tick(5);
    }, 5000);
    return () => window.clearInterval(id);
  }, [ready]);

  if (!ready) return <Splash />;
  return <Shell />;
}

function Splash() {
  return (
    <main className="grid min-h-dvh place-items-center bg-night px-6 text-center text-ink">
      <div>
        <p className="font-display text-4xl text-gold">Lummings</p>
        <p className="mt-2 text-mist">A little light is waking.</p>
      </div>
    </main>
  );
}

function Shell() {
  const view = useLumm((s) => s.view);
  const onboarded = useLumm((s) => s.onboarded);
  const showNav = onboarded && view !== "story";

  return (
    <div className="relative min-h-dvh text-ink">
      <img
        src="/crew/forest.jpg"
        alt=""
        className="pointer-events-none fixed inset-0 h-full w-full object-cover opacity-45"
      />
      <div className="pointer-events-none fixed inset-0 bg-night/75" />
      <div className="relative mx-auto flex h-dvh w-full max-w-lg flex-col">
        <div className="min-h-0 flex-1 overflow-y-auto px-4 pt-6 pb-4">
          {view === "welcome" && <Welcome />}
          {view === "safety" && <Safety />}
          {view === "pick" && <Pick />}
          {view === "home" && <Home />}
          {view === "story" && <Story />}
          {view === "adventures" && <Adventures />}
          {view === "collection" && <Collection />}
          {view === "care" && <Care />}
          {view === "parent" && <Parent />}
        </div>
        {showNav && <Nav />}
      </div>
    </div>
  );
}

function Nav() {
  const view = useLumm((s) => s.view);
  const go = useLumm((s) => s.go);
  return (
    <nav className="z-20 grid shrink-0 grid-cols-5 gap-1 border-t border-line bg-night/95 px-2 py-2 backdrop-blur">
      {NAV.map((item) => {
        const Icon = item.icon;
        const on = view === item.id;
        return (
          <button
            key={item.id}
            type="button"
            onClick={() => {
              if (item.id === "adventures") speak(TOGETHER, useLumm.getState().muted);
              go(item.id);
            }}
            aria-current={on ? "page" : undefined}
            className={`flex min-h-14 flex-col items-center justify-center gap-1 rounded-2xl px-0.5 text-center text-sm leading-none ${on ? "bg-dusk text-gold" : "text-mist"}`}
          >
            <Icon className="size-5" aria-hidden />
            {item.label}
          </button>
        );
      })}
    </nav>
  );
}

function Welcome() {
  const go = useLumm((s) => s.go);
  return (
    <main className="flex min-h-full flex-col justify-end gap-5 pb-2">
      <div className="flex items-end justify-center">
        {CREW.map((c) => (
          <img
            key={c.id}
            src={c.src}
            alt=""
            className="-mx-2 h-44 w-20 rounded-3xl object-cover object-top shadow-lg ring-2 ring-night sm:h-56 sm:w-24"
          />
        ))}
      </div>
      <div className="text-center">
        <p className="text-sm tracking-wide text-gold">Welcome to</p>
        <h1 className="font-display text-5xl leading-none text-gold">Lummings</h1>
        <p className="mt-2 text-lg text-ink">A friend who stays for the story, and for the dark.</p>
      </div>
      <button
        type="button"
        onClick={() => go("pick")}
        className="min-h-14 rounded-full bg-gold px-6 font-display text-2xl text-night"
      >
        Pick a friend
      </button>
      <button
        type="button"
        onClick={() => go("safety")}
        className="min-h-11 self-center text-sm text-mist"
      >
        Grown-ups
      </button>
    </main>
  );
}

function Safety() {
  const go = useLumm((s) => s.go);
  const pin = useLumm((s) => s.pin);
  const setPin = useLumm((s) => s.setPin);
  const limitMin = useLumm((s) => s.limitMin);
  const setLimit = useLumm((s) => s.setLimit);
  const privacy = useLumm((s) => s.privacy);
  const filters = useLumm((s) => s.filters);
  const toggle = useLumm((s) => s.toggle);

  return (
    <main className="space-y-4 pb-6">
      <button type="button" onClick={() => go("welcome")} className="min-h-11 text-sm text-mist">
        Back
      </button>
      <h1 className="font-display text-4xl text-gold">Parents & safety</h1>
      <p className="text-sm leading-relaxed text-mist">
        A gate on this phone, not an account. The bond never leaves the device. The microphone stays off
        unless you allow Talk. If you do, this browser may send speech away. Stories do not.
      </p>
      <label className="block rounded-3xl border border-line bg-panel/80 p-4">
        <span className="text-sm text-ink">Parent PIN</span>
        <input
          value={pin}
          onChange={(e) => setPin(e.target.value.replace(/\D/g, "").slice(0, 4))}
          inputMode="numeric"
          autoComplete="off"
          maxLength={4}
          placeholder="4 numbers"
          aria-label="Parent PIN"
          className="mt-2 min-h-11 w-full rounded-2xl border border-line bg-night px-3 text-lg tracking-widest text-ink"
        />
        <span className="mt-2 block text-sm text-mist">
          {pin.length === 4 ? "Saved on this device." : "Optional for now. Four numbers, when you are ready."}
        </span>
      </label>
      <div className="rounded-3xl border border-line bg-panel/80 p-4">
        <p className="text-center text-sm text-ink">Gentle limit: {formatSpan(limitMin)} / 2h</p>
        <input
          type="range"
          min={30}
          max={120}
          step={15}
          value={limitMin}
          aria-label="Gentle screen time limit"
          onChange={(e) => setLimit(Number(e.target.value))}
        />
        <p className="text-sm text-mist">
          When the limit arrives, adventures rest. Stories and hugs stay. It is a pause, not a punishment.
        </p>
      </div>
      <div className="grid gap-2 sm:grid-cols-2">
        <Toggle on={privacy} label="Microphone stays off" onClick={() => toggle("privacy")} />
        <Toggle on={filters} label="Skip the silly choices" onClick={() => toggle("filters")} />
      </div>
      <p className="rounded-3xl border border-gold/40 px-4 py-3 text-center font-display text-gold">
        Heartlight Plus is a free preview. The bond is never paywalled.
      </p>
      <button
        type="button"
        onClick={() => go("pick")}
        className="min-h-12 w-full rounded-full bg-gold font-display text-xl text-night"
      >
        Start growing together
      </button>
    </main>
  );
}

function Pick() {
  const go = useLumm((s) => s.go);
  const choose = useLumm((s) => s.choose);
  return (
    <main className="space-y-4">
      <button type="button" onClick={() => go("welcome")} className="min-h-11 text-sm text-mist">
        Back
      </button>
      <h1 className="font-display text-4xl text-gold">Who first?</h1>
      <div className="flex snap-x snap-mandatory gap-3 overflow-x-auto pb-3">
        {CREW.map((c) => (
          <button
            key={c.id}
            type="button"
            onClick={() => {
              speak(c.hello, useLumm.getState().muted, c.id);
              choose(c.id);
            }}
            className="w-56 shrink-0 snap-center overflow-hidden rounded-3xl border border-gold/30 bg-panel text-left"
          >
            <img src={c.src} alt="" className="h-72 w-full object-cover object-top" />
            <span className="block px-3 py-3 font-display text-2xl">{c.name}</span>
          </button>
        ))}
      </div>
    </main>
  );
}

function Home() {
  const s = useLumm();
  const friend = crewById(s.active ?? s.primary ?? "lumo");
  const [line, setLine] = useState<string | null>(null);
  const [listening, setListening] = useState(false);
  const rec = useRef<{ stop: () => void } | null>(null);
  const shown = line ?? friend.line;
  const xp = s.primary ? s.xp[s.primary] : 0;
  const circle = s.primary ? roster(s.primary, xp) : [];
  const asleep = resting(s);

  useEffect(() => {
    setLine(null);
  }, [friend.id]);

  useEffect(() => () => rec.current?.stop(), []);

  function say(text: string, grant: boolean) {
    setLine(text);
    if (grant) s.talk(friend.id);
    speak(text, s.muted, friend.id);
  }

  function onMic() {
    if (s.privacy) {
      say("The mic is off. Tap Moon or Sleep.", false);
      return;
    }
    if (listening) {
      rec.current?.stop();
      setListening(false);
      return;
    }
    const next = listen(
      (text) => {
        const reply = answerFor(friend.id, text);
        setLine(reply);
        useLumm.getState().talk(friend.id);
        speak(reply, useLumm.getState().muted, friend.id);
      },
      () => setListening(false),
    );
    if (!next) {
      s.flash("Talk isn't in this browser. Tap Moon or Sleep.");
      return;
    }
    rec.current = next;
    setListening(true);
  }

  return (
    <main className="space-y-4">
      <Meter label="Light" value={s.heartlight} icon={<Heart className="size-5 text-ember" aria-hidden />} />
      <div className="flex justify-between gap-1">
        {circle.map((slot) => {
          const c = crewById(slot.id);
          return (
            <button
              key={slot.id}
              type="button"
              disabled={!slot.open}
              onClick={() => {
                if (!slot.open) return;
                s.setActive(slot.id);
                const next = crewById(slot.id);
                setLine(next.hello);
                speak(next.hello, s.muted, slot.id);
              }}
              className={`w-16 ${s.active === slot.id ? "text-gold" : "text-mist"}`}
              aria-label={slot.open ? c.name : `${c.name} joins later`}
            >
              <span className="relative mx-auto block w-14">
                <img
                  src={c.src}
                  alt=""
                  className={`size-14 rounded-full object-cover object-top ${slot.open ? "" : "opacity-40"} ${s.active === slot.id ? "ring-2 ring-gold" : ""}`}
                />
                {!slot.open && <Lock className="absolute right-0 bottom-0 size-3 text-gold" aria-hidden />}
              </span>
              <span className="mt-1 block truncate text-sm">{c.name}</span>
            </button>
          );
        })}
      </div>
      <div className="relative overflow-hidden rounded-3xl border border-gold/30 bg-panel">
        <button
          type="button"
          className="block w-full"
          aria-label={`Hear ${friend.name}`}
          onClick={() => {
            setLine(friend.hello);
            speak(friend.hello, s.muted, friend.id);
          }}
        >
          <img src={friend.src} alt={friend.name} className="h-80 w-full object-cover object-top" />
        </button>
        <p
          role="status"
          aria-live="polite"
          className="absolute inset-x-3 bottom-3 rounded-2xl bg-night/90 p-4 text-lg leading-snug"
        >
          {shown}
        </p>
      </div>
      <p className="text-center font-display text-2xl text-gold">{friend.name}</p>
      {asleep && (
        <p className="rounded-2xl bg-dusk px-3 py-2 text-center text-base text-ink">
          Play waits until tomorrow. Hugs and stories stay.
        </p>
      )}
      <div className="grid grid-cols-2 gap-2">
        <Chip icon={<Moon className="size-5" />} label="Moon" onClick={() => say(friend.moon, true)} />
        <Chip icon={<Sparkles className="size-5" />} label="Sleep" onClick={() => say(friend.sleep, true)} />
      </div>
      <div className="flex justify-center">
        <button
          type="button"
          onClick={onMic}
          aria-pressed={listening}
          aria-label={s.privacy ? "Microphone off while privacy is on" : listening ? "Stop listening" : "Talk"}
          className="inline-flex min-h-14 items-center gap-2 rounded-full border border-tide bg-dusk px-6 text-lg text-tide"
        >
          {s.privacy ? <MicOff aria-hidden /> : <Mic aria-hidden />}
          Talk
        </button>
      </div>
      {s.note && (
        <p role="status" className="text-center text-sm text-gold">
          {s.note}
        </p>
      )}
      <div className="grid grid-cols-2 gap-2">
        <Action
          icon={<BookOpen className="size-6" />}
          label="Their story"
          onClick={() => {
            speak(friend.hello, s.muted, friend.id);
            s.openTale(originFor(friend.id).id);
          }}
        />
        <Action
          icon={<Heart className="size-6" />}
          label="Hug"
          onClick={() => {
            s.hug(friend.id);
            setLine(friend.hug);
            speak(friend.hug, s.muted, friend.id);
          }}
        />
      </div>
      <button type="button" onClick={() => s.go("story")} className="min-h-11 w-full text-base text-mist">
        More stories
      </button>
    </main>
  );
}

function PlayBox({ play, onSolved }: { play: Play; onSolved: () => void }) {
  const [note, setNote] = useState("");
  const [done, setDone] = useState(false);
  const [roll, setRoll] = useState<number | null>(null);

  function finish(line: string) {
    setNote(line);
    setDone(true);
    onSolved();
  }

  if (play.kind === "dice") {
    return (
      <div className="space-y-3 rounded-3xl border border-gold/40 bg-dusk p-4">
        <p className="text-base">{play.prompt}</p>
        <button
          type="button"
          disabled={done}
          className="min-h-16 w-full rounded-full bg-gold font-display text-2xl text-night disabled:opacity-60"
          onClick={() => {
            const face = 1 + Math.floor(Math.random() * play.faces.length);
            setRoll(face);
            finish(`You rolled ${face}. ${play.faces[face - 1]}.`);
          }}
        >
          {roll ? `Rolled ${roll}` : "Roll the die"}
        </button>
        {note && <p className="text-gold">{note}</p>}
      </div>
    );
  }

  if (play.kind === "sum") {
    const right = play.a + play.b;
    const options = [right, right + 1, Math.max(0, right - 1)].filter((n, i, all) => all.indexOf(n) === i);
    return (
      <div className="space-y-3 rounded-3xl border border-gold/40 bg-dusk p-4">
        <p className="text-base">{play.prompt}</p>
        <div className="grid grid-cols-3 gap-2">
          {options.map((n) => (
            <button
              key={n}
              type="button"
              disabled={done}
              className="min-h-16 rounded-2xl border border-gold/40 font-display text-3xl"
              onClick={() => {
                if (n === right) finish("Yes. That many.");
                else setNote("Not yet. Count once more.");
              }}
            >
              {n}
            </button>
          ))}
        </div>
        {note && <p className="text-gold">{note}</p>}
      </div>
    );
  }

  if (play.kind === "guess") {
    return (
      <div className="space-y-3 rounded-3xl border border-gold/40 bg-dusk p-4">
        <p className="text-base">{play.prompt}</p>
        <div className="grid gap-2">
          {play.options.map((option) => (
            <button
              key={option}
              type="button"
              disabled={done}
              className="min-h-14 rounded-full border border-gold/40 px-4 text-left text-lg"
              onClick={() => {
                if (option === play.answer) finish(`${play.answer}. You found it.`);
                else setNote("Close. Try another.");
              }}
            >
              {option}
            </button>
          ))}
        </div>
        {note && <p className="text-gold">{note}</p>}
      </div>
    );
  }

  return (
    <div className="space-y-3 rounded-3xl border border-gold/40 bg-dusk p-4">
      <p className="text-base">{play.prompt}</p>
      <div className="grid grid-cols-2 gap-2">
        {play.items.map((item, index) => (
          <button
            key={`${item}-${index}`}
            type="button"
            disabled={done}
            className="min-h-16 rounded-2xl border border-gold/40 text-lg"
            onClick={() => {
              if (item === play.odd) finish(`The ${play.odd.toLowerCase()}. Good eyes.`);
              else setNote("That one matches. Look for the different one.");
            }}
          >
            {item}
          </button>
        ))}
      </div>
      {note && <p className="text-gold">{note}</p>}
    </div>
  );
}

function Story() {
  const go = useLumm((s) => s.go);
  const finishStory = useLumm((s) => s.finishStory);
  const filters = useLumm((s) => s.filters);
  const plus = useLumm((s) => s.plus);
  const muted = useLumm((s) => s.muted);
  const active = useLumm((s) => s.active ?? s.primary ?? "lumo");
  const focusStory = useLumm((s) => s.focusStory);
  const list = storiesFor(active);
  const friend = crewById(active);
  const [picked, setPicked] = useState<string | null>(null);
  const story = list.find((item) => item.id === picked) ?? null;
  const [beatId, setBeatId] = useState(story?.start ?? "");
  const [solved, setSolved] = useState(false);
  const granted = useRef(false);
  const beat = story ? (story.beats[beatId] ?? story.beats[story.start]) : undefined;

  useEffect(() => {
    if (!focusStory) return;
    if (!list.some((item) => item.id === focusStory)) return;
    setPicked(focusStory);
  }, [focusStory, list]);

  useEffect(() => {
    if (!story) return;
    setBeatId(story.start);
    setSolved(false);
    granted.current = false;
  }, [story]);

  useEffect(() => {
    return () => stopSpeak();
  }, []);

  if (!story || !beat) {
    return (
      <main className="space-y-4">
        <button type="button" onClick={() => go("home")} className="min-h-14 text-base text-mist">
          Back
        </button>
        <h1 className="font-display text-4xl text-gold">Stories</h1>
        <p className="text-base text-mist">How {friend.name} began, then the nights after.</p>
        <div className="grid gap-2">
          {list.map((item) => (
            <button
              key={item.id}
              type="button"
              className="min-h-16 rounded-3xl border border-gold/40 bg-dusk px-4 text-left text-ink"
              onClick={() => {
                setPicked(item.id);
                useLumm.setState({ focusStory: null });
                speak(friend.hello, muted, active);
              }}
            >
              <span className="block text-sm text-gold">
                {item.origin ? "Their story" : item.shared ? "How we met" : "A night"}
              </span>
              <span className="font-display text-2xl">{item.title}</span>
            </button>
          ))}
        </div>
      </main>
    );
  }

  return (
    <main className="space-y-4">
      <button
        type="button"
        onClick={() => {
          useLumm.setState({ focusStory: null });
          setPicked(null);
        }}
        className="min-h-14 text-base text-mist"
      >
        Back
      </button>
      <p className="font-display text-2xl text-gold">{friend.name}</p>
      <p className="text-sm text-mist">
        Page {["p1", "p2", "p3", "p4", "p5", "p6", "end"].indexOf(beatId) + 1} of 7
      </p>
      <img src={friend.src} alt="" className="h-48 w-full rounded-3xl object-cover object-top" />
      <p className="text-lg leading-relaxed">{beat.text}</p>
      {beat.play && (
        <PlayBox
          key={beatId}
          play={beat.play}
          onSolved={() => setSolved(true)}
        />
      )}
      {beat.end && plus && <p className="leading-relaxed text-gold">{AFTER[active]}</p>}
      {beat.end && !plus && (
        <p className="text-sm text-mist">
          Heartlight Plus keeps one extra page. This story, and the bond, stay free either way.
        </p>
      )}
      <div className="grid gap-2">
        {(!beat.play || solved) &&
          (beat.choices ?? [])
            .filter((choice) => !(filters && choice.playful))
            .map((choice) => (
            <button
              key={choice.label}
              type="button"
              className="min-h-11 rounded-full border border-gold/40 bg-dusk px-4 text-left text-ink"
              onClick={() => {
                const next = story.beats[choice.next];
                setBeatId(choice.next);
                setSolved(false);
                if (next?.text) speak(next.text, muted, active);
                if (next?.end && !granted.current) {
                  granted.current = true;
                  finishStory(active);
                }
              }}
            >
              {choice.label}
            </button>
            ))}
      </div>
      {beat.end && (
        <button
          type="button"
          onClick={() => go("home")}
          className="min-h-12 w-full rounded-full bg-gold font-display text-lg text-night"
        >
          Close the book
        </button>
      )}
    </main>
  );
}

function Adventures() {
  const s = useLumm();
  const [play, setPlay] = useState<string | null>(null);
  const [ending, setEnding] = useState<string | null>(null);
  const adv = ADVENTURES.find((a) => a.id === play);
  const asleep = resting(s);
  const primary = s.primary;
  const open = new Set(
    primary ? roster(primary, s.xp[primary]).filter((r) => r.open).map((r) => r.id) : [],
  );
  const doneCount = s.adventures.length;

  if (adv) {
    const who = adv.crew ? crewById(adv.crew) : primary ? crewById(primary) : CREW[2];
    return (
      <main className="space-y-4">
        <button
          type="button"
          className="min-h-11 text-sm text-mist"
          onClick={() => {
            setPlay(null);
            setEnding(null);
          }}
        >
          Back to the path
        </button>
        <p className="text-sm text-gold">{who.name}</p>
        <h1 className="font-display text-3xl">{adv.title}</h1>
        <img src={who.src} alt="" className="h-44 w-full rounded-3xl object-cover object-top" />
        <p className="leading-relaxed">{ending ?? adv.text}</p>
        {!ending && (
          <div className="grid gap-2">
            {adv.choices.map((choice) => (
              <button
                key={choice.label}
                type="button"
                className="min-h-11 rounded-full border border-gold/40 bg-dusk px-4 text-left"
                onClick={() => {
                  setEnding(choice.end);
                  speak(choice.end, s.muted, who.id);
                }}
              >
                {choice.label}
              </button>
            ))}
          </div>
        )}
      </main>
    );
  }

  return (
    <main className="space-y-4">
      <h1 className="font-display text-4xl text-gold">Play</h1>
      <Meter
        label="Adventure progress"
        value={(doneCount / ADVENTURES.length) * 100}
        icon={<Flame className="size-4 text-ember" aria-hidden />}
      />
      <p className="text-center text-sm text-mist">Heartlight {s.heartlight}. Growing together.</p>
      {asleep && (
        <p className="rounded-2xl bg-dusk px-3 py-2 text-sm text-mist">
          New paths rest until tomorrow. Ones you already walked can be remembered.
        </p>
      )}
      <ol className="space-y-3 border-l border-gold/40 pl-4">
        {ADVENTURES.map((item) => {
          const done = s.adventures.includes(item.id);
          const locked = Boolean(item.crew && !open.has(item.crew));
          const paused = asleep && !done;
          const face = item.crew ? crewById(item.crew) : null;
          return (
            <li key={item.id} className="rounded-3xl border border-line bg-panel/85 p-4">
              <div className="flex gap-3">
                {face && (
                  <img src={face.src} alt="" className="size-14 rounded-2xl object-cover object-top" />
                )}
                <div>
                  <h2 className="font-display text-xl">{item.title}</h2>
                  <p className="text-sm text-mist">{item.blurb}</p>
                  <p className="text-sm text-gold">
                    {done ? "Remembered" : item.cost === 0 ? "No heartlight needed" : `${item.cost} heartlight`}
                  </p>
                </div>
              </div>
              <button
                type="button"
                disabled={locked || paused}
                className="mt-3 min-h-11 w-full rounded-full bg-gold text-night disabled:bg-dusk disabled:text-mist"
                onClick={() => {
                  if (!done) {
                    const result = s.finishAdventure(item);
                    if (result === "poor") {
                      s.flash("Heartlight is low. A hug or a story warms it.");
                      return;
                    }
                    if (result !== "ok") return;
                  }
                  setEnding(null);
                  setPlay(item.id);
                  speak(item.text, s.muted, face?.id ?? primary ?? "lumo");
                }}
              >
                {locked ? "Waiting on the bond" : paused ? "Resting tonight" : done ? "Walk it again" : "Walk this path"}
              </button>
            </li>
          );
        })}
      </ol>
      {s.note && <p className="text-center text-sm text-gold">{s.note}</p>}
    </main>
  );
}

function Collection() {
  const charms = useLumm((s) => s.charms);
  const whole = setComplete(charms);
  return (
    <main className="space-y-4">
      <h1 className="font-display text-4xl text-gold">Stars</h1>
      <p className="rounded-full border border-gold/40 px-4 py-2 text-center text-sm">
        {whole ? "The set is whole. The reward is the crew, still free." : "Complete the set for a quiet reward."}
      </p>
      <ul className="grid grid-cols-3 gap-3">
        {CHARMS.map((charm) => {
          const value = charms[charm.id];
          const locked = Boolean(charm.soon);
          return (
            <li key={charm.id} className="rounded-3xl border border-line bg-panel/80 px-2 py-3 text-center">
              <div className="relative">
                <div className={`charm ${locked ? "opacity-40" : ""}`} data-id={charm.id} />
                {locked && <Lock className="absolute top-3 left-1/2 size-4 -translate-x-1/2 text-ink" aria-hidden />}
              </div>
              <p className="mt-2 font-display text-xs leading-tight sm:text-sm">{charm.name}</p>
              <p className="text-xs text-mist">{locked ? "Coming soon" : charm.hint}</p>
              <div className="mx-auto mt-2 h-1.5 w-full overflow-hidden rounded-full bg-dusk">
                <div
                  className="h-full rounded-full bg-gold"
                  style={{ width: `${locked ? 0 : value}%` }}
                />
              </div>
            </li>
          );
        })}
      </ul>
    </main>
  );
}

function Care() {
  const s = useLumm();
  const friend = crewById(s.active ?? s.primary ?? "lumo");
  const [draft, setDraft] = useState("");
  const today = todayKey();
  const memories = s.plus ? s.memories : s.memories.slice(0, 1);
  const savedToday = s.memoryDay === today;

  return (
    <main className="space-y-4">
      <h1 className="font-display text-4xl text-gold">Night</h1>
      <button
        type="button"
        onClick={() => {
          speak(friend.hello, s.muted, friend.id);
          s.openTale(originFor(friend.id).id);
        }}
        className="min-h-16 w-full rounded-3xl bg-gold px-4 text-left font-display text-2xl text-night"
      >
        Their story, then sleep
      </button>
      <p className="text-base text-ink">Then tuck in, sit a quiet minute, and leave the lantern low.</p>
      <p className="text-sm text-mist">
        {s.streak > 0 ? `${s.streak} ${s.streak === 1 ? "day" : "days"} of growing together.` : "A soft ritual, once each night."}
      </p>
      <div className="grid gap-2">
        {CARE.map((item) => {
          const done = s.careDone[item.kind] === today;
          return (
            <button
              key={item.kind}
              type="button"
              disabled={done}
              onClick={() => {
                const ok = s.care(item.kind, friend.id);
                if (ok) speak(friend.goodnight, s.muted, friend.id);
              }}
              className="min-h-11 rounded-3xl border border-line bg-panel/80 px-4 py-3 text-left disabled:opacity-60"
            >
              <span className="block font-display text-xl">{item.title}</span>
              <span className="text-sm text-mist">{done ? "Done for tonight." : item.text}</span>
            </button>
          );
        })}
      </div>
      <form
        className="space-y-2 rounded-3xl border border-line bg-panel/80 p-4"
        onSubmit={(e) => {
          e.preventDefault();
          if (s.remember(draft, friend.id)) setDraft("");
        }}
      >
        <label className="block font-display text-xl" htmlFor="memory">
          A memory
        </label>
        <textarea
          id="memory"
          value={draft}
          maxLength={140}
          disabled={savedToday}
          onChange={(e) => setDraft(e.target.value.slice(0, 140))}
          placeholder={savedToday ? "One memory a day. This one is kept." : "One sentence from tonight."}
          className="min-h-24 w-full rounded-2xl border border-line bg-night px-3 py-2 text-ink"
        />
        <div className="flex items-center justify-between gap-3">
          <span className="text-xs text-mist">{draft.length}/140 · stays on this device</span>
          <button
            type="submit"
            disabled={savedToday || !draft.trim()}
            className="min-h-11 rounded-full bg-gold px-4 text-night disabled:bg-dusk disabled:text-mist"
          >
            Keep it
          </button>
        </div>
      </form>
      {s.note && <p className="text-sm text-gold">{s.note}</p>}
      <ul className="space-y-2">
        {memories.map((memory) => (
          <li key={memory.id} className="rounded-2xl bg-dusk px-3 py-2 text-sm">
            <span className="text-gold">{crewById(memory.crew).name}. </span>
            {memory.text}
          </li>
        ))}
        {!s.plus && s.memories.length > 1 && (
          <li className="text-sm text-mist">
            The rest of the gallery waits with Heartlight Plus. Your bond is not locked.
          </li>
        )}
        {s.memories.length === 0 && <li className="text-sm text-mist">No memories yet. One sentence is enough.</li>}
      </ul>
    </main>
  );
}

function Parent() {
  const s = useLumm();
  const [attempt, setAttempt] = useState("");
  const [nextPin, setNextPin] = useState("");
  const [confirm, setConfirm] = useState(false);
  const [wipePin, setWipePin] = useState("");
  const today = todayKey();
  const used = s.usedDay === today ? s.usedSec : 0;
  const cap = limitSeconds(s);
  const ratio = cap > 0 ? Math.min(1, used / cap) : 0;

  if (!s.pinReady || !s.parentOpen) {
    return (
      <main className="space-y-4">
        <h1 className="font-display text-4xl text-gold">Parent</h1>
        <p className="text-sm text-mist">A local gate. Not a login, and not sent anywhere.</p>
        {!s.pinReady ? (
          <form
            className="space-y-3"
            onSubmit={(e) => {
              e.preventDefault();
              if (attempt.length !== 4) {
                s.flash("Four numbers, when you are ready.");
                return;
              }
              s.setPin(attempt);
              s.openParent(attempt);
              setAttempt("");
            }}
          >
            <input
              value={attempt}
              onChange={(e) => setAttempt(e.target.value.replace(/\D/g, "").slice(0, 4))}
              inputMode="numeric"
              autoComplete="off"
              type="password"
              aria-label="Choose a parent PIN"
              placeholder="Choose 4 numbers"
              className="min-h-11 w-full rounded-2xl border border-line bg-night px-3 tracking-widest text-ink"
            />
            <button type="submit" className="min-h-12 w-full rounded-full bg-gold text-night">
              Save and open
            </button>
          </form>
        ) : (
          <form
            className="space-y-3"
            onSubmit={(e) => {
              e.preventDefault();
              const ok = s.openParent(attempt);
              if (!ok) s.flash("That PIN doesn't match. Try again, gently.");
              setAttempt("");
            }}
          >
            <input
              value={attempt}
              onChange={(e) => setAttempt(e.target.value.replace(/\D/g, "").slice(0, 4))}
              inputMode="numeric"
              autoComplete="off"
              type="password"
              aria-label="Parent PIN"
              placeholder="Parent PIN"
              className="min-h-11 w-full rounded-2xl border border-line bg-night px-3 tracking-widest text-ink"
            />
            <button type="submit" className="min-h-12 w-full rounded-full bg-gold text-night">
              Open dashboard
            </button>
          </form>
        )}
        {s.note && <p className="text-sm text-gold">{s.note}</p>}
      </main>
    );
  }

  const bonus = s.bonusDay === today ? s.bonusSec : 0;

  return (
    <main className="space-y-4">
      <div className="flex items-start justify-between gap-3">
        <h1 className="font-display text-4xl text-gold">Parent dashboard</h1>
        <p className="rounded-2xl border border-tide px-2 py-1 text-center text-xs text-tide">Safety first</p>
      </div>
      <div className="grid grid-cols-2 gap-2">
        <section className="rounded-3xl border border-line bg-panel/80 p-3">
          <p className="text-sm text-mist">Daily streak</p>
          <p className="mt-2 flex items-center gap-2 font-display text-2xl text-gold">
            <Flame className="size-5" aria-hidden /> {s.streak} {s.streak === 1 ? "day" : "days"}
          </p>
        </section>
        <section className="rounded-3xl border border-line bg-panel/80 p-3">
          <p className="text-sm text-mist">Screen time</p>
          <div className="mt-2 flex items-center gap-2">
            <Ring value={ratio} />
            <p className="text-sm">
              Gentle limit
              <span className="block text-gold">
                {formatSpan(s.limitMin)} / 2h
              </span>
            </p>
          </div>
        </section>
      </div>
      <p className="text-sm text-mist">
        Tonight {formatClock(used)} of {formatClock(cap)}
        {bonus > 0 ? " — includes a little extra." : "."} When it fills, adventures pause. Stories and hugs stay.
      </p>
      <section className="rounded-3xl border border-line bg-panel/80 p-3">
        <h2 className="font-display text-xl">Bond levels</h2>
        <ul className="mt-3 grid grid-cols-5 gap-1">
          {CREW.map((c) => (
            <li key={c.id} className="text-center">
              <img src={c.src} alt="" className="mx-auto size-12 rounded-full object-cover object-top" />
              <Stars n={bondLevel(s.xp[c.id])} />
              <p className="text-xs text-mist">Lv {bondLevel(s.xp[c.id])}</p>
            </li>
          ))}
        </ul>
      </section>
      <div className="grid gap-2">
        <Toggle
          on={s.privacy}
          label="Microphone stays off"
          onClick={() => {
            if (s.privacy) s.flash("Microphone can turn on. This browser may send speech off the device.");
            s.toggle("privacy");
          }}
        />
        <Toggle on={s.filters} label="Skip the silly choices" onClick={() => s.toggle("filters")} />
        <Toggle
          on={!s.muted}
          label="Voice on"
          onClick={() => {
            if (!s.muted) stopSpeak();
            s.toggle("muted");
          }}
        />
        <Toggle
          on={s.plus}
          label="Extra page preview"
          onClick={() => {
            s.toggle("plus");
            s.flash("Preview only. Nothing is charged. The bond stays free.");
          }}
        />
      </div>
      <p className="text-sm leading-relaxed text-mist">
        The extra page and the full memory list are a preview. They never lock a friend, a hug, or the bond.
        Talk is the only thing that can leave this phone, and only if you turn the microphone on.
      </p>
      <div className="rounded-3xl border border-line bg-panel/80 p-3">
        <p className="text-sm">Gentle limit: {formatSpan(s.limitMin)} / 2h</p>
        <input
          type="range"
          min={30}
          max={120}
          step={15}
          value={s.limitMin}
          aria-label="Gentle screen time limit"
          onChange={(e) => s.setLimit(Number(e.target.value))}
        />
        <button type="button" onClick={() => s.extendTonight()} className="min-h-11 text-sm text-gold">
          Add 15 quieter minutes tonight
        </button>
      </div>
      <form
        className="flex gap-2"
        onSubmit={(e) => {
          e.preventDefault();
          if (nextPin.length !== 4) return;
          s.setPin(nextPin);
          s.flash("New PIN saved on this device.");
          setNextPin("");
        }}
      >
        <input
          value={nextPin}
          onChange={(e) => setNextPin(e.target.value.replace(/\D/g, "").slice(0, 4))}
          inputMode="numeric"
          type="password"
          autoComplete="off"
          aria-label="New parent PIN"
          placeholder="New PIN"
          className="min-h-11 flex-1 rounded-2xl border border-line bg-night px-3 text-ink"
        />
        <button type="submit" className="min-h-11 rounded-full border border-gold/40 px-4">
          Save
        </button>
      </form>
      {s.note && <p className="text-sm text-gold">{s.note}</p>}
      {!confirm ? (
        <button type="button" onClick={() => setConfirm(true)} className="min-h-11 text-sm text-mist">
          Begin again on this device
        </button>
      ) : (
        <div className="rounded-3xl border border-line bg-dusk p-4">
          <p className="text-sm">Type the PIN to clear the bond on this phone. This cannot be undone.</p>
          <input
            value={wipePin}
            onChange={(e) => setWipePin(e.target.value.replace(/\D/g, "").slice(0, 4))}
            inputMode="numeric"
            type="password"
            autoComplete="off"
            aria-label="PIN to clear the bond"
            placeholder="PIN"
            className="mt-3 min-h-11 w-full rounded-2xl border border-line bg-night px-3 text-ink"
          />
          <div className="mt-3 flex gap-2">
            <button
              type="button"
              onClick={() => {
                if (wipePin !== s.pin) {
                  s.flash("That PIN doesn't match. The bond stays.");
                  return;
                }
                s.beginAgain();
              }}
              className="min-h-11 flex-1 rounded-full bg-gold text-night"
            >
              Clear the bond
            </button>
            <button type="button" onClick={() => setConfirm(false)} className="min-h-11 flex-1 rounded-full border border-line">
              Keep it
            </button>
          </div>
        </div>
      )}
    </main>
  );
}

function Meter({
  label,
  value,
  icon,
  gold,
}: {
  label: string;
  value: number;
  icon: ReactNode;
  gold?: boolean;
}) {
  return (
    <div className="rounded-full border border-gold/40 bg-night/75 px-4 py-2">
      <div className="flex items-center gap-2 text-sm">
        {icon}
        <span className="font-display">{label}</span>
      </div>
      <div className="mt-1 h-2 overflow-hidden rounded-full bg-dusk" role="meter" aria-valuenow={Math.round(value)} aria-valuemin={0} aria-valuemax={100} aria-label={label}>
        <div
          className={`h-full rounded-full ${gold ? "bg-gold" : "bg-ember"}`}
          style={{ width: `${Math.max(0, Math.min(100, value))}%` }}
        />
      </div>
    </div>
  );
}

function Chip({ icon, label, onClick }: { icon: ReactNode; label: string; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="flex min-h-16 w-full items-center justify-center gap-2 rounded-full border border-line bg-dusk px-4 text-lg"
    >
      {icon}
      {label}
    </button>
  );
}

function Action({ icon, label, onClick }: { icon: ReactNode; label: string; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="flex min-h-16 flex-col items-center justify-center gap-1 rounded-3xl border border-gold/40 bg-dusk px-2 py-3 text-center font-display text-xl text-ink"
    >
      {icon}
      {label}
    </button>
  );
}

function Toggle({ on, label, onClick }: { on: boolean; label: string; onClick: () => void }) {
  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      onClick={onClick}
      className="flex min-h-11 items-center justify-between gap-3 rounded-2xl border border-line bg-dusk px-3 text-left text-sm"
    >
      <span>{label}</span>
      <span className={`flex h-6 w-11 shrink-0 items-center rounded-full p-0.5 ${on ? "bg-trail" : "bg-line"}`}>
        <span className={`size-5 rounded-full bg-ink ${on ? "translate-x-5" : ""}`} />
      </span>
    </button>
  );
}

function Stars({ n }: { n: number }) {
  return (
    <span className="mt-1 flex justify-center" aria-label={`Level ${n}`}>
      {Array.from({ length: 5 }, (_, i) => (
        <Star key={i} className={`size-3 ${i < n ? "fill-gold text-gold" : "text-line"}`} aria-hidden />
      ))}
    </span>
  );
}

function Ring({ value }: { value: number }) {
  const r = 16;
  const c = 2 * Math.PI * r;
  const dash = c * Math.max(0, Math.min(1, value));
  return (
    <svg viewBox="0 0 40 40" className="size-12 shrink-0" aria-hidden>
      <circle cx="20" cy="20" r={r} className="fill-none stroke-dusk" strokeWidth="4" />
      <circle
        cx="20"
        cy="20"
        r={r}
        className="fill-none stroke-tide"
        strokeWidth="4"
        strokeDasharray={`${dash} ${c - dash}`}
        strokeLinecap="round"
        transform="rotate(-90 20 20)"
      />
    </svg>
  );
}
