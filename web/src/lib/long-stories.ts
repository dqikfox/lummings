import type { CrewId, Play, Story } from "@/lib/crew";

const NAMES: Record<CrewId, string> = {
  sprout: "Sprout",
  luna: "Luna",
  lumo: "Lumo",
  nori: "Nori",
  moki: "Moki",
};

const MIDDLES: Record<CrewId, string[]> = {
  sprout: [
    "The path splits around a sleeping beetle. You step wide so its dream stays whole. Sprout nods, the way a scout nods when you already knew the kind thing.",
    "Ferns tick the lantern. Each tick is a page. Sprout does not rush the ticks. “A long trail is just a short one that let you look.”",
    "An acorn cup holds a sip of rain. You are not thirsty. You still wait while a moth drinks first. The trail approves by staying put.",
    "Boot prints from earlier have filled with moonlight. Sprout fits a smaller foot beside them. “Someone came home this way. We can too.”",
    "The hill pretends to be taller than it is. You count twenty slow steps and the top arrives anyway. Sprout plants the lantern like a flag that does not boast.",
    "A branch has fallen across the path. It is not a gate. It is a seat. You sit until your breath matches the leaves.",
    "Moss makes a mile feel like a rug. Sprout takes off nothing, but walks as if the ground asked to be thanked.",
    "A root has learned your name and lifts itself just enough. You step over. The root settles, proud of a small kindness.",
  ],
  luna: [
    "Luna licks the pencil and the margin grows a door. Inside is the same night, only with more room for the sentence you have not said yet.",
    "A comma curls up like a cat. You scratch behind its ear and the sentence stretches, happy to be longer. Luna whispers, “Stories like being stayed with.”",
    "The next page is blank on purpose. Luna will not write it for you. She holds the pencil out, blunt end first, so the choice is gentle.",
    "Somewhere a book sneezes. Dust turns into tiny stars and settles on your sleeve. Luna brushes one off and puts it back in the story, where it was warm.",
    "You read a line twice because it was good. Luna does not turn the page. “Again is allowed. Again is how a line becomes yours.”",
    "The villain of this page is only a misplaced sock. You put it back in the drawer of the story. The drawer clicks, satisfied.",
    "A chapter mark bows as you pass. It was lonely, being a mark. Luna introduces you. Now it is a small friend who holds your place.",
    "The last word on the page refuses to be loud. You lean in. It says goodnight in a voice smaller than a moth.",
  ],
  lumo: [
    "Lumo sets the controller on the moss so both hands are free. “Pause is a power-up. Crew first means we check you are still having fun.”",
    "A health heart blinks in the corner of the night. It is not a score. It is a reminder to drink water and unclench your shoulders.",
    "The bridge is three planks and a promise. Lumo tests the first plank, then waits so you can test the second. Nobody crosses alone.",
    "A chest sits under a rune. The loot is a blanket. Lumo laughs once, quietly. “Best drop in the game.”",
    "The boss of this level is a loud thought. You and Lumo turn the volume down together until it is only a moth.",
    "Save point: the lantern. If the page gets big, you can come back here. Lumo writes your name in the log and underlines it twice.",
    "A tutorial ghost tries to hurry you. Lumo waves it off. “We already know how to be kind. Skip.”",
    "Two-player mode means Lumo walks half a step behind, close enough to catch a stumble, far enough that the quest is still yours.",
  ],
  nori: [
    "The tide writes a question and then wipes it away. Nori says you do not have to answer what the sea itself forgot.",
    "A shell holds a small weather report: calm, then calmer. You hold it to your ear and hear your own breath doing a good job.",
    "Moonlight lies on the water in tiles. Nori steps only on the bright ones, and the dark ones do not mind being left.",
    "A gull has gone to bed early. You and Nori agree not to file a report. Some nights are allowed to be unfinished.",
    "The lantern drinks a little fog and glows fatter. Nori turns it down so the fish can sleep. “Light is a guest. It should not stay loud.”",
    "Nori answers the big feeling with a smaller one, and that one you can carry in a pocket.",
    "A pool keeps a star and then lets it go. Nori says that is the whole lesson, and you do not have to pass a test about it.",
    "The shore counts your steps and then forgets them, so tomorrow can be new. Nori likes a shore with manners.",
  ],
  moki: [
    "Moki’s sparkle tries to be fireworks. You both shush it until it is a night-light with a sense of humor.",
    "A glitch hops onto the page and spells your name almost right. Moki fixes one letter and leaves one wrong, so the page still feels handmade.",
    "The dice in Moki’s pocket are warm. They want a job. Not yet. First you walk to the part of the story that needs a surprise.",
    "Something giggles in the margin. It is not a monster. It is the story, pleased that you noticed. Moki bows to it.",
    "A zigzag ear picks up a far-off song. Moki hums the polite version, the one without the crash. You hum the last note.",
    "The scarf tries to escape into the sky again. You catch one corner. The stars can wait their turn.",
    "A glitch apologises to a pebble for bumping it. The pebble has no mouth, so you say “accepted” on its behalf. Moki looks relieved.",
    "Sparkles queue in a line, which is new for them. Moki gives the front one a tiny clap. The rest wait, almost patient.",
  ],
};

