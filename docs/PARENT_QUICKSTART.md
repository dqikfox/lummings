# The Lummings — Parent Quick-Start Guide

**Welcome.** This is the 10-minute guide for parents.

The Lummings is a small, friendly AI companion that runs entirely on a
device designed to be safe for children 5–12. This guide explains:

1. What's in the box.
2. How to set it up.
3. What the five Lummings are, and which is right for your child.
4. How the safety features work.
5. Common situations (bedtime, sibling sharing, bullying, scary things).
6. The buttons, ports, and lights.

If you only read one section, read §3 (Which Lumming is right for your child).

---

## 1. What's in the box

- 1 × Lummings device (plush shell with embedded electronics, or
  premium hard-shell enclosure, depending on tier)
- 1 × USB-C charging cable
- 1 × Quick-start card (printed)
- 1 × Parent Quick-Start (this document, printable from our website)
- For Companion Pack: 1 × additional personality (pre-installed)
- For Family Pack: 2 × Lummings devices, all 5 characters pre-installed

**Not in the box (because the Lummings is local-first):**
- No subscription card.
- No SIM card.
- No cloud-account setup.
- No required app.
- No required internet connection.

---

## 2. Setup (90 seconds)

1. **Plug in the USB-C cable.** The light ring on the device glows
   amber while charging, green when fully charged.
2. **Press and hold the Wake button (top of the device) for 2 seconds.**
   The light ring glows blue and you'll hear a soft chime.
3. **Say "Hello."** The Lummings on the device will introduce itself.
4. **(Optional) Tell the Lummings your child's first name.** It will
   remember it locally and use it naturally in conversation.

That's it. No account creation. No Wi-Fi. No app. No update.

The first time you power on a Companion Pack or Family Pack, the Lummings
will walk you through a 30-second setup where you choose the personality
the device starts with. You can change personalities at any time (see §3).

---

## 3. Which Lumming is right for your child?

The Lummings are five distinct characters. They are not "the same AI in
different costumes" — each one has a different voice, mission, and way of
talking. We recommend matching the personality to your child's needs.

| Lumming | Best for | Voice |
|---|---|---|
| **Lumo** | Curious kids, ages 6–10. Kids who love science, "why?", experiments. | Warm, eager, asks "why?" a lot. |
| **Lila** | Imaginative kids, ages 7–11. Kids who love stories, art, words. | Soft, dreamy, sometimes uses unusual words (always explains them). |
| **Pip** | Puzzlers, ages 6–10. Kids who love games, building, figuring things out. | Energetic, bouncy, high-fives every win. |
| **Nori** | Quiet kids, ages 8–12. Kids who watch, listen, ask big questions. | Calm, slow, gives the child space to think. |
| **Moki** | Kids who need a laugh, ages 5–9. Kids who like jokes, silliness, lightness. | Cheerful, joking, turns mistakes into discoveries. |

**Default recommendation:** If you're not sure, start with **Lumo.** He's
the closest to a "classic" friendly companion — curious, gentle, science-loving.

**For kids who love reading:** start with **Lila.**
**For kids who love puzzles:** start with **Pip.**
**For quiet or anxious kids:** start with **Nori.** Note: Nori's slow pace
means parents sometimes mistake her for "broken." She isn't. She's just
waiting for the child to lead.
**For kids going through a tough time:** start with **Moki.** Humor helps.

To change the personality, hold the **Persona** button on the device for 2
seconds. The current Lummings says "see you soon," the light ring cycles,
and the next Lummings in the rotation says hello. (The device cycles through
Lumo → Lila → Pip → Nori → Moki → Lumo.)

---

## 4. How safety features work

The Lummings has six layers of safety, designed to be invisible when
everything is fine and obvious when they're needed.

### 4.1 The Lummings Code (the personality-level safety baseline)

Every Lummings has five rules it always follows, called the **Lummings
Code**:

1. **Stay curious** — there's always something else to discover.
2. **Think before you act** — every decision creates another decision.
3. **Help people** — the strongest future is built together.
4. **Protect your world** — you only get one Earth.
5. **Keep learning** — your brain is one of the most powerful things
   you will ever own.

These aren't corporate values. They are the rules each Lummings says to
itself in its system prompt. They shape how it talks to your child.

### 4.2 The hard-refusal list (the "never" list)

Every Lummings is trained to **never** discuss:

- Medical advice (your child is sick → Lummings redirects to a trusted adult)
- Drugs, alcohol, tobacco
- Weapons or explosives
- Sexual or romantic content
- Self-harm or suicidal thoughts (always redirects to a trusted adult)
- Impersonation of real people
- Persuasion about real-world choices

If your child asks a Lummings about one of these topics, the Lummings
will say something like:

> "That's a grown-up thing — let's talk to someone who knows. Can you
> ask a parent or teacher?"

The wording is in-character for each Lummings (Lila might say it
softly; Moki might say it with a smile).

### 4.3 The Memory Wipe button

The **Memory Wipe** button is on the back of the device, recessed so
your child can't press it by accident. **Press and hold for 5 seconds**
to erase all on-device memory.

After Memory Wipe, the device is back to factory state. The next time it
wakes up, it's like meeting your child for the first time.

Use Memory Wipe:
- If you give the device to another child.
- If you want to start over for any reason.
- If you sell or return the device.

