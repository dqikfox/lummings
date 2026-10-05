# Telegram Promotion Plan

The Telegram bot @Ultron420bot is our most direct channel. Every DM = a real sales lead.

## Immediate actions (today, no account setup needed)

### 1. Share-linkable URLs

For every channel we use, create a `t.me/Ultron420bot?start=<intent>` link that:
- Sets the bot's start command to `/start <intent>`
- Lets us track which channel drove the contact
- Pre-fills context so the bot can show relevant products

Generated URLs:

- `https://t.me/Ultron420bot?start=lummings` → bot shows Lummings free options
- `https://t.me/Ultron420bot?start=shineyverse` → bot shows SHInEyVErSE plans
- `https://t.me/Ultron420bot?start=ultrastudio` → bot shows Ultra Studio packs
- `https://t.me/Ultron420bot?start=leadgift` → bot sends a free lead magnet
- `https://t.me/Ultron420bot?start=demo` → bot shows the 30-second demo

### 2. Add to all public surfaces

- gh-pages landing pages: floating "DM us" button
- Shop page: secondary CTA "Order via Telegram"
- Email signature: "Get the build log: t.me/Ultron420bot?start=buildlog"
- Reddit/Show HN posts: include as contact channel

### 3. Update bot commands for discoverability

Tell Telegram's @BotFather to set:
- Description: "Five local-AI characters for kids. No cloud, no subscription, no surveillance. Free to try. Optional $29-$499 paid packs."
- About: "Built solo in Sydney. 1Password input for store rooms."
- Commands list:
  - `/start` - Welcome
  - `/skus` - List products with prices
  - `/buy <sku>` - Order a product (Stripe checkout link)
  - `/demo` - 30-second interactive demo
  - `/lead` - Free starter packs (email capture)
  - `/support` - Refund/support
  - `/status` - Your orders

### 4. Find existing Telegram groups to share in

Find 5-10 parenting, AI, indie-dev, or kids-tech Telegram groups. Each one is a sales channel.

Search strategy:
- Telegram search: "kids AI", "parenting Australia", "indie hacker", "AI studio"
- Look for groups with 100-5000 members (avoid huge ones, too noisy)
- Read rules first, look for #intro or #promo channels

For each group:
- Wait 3-5 days after joining (don't spam immediately)
- Be helpful in regular chat
- Share the bot ONCE in an intro or #promo thread

### 5. Share on existing channels you control

- Twitter/X / Bluesky (need account)
- LinkedIn (need login)
- Discord servers you're already in
- Email signature
- Existing Telegram groups you moderate

### 6. Pay for Telegram channel ads (only if revenue supports it)

Telegram has a "Promoted" feature. Budget: $5-20 per channel per month.

NOT recommended for first month — focus on organic first.

## Target outcome

- Week 1: 0-2 real customers via bot
- Week 2: 5-10 customers if Reddit + bot combined
- Week 4: 20-50 customers, $500-2000 revenue

The bot is the highest-leverage distribution channel we have because:
- It's interactive (not just a link)
- It's bidirectional (we can answer questions, upsell)
- It tracks (we can see every conversation)
- It's cheap (zero cost)

## Existing bot commands

```
$ /start        Welcome + product menu
$ /products     List all 3 products
$ /skus         Same as /products
$ /buy <sku>    Order a product
$ /order        Complete current order
$ /status       Check order
$ /help         Usage
```

## Lead magnet SKUs (newly added)

```
$ /buy lm-lummings-5pk    Free 5-portrait pack
$ /buy lm-shiney-sampler  Free SHInEyVErSE image sampler
$ /buy lm-free-samples    Free 10-asset CC0 starter
```

When the bot sees these SKUs, it should send the direct download URL instead of payment link.