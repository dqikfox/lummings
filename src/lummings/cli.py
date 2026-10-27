"""Terminal REPL for testing Lummings locally."""

import argparse
import json
import urllib.request
from pathlib import Path

from .engine import (
    Memory,
    Mood,
    build_runtime_prompt,
    extract_facts,
    get_character_model,
    load_persona,
    sanitize_reply,
)


def chat(base_url: str, model: str, system: str, user: str, history=None,
         max_tokens: int = 256, temperature: float = 0.7, timeout: int = 60) -> dict:
    """Call Ollama /api/chat directly for reliable character responses.
    
    /v1/chat/completions exposes reasoning chains on thinking models,
    while /api/chat returns clean responses in the content field.
    """
    # Build messages
    msgs = []
    if history:
        for h in history[-6:]:
            msgs.append({"role": h["role"], "content": h["content"]})
    msgs.append({"role": "user", "content": user})
    
    body = json.dumps({
        "model": model,
        "messages": msgs,
        "stream": False,
        "options": {
            "num_predict": max_tokens,
            "temperature": temperature,
        }
    }).encode()
    
    req = urllib.request.Request(
        f"{base_url.rstrip('/').replace('/v1', '')}/api/chat",
        data=body, headers={"Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            data = json.loads(r.read())
            msg = data.get("message", {})
            content = msg.get("content", "").strip()
            # Fallback to thinking field if content is empty (reasoning models)
            if not content:
                content = msg.get("thinking", "").strip()
            return {"ok": True, "content": content}
    except Exception as e:  # noqa: BLE001 - boundary: report any provider failure to the caller
        return {"ok": False, "error": str(e)[:120]}


FACES = {
    "curious": "( • o • )?", "excited": "( ^o^ )!", "playful": "( ^ _ ^ )",
    "calm": "( • _ • )", "drowsy": "( -  - )..zz", "tired": "( - _ - )",
    "watchful": "( • • )", "embarrassed": "( ° △ ° )",
}


def main():
    ap = argparse.ArgumentParser(description="Talk to a Lumming in the terminal")
    ap.add_argument("--persona", default="lumo", choices=["lumo", "lila", "pip", "nori", "moki"])
    ap.add_argument("--base-url", default="http://127.0.0.1:11434/v1")
    ap.add_argument("--model", default=None, help="Override the dedicated character model")
    ap.add_argument("--db", default="./lummings.sqlite")
    args = ap.parse_args()

    persona = load_persona(args.persona)
    model = args.model or get_character_model(args.persona)
    print(f"\n=== {persona['name']} ===")
    print(f"{persona['tagline']}\n")
    print(f"[using model: {model}]\n")

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
        runtime_ctx = build_runtime_prompt(persona, memory_summary=mem.summarize(), mood=mood.state)
        if runtime_ctx.strip():
            final_user = f"{runtime_ctx}\n\n{user}"
        else:
            final_user = user

        r = chat(args.base_url, model, "", final_user, history=history)
        if not r["ok"]:
            print(f"{persona['name']} (silent -- {r['error'][:60]})")
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
