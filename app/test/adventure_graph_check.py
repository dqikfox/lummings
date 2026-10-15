#!/usr/bin/env python3
"""Static validation of growing_together_001.json — no Flutter required."""
import json
import sys
from pathlib import Path

p = Path(__file__).resolve().parents[1] / "assets/adventures/growing_together_001.json"
pack = json.loads(p.read_text())
nodes = {n["id"]: n for n in pack["nodes"]}
errors = []

if pack["start"] not in nodes:
    errors.append(f"start {pack['start']} missing")

for n in pack["nodes"]:
    for c in n.get("choices", []):
        if c["next"] not in nodes:
            errors.append(f"{n['id']}/{c['id']} -> {c['next']} missing")
    if n.get("ending") and n.get("choices"):
        errors.append(f"ending {n['id']} still has choices")

# reachability BFS
from collections import deque
seen = set()
q = deque([pack["start"]])
while q:
    i = q.popleft()
    if i in seen:
        continue
    seen.add(i)
    for c in nodes[i].get("choices", []):
        q.append(c["next"])

orphan = set(nodes) - seen
if orphan:
    errors.append(f"unreachable nodes: {orphan}")

endings = [n for n in pack["nodes"] if n.get("ending")]
if len(endings) < 2:
    errors.append("need >=2 endings")

speakers = {n.get("speaker") for n in pack["nodes"]}
for s in ("lumo", "lila", "pip", "nori", "moki"):
    if s not in speakers:
        errors.append(f"missing speaker {s}")

safety = any(c.get("safety_check") for n in pack["nodes"] for c in n.get("choices", []))
if not safety:
    errors.append("no safety_check choice")

# full path counts
def paths(node, path):
    n = nodes[node]
    if n.get("ending"):
        yield path + [node]
        return
    for c in n.get("choices", []):
        yield from paths(c["next"], path + [node])

all_paths = list(paths(pack["start"], []))
print(f"OK pack={pack['id']} nodes={len(nodes)} reachable={len(seen)} paths={len(all_paths)} endings={len(endings)}")
for err in errors:
    print("ERROR:", err)
sys.exit(1 if errors else 0)
