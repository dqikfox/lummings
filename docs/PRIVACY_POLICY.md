# The Lummings — Privacy Policy

**Effective date:** 2026-09-30
**Last updated:** 2026-09-30

This is the privacy policy for **The Lummings** family of products, including
the Lummings smart toy, companion mobile app, web dashboard, and online services
(collectively, "the Lummings"). The Lummings are made by **Flyxion Pty Ltd**
(Australian Company Number 12 345 678 901).

We have written this policy in plain English because the people reading it
include parents, teachers, clinicians, and children themselves.

---

## 1. The single most important fact

**The Lummings does not collect, transmit, or sell your child's data.**

Not "we anonymize it." Not "we strip the identifiers." Not "we don't store it
on our servers."

**We never receive it.**

The Lummings runs a language model locally on the device. All conversation
between your child and a Lummings character stays on the device. There is no
cloud component to our inference path. There is no telemetry SDK. There is no
analytics endpoint. There is no crash reporter. There is no advertising.

If a feature on a future device sends anything off the device — for example,
optional firmware updates, or an optional parent companion app — that data
flow is documented in §7 (Companion app) and §8 (Updates), is opt-in by
default, and can be turned off entirely in the parent controls.

---

## 2. What the device stores (and what it doesn't)

**The device stores:**
- A SQLite database of "facts" the Lummings has learned about your child
  (their name, age, things they like). This is stored under
  `/data/lummings/memory.sqlite` on the device, owned by the
  `lummings` user, with permissions `0600` (owner-only read/write).
- The recent conversation history (up to 100 turns) so the Lummings
  has short-term memory.
- A log of mood transitions for the current session.

**The device does NOT store:**
- Audio recordings of your child.
- Photographs or video.
- Location data.
- Contacts.
- Biometric data (the device does not collect voiceprints or faceprints).
- Device identifiers linked to a remote account.
- Any data that can be used to identify your child outside the device.

---

## 3. What we (Flyxion) collect

We collect almost nothing about our customers, because the device does almost
nothing that needs us.

**When you buy a Lummings** (via our DTC site, Kickstarter, or a retail
partner), the order is processed by Stripe (US/EU), Shopify (DTC), or the
retailer's own system. We receive:
- Your name and shipping address (to fulfil the order).
- Your email address (to send you the tracking number, the user manual,
  and the post-purchase survey).
- Your phone number if you voluntarily add it for delivery SMS.

We do NOT receive any information about how your child interacts with the
Lummings.

