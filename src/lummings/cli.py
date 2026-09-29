"""Terminal REPL for testing Lummings locally."""

import argparse
import json
import urllib.request
from pathlib import Path

from .engine import (
    load_persona,
    build_system_prompt,
    Memory,
    Mood,
    sanitize_reply,
    extract_facts,
)


def chat(base_url: str, model: str, system: str, user: str, history=None,
         max_tokens: int = 120, temperature: float = 0.7, timeout: int = 60) -> dict:
    msgs = [{"role": "system", "content": system}]
    if history:
        msgs.extend(history[-6:])
    msgs.append({"role": "user", "content": user})
    body = json.dumps({
        "model": model, "messages": msgs, "max_tokens": max_tokens,
        "temperature": temperature, "stream": False
    }).encode()
    req = urllib.request.Request(
        f"{base_url.rstrip('/')}/chat/completions",
        data=body, headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            data = json.loads(r.read())
            return {"ok": True, "content": data["choices"][0]["message"]["content"]}
    except Exception as e:
        return {"ok": False, "error": str(e)[:120]}


FACES = {
    "curious": "( • o • )?", "excited": "( ^o^ )!", "playful": "( ^ _ ^ )",
    "calm": "( • _ • )", "drowsy": "( -  - )..zz", "tired": "( - _ - )",
    "watchful": "( • • )", "embarrassed": "( ° △ ° )",
}


def main():
    ap = argparse.ArgumentParser(description="Talk to a Lumming in the terminal")
    ap.add_argument("--persona", default="lumo", choices=["lumo", "lumi", "piko", "nomi", "moki"])
    ap.add_argument("--base-url", default="http://127.0.0.1:11434/v1")
    ap.add_argument("--model", default="qwen2.5-3b-instruct")
    ap.add_argument("--db", default="./lummings.sqlite")
    args = ap.parse_args()

    persona = load_persona(args.persona)
    print(f"\n=== {persona['name']} ===")
    print(f"{persona['tagline']}\n")

    mem = Memory(Path(args.db), persona["name"])
    mood = Mood(persona)
    history = []

    while True:
        try:
            user = input("you > ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nbye.")
            break
        if not user:
            continue
        if user.lower() in ("quit", "exit"):
            break

        mood.on_user_input()
        mem.add_event("user", user)
        sys_prompt = build_system_prompt(persona, memory_summary=mem.summarize())

        r = chat(args.base_url, args.model, sys_prompt, user, history=history)
        if not r["ok"]:
            print(f"{persona['name']} (silent — {r['error'][:60]})")
            continue
        reply = sanitize_reply(r["content"], persona)
        mem.add_event("assistant", reply)
        for f in extract_facts(user, reply):
            mem.add_fact(f)

        history.append({"role": "user", "content": user})
        history.append({"role": "assistant", "content": reply})

        face = FACES.get(mood.state, "( • _ • )")
        print(f"\n{persona['name']} [{mood.state}] {face}")
        print(f"  {reply}\n")
        mood.state = mood.next_mood_after_response()


if __name__ == "__main__":
    main()
