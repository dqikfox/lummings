import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { CREW_IDS, bondLevel, crewById, originFor, roster, storiesFor, todayKey } from "@/lib/crew";
import { limitSeconds, resting, useLumm } from "@/lib/store";
import { TOGETHER, clipFor } from "@/lib/voice";

describe("bond", () => {
  it("opens one friend at the start and the circle by level 5", () => {
    assert.equal(bondLevel(0), 1);
    assert.equal(bondLevel(19), 1);
    assert.equal(bondLevel(20), 2);
    assert.equal(bondLevel(80), 5);
    assert.equal(bondLevel(200), 5);
    assert.equal(roster("lumo", 0).filter((slot) => slot.open).length, 1);
    assert.equal(roster("sprout", 40).filter((slot) => slot.open).length, 3);
    assert.equal(roster("moki", 80).filter((slot) => slot.open).length, 5);
  });
});

describe("bedtime rest", () => {
  it("rests only after today's limit, and a bonus pushes it back", () => {
    const day = todayKey();
    const base = { usedDay: day, limitMin: 30, bonusSec: 0, bonusDay: "" };
    assert.equal(limitSeconds(base), 1800);
    assert.equal(resting({ ...base, usedSec: 1799 }), false);
    assert.equal(resting({ ...base, usedSec: 1800 }), true);
    assert.equal(resting({ ...base, usedSec: 1800, usedDay: "1999-1-1" }), false);
    assert.equal(resting({ ...base, usedSec: 1800, bonusDay: day, bonusSec: 60 }), false);
  });

  it("ticks up to the rest and a hug still warms the bond", () => {
    useLumm.getState().beginAgain();
    useLumm.getState().choose("lumo");
    const day = todayKey();
    useLumm.setState({ usedDay: day, usedSec: 0, limitMin: 30, bonusSec: 0, bonusDay: day });
    assert.equal(resting(useLumm.getState()), false);
    useLumm.getState().tick(30 * 60);
    assert.equal(resting(useLumm.getState()), true);
    const before = useLumm.getState().xp.lumo;
    useLumm.getState().hug("lumo");
    assert.equal(useLumm.getState().xp.lumo, before + 10);
  });

  it("stops bond talk after three listens in a day", () => {
    useLumm.getState().beginAgain();
    useLumm.getState().choose("nori");
    const start = useLumm.getState().xp.nori;
    useLumm.getState().talk("nori");
    useLumm.getState().talk("nori");
    useLumm.getState().talk("nori");
    useLumm.getState().talk("nori");
    assert.equal(useLumm.getState().xp.nori, start + 12);
    assert.equal(useLumm.getState().talkCount, 3);
  });
});

describe("voices", () => {
  it("plays a real take and stays quiet when there isn't one", () => {
    for (const id of CREW_IDS) {
      const friend = crewById(id);
      assert.ok(clipFor(friend.hello, id)?.endsWith(".mp3"));
      assert.equal(clipFor(friend.hug, id), undefined);
      assert.equal(clipFor(friend.sleep, id), undefined);
      assert.equal(storiesFor(id).length, 7);
      const book = storiesFor(id)[0];
      assert.equal(Object.keys(book.beats).length, 7);
      assert.ok(book.beats.p4.play);
      assert.equal(originFor(id).origin, true);
      assert.equal(storiesFor(id).filter((story) => story.shared).length, 1);
    }
    assert.equal(clipFor(crewById("nori").moon, "nori"), "/voices/nori-moon.mp3");
    assert.equal(clipFor(crewById("lumo").moon, "lumo"), undefined);
    assert.equal(clipFor(TOGETHER), "/voices/together.mp3");
    assert.equal(clipFor("a made-up line", "moki"), undefined);
  });
});