**When you visit dqikfox.github.io/lummings/** (our marketing site), the
hosting provider (GitHub Pages) collects standard HTTP request logs
(IP address, User-Agent, referrer). These logs are rotated every 24 hours
and are not linked to any customer record. GitHub's privacy policy
applies: https://docs.github.com/en/site-policy/privacy-policies/github-privacy-statement

**When you visit our DTC storefront** (when launched), the storefront
platform (Shopify Basic) collects standard e-commerce data. Shopify's
privacy policy applies: https://www.shopify.com/legal/privacy

---

## 4. Where the SQLite memory goes

The SQLite memory file on the device is local. It is not synced to any cloud
service by default. If you create a parent companion account and enable
"cross-device memory sync" (opt-in, off by default), the SQLite file is
encrypted with a key derived from your parent password and synced to a
storage bucket we operate.

This is the only data that ever leaves the device, and only with explicit
opt-in.

---

## 5. Children's privacy (COPPA, GDPR-K, AU Privacy Act)

The Lummings is designed for children ages 5–12. We comply with:

- **COPPA** (Children's Online Privacy Protection Act, US, under-13)
- **GDPR Article 8** (EU, under-16 by default, member states can lower to
  under-13)
- **UK Age-Appropriate Design Code** (AADC)
- **Australia Privacy Principles** (Privacy Act 1988)
- **EU KIDS Act** (proposed, expected to be adopted in 2027)
- **California SB-976 + SB-1004** (effective 2026)
- **COPPA 2.0** (S. 836, Senate-passed March 2026, pending House)

Because we collect **zero personal data** from the device, we satisfy the
substantive requirements of all of these laws without a parental consent
flow. Our COPPA / GDPR-K posture is documented in our annual compliance
review at `https://github.com/dqikfox/lummings/blob/main/docs/PRIVACY.md`.

---

## 6. Your rights

Regardless of where you live, you have these rights over your child's
data on the Lummings device:

| Right | How to exercise it |
|---|---|
| **Access** | Plug the device into a computer over USB-C; the SQLite file is readable as `/data/lummings/memory.sqlite`. |
| **Erasure ("right to be forgotten")** | Press and hold the **Memory Wipe** button on the device for 5 seconds. The SQLite file is deleted. |
| **Rectification** | Open the companion app (when available), edit the facts the Lummings has stored. |
| **Portability** | Plug into USB-C; copy the SQLite file. It is a standard SQLite 3 database. |
| **Restriction of processing** | Toggle **Quiet Hours** in the device settings. The Lummings will not save any new facts during Quiet Hours. |
| **Object to processing** | **Memory Wipe** does this completely. |
| **No automated decision-making** | The Lummings does not make decisions about your child that have legal or similarly significant effects. It is a conversational companion. |

---

## 7. Companion app (future)

If we ship a companion app (planned for late 2027), it will:
- Be **opt-in** (the device works fine without it).
- Run **locally first** (default), with cloud sync opt-in.
- Have its own privacy policy linked from inside the app.
- Support the rights in §6.

The companion app is **not required** to use the Lummings.

---

## 8. Firmware updates

Firmware updates are delivered over USB-C only by default. If we ship
optional OTA updates in the future:
- They are **opt-in** in the parent controls.
- They never modify the on-device memory SQLite file.
- They are signed by Flyxion's release key (the device verifies the
  signature before applying).
- They are documented in our public release notes at
  `https://github.com/dqikfox/lummings/releases`.

---

## 9. Third-party services we use

| Service | Purpose | Data shared |
|---|---|---|
| GitHub Pages | Marketing site hosting | HTTP request logs (IP, UA, referrer) |
| Stripe | Order payment (when launched) | Card details (encrypted end-to-end), billing address |
| Shopify Basic | DTC storefront | Customer email, order history |
| Local courier (AU Post, USPS, Royal Mail) | Delivery | Shipping address, tracking number |
| (No other service) | — | — |

We do not use Google Analytics, Meta Pixel, TikTok Pixel, Hotjar, Mixpanel,
Amplitude, Sentry, or any other analytics or crash-reporter on the device
or on the marketing site.

---

## 10. International transfers

If you are in the EU, UK, or AU and buy from our US storefront:
- We rely on Standard Contractual Clauses (SCCs) for any cross-border
  data transfer.
- The Shopify/Stripe agreements include GDPR-compliant Data Processing
  Addenda (DPAs).
- We do not transfer the device memory file at all (see §4).

---

## 11. Changes to this policy

We will announce changes to this policy via:
- The companion app (when available).
- Our Substack newsletter (`dqikst.substack.com`).
- The GitHub Releases page.

Material changes (anything that expands what data we collect) will be
announced at least 30 days before they take effect, and you will have the
option to **Memory Wipe** before the change takes effect.

---

## 12. Contact us

- Email: dqikst@gmail.com
- Postal: Flyxion Pty Ltd, PO Box 1234, Blackett NSW 2770, Australia
- Response time: 30 days for general enquiries, 72 hours for privacy/security
- Data Protection Officer: dqikst@gmail.com

---

## 13. The brand promise

The Lummings are built on a single promise:

> **The first AI toy that doesn't phone home.**

If a future feature ever compromises this promise, you will know about it
before it ships. We will not surprise our customers.

---

*Document version 2026-09-30.1*
*License: CC-BY-SA 4.0*
*Source: https://github.com/dqikfox/lummings/blob/main/docs/PRIVACY_POLICY.md*
