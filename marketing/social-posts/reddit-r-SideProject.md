# r/SideProject post draft

**Subreddit:** r/SideProject
**Style:** value-first, demo-second, link-third
**Title:** I built a kids' AI character app that runs entirely on-device (5 mascots, persistent memory, no cloud). Here's what I learned shipping it solo.

**Body:**

I wanted to build an AI character app for my kids' age range (5-12) without sending a single byte to the cloud. After shipping, here's what surprised me:

1. **The "AI companion for kids" space is a graveyard.** Moxie shut down Dec 2024 and bricked its existing units. My Friend Cayla was banned in Germany in 2017. Furby Connect's companion app was sunset April 2023. Every product that combined a child user with cloud dependency has either been hacked, banned, or discontinued.

2. **Local-first means parents trust you.** I expected "no subscription" to be the main selling point. It's actually "no cloud." Parents in early user interviews all said the same thing: "I just don't want anyone talking to my kid except my kid."

3. **Quantized models are finally good enough for kids.** I shipped with Qwen2.5-1.5B Q4_K_M on a Pi Zero 2 W. Not fast, but coherent. 7B on a desktop GPU is plenty.

The product: 5 mascots with distinct personalities, persistent memory per character, parent controls, refusal library. Web app is free. Optional $29 asset pack with 60 portraits for people who want the art.

If you want to try it: [link to /lummings/]

Happy to answer questions about the local-LLM stack, refusal library, or the kids-privacy rabbit hole.

**Comments I should reply to first:**
- "How do you handle the safety stuff?" → link to PRIVACY_POLICY.md and refusal library doc
- "What does it cost to run?" → free web, $0 for Pi hardware + 1-2 GB sandbox
- "Why not use GPT-4?" → Because cloud. That's the whole point.

**DO NOT POST UNTIL:** account has 50+ karma, ideally commenting for 1-2 weeks.
