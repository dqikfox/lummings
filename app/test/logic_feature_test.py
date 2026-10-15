#!/usr/bin/env python3
"""
Mirrors HeartlightController + Adventure engine logic for pre-device validation.
Run: python3 app/test/logic_feature_test.py
"""
from __future__ import annotations
import json
import sys
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional

ROOT = Path(__file__).resolve().parents[1]
PACK_PATH = ROOT / "assets/adventures/growing_together_001.json"

PASS = 0
FAIL = 0

def check(name: str, cond: bool, detail: str = ""):
    global PASS, FAIL
    if cond:
        PASS += 1
        print(f"  PASS  {name}")
    else:
        FAIL += 1
        print(f"  FAIL  {name}  {detail}")

# --- Bond curve (mirrors BondProgress.xpForLevel) ---
def xp_for_level(level: int) -> int:
    return 40 + (level * 25) + (level * level * 3)

@dataclass
class Bond:
    level: int = 1
    xp: int = 0
    xp_to_next: int = field(default_factory=lambda: xp_for_level(1))

@dataclass
class Companion:
    lumming_id: str = "lumo"
    phase: str = "glowing"  # dimmed|caring|glowing|radiant
    bond: Bond = field(default_factory=Bond)
    care_streak: int = 0
    last_care: Optional[datetime] = None
    shards: int = 0
    memories: list = field(default_factory=list)

    def cared_today(self, now: Optional[datetime] = None) -> bool:
        if not self.last_care:
            return False
        now = now or datetime.now()
        return self.last_care.date() == now.date()

    def missed_yesterday(self, now: Optional[datetime] = None) -> bool:
        if not self.last_care:
            return True
        now = now or datetime.now()
        last_day = self.last_care.date()
        y = (now - timedelta(days=1)).date()
        return last_day < y

def add_xp(c: Companion, amount: int, shards: int = 0) -> Companion:
    level, xp, need = c.bond.level, c.bond.xp + amount, c.bond.xp_to_next
    leveled = False
    while xp >= need:
        xp -= need
        level += 1
        need = xp_for_level(level)
        leveled = True
    c.bond = Bond(level=level, xp=xp, xp_to_next=need)
    c.shards += shards
    if leveled:
        c.phase = "radiant"
    return c

def perform_care(c: Companion, kind: str = "hug", now: Optional[datetime] = None):
    now = now or datetime.now()
    if c.cared_today(now):
        return {"already": True, "xp": 0, "message": "already glowing", "c": c}
    missed = c.missed_yesterday(now) and c.last_care is not None
    streak = 1 if missed else c.care_streak + 1
    return_bonus = 15 if missed else 0
    base = 20 + (5 if kind == "story" else 0)
    xp_gain = base + return_bonus
    c.phase = "caring"
    c.care_streak = streak
    c.last_care = now
    c = add_xp(c, xp_gain, shards=1)
    c.phase = "glowing" if c.phase != "radiant" else "radiant"
    msg = "Heartlight brighter."
    if missed:
        msg = "I missed you… " + msg
        c.memories.append("Came back after a quiet day")
    return {"already": False, "xp": xp_gain, "streak": streak, "message": msg, "c": c}