function hash(id: string): number {
  return [...id].reduce((n, ch) => n + ch.charCodeAt(0), 0);
}

function take(bank: string[], n: number, count: number): string[] {
  return Array.from({ length: count }, (_, i) => bank[(n + i) % bank.length]);
}

function playFor(story: Story, slot: number): Play {
  const n = hash(story.id) + slot * 3;
  const kind = (hash(story.id) + slot) % 4;
  const who = NAMES[story.crew];
  if (kind === 0) {
    return {
      kind: "dice",
      prompt: `${who} holds out a soft die. Roll it. The path bends, and every bend still comes home.`,
      faces: ["Fern bend", "Lantern bend", "Quiet bend", "Beetle bend", "Moon bend", "Home bend"],
    };
  }
  if (kind === 1) {
    const a = (n % 3) + 1;
    const b = ((n >> 1) % 4) + 1;
    return {
      kind: "sum",
      prompt: `${who} counts with you. ${a} on this side, ${b} on that side. How many together?`,
      a,
      b,
    };
  }
  if (kind === 2) {
    const sets = [
      { options: ["An acorn", "A drum", "A boot"], answer: "An acorn" },
      { options: ["A pencil", "A trumpet", "A kettle"], answer: "A pencil" },
      { options: ["A shell", "A helmet", "A brick"], answer: "A shell" },
      { options: ["A star", "A spoon", "A stone"], answer: "A star" },
    ];
    const set = sets[n % sets.length];
    return {
      kind: "guess",
      prompt: `Something small is waiting in the story. ${who} gives you three guesses. What is it?`,
      options: set.options,
      answer: set.answer,
    };
  }
  const odds = ["Acorn", "Pencil", "Shell", "Star", "Scarf"];
  const odd = odds[n % odds.length];
  return {
    kind: "spot",
    prompt: `Look closely. One of these does not match. Tap the different one. ${who} will wait.`,
    items: ["Lantern", "Lantern", odd, "Lantern", "Lantern", "Lantern"],
    odd,
  };
}

const ORDER = ["p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "p10", "p11", "end"] as const;

export function pageCount(): number {
  return ORDER.length;
}

export function pageOf(beatId: string): number {
  const i = ORDER.indexOf(beatId as (typeof ORDER)[number]);
  return i < 0 ? 1 : i + 1;
}

/** Turn a short night into a book: twelve pages, two different games, then the ending. */
export function lengthen(story: Story): Story {
  if (story.beats.p1 && story.beats.end && !story.chapters) return story;
  const opening = story.beats[story.start];
  const ending = Object.values(story.beats).find((beat) => beat.end) ?? opening;
  const n = hash(story.id);
  const chapters = story.chapters?.length
    ? story.chapters
    : take(MIDDLES[story.crew], n, 8);
  const [a, b, c, d, e, f, g, h] = [...chapters, ...take(MIDDLES[story.crew], n, 8)].slice(0, 8);
  const who = NAMES[story.crew];
  return {
    ...story,
    start: "p1",
    beats: {
      p1: { text: opening.text, choices: [{ label: "Turn the page", next: "p2" }] },
      p2: { text: a, choices: [{ label: "Keep going", next: "p3" }] },
      p3: { text: b, choices: [{ label: "The night gets wider", next: "p4" }] },
      p4: {
        text: `${who} stops in “${story.title}”. This page is a game. A wrong try only means another try.`,
        play: playFor(story, 0),
        choices: [{ label: "On we go", next: "p5" }],
      },
      p5: { text: c, choices: [{ label: "Another page", next: "p6" }] },
      p6: { text: d, choices: [{ label: "Stay a little", next: "p7" }] },
      p7: {
        text: `The path asks for a second game, a different one. ${who} sits beside you until it is done.`,
        play: playFor(story, 1),
        choices: [{ label: "That was the game", next: "p8" }],
      },
      p8: { text: e, choices: [{ label: "Nearly there", next: "p9" }] },
      p9: { text: f, choices: [{ label: "One more turn", next: "p10" }] },
      p10: { text: g, choices: [{ label: "The quiet bit", next: "p11" }] },
      p11: { text: h, choices: [{ label: "The last page", next: "end" }] },
      end: { text: ending.text, end: true },
    },
  };
}