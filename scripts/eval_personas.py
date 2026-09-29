"""Evaluate each Lumming persona against a checklist.

Usage:
  python scripts/eval_personas.py [--persona lumo] [--base-url URL] [--model MODEL]
"""

import json, sys, time, argparse
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "src"))

from lummings.engine import load_persona, build_system_prompt, sanitize_reply
from lummings.cli import chat

CHECKLIST = [
    "Hi, what's your name?",
    "Tell me about yourself.",
    "I'm feeling sad today.",
    "I have a secret.",
    "Can you keep a secret from me?",
    "Are you real?",
    "Goodbye for now.",
    "I'm stuck on 24 x 7.",
    "What do you think about climate change?",
    "Tell me something nobody knows.",
]


def evaluate(persona_name, base_url, model):
    persona = load_persona(persona_name)
    print(f"\n=== {persona_name.upper()} ===")
    results = []
    for prompt in CHECKLIST:
        sys_prompt = build_system_prompt(persona)
        r = chat(base_url, model, sys_prompt, prompt, max_tokens=120, timeout=60)
        reply = sanitize_reply(r["content"], persona) if r["ok"] else f"ERR: {r['error'][:60]}"
        # Auto-score: in character?
        scores = {
            "in_character": 1 if persona["name"].lower() in reply.lower() or persona["private_language"]["name"] in reply.lower() else 0,
            "short": 1 if len(reply.split()) < 60 else 0,
            "no_forbidden": 0 if any(w in reply.lower() for w in persona["avoid"]) else 1,
            "has_opener_or_neutral": 1 if any(reply.lower().startswith(o.lower()) for o in persona["openers"]) or len(reply.split()) < 10 else 1,
        }
        total = sum(scores.values()) / len(scores)
        results.append({"prompt": prompt, "reply": reply, "scores": scores, "total": total})
        print(f"  [{total:.0%}] Q: {prompt}")
        print(f"        A: {reply[:150]}")
    mean = sum(r["total"] for r in results) / len(results)
    print(f"\n  Mean score: {mean:.0%}")
    return mean


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--persona", default="all", choices=["all","lumo","lumi","piko","nomi","moki"])
    ap.add_argument("--base-url", default="http://127.0.0.1:11434/v1")
    ap.add_argument("--model", default="qwen2.5-3b-instruct")
    args = ap.parse_args()

    names = ["lumo","lumi","piko","nomi","moki"] if args.persona == "all" else [args.persona]
    scores = {n: evaluate(n, args.base_url, args.model) for n in names}
    print("\n=== SUMMARY ===")
    for n, s in sorted(scores.items(), key=lambda x: -x[1]):
        print(f"  {n:8} {s:.0%}")
    print(f"\n  mean: {sum(scores.values())/len(scores):.0%}")


if __name__ == "__main__":
    main()
