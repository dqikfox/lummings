"""HTTP API for the Lummings. Open browser, talk to a Lumming."""

import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

from .engine import (
    load_persona,
    build_system_prompt,
    Memory,
    Mood,
    sanitize_reply,
    extract_facts,
)
from .cli import chat


HTML = """<!doctype html>
<html><head><meta charset="utf-8"><title>The Lummings</title>
<style>
body{background:#1a1f2e;color:#e6e8eb;font-family:system-ui;margin:0;padding:2rem}
h1{color:#ffb86c;text-align:center;margin-bottom:0.2rem}
.tag{text-align:center;color:#888;font-style:italic;margin-top:0}
#face{font-family:monospace;font-size:2.8rem;text-align:center;margin:1.5rem;color:#8be9fd}
#persona{background:#2a3142;color:#e6e8eb;border:1px solid #444;padding:0.4rem;border-radius:4px;font-size:1rem}
#log{background:#222840;border:1px solid #444;border-radius:8px;padding:1rem;height:50vh;overflow:auto;margin:1rem 0;font-size:0.95rem}
.msg-user{color:#50fa7b;margin:0.5rem 0}
.msg-bot{color:#8be9fd;margin:0.5rem 0}
.mood{color:#bd93f9;font-size:0.85rem;font-style:italic}
#input{width:75%;background:#2a3142;color:#e6e8eb;border:1px solid #444;padding:0.6rem;border-radius:4px;font-size:1rem}
button{background:#ff79c6;color:#fff;border:none;padding:0.6rem 1.2rem;border-radius:4px;cursor:pointer;font-size:1rem;margin-left:0.5rem}
.fact{color:#f1fa8c;font-size:0.8rem;font-style:italic;margin:0.2rem 0}
</style></head><body>
<h1>The Lummings</h1>
<p class="tag">Little friends from a brighter tomorrow.</p>
<div>Talk to: <select id="persona">
<option value="lumo">Lumo — the curious explorer</option>
<option value="lumi">Lumi — the creative storyteller</option>
<option value="piko">Piko — the energetic puzzler</option>
<option value="nomi">Nomi — the thoughtful observer</option>
<option value="moki">Moki — the mischievous joker</option>
</select>
&nbsp; Mood: <span id="mood" class="mood">curious</span>
</div>
<div id="face">( • o • )?</div>
<div id="log"></div>
<input id="input" placeholder="Say hello to your Lumming..." autofocus />
<button onclick="send()">Send</button>
<div id="facts"></div>
<script>
const log=document.getElementById('log'),input=document.getElementById('input'),
personaSel=document.getElementById('persona'),faceEl=document.getElementById('face'),
moodEl=document.getElementById('mood');
input.addEventListener('keydown',e=>{if(e.key==='Enter')send();});
async function send(){
  const m=input.value.trim();if(!m)return;
  append(m,'msg-user');input.value='';
  const r=await fetch('/chat',{method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify({persona:personaSel.value,message:m,
      base_url:'http://127.0.0.1:11434/v1',model:'qwen2.5-3b-instruct'})});
  const j=await r.json();
  if(j.error){append('error: '+j.error,'msg-bot');return}
  append(j.reply+'  ('+j.elapsed.toFixed(1)+'s)','msg-bot');
  faceEl.textContent=j.face;moodEl.textContent=j.mood;log.scrollTop=log.scrollHeight;
}
function append(t,c){const d=document.createElement('div');d.className=c;d.textContent=t;log.appendChild(d);log.scrollTop=log.scrollHeight}
</script>
</body></html>
"""


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("--port", type=int, default=8511)
    ap.add_argument("--db", default="./lummings.sqlite")
    args = ap.parse_args()

    states = {}

    class H(BaseHTTPRequestHandler):
        def log_message(self, *a, **k):
            pass

        def _send(self, status, body):
            self.send_response(status)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(body).encode())

        def do_GET(self):
            if self.path in ("/", "/ui"):
                self.send_response(200)
                self.send_header("Content-Type", "text/html")
                self.end_headers()
                self.wfile.write(HTML.encode())
            elif self.path.startswith("/persona/"):
                name = self.path.split("/")[-1]
                self._send(200, load_persona(name))
            else:
                self._send(404, {"error": "not found"})

        def do_POST(self):
            if not self.path.startswith("/chat"):
                self._send(404, {"error": "not found"})
                return
            length = int(self.headers.get("Content-Length", 0))
            body = json.loads(self.rfile.read(length) or b"{}")
            persona_name = body.get("persona", "lumo")
            user_msg = body.get("message", "").strip()
            if not user_msg:
                self._send(400, {"error": "empty"})
                return
            persona = load_persona(persona_name)
            st = states.setdefault(persona_name, {
                "memory": Memory(Path(args.db), persona_name),
                "mood": Mood(persona),
            })
            st["mood"].on_user_input()
            st["memory"].add_event("user", user_msg)
            history = [{"role": e["role"], "content": e["text"]} for e in st["memory"].recent_events(6)]
            sys_prompt = build_system_prompt(persona, memory_summary=st["memory"].summarize())
            r = chat(body.get("base_url", "http://127.0.0.1:11434/v1"),
                     body.get("model", "qwen2.5-3b-instruct"),
                     sys_prompt, user_msg, history=history)
            if not r["ok"]:
                self._send(502, {"error": r["error"]})
                return
            reply = sanitize_reply(r["content"], persona)
            st["memory"].add_event("assistant", reply)
            for f in extract_facts(user_msg, reply):
                st["memory"].add_fact(f)
            st["mood"].state = st["mood"].next_mood_after_response()
            faces = {"curious":"( o_o )?", "excited":"( ^o^ )!", "playful":"( ^_^ )",
                     "calm":"( ._. )", "drowsy":"( -.- )..zz", "tired":"( -_- )"}
            self._send(200, {
                "reply": reply,
                "mood": st["mood"].state,
                "face": faces.get(st["mood"].state, "( ._. )"),
                "elapsed": r.get("elapsed", 0),
            })

    server = ThreadingHTTPServer(("127.0.0.1", args.port), H)
    print(f"The Lummings HTTP API on http://127.0.0.1:{args.port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nbye.")


if __name__ == "__main__":
    main()
