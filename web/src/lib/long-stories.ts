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
  ],
  luna: [
    "Luna licks the pencil and the margin grows a door. Inside is the same night, only with more room for the sentence you have not said yet.",
    "A comma curls up like a cat. You scratch behind its ear and the sentence stretches, happy to be longer. Luna whispers, “Stories like being stayed with.”",
    "The next page is blank on purpose. Luna will not write it for you. She holds the pencil out, blunt end first, so the choice is gentle.",
    "Somewhere a book sneezes. Dust turns into tiny stars and settles on your sleeve. Luna brushes one off and puts it back in the story, where it was warm.",
    "You read a line twice because it was good. Luna does not turn the page. “Again is allowed. Again is how a line becomes yours.”",
    "The villain of this page is only a misplaced sock. You put it back in the drawer of the story. The drawer clicks, satisfied.",
  ],
  lumo: [
    "Lumo sets the controller on the moss so both hands are free. “Pause is a power-up. Crew first means we check you are still having fun.”",
    "A health heart blinks in the corner of the night. It is not a score. It is a reminder to drink water and unclench your shoulders.",
    "The bridge is three planks and a promise. Lumo tests the first plank, then waits so you can test the second. Nobody crosses alone.",
    "A chest sits under a rune. The loot is a blanket. Lumo laughs once, quietly. “Best drop in the game.”",
    "The boss of this level is a loud thought. You and Lumo turn the volume down together until it is only a moth.",
    "Save point: the lantern. If the page gets big, you can come back here. Lumo writes your name in the log and underlines it twice.",
  ],
  nori: [
    "The tide writes a question and then wipes it away. Nori says you do not have to answer what the sea itself forgot.",
    "A shell holds a small weather report: calm, then calmer. You hold it to your ear and hear your own breath doing a good job.",
    "Moonlight lies on the water in tiles. Nori steps only on the bright ones, and the dark ones do not mind being left.",
    "A gull has gone to bed early. You and Nori agree not to file a report. Some nights are allowed to be unfinished.",
    "The lantern drinks a little fog and glows fatter. Nori turns it down so the fish can sleep. “Light is a guest. It should not stay loud.”",
    "You ask why, and Nori answers with a smaller why, and that one you can carry in a pocket.",
  ],
  moki: [
    "Moki’s sparkle tries to be fireworks. You both shush it until it is a night-light with a sense of humor.",
    "A glitch hops onto the page and spells your name almost right. Moki fixes one letter and leaves one wrong, so the page still feels handmade.",
    "The dice in Moki’s pocket are warm. They want a job. Not yet. First you walk to the part of the story that needs a surprise.",
    "Something giggles in the margin. It is not a monster. It is the story, pleased that you noticed. Moki bows to it.",
    "A zigzag ear picks up a far-off song. Moki hums the polite version, the one without the crash. You hum the last note.",
    "The scarf tries to escape into the sky again. You catch one corner. The stars can wait their turn.",
  ],
};

function hash(id: string): number {
  return [...id].reduce((n, ch) => n + ch.charCodeAt(0), 0);
}

function playFor(story: Story): Play {
  const n = hash(story.id);
  const kind = n % 4;
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
    const b = (n % 4) + 1;
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

function take(bank: string[], n: number, count: number): string[] {
  return Array.from({ length: count }, (_, i) => bank[(n + i) % bank.length]);
}

/** Turn a short night into a book: several pages, then one game, then the ending you already had. */
export function lengthen(story: Story): Story {
  const opening = story.beats[story.start];
  const ending = Object.values(story.beats).find((beat) => beat.end) ?? opening;
  const n = hash(story.id);
  const [a, b, c, d] = take(MIDDLES[story.crew], n, 4);
  const who = NAMES[story.crew];
  return {
    ...story,
    start: "p1",
    beats: {
      p1: {
        text: opening.text,
        choices: [{ label: "Turn the page", next: "p2" }],
      },
      p2: {
        text: a,
        choices: [{ label: "Keep going", next: "p3" }],
      },
      p3: {
        text: b,
        choices: [{ label: "The night gets wider", next: "p4" }],
      },
      p4: {
        text: `${who} stops in the middle of “${story.title}”. This page is a game. Take your time. Getting it wrong only means trying once more.`,
        play: playFor(story),
        choices: [{ label: "On we go", next: "p5" }],
      },
      p5: {
        text: c,
        choices: [{ label: "Almost morning", next: "p6" }],
      },
      p6: {
        text: d,
        choices: [{ label: "The last page", next: "end" }],
      },
      end: {
        text: ending.text,
        end: true,
      },
    },
  };
}