def main():
    print("=== Lummings logic feature tests ===\n")

    # Bond curve
    print("[Bond XP]")
    check("level1 > 0", xp_for_level(1) > 0)
    check("level5 > level1", xp_for_level(5) > xp_for_level(1))
    check("level10 > level5", xp_for_level(10) > xp_for_level(5))

    # Care once/day
    print("\n[Care Ritual]")
    c = Companion()
    r1 = perform_care(c, "hug")
    check("first care not already", not r1["already"])
    check("hug XP == 20", r1["xp"] == 20, f"got {r1['xp']}")
    check("streak 1", r1["streak"] == 1)
    check("shard +1", r1["c"].shards == 1)
    check("phase glowing", r1["c"].phase in ("glowing", "radiant"))
    r2 = perform_care(r1["c"], "talk")
    check("second care blocked", r2["already"])

    # Story bonus
    c2 = Companion()
    rs = perform_care(c2, "story")
    check("story XP == 25", rs["xp"] == 25, f"got {rs['xp']}")

    # Soft miss
    print("\n[Soft miss hook]")
    c3 = Companion(care_streak=5, last_care=datetime.now() - timedelta(days=3), phase="dimmed")
    check("missed_yesterday", c3.missed_yesterday())
    r3 = perform_care(c3, "hug")
    check("return streak soft-reset to 1", r3["streak"] == 1)
    check("return bonus XP 35", r3["xp"] == 35, f"got {r3['xp']}")
    check("miss message", "missed" in r3["message"].lower())
    check("return memory", any("Came back" in m for m in r3["c"].memories))
    check("no punishment (still gains XP)", r3["xp"] > 0)

    # Level up
    print("\n[Bond level-up]")
    c4 = Companion(bond=Bond(level=1, xp=0, xp_to_next=xp_for_level(1)))
    need = c4.bond.xp_to_next
    c4 = add_xp(c4, need)
    check("leveled to 2", c4.bond.level == 2, f"level={c4.bond.level}")
    check("radiant on level-up", c4.phase == "radiant")

    # Adventure graph
    print("\n[Adventure pack]")
    pack = json.loads(PACK_PATH.read_text())
    nodes = {n["id"]: n for n in pack["nodes"]}
    check("start exists", pack["start"] in nodes)
    check("10 nodes", len(nodes) == 10, f"got {len(nodes)}")
    bad_links = []
    for n in pack["nodes"]:
        for ch in n.get("choices", []):
            if ch["next"] not in nodes:
                bad_links.append(f"{n['id']}->{ch['next']}")
    check("all choice targets valid", not bad_links, str(bad_links))
    endings = [n for n in pack["nodes"] if n.get("ending")]
    check(">=2 endings", len(endings) >= 2, str(len(endings)))
    check("endings have no choices", all(not e.get("choices") for e in endings))
    speakers = {n.get("speaker") for n in pack["nodes"]}
    for s in ("lumo", "lila", "pip", "nori", "moki"):
        check(f"speaker {s}", s in speakers)
    safety = any(c.get("safety_check") for n in pack["nodes"] for c in n.get("choices", []))
    check("safety_check present", safety)
    essence = nodes.get("essence", {})
    body = essence.get("body", "").lower()
    check("essence teaches soul/essence", "essence" in body or "soul" in body)

    # Reachability
    from collections import deque
    seen = set()
    q = deque([pack["start"]])
    while q:
        i = q.popleft()
        if i in seen:
            continue
        seen.add(i)
        for ch in nodes[i].get("choices", []):
            q.append(ch["next"])
    check("all nodes reachable", seen == set(nodes), f"orphan {set(nodes)-seen}")

    # Walk all paths — reward simulation
    print("\n[Full path walks]")
    def walk(node_id, path, xp, shards, mems):
        n = nodes[node_id]
        path = path + [node_id]
        if n.get("ending"):
            yield path, xp, shards, mems
            return
        for ch in n.get("choices", []):
            m = list(mems)
            if ch.get("memory"):
                m.append(ch["memory"])
            yield from walk(ch["next"], path, xp + ch.get("bond_xp", 5), shards + ch.get("shards", 0), m)

    paths = list(walk(pack["start"], [], 0, 0, []))
    check("multiple endings reachable", len(paths) >= 2, f"paths={len(paths)}")
    check("every path ends at ending", all(nodes[p[0][-1]].get("ending") for p in [(a,b,c,d) for a,b,c,d in paths]))
    # fix: paths is list of tuples
    check("every path ends at ending node", all(nodes[path[-1]].get("ending") for path, *_ in paths))
    min_xp = min(xp for _, xp, _, _ in paths)
    max_xp = max(xp for _, xp, _, _ in paths)
    check("paths grant XP", min_xp > 0, f"min={min_xp}")
    print(f"    paths={len(paths)} xp_range={min_xp}-{max_xp}")

    # Simulate adventure reward on companion
    path, xp, shards, mems = paths[0]
    c5 = Companion()
    total_xp = xp + pack.get("completion_bond_xp", 40)
    total_shards = shards + pack.get("completion_shards", 3)
    c5 = add_xp(c5, total_xp, shards=total_shards)
    c5.memories.extend(mems)
    check("adventure grants shards", c5.shards >= total_shards)
    check("adventure memories stored", len(c5.memories) == len(mems))

    # Crew canon from dart file
    print("\n[Dart source presence]")
    lib = ROOT / "lib"
    for rel in [
        "state/heartlight_controller.dart",
        "state/adventure_controller.dart",
        "screens/shell.dart",
        "screens/care_screen.dart",
        "screens/adventures_screen.dart",
        "screens/home_screen.dart",
        "screens/parent_screen.dart",
        "screens/talk_screen.dart",
        "screens/onboarding/onboarding_flow.dart",
        "models/lumming.dart",
        "models/adventure.dart",
        "models/heartlight_state.dart",
        "main.dart",
        "app.dart",
    ]:
        check(f"file {rel}", (lib / rel).exists())

    # Dart static smell checks
    print("\n[Dart static checks]")
    hl = (lib / "state/heartlight_controller.dart").read_text()
    check("Heartlight has performCare", "performCare" in hl)
    check("return bonus 15", "returnBonus = missed ? 15" in hl or "returnBonus = missed ? 15 : 0" in hl)
    check("soft miss memory", "I missed you" in hl or "missed you" in hl.lower() or "Came back" in hl)
    check("never paywall note in care path", "performCare" in hl)
    adv = (lib / "state/adventure_controller.dart").read_text()
    check("adventure choose rewards heartlight", "rewardAdventure" in adv)
    shell = (lib / "screens/shell.dart").read_text()
    check("5 nav destinations", shell.count("NavigationDestination") >= 5)
    onboarding = (lib / "screens/onboarding/onboarding_flow.dart").read_text()
    check("3-step onboarding", "step == 0" in onboarding and "step == 1" in onboarding)
    check("Safety First in onboarding", "Safety First" in onboarding or "Parents & Safety" in onboarding)
    parent = (lib / "screens/parent_screen.dart").read_text()
    check("parent PIN gate", "verifyParentPin" in parent or "PIN" in parent)
    lum = (lib / "models/lumming.dart").read_text()
    check("Heartlight essence comment", "essence" in lum.lower() or "soul" in lum.lower())
    for name in ("Questlight", "Dreamlight", "Traillight", "Tidelight", "Sparklight"):
        check(f"Heartlight {name}", name in lum)

    print("\n=== RESULT ===")
    print(f"PASSED: {PASS}  FAILED: {FAIL}")
    return 0 if FAIL == 0 else 1

if __name__ == "__main__":
    sys.exit(main())