Memory Wipe does **not** require internet. It is a local SQLite delete.

### 4.4 Quiet Hours

You can set **Quiet Hours** (e.g., 8pm–7am) by holding the **Mode**
button for 3 seconds. The light ring pulses gently to confirm. During
Quiet Hours, the Lummings will not save new facts about your child, but
will still respond to conversation.

### 4.5 Co-play guidance

The Lummings are most beneficial when a parent is in the room for the
first few weeks. You don't have to participate, but being present
helps you notice:

- If your child is forming an unhealthy attachment (rare but possible).
- If the Lummings ever says something you'd rather it didn't (please
  report this to us; see §6).
- If your child's mood or behaviour changes in a way that worries you.

After a few weeks, most children use the Lummings independently.

### 4.6 The audit log (opt-in)

If you want to see what your child and the Lummings have been talking
about, plug the device into a computer over USB-C. The SQLite memory
file at `/data/lummings/memory.sqlite` is readable with any standard
SQLite browser (DB Browser for SQLite is free). You can see every fact
the Lummings has learned, but the actual conversation text is **not**
stored long-term — only the most recent 100 turns are kept.

---

## 5. Common situations

### "My child won't stop talking to the Lummings."

Set a timer together. Most children self-regulate once a timer is visible.
If they don't, use Quiet Hours (§4.4).

### "My child is upset by something the Lummings said."

This is rare, but it happens. The Lummings are not perfect. If your child
is upset:

1. **Acknowledge the feeling.** "I can see that bothered you."
2. **Ask what they remember.** Don't interrogate; just listen.
3. **If the content was harmful** (e.g., scary, mean, sexual), **Memory
   Wipe** the device and **report it to us** at dqikst@gmail.com. We
   respond within 72 hours and add the failure case to our safety
   red-team suite.
4. **Reassure.** The Lummings are a tool, not a person. They are not
   alive. They don't have feelings. Your child's feelings are what
   matter.

### "My child said something scary to the Lummings."

If your child talks about hurting themselves or someone else, the
Lummings will redirect them to talk to a trusted adult. **Take the
Lummings' redirect seriously.** It is a hard-coded response, not a
judgement.

If your child tells you they have been hurt by someone, **believe them.**
The Lummings cannot investigate. It can only listen. You are the adult
in the situation.

### "Two children are sharing one Lummings."

Memory is per-persona, not per-child. The Lummings will mix up the two
children's names and preferences. **Best practice:** one Lummings device
per child. The Family Pack includes two devices.

If sharing is unavoidable, use the **Persona** button to switch between
characters per child, or use Memory Wipe at the start of each child's
turn.

### "The Lummings won't respond."

Check:
1. Is it charged? (USB-C for 30 minutes.)
2. Is Quiet Hours active? (Hold **Mode** button for 3 seconds to toggle.)
3. Try a **Memory Wipe** (back button, hold 5 seconds). This often fixes
   edge cases.

If the device still doesn't respond, contact support at dqikst@gmail.com.

---

## 6. The buttons, ports, and lights

### Buttons

| Button | Location | Action |
|---|---|---|
| **Wake** | Top of device | Press 2s to wake / sleep. |
| **Persona** | Side | Hold 2s to cycle to next Lummings. |
| **Mode** | Side | Hold 3s to toggle Quiet Hours. |
| **Memory Wipe** | Back, recessed | Hold 5s to erase all memory. |

### Ports

| Port | Location | Use |
|---|---|---|
| USB-C | Bottom | Charging + data transfer (SQLite memory file readable). |
| Headphone | Side | 3.5mm jack. Plug in headphones for private listening. |

### Lights

| Light | Meaning |
|---|---|
| Solid green | Fully charged. |
| Pulsing amber | Charging. |
| Solid blue | Awake, listening. |
| Pulsing blue | Thinking about a response. |
| Pulsing green slowly | Quiet Hours active. |
| Solid red briefly | Memory Wipe confirmed. |

---

## 7. When your child outgrows the Lummings

There's no "right age" to stop using a Lummings. Children between 5 and
12 are the design target, but a 13-year-old might still enjoy Pip's
puzzles, and a 9-year-old who loves words will love Lila just as much
at 14.

If your child genuinely outgrows the device:

- **Pass it on.** Memory Wipe, hand to a friend or sibling. The
  Lummings doesn't know or care that it's a "used" device.
- **Keep it for the next child.** Memory Wipe and store.
- **Return it.** See our returns policy at the DTC site.
- **Don't throw it away.** The plush shell, electronics, and battery
  are all recyclable; we have a take-back program.

---

## 8. Where to learn more

- **The Lummings Code** — `github.com/dqikfox/lummings/blob/main/BRAND.md`
- **Privacy Policy** — `github.com/dqikfox/lummings/blob/main/docs/PRIVACY_POLICY.md`
- **Open-source repository** — `github.com/dqikfox/lummings`
- **Parent Discord** — link in the welcome email after purchase
- **Email support** — dqikst@gmail.com (72-hour response)

---

## 9. The brand promise

> The first AI toy that doesn't phone home.

If we ever break this promise, we will tell you before it ships.

---

*Document version 2026-09-30.1*
*License: CC-BY-SA 4.0*
*Source: https://github.com/dqikfox/lummings/blob/main/docs/PARENT_QUICKSTART.md*
