import { create } from "zustand";
import { persist } from "zustand/middleware";
import {
  type Adventure,
  type CharmId,
  type CrewId,
  MAIN_CHARMS,
  crewById,
  todayKey,
  yesterdayKey,
} from "@/lib/crew";

export type View =
  | "welcome"
  | "safety"
  | "pick"
  | "home"
  | "story"
  | "adventures"
  | "collection"
  | "care"
  | "parent";

export type Memory = { id: string; text: string; crew: CrewId; at: number };
export type CareKind = "tuck" | "quiet" | "lantern";

type XpMap = Record<CrewId, number>;
type CharmMap = Record<CharmId, number>;

const ZERO_XP: XpMap = { sprout: 0, luna: 0, lumo: 0, nori: 0, moki: 0 };
const ZERO_CHARMS: CharmMap = {
  traillight: 0,
  dreamlight: 0,
  questlight: 0,
  tidelight: 0,
  sparklight: 0,
  heartlight: 0,
  dawnlight: 0,
  stowlight: 0,
};

export type LummState = {
  view: View;
  onboarded: boolean;
  primary: CrewId | null;
  active: CrewId | null;
  xp: XpMap;
  heartlight: number;
  charms: CharmMap;
  adventures: string[];
  streak: number;
  lastCare: string | null;
  careDone: Partial<Record<CareKind, string>>;
  pin: string;
  pinReady: boolean;
  parentOpen: boolean;
  limitMin: number;
  bonusSec: number;
  bonusDay: string;
  privacy: boolean;
  filters: boolean;
  memories: Memory[];
  memoryDay: string;
  usedSec: number;
  usedDay: string;
  talkCount: number;
  talkDay: string;
  muted: boolean;
  note: string;
  focusStory: string | null;
  go: (view: View) => void;
  openTale: (storyId: string) => void;
  choose: (id: CrewId) => void;
  setActive: (id: CrewId) => void;
  setPin: (pin: string) => void;
  openParent: (pin: string) => boolean;
  closeParent: () => void;
  setLimit: (min: number) => void;
  toggle: (key: "privacy" | "filters" | "muted") => void;
  grant: (id: CrewId, xp: number, heart?: number, charm?: CharmId, charmN?: number) => void;
  hug: (id: CrewId) => void;
  talk: (id: CrewId) => void;
  finishStory: (id: CrewId) => void;
  finishAdventure: (adv: Adventure) => "ok" | "repeat" | "poor" | "locked";
  care: (kind: CareKind, id: CrewId) => boolean;
  remember: (text: string, id: CrewId) => boolean;
  tick: (sec: number) => void;
  extendTonight: () => void;
  flash: (note: string) => void;
  beginAgain: () => void;
};

function freshDayFields(day: string) {
  return { usedDay: day, usedSec: 0, talkDay: day, talkCount: 0, bonusDay: day, bonusSec: 0 };
}

const persistedDefaults = {
  onboarded: false,
  primary: null as CrewId | null,
  active: null as CrewId | null,
  xp: ZERO_XP,
  heartlight: 72,
  charms: ZERO_CHARMS,
  adventures: [] as string[],
  streak: 0,
  lastCare: null as string | null,
  careDone: {} as Partial<Record<CareKind, string>>,
  pin: "",
  pinReady: false,
  limitMin: 90,
  bonusSec: 0,
  bonusDay: "",
  privacy: true,
  filters: true,
  memories: [] as Memory[],
  memoryDay: "",
  usedSec: 0,
  usedDay: "",
  talkCount: 0,
  talkDay: "",
  muted: false,
};

function savedCrew(id: string | null | undefined): CrewId | null {
  if (id === "pip") return "sprout";
  if (id === "lila") return "luna";
  if (id === "sprout" || id === "luna" || id === "lumo" || id === "nori" || id === "moki") return id;
  return null;
}

function savedXp(xp: Partial<Record<string, number>> | undefined): XpMap {
  const src = xp ?? {};
  return {
    sprout: src.sprout ?? src.pip ?? 0,
    luna: src.luna ?? src.lila ?? 0,
    lumo: src.lumo ?? 0,
    nori: src.nori ?? 0,
    moki: src.moki ?? 0,
  };
}

export const useLumm = create<LummState>()(
  persist(
    (set, get) => ({
      ...persistedDefaults,
      view: "welcome",
      parentOpen: false,
      note: "",
      focusStory: null,
      go: (view) =>
        set({
          view,
          focusStory: null,
          parentOpen: view === "parent" ? get().parentOpen : false,
          note: "",
        }),
      openTale: (storyId) => set({ focusStory: storyId, view: "story", parentOpen: false, note: "" }),
      choose: (id) =>
        set({
          primary: id,
          active: id,
          onboarded: true,
          view: "home",
          note: `${crewById(id).name} saved you a place. The bond begins.`,
        }),
      setActive: (id) => set({ active: id }),
      setPin: (pin) => set({ pin, pinReady: pin.length === 4 }),
      openParent: (pin) => {
        const ok = get().pinReady && pin === get().pin;
        if (ok) set({ parentOpen: true, view: "parent" });
        return ok;
      },
      closeParent: () => set({ parentOpen: false }),
      setLimit: (min) => set({ limitMin: Math.min(120, Math.max(30, min)) }),
      toggle: (key) => set({ [key]: !get()[key] }),
      grant: (id, xp, heart = 0, charm, charmN = 0) =>
        set((s) => ({
          xp: { ...s.xp, [id]: Math.min(100, s.xp[id] + xp) },
          heartlight: Math.min(100, s.heartlight + heart),
          charms: charm
            ? { ...s.charms, [charm]: Math.min(100, s.charms[charm] + charmN) }
            : s.charms,
        })),
      hug: (id) => {
        const c = get();
        c.grant(id, 10, 8, "heartlight", 8);
        set({ note: "Bond grew. Heartlight warmed." });
      },
      talk: (id) => {
        const day = todayKey();
        const s = get();
        const count = s.talkDay === day ? s.talkCount : 0;
        if (count < 3) {
          s.grant(id, 4, 2);
          set({ talkDay: day, talkCount: count + 1, note: "The crew heard you." });
        } else {
          set({ note: "They're still listening. The bond is already glowing." });
        }
      },
      finishStory: (id) => {
        const charm = (
          { sprout: "traillight", luna: "dreamlight", lumo: "questlight", nori: "tidelight", moki: "sparklight" } as const
        )[id];
        get().grant(id, 15, 6, charm, 18);
        set({ note: "The story tucked itself in beside your bond." });
      },
      finishAdventure: (adv) => {
        const s = get();
        if (!s.primary) return "locked";
        if (s.adventures.includes(adv.id)) return "repeat";
        if (s.heartlight < adv.cost) return "poor";
        const who = adv.crew ?? s.primary;
        set({
          heartlight: s.heartlight - adv.cost,
          adventures: [...s.adventures, adv.id],
        });
        get().grant(who, adv.xp, 0, adv.charm, 34);
        if (who !== s.primary) get().grant(s.primary, 6, 0);
        set({ note: "The path remembers this step." });
        return "ok";
      },
      care: (kind, id) => {
        const day = todayKey();
        const s = get();
        if (s.careDone[kind] === day) return false;
        const firstToday = s.lastCare !== day;
        const streak = !firstToday ? s.streak : s.lastCare === yesterdayKey() ? s.streak + 1 : 1;
        const hearts = kind === "tuck" ? 16 : 10;
        const xp = kind === "tuck" ? 12 : 8;
        get().grant(id, xp, hearts, "heartlight", 10);
        set({
          careDone: { ...get().careDone, [kind]: day },
          lastCare: day,
          streak,
          note: firstToday ? `Day ${streak} of growing together.` : "Cared for, softly.",
        });
        return true;
      },
      remember: (text, id) => {
        const trimmed = text.trim().slice(0, 140);
        if (!trimmed) return false;
        const day = todayKey();
        const s = get();
        if (s.memoryDay === day) return false;
        const memory: Memory = { id: `${Date.now()}`, text: trimmed, crew: id, at: Date.now() };
        set({
          memories: [memory, ...s.memories].slice(0, 12),
          memoryDay: day,
        });
        get().grant(id, 6, 4, "heartlight", 6);
        set({ note: "Saved on this device, in the quiet gallery." });
        return true;
      },
      tick: (sec) => {
        const day = todayKey();
        const s = get();
        if (!s.onboarded) return;
        if (s.usedDay !== day) {
          set({ ...freshDayFields(day), usedSec: sec });
          return;
        }
        set({ usedSec: s.usedSec + sec });
      },
      extendTonight: () => {
        const day = todayKey();
        const s = get();
        const bonus = s.bonusDay === day ? s.bonusSec : 0;
        set({ bonusDay: day, bonusSec: bonus + 15 * 60, note: "Fifteen quieter minutes, just for tonight." });
      },
      flash: (note) => set({ note }),
      beginAgain: () =>
        set({
          ...persistedDefaults,
          xp: { ...ZERO_XP },
          charms: { ...ZERO_CHARMS },
          view: "welcome",
          parentOpen: false,
          note: "",
        }),
    }),
    {
      name: "lummings",
      skipHydration: true,
      partialize: (s) => ({
        onboarded: s.onboarded,
        primary: s.primary,
        active: s.active,
        xp: s.xp,
        heartlight: s.heartlight,
        charms: s.charms,
        adventures: s.adventures,
        streak: s.streak,
        lastCare: s.lastCare,
        careDone: s.careDone,
        pin: s.pin,
        pinReady: s.pinReady,
        limitMin: s.limitMin,
        bonusSec: s.bonusSec,
        bonusDay: s.bonusDay,
        privacy: s.privacy,
        filters: s.filters,
        memories: s.memories,
        memoryDay: s.memoryDay,
        usedSec: s.usedSec,
        usedDay: s.usedDay,
        talkCount: s.talkCount,
        talkDay: s.talkDay,
        muted: s.muted,
      }),
      merge: (persisted, current) => {
        const saved = (persisted ?? {}) as Partial<LummState> & {
          xp?: Partial<Record<string, number>>;
          primary?: string | null;
          active?: string | null;
        };
        return {
          ...current,
          ...saved,
          xp: savedXp(saved.xp),
          primary: savedCrew(saved.primary),
          active: savedCrew(saved.active),
          memories: (saved.memories ?? []).map((memory) => ({
            ...memory,
            crew: savedCrew(memory.crew) ?? "lumo",
          })),
        };
      },
    },
  ),
);

export function limitSeconds(s: { limitMin: number; bonusSec: number; bonusDay: string }): number {
  const bonus = s.bonusDay === todayKey() ? s.bonusSec : 0;
  return s.limitMin * 60 + bonus;
}

export function resting(s: { usedSec: number; usedDay: string; limitMin: number; bonusSec: number; bonusDay: string }): boolean {
  if (s.usedDay !== todayKey()) return false;
  return s.usedSec >= limitSeconds(s);
}

export function setComplete(charms: Record<CharmId, number>): boolean {
  return MAIN_CHARMS.every((id) => charms[id] >= 100);
}
