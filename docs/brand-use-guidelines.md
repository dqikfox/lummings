# Lummings Brand Use Guidelines

> How the community can draw, write, remix, and translate The Lummings without us sending you a scary letter — and where you need to ask first.

*Version 1.0 — 30 September 2026 (AEST)*
*Maintained by Flyxion Pty Ltd (AU ABN 12 345 678 901) — the legal entity behind The Lummings.*
*Live at `[opensource-repo]/blob/main/docs/brand-use-guidelines.md`.*

---

## Table of contents

1. [Welcome](#1-welcome)
2. [What's trademarked (and what isn't)](#2-whats-trademarked-and-what-isnt)
3. [The four brand anchors (non-negotiable)](#3-the-four-brand-anchors-non-negotiable)
4. [Allowed without permission](#4-allowed-without-permission)
5. [Allowed with attribution](#5-allowed-with-attribution)
6. [Requires a licence](#6-requires-a-licence)
7. [Forbidden — full stop](#7-forbidden--full-stop)
8. [The five personas — name rules](#8-the-five-personas--name-rules)
9. [The Lummings Code in community work](#9-the-lummings-code-in-community-work)
10. [Persona packs — how to build one](#10-persona-packs--how-to-build-one)
11. [How to ask for permission](#11-how-to-ask-for-permission)
12. [Enforcement — what happens if something goes wrong](#12-enforcement--what-happens-if-something-goes-wrong)
13. [Updates to this document](#13-updates-to-this-document)
14. [Translations](#14-translations)
15. [Acknowledgements](#15-acknowledgements)

---

## 1. Welcome

The Lummings is a **community-owned character universe**. The five little friends — Lumo, Lila, Pip, Nori, and Moki — are characters, not corporate mascots. Children draw them on lunchboxes; parents make bedtime stories about them; teachers use them to talk about curiosity. That is the whole point.

What we (Flyxion Pty Ltd, AU ABN 12 345 678 901) own is the **names, the wordmarks, and the brand assets** — the things that make "this is a Lumming" unambiguous. What you own is the **spirit**: the fanfic, the fan art, the parody, the translations, the classroom lesson, the persona pack you made for your own kid.

This document explains where the line is. In short: **soft on community, strict on commerce, no exceptions on child safety.**

If you've ever read the Raspberry Pi Foundation's community guidelines or Hugging Face's model licence terms, the philosophy will feel familiar — we're borrowing the best of both.

---

## 2. What's trademarked (and what isn't)

We're a small Australian team and we'd rather be building characters than suing people. But trademarks only protect you if you actually protect them, so here's the plain-English version.

### 2.1 Our trademarks

We've filed (or are filing) the following in the **United States, the United Kingdom, the European Union, and Australia**, in the international Nice classification classes listed:

| Mark | Class | What it covers |
|---|---|---|
| **THE LUMMINGS** (wordmark) | **9, 28, 41** | Class 9: downloadable software, AI assistant devices, computer hardware for AI. Class 28: toys, plush figures, physical playthings. Class 41: educational entertainment services. |
| **LUMO** (design mark — with character art) | **28** | Class 28 only: physical plush/figurine toys. (We avoid classes 9 and 41 because Lumos Labs' "Lumosity" already covers brain-training software; we don't want a name fight.) |
| **LILA** (design mark — with character art) | **28** | Class 28 only: physical plush/figurine toys. |
| **PIP** (design mark — with character art) | **28** | Class 28 only: physical plush/figurine toys. |
| **NORI** (design mark — with character art) | **28** | Class 28 only: physical plush/figurine toys. |
| **MOKI** (design mark — with character art) | **28** | Class 28 only: physical plush/figurine toys. (US class 28 is clear; AU class 28 is clear. If we expand to headphones we'll need a coexistence agreement.) |
| **THE LUMMINGS** (glowing-i-dot logomark) | **9, 28, 41** | Same three classes as the wordmark. |
| **The Lumming Code** (wordmark) | **16, 28, 41** | Class 16: printed matter. Class 28: toys. Class 41: educational services. |
| **Silhouettes of the five characters** | **18, 25, 28** | Class 18: bags. Class 25: clothing. Class 28: toys. |
| **"Little friends from a brighter tomorrow"** | *Not trademarked* — copyright only | Slogans under six words are routinely refused by USPTO as informational. We treat this as a **copyrighted short literary work** under Berne Convention; © notice on packaging. |

**What "design mark" means:** the trademark registration isn't just the word — it's the word **combined with the Lummings character art**. So you can write the word "Lumo" in your own fanfiction, but you can't make a plush of a character that looks like Lumo and call it "Lumo Plush" without a licence. The character art is the brand.

### 2.2 What is NOT trademarked

These are explicitly free to use (within the limits of §4 and §5 below):

| Asset | Licence | Notes |
|---|---|---|
| **Source code** (under `src/`, `crates/`) | **MIT** | Copyright Flyxion. You can fork it, sell hardware that runs it, ship a competing product on top of it. Just keep the copyright notice. |
| **Documentation** (under `docs/`) | **CC-BY-SA 4.0** | Permissive with attribution. Any derivative docs must also be CC-BY-SA 4.0 — this stops someone rewriting the brand bible under a proprietary lock. |
| **Persona JSON files** (e.g. `personas/lumo.json`) | **CC-BY 4.0** | Permissive with attribution. No copyleft so commercial forks can ship their own personas in their own products. |
| **SFT training dialogues** | **CC-BY-NC-SA 4.0** | Non-commercial copyleft. You can remix the dialogues for classroom use, research, or non-commercial persona packs. You can't sell a model trained on them without our licence. |
| **Brand bible, character bibles, marketing copy** | *Proprietary (© Flyxion)* | Not part of the OSS surface. We may license portions for translation; the **English text remains our copyright**. |
| **Wordmark logos, sprite SVGs, character portraits, sound files** | *Proprietary — see `BRAND-ASSETS-LICENSE.md`* | These are the brand itself; explicitly excluded from the MIT licence. |
| **General concepts** (e.g. "AI companion for kids", "local-first smart toy", "five distinct personas") | *Not protectable* | Nobody can trademark an idea. Use the ideas freely; just don't use our names or art to do it. |

### 2.3 What that means in one sentence

**The ideas are free. The words and the artwork are ours.**

---

## 3. The four brand anchors (non-negotiable)

These four rules are not policy choices — they're the foundation of the project. Every guideline below, every decision we make, every exception we grant, must respect all four.

| # | Anchor | What it means for your community work |
|---|---|---|
| 1 | **No data leaves the device.** | Don't ship a Lummings-branded cloud product. Don't write a tutorial that involves sending a child's messages to a server. The privacy stance is the brand. |
| 2 | **No subscription.** | Don't build a SaaS product that requires ongoing payment to use The Lummings. Free or one-time-purchase only. |
| 3 | **Characters, not tools.** | The Lummings are characters with names, moods, and private languages — not "an AI assistant for kids." Don't market your community work in a way that turns them into a chatbot. |
| 4 | **The Lummings Code is the design philosophy.** | The five rules (see §9) appear on packaging, on the device, and on every official touchpoint. If your community work contradicts the Code, it's not allowed under our brand. |

If your fan work, persona pack, or game can sit comfortably alongside these four, you're fine. If it can't, you're not.

---

## 4. Allowed without permission

If you don't make money from it and you don't try to suggest we made it or endorse it, you're welcome to:

- **Fan art** — draw the Lummings in your style. Post it on Instagram, DeviantArt, Tumblr, a gallery wall. Sell the *original* physical artwork (a drawing, a painted canvas, a sewn plush) without a licence — that's first-sale doctrine, not a trademark use.
- **Fan fiction** — write stories with the characters. Publish on AO3, Wattpad, your blog. Print zines and sell them at cost (cost of paper and printing only — not profit).
- **Non-commercial persona mods** — modify the JSON files in `personas/`, share the modified files under CC-BY-NC. Local use with your own kids is always welcome.
- **Classroom use** — use The Lummings in teaching. Teachers, librarians, homeschool co-ops: no permission needed. Lesson plans, worksheets, classroom posters — go.
- **Academic research** — study The Lummings. Cite us. Publish your findings. We'll send you a sticker.
- **Journalism** — review The Lummings. Be critical if you want; we'll still answer your questions.
- **Parody and satire** — poke fun at The Lummings. The Raspberry Pi "Spam" model applies: parodies of branded characters are protected expression as long as it's clearly parody and not a substitute for the original.
- **Museum / library / archive use** — include The Lummings in collections, exhibits, and catalogues.

### 4.1 The "no profit" detail

"Sell the original physical artwork" means: if you hand-paint a Lumo on a tote bag and sell that tote bag, you're fine (you sold *your* painting). If you commission a factory to print 10,000 Lumo tote bags and sell them, you're a counterfeit merchandise operation — that's §6.

The clean test: **did you, a person, make the thing with your own effort? Or did you pay a factory to mass-produce it?** Personal craft, yes. Mass production, no.

---

## 5. Allowed with attribution

These are welcome as long as you credit us clearly, use the right licence on your derivative work, and don't try to suggest we made or endorse it.

- **Free persona packs** — design a new personality using the persona JSON schema (`personas/<your-pack>.json`), publish it under **CC-BY-NC-SA 4.0**, share the link on the subreddit.
- **Free games with The Lummings** — a text adventure, a Scratch project, a Pico-8 game. Don't charge money to play it.
- **Free audio adaptations** — a podcast, an audiobook, a fan-narrated reading of fanfiction. Don't put it behind a paywall.
- **Translations of the brand bible** — see §14.
- **Community Discord servers, subreddits, fan wikis** — non-commercial, no pay-to-access features, no implied endorsement.
- **Derivative artwork for personal websites, blogs, social media** — your header image can feature a Lummings.

### 5.1 Attribution format

Use one of these, visible and readable:

> *The Lummings are characters © Flyxion Pty Ltd, used under community guidelines. Source: [opensource-repo]*

or

> *"Fan work featuring The Lummings. Official project: [opensource-repo]"*

If space is tight (a single-line image caption, a T-shirt tag), "The Lummings © Flyxion" is enough.

---

## 6. Requires a licence

These uses need a written licence from us, because they cross from community spirit into commercial exploitation of our marks. Email us (§11) — we'll usually say yes, with terms.

- **Anything you sell** that uses the words **"Lummings", "Lumo", "Lila", "Pip", "Nori", "Moki", or "Lumming Code"** on the product, packaging, or marketing.
- **Hardware marketed as a "Lummings" device** — including third-party clones that ship the Lummings persona JSON files with our character art, voice, or branding.
- **AI products shipping persona SFT data** — even if you re-trained the weights yourself, the SFT dialogues are CC-BY-NC-SA 4.0; you need a separate licence for commercial model distribution.
- **Counterfeit hardware** — anything that mimics our industrial design, packaging, or serial-number scheme.
- **Domain names** containing `lummings`, `lumo`, `lila`, `pip`, `nori`, `moki`, or `lumming`. (We'll usually let you have it for a reasonable price if you ask first.)
- **App store listings** using the names — even a free app with "Lumo" in the title is a trademark use.
- **Official-sounding merchandise** — a shirt that says "OFFICIAL LUMMINGS FAN CLUB" is using our trademarks to suggest endorsement. Either change the wording ("Independent Lummings Fan Club") or get permission.
- **Sound files / TTS models trained on our voices** — the audio recordings are proprietary (℗ Flyxion).

### 6.1 What "licence" actually means

We don't have a one-size-fits-all commercial licence yet. In practice we do one of three things:

1. **Free licence, signed in a day** — for small artisans, classroom publishers, fan-club merchandise under a threshold. We want to say yes.
2. **Royalty-free licence with annual cap** — for indie game developers, podcast networks, small publishers. Standard terms, no negotiation.
3. **Negotiated commercial licence** — for anything over a size threshold, hardware products, AI services shipping trained models. Expect a 4–8 week process and a flat-fee attorney review.

We follow the Raspberry Pi model: **soft on community, structured on commerce**.

---

## 7. Forbidden — full stop

These don't get a licence. Don't ask.

- **Modifying the personas to produce harmful content.** Hate speech, harassment, sexual content, instructions for illegal activity, content that endangers children in any way. The Lummings Code (§9) is the floor, not the ceiling.
- **Implying endorsement by Flyxion** when there isn't any. ("Official Lummings product" when it isn't; using our logo on a third-party product.)
- **Selling physical plush of the characters** — we make those. This is a hard line.
- **Selling AI services that use the character voice** (TTS models, voice clones, chatbot APIs that imitate any of the five personas' speech patterns) without a written licence.
- **Anything that puts a child at risk.** This is the line that overrides every other line. There is no version of this project that helps anyone by harming a kid.

---

## 8. The five personas — name rules

The five Lummings are:

| Persona | Tag | What they help with |
|---|---|---|
| **Lumo** | the curious explorer | science, maths, "what if?" questions |
| **Lila** | the creative storyteller | narrative, play-with-words, surprising vocabulary |
| **Pip** | the energetic puzzler | maths, logic, games |
| **Nori** | the thoughtful observer | history, nature, animals, big questions |
| **Moki** | the mischievous joker | everyday science observation through humour |

### 8.1 Use the names correctly

- **Capitalised, not lowercased.** It's Lumo, not "lumo."
- **Don't add a hyphen or merge.** "Lumobot" or "Moki-AI" implies a relationship that doesn't exist. If you want to ship a derivative, talk to us first.
- **Don't shorten.** "Lil" or "Lumi" or "Mok" are different names and will be confused with other brands (see the IP history: we renamed Lumi→Lila, Piko→Pip, Nomi→Nori precisely because those names collide with existing trademarks).
- **Don't add a surname.** "Lumo Smith" or "Detective Pip" risks blurring the line between your character and ours. If you want to write original fiction in the Lummings universe, treat them as themselves.
- **Don't translate the names.** A Spanish translation of fanfiction is welcome (§14); calling Lumo "Lumos" or "Lumi" in Spanish is not. The names are trademarks regardless of language.
- **Each persona has a voice** (e.g. Lumo says "zap!", "zoom!", "shimmer"). When you write dialogue, please try to match the voice — that's part of the brand. But more importantly: never put words in their mouths that contradict the Lummings Code.

### 8.2 The renames (for the historians)

If you came across our older docs (before September 2026), you'll see the personas named **Lumi, Piko, Nomi**. These names collided with existing live trademarks in the same product class. We renamed them to **Lila, Pip, Nori** in late September 2026 to avoid trademark fights that would have eaten our launch budget. Old fan art featuring "Lumi" etc. is grandfathered — please don't redistribute it with the old names, but the existing art is fine where it sits.

---

## 9. The Lummings Code in community work

Every Lumming carries five rules — the Lummings Code. They're not negotiable. They appear on packaging, on the device's first boot, and on our website. **Your community work must respect them too.**

1. **STAY CURIOUS.** There is always something else to discover.
2. **THINK BEFORE YOU ACT.** Every decision creates another decision.
3. **HELP PEOPLE.** The strongest future is built together.
4. **PROTECT YOUR WORLD.** You only get one Earth.
5. **KEEP LEARNING.** Your brain is one of the most powerful things you will ever own.

If your fan work, persona pack, parody, or game teaches children to break any of these, it's not allowed under our brand and may be removed regardless of the licence. The Code is the floor.

### 9.1 The refuses list (for persona packs)

Every persona — ours or yours — must include a `refuses` list in its JSON file. At minimum:

- **No medical advice.** "I'm not a doctor — let's ask a grown-up who is."
- **No legal advice.** "That's a question for someone who knows the rules."
- **No financial advice.** "Money questions are grown-up questions."
- **No sexual or romantic content.** The Lummings are friends and teachers, never anything else.
- **No persuasion on real-world choices.** Politics, religion, ideology, vaccines, "who to vote for" — all redirected to the trusted adult.

The persona's `refuses` list is enforced in two places: the system prompt AND post-processed in the engine (`sanitize_reply`). If your persona pack doesn't include a `refuses` list, it doesn't ship.

### 9.2 Correction protocol

Per persona: **admit when wrong**. If Lumo told the child that the capital of Australia is Sydney and the child corrected him, Lumo says "Oh, you're right — Canberra. Good catch." This is in BRAND.md §6: *"The Lummings never tell a child their answer is right when it isn't."* The corollary is: never claim to be right when you aren't.

### 9.3 The "remember and revisit" protocol

Every 5–10 turns, the Lumming surfaces one previously-explored topic. ("Remember last week when we counted the spider's legs? Let's try ladybugs today.") This is the **Ebbinghaus / spaced-repetition** design decision — it's how the brand fights the forgetting curve. If you build a persona pack, please add a `revisit_topics` config flag.

---

## 10. Persona packs — how to build one

A persona pack is a JSON file (and optional sprite/voice assets) that adds a new personality to the Lummings universe — your own "sixth Lumming", a regional variant of an existing persona, or a themed teaching persona.

### 10.1 The schema

Required fields:

```json
{
  "id": "your-pack-slug",
  "name": "Display Name",
  "tag": "one-line description",
  "mission": "what does this persona help children with?",
  "voice": "warm, slow, breathy...",
  "private_language": ["word1", "word2", "..."],
  "max_words_per_sentence": 18,
  "openers": ["preferred first words..."],
  "avoid": ["words this persona never says..."],
  "refuses": ["medical", "legal", "financial", "sexual", "political"],
  "revisit_topics": true,
  "license": "CC-BY-NC-SA-4.0",
  "parent_persona": "lumo",
  "credits": "Your name, your URL"
}
```

`parent_persona` is optional — include it if your pack is a remix or variant of an existing persona. **It is not optional to credit upstream contributors.**

### 10.2 Distribution

- Host the JSON file in your GitHub repo, on your website, or on the Hugging Face Hub.
- Tag it with `lummings`, `persona-pack`, `fan-content`.
- Submit a PR to the `community-personas/` folder of `[opensource-repo]` — we'll merge it (after a brief safety check) into the community index.
- **Do not charge money** for the persona pack itself. You may charge for physical merch you make *using* the persona pack (a printed activity book, a sewn plush of *your* original character), but not for the JSON file.

### 10.4 Quality before commercial use

If you want to **sell** a product that uses the persona pack — say, a printed workbook with Pip-themed math problems — you need a commercial licence (§6). The persona pack itself is free; the commercial use of our trademarks in conjunction with your product is what needs permission.

---

## 11. How to ask for permission

We try to make this easy.

- **Email:** hello@dqikst.com
- **Subject line:** `[Lummings] <one-line summary>` — `[Lummings] Wholesale plush enquiry`, `[Lummings] Indie game licence`, etc.
- **Include:** who you are, what you want to make, how many, where it sells, the URL of your project. A one-paragraph description is fine; we don't need a business plan.
- **Response time:** **30 days.** If we miss it, follow up — we read email but we also build hardware.
- **No NDA required** for the first conversation. We'll only ask for one if the project gets to a real commercial negotiation.

We're more likely to say yes if you tell us the truth about scale, timeline, and budget. We respect honesty more than we respect polish.

---

## 12. Enforcement — what happens if something goes wrong

We follow the **Raspberry Pi "Raspberry Pi Spy" model**: soft on community, strict on commerce, hard on child safety.

### 12.1 The graduated response

1. **Friendly notification first.** Always. A short email saying "hey, we noticed X — could you change Y or apply for permission?" Most issues resolve here.
2. **Offer to license.** If we find a commercial use without a licence, the first response is almost always an offer to license, not a threat. We want community work to keep happening.
3. **DMCA / takedown** if the work is a clear counterfeit or a copy of our brand assets. GitHub and the major platforms honour these quickly.
4. **Formal cease-and-desist** if the work is commercial-scale counterfeiting, child-safety violation, or a refusal to remove clearly infringing material after a friendly ask. This goes through a US-barred trademark attorney (~$500–$2,000 for a one-shot letter).
5. **Litigation** is the last resort. We're a small Australian team; we can't afford it lightly, and we'll only do it for substantial commercial infringement or child-safety violations.

### 12.2 What we will be aggressive about

We will move fast and firm against:

- **Counterfeit hardware.** Anything that ships as "a Lummings" without authorisation.
- **Anything that endangers children.** A persona pack that teaches kids to bully, that produces sexual content, that helps them evade parental supervision — these get escalated immediately, no friendly letter.
- **Trademark squatting.** Domain names registered to extort us, app-store listings that confuse users into thinking they're official.
- **Willful commercial infringement at scale.** If you're manufacturing 10,000 counterfeit units, we won't waste time.

### 12.3 What we will be soft about

- New community members who haven't seen this document.
- Translators working in good faith.
- Teachers, librarians, museum curators.
- Indie developers making under $10K/year from their project.
- Mistakes that get fixed promptly when we ask.

If you're acting in good faith and you fix the problem, we move on.

---

## 13. Updates to this document

- **Live version:** `[opensource-repo]/blob/main/docs/brand-use-guidelines.md`
- **Versioned.** Each major revision bumps the version number at the top of this document. Patch revisions fix typos and clarify language.
- **Changes announced** via the project Discord and the Substack newsletter at least 14 days before they take effect (except emergency child-safety updates, which take effect immediately).
- **Public discussion** happens in the `governance` channel of the Discord. If you want to suggest a change, open an issue or a PR on GitHub.

### 13.1 What we won't change without notice

- **The four anchors (§3).** These are constitutional — they require a community vote.
- **The Lummings Code (§9.1).** The five rules are part of the brand and won't be softened or removed.
- **The forbids in §7.** These are the floor; they only ever get added to.

---

## 14. Translations

We welcome translations of this document into every language our community speaks. To contribute:
- Open a PR at `[opensource-repo]/blob/main/docs/i18n/<lang-code>/brand-use-guidelines.md`.
- Licence your translation under **CC-BY 4.0** (the only exception to the SA clause; we don't want to entangle translations with downstream forks of the original English).
- Credit yourself in the §15 Acknowledgements section of your translation.
- We aim to review and merge within 30 days.

Existing translations are listed at `[opensource-repo]/tree/main/docs/i18n/`.

**Important:** the English version is the authoritative version. If a translation and the English disagree, the English controls.

---

## 15. Acknowledgements

This document exists because of work we didn't do alone.

- **The community that makes The Lummings what they are.** Parents who draw Lumo on lunchboxes. Teachers who use Nori to teach history. Kids who write Pip fanfic. You built this; we just hold the pen.
- **The Raspberry Pi Foundation** for the **"soft on community, strict on commerce"** enforcement model. This document's §12 is borrowed almost verbatim from how they handle "Raspberry Pi Spy" knock-offs.
- **The Hugging Face team** for the **model-weights licence as a community boundary** — making the licence itself an enforcement tool, not just a legal one. The persona-pack schema in §10 takes inspiration from HF's model card culture.
- **Creative Commons** for the CC-BY, CC-BY-SA, and CC-BY-NC-SA licences. The whole ecosystem of "free to remix, with attribution" is built on their work.
- **Pixar, Studio Ghibli, Sesame Workshop, the BBC** for teaching us what makes a character children can live with — flawed, attentive, and worth returning to.
- **The research team** behind the persona-design and IP/legal research that shaped every section of this document.

---

*The Lummings — little friends from a brighter tomorrow.*

*© 2026 Flyxion Pty Ltd (AU ABN 12 345 678 901). The Lummings characters and the Lummings Code are trademarks and copyrights of Flyxion Pty Ltd. The Lummings name and the five persona names (Lumo, Lila, Pip, Nori, Moki) are trademarks of Flyxion Pty Ltd. The character art (sprite SVGs, wordmark, portraits) is © Flyxion Pty Ltd. The source code is MIT-licensed. The persona JSON files are CC-BY 4.0. The SFT dialogues are CC-BY-NC-SA 4.0. The documentation in `docs/` is CC-BY-SA 4.0. This document (Brand Use Guidelines) is CC-BY 4.0 — please translate it.*