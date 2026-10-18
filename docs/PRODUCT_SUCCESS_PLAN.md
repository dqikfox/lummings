# Lummings: product validation and launch priorities

> Strategy update, 13 October 2026: the current priority is software and marketing. Hardware is deferred. See [Software launch strategy](../marketing/SOFTWARE_LAUNCH_STRATEGY.md) for the active launch sequence; hardware milestones below are future considerations.

Assessment: 13 October 2026. Current cast: Lumo, Luna, Sprout, Nori and Moki. Recommendations below are proposed product decisions, not validated demand or delivery promises.

## Product proposition

A magical companion that lights up your child's curiosity, remembers shared discoveries and helps them explore safely.

Children get a character and adventure. Parents get a useful, bounded learning experience and understandable controls. Heartlights, distinct voices and shared history should make the promise visible in everyday use.

## What the repository currently demonstrates

- Five structured characters, illustrated assets, Heartlight lore and runtime system prompts.
- Python text conversation through an external OpenAI-compatible endpoint, SQLite memory, mood transitions and a browser/terminal interface.
- Existing tests cover data/prompt behaviour and rendering. Passing them does not demonstrate generated-response safety, speech quality, child usability or hardware readiness.
- The companion preference evolution engine, physical Heartlight controls and complete product interaction remain unproven by this assessment.

## Problems to resolve before launch

1. Choose an initial age band and use case. Proposed starting hypothesis: ages 6–9, parent-configured, 5–10 minute curiosity adventures. Validate that with families rather than treating it as an established ideal.
2. Build one complete loop: child asks, character listens, Heartlight invites attention, character offers a short explanation or safe activity, child contributes, appropriate discovery is remembered, session closes comfortably.
3. Demonstrate speech on the actual proposed hardware: noisy-room recognition, interruption, response latency, voice distinctiveness, battery, temperature, recovery and offline behaviour. Record cold and warm performance. The current Python client sends requests to a separate inference endpoint; that alone is not proof of self-contained on-device inference.
4. Implement inspectable, editable, deletable memory, separate child profiles and preference updates that can supersede old information. Use explicit preferences; do not infer vulnerabilities or sensitive traits. Test memory isolation and correction across sessions.
5. Translate 'safety first' into product controls: adult setup, physical mute, visible microphone state, limits, reliable help-seeking, age-appropriate activities and no secret-keeping or exclusive attachment pressure. Have qualified specialists assess generated responses, developmental suitability, privacy and physical design.
6. Reconcile public claims with measured behaviour. The parent guide currently describes 10-minute charging, 12-hour conversation battery life, app-store availability and Bluetooth pairing. This review did not verify those claims. Label them as concepts until supported. Explain 'local-only' precisely and distinguish local storage from no collection.
7. Validate demand with a four-week parent-consented supervised pilot. Suggested first cohort: 10–15 families. Observe setup friction, independent voluntary return, remembered discoveries, parent-rated usefulness, incidents and genuine willingness to buy. Sample is directional, not proof of broad-market fit. Use minimal consented data and no covert child analytics.
8. Rebuild unit economics using supplier quotes and realistic volumes. Include assembled electronics, shell/plush, light, audio, batteries, packaging, QA, compliance, freight, duties/taxes, payment fees, fulfilment, returns, warranty, support and customer acquisition. The existing $149 sale / $95 allocation leaves $54, about 36% of revenue before remaining costs; calling this net margin is misleading.
9. Clear the brand before packaging or paid launch: Lummings, Lumo and all character names across intended markets and relevant goods/services. Names are not cleared by this review. Keep source artwork and production rights organised.

## Recommended first release

One hero device or character-led prototype led by Lumo, with the other four present in the world and ready for later rollout. Three modes: Wonder (questions), Quest (short guided activities), and Wind-down (stories and reflection). One obvious parent setup flow and one optional short daily invitation; no streak penalties. Make every character memorable through their Heartlight and response style rather than a long biography.

Retain the full five-character vision; sequence engineering and manufacturing so the first shipped experience is excellent. Validate through existing parent-owned hardware before committing to a production mould or inventory.

## Proposed eight-week sequence

- Weeks 1–2: define age/use-case hypothesis; audit claims; build and measure one complete interaction.
- Weeks 3–4: complete voice/light prototype, adult controls and correction/deletion of memory; conduct specialist reviews.
- Weeks 5–8: run four-week family pilot, obtain supplier/compliance quotes and test realistic price choices with parents.
- Decision: move toward manufacturing only with evidence of useful voluntary return, no unresolved critical safety issue, acceptable support burden and viable contribution economics. Set numeric acceptance criteria before the pilot; do not invent universal retention benchmarks.

## Official references checked

- Raspberry Pi Zero 2 W specifications: 512MB SDRAM and 1GHz quad-core processor. The proposed architecture needs measurement and likely revision, not assumed feasibility: https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/
- FTC COPPA FAQs, including child-directed online services and connected toys: https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions
- OAIC Children's Online Privacy Code work: https://www.oaic.gov.au/privacy/privacy-registers/privacy-codes/childrens-online-privacy-code
- ACCC product safety requirements must be mapped to the actual product and intended ages; button/coin battery standards apply if such batteries are used: https://www.productsafety.gov.au/business/search-mandatory-standards/button-and-coin-batteries-mandatory-standards/products-containing-button-and-coin-batteries-mandatory-safety-standard
- IP Australia trade mark searching: https://www.ipaustralia.gov.au/trade-marks/search-existing-trade-marks

A jurisdiction-specific assessment is needed once launch markets, architecture and age grading are fixed. This document does not establish compliance, trademark availability or proven learning outcomes.
