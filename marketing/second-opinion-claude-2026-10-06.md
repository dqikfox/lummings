# Claude Second Opinion — Marketing Plan Review (2026-10-06)

## Verdict
The plan builds infrastructure for traffic that doesn't exist. Four of the six agents are pointless until something sends visitors, and none of them creates visitors.

## 1. The 6-agent plan
| Agent | Verdict |
|---|---|
| SEO/AEO | Low value in month 1. New domains on gh-pages take 3–6 months to rank. Do a 1-hour fix of title, meta, OG tags and sitemap, not an agent project. |
| Outreach | The only one that matters, but "build a post queue of 30" is the wrong shape. Mass-posting gets you banned. Plan for 5–8 quality posts and manual replies. |
| Email capture | Worth doing. It's the only way to own an audience. Use a static-friendly endpoint (Stripe receipts, a Telegram bot, or a self-hosted form to a local DB). |
| Analytics | Plausible and Umami cloud violate your local-first rule. At <100 visits/day, use UTM links, the Stripe dashboard and GoatCounter (or nothing). |
| Affiliate | Skip. Affiliates need an audience to promote to, so a doc with no traffic recruits nobody. |
| Retargeting / FORGE30 | Skip. An exit-intent popup on ~20 visitors/day converts about 0 people. A discount also trains buyers to wait. |

Missing items, in priority order:
- Demo assets. A 30–60s screen recording or GIF per product, and 3–5 screenshots.
- A free hook. SHInEyVErSE and Ultra Studio need a free sample (10 free 3D assets, a free image pack) as the lead magnet.
- Positioning. Three unrelated products on one storefront reads as a hobby shop. Lead with one product and make the others secondary links.
- Audit the 39 orders. If they're mostly test or self orders, your baseline is ~0.
- Kids and privacy. Market to parents, not kids. Collecting emails touches COPPA.
- Refund and support page, plus a visible human-sounding "built by one dev in Sydney" story.

## 2. Crew AI vs delegate_task
Skip Crew AI — adds a framework with no gain. Crew is open source and can run on Ollama, so the cloud dependency argument was weak. The real reason: agent orchestration isn't the bottleneck; distribution is. Agents can draft posts but can't earn karma on Reddit. Use delegate_task for drafting, kanban for the 14-day checklist.

## 3. 14-day plan
Day 1: Audit orders. Pick ONE lead product. Fix shop title/meta/OG tags. Install GoatCounter. Add UTM links.
Day 2: Record demos. Make a free sample. Add email capture.
Day 3: Write build-in-public post. Create Reddit/X/Bluesky under brand. No links yet.
Day 4: First subreddit post (relevant to lead product). Reply to every comment.
Day 5: Submit to 3–5 directories (itch.io, Product Hunt upcoming, indie directories). Cross-post demo to X/Bluesky.
Day 6: Engage all day. Fix feedback.
Day 7: Review analytics. Double down on what worked. Post devlog.
Day 8–9: Second community, different angle. One Show HN on weekday morning US time.
Day 10: One long-form evergreen post.
Day 11–12: 10–15 personalised messages to small creators/newsletters offering free copy.
Day 13: Fix biggest conversion leak.
Day 14: Review. Count visits/signups/sales per channel. Keep one that worked, drop the rest.

## 4. Top 3 channels at $0
1. Reddit niche communities (r/StableDiffusion, r/comfyui, r/gamedev, r/Unity3D, parent/homeschool). Read self-promo rules. Value first, demo second, link third.
2. Show HN. Local-first angle fits HN well. One-shot high-variance bet.
3. Short-form video + itch.io. 30–60s demos on X/TikTok/Bluesky/Shorts. itch.io is real discovery traffic for Lummings and 3D assets.

## 5. Realistic first-month revenue
Median: $0–$150
Good: $200–$600
Ceiling: ~$1,000–$1,500 (<5% likelihood)

$299/$499 will sell 0 in month 1. Cold buyers need trust not yet built.
Real month-1 goal: learn which channel works + 100–300 email signups.
Revenue follows in months 2–4 if posting continues.


## Deltas vs my original plan
- Drop SEO agent (gh-pages too new to rank in month 1)
- Drop affiliate agent (no audience to recruit affiliates)
- Drop exit-intent popup + FORGE30 coupon (low traffic, trains buyers to wait)
- Replace cloud Plausible with self-hosted GoatCounter or UTMs only
- Outreach agent becomes '5–8 quality posts with manual replies' not '30-post spam'
- ADD demo assets (30-60s video per product)
- ADD free sample/lead magnet for SHInEyVErSE and Ultra Studio
- Lead with ONE product (Lummings is most unique)
