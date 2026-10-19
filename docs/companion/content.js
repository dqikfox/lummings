(function(root) {
  'use strict';

  // ── Character registry ──────────────────────────────────────────────────
  // Canonical IDs: lumo, lila, pip, nori, moki
  // Legacy alias map preserves old luna→lila, sprout→pip for any saved progress
  const characters = [
    {
      id: 'lumo', name: 'Lumo', light: 'Questlight', color: '#ed4054',
      portrait: '../portraits/lumo-happy.svg',
      description: 'Your ruby-red co-op captain. Big questions become little quests.',
      catchphrase: 'Player one. Crew first.',
      portraits: {
        default:   '../portraits/lumo-happy.svg',
        curious:   '../portraits/lumo-curious.svg',
        excited:   '../portraits/lumo-excited.svg',
        thoughtful:'../portraits/lumo-thoughtful.svg',
        calm:      '../portraits/lumo-calm.svg',
        warm:      '../portraits/lumo-warm.svg',
        playful:   '../portraits/lumo-playful.svg',
        amused:    '../portraits/lumo-amused.svg',
        cryptic:   '../portraits/lumo-cryptic.svg',
      }
    },
    {
      id: 'lila', name: 'Lila', light: 'Dreamlight', color: '#b59aff',
      portrait: '../portraits/lila-happy.svg',
      description: 'A gentle spooky poet who finds a story in the ordinary.',
      catchphrase: 'What if the story went sideways?',
      portraits: {
        default:   '../portraits/lila-happy.svg',
        curious:   '../portraits/lila-curious.svg',
        excited:   '../portraits/lila-excited.svg',
        thoughtful:'../portraits/lila-thoughtful.svg',
        calm:      '../portraits/lila-calm.svg',
        warm:      '../portraits/lila-warm.svg',
        playful:   '../portraits/lila-playful.svg',
        amused:    '../portraits/lila-amused.svg',
        cryptic:   '../portraits/lila-cryptic.svg',
      }
    },
    {
      id: 'pip', name: 'Pip', light: 'Traillight', color: '#57db91',
      portrait: '../portraits/pip-happy.svg',
      description: 'A curious scout with a new route for every puzzle.',
      catchphrase: 'New route. Same brave little feet!',
      portraits: {
        default:   '../portraits/pip-happy.svg',
        curious:   '../portraits/pip-curious.svg',
        excited:   '../portraits/pip-excited.svg',
        thoughtful:'../portraits/pip-thoughtful.svg',
        calm:      '../portraits/pip-calm.svg',
        warm:      '../portraits/pip-warm.svg',
        playful:   '../portraits/pip-playful.svg',
        amused:    '../portraits/pip-amused.svg',
        cryptic:   '../portraits/pip-cryptic.svg',
      }
    },
    {
      id: 'nori', name: 'Nori', light: 'Tidelight', color: '#9edbff',
      portrait: '../portraits/nori-happy.svg',
      description: 'Quiet wonder, thoughtful questions, and room to pause.',
      catchphrase: 'Small things have big stories.',
      portraits: {
        default:   '../portraits/nori-happy.svg',
        curious:   '../portraits/nori-curious.svg',
        excited:   '../portraits/nori-excited.svg',
        thoughtful:'../portraits/nori-thoughtful.svg',
        calm:      '../portraits/nori-calm.svg',
        warm:      '../portraits/nori-warm.svg',
        playful:   '../portraits/nori-playful.svg',
        amused:    '../portraits/nori-amused.svg',
        cryptic:   '../portraits/nori-cryptic.svg',
      }
    },
    {
      id: 'moki', name: 'Moki', light: 'Sparklight', color: '#ffa2cc',
      portrait: '../portraits/moki-happy.svg',
      description: 'Playful ideas and kind jokes. Mistakes welcome.',
      catchphrase: 'Oops. Plot twist!',
      portraits: {
        default:   '../portraits/moki-happy.svg',
        curious:   '../portraits/moki-curious.svg',
        excited:   '../portraits/moki-excited.svg',
        thoughtful:'../portraits/moki-thoughtful.svg',
        calm:      '../portraits/moki-calm.svg',
        warm:      '../portraits/moki-warm.svg',
        playful:   '../portraits/moki-playful.svg',
        amused:    '../portraits/moki-amused.svg',
        cryptic:   '../portraits/moki-cryptic.svg',
      }
    }
  ];

  // Legacy alias support — maps old saved IDs to current canonical IDs
  const aliases = { luna: 'lila', sprout: 'pip' };

  // ── Story builder helpers ───────────────────────────────────────────────
  function story(id, characterId, title, intro, choiceTitle, choiceText, options, explanation, reflectionText, closingText, portrait) {
    /* options: array of [label, narration_text] — each generates one branch node */
    const nodes = {
      arrival: {
        type: 'narration', title, text: intro, mood: 'curious', next: 'puzzle'
      },
      puzzle: {
        type: 'choice', title: choiceTitle, text: choiceText, mood: 'excited',
        hint: options[0] ? 'Take your time. There is no wrong way to start.' : undefined,
        choices: options.map((o, i) => ({ id: 'pick' + i, label: o[0], next: 'answer' + i })),
        skipNext: 'explain'
      },
      ...Object.fromEntries(options.map((o, i) => [
        'answer' + i,
        { type: 'narration', title: 'Let\'s explore that', text: o[1], mood: o[2] || 'warm', next: 'explain' }
      ])),
      explain: {
        type: 'narration', title: 'A little lightbulb moment', text: explanation, mood: 'excited', next: 'reflection'
      },
      reflection: {
        type: 'reflection', title: 'Take it into your world', text: reflectionText, mood: 'thoughtful',
        next: 'closing', skipNext: 'closing'
      },
      closing: {
        type: 'closing', title: 'A little discovery. A bigger world.', text: closingText, mood: 'warm'
      }
    };
    return { id, version: 1, characterId, title, start: 'arrival', nodes };
  }

  // ── All 15 Heartlight Adventures ───────────────────────────────────────

  // LUMO 1 — The Gate of Sixes
  const gateOfSixes = story(
    'gate-of-sixes', 'lumo', 'The Gate of Sixes',
    'Lumo swept his ruby-red quiff away from his eyes. His Questlight scattered gold stars over a locked gate. "Captain\'s log: extremely dramatic door. Four constellations. Six stars in each. I rushed my guess. Your turn to choose our strategy."',
    'Choose our first move',
    'Four constellations hang above the gate. Each holds six stars. How many stars altogether?',
    [
      ['Count in sixes', '"Six… twelve… eighteen… twenty-four." Lumo lit one constellation with each number, one careful step at a time. "Four groups. Four steps. We checked every star."', 'excited'],
      ['Draw the groups', 'Imagine four circles with six dots inside each. Count the dots if you want. "A picture can help us see what the numbers mean," Lumo said. No need to share your drawing.', 'thoughtful'],
      ['Split six into five and one', '"Four groups of five make twenty," Lumo said. "Each group has one more star. Four extra ones make four. Twenty plus four makes twenty-four!"', 'excited'],
    ],
    'All three paths land on twenty-four. Six, twelve, eighteen, twenty-four. Four drawn groups. Twenty fives and four ones. Questlight glows for checking the work together — not for pretending Lumo knew it first.',
    'Which strategy felt most like yours? Count, draw, or split? Tell someone, point, or keep it to yourself. All answers are welcome.',
    '"A discovery, another question, or a quiet goodbye?" Lumo asks. Every choice is fine. If schoolwork still feels confusing, a trusted adult can try a different explanation with you.',
  );

  // LUMO 2 — The Save-Point Bridge
  const savePointBridge = story(
    'save-point', 'lumo', 'The Save-Point Bridge',
    'The star bridge is longer than it looked. Lumo taps his Questlight and a gentle glow marks the planks beneath his feet. "Save point. We can stop, and the quest will wait. What should the crew do?"',
    'What will the crew do?',
    'The bridge goes on further than expected. Every choice is a good plan.',
    [
      ['Rest at the lantern', 'Lumo marks the plank with Questlight. Nothing unspools while you sit. The crew can breathe, look around, and decide what comes next when they are ready.', 'calm'],
      ['Three more steps, then rest', '"A short plan, then the same lantern," Lumo says. The bridge does not punish a pause. Three steps is still a full plan.', 'playful'],
      ['Stop right now', 'Lumo nods. "Player one. Crew first. That includes you being finished." The Questlight holds the spot until you are ready, for as long as you need.', 'warm'],
    ],
    'A save point is a promise that the place will still be there. Leaving a quest is not losing it. Lumo used to think heroes never sat down. The bridge only opens for a crew that knows how to choose to stop.',
    'What would your own save-point signal look like? A bookmark, a word, a sticker? You do not have to answer — the idea is yours.',
    '"The quest is patient," Lumo says. "Come back when the Heartlight feels ready." The bridge will be here. So will the crew.',
  );

  // LUMO 3 — The Rumour Rune
  const rumourRune = story(
    'rumour-rune', 'lumo', 'The Rumour Rune',
    'A whisper says the portal opens only for the fastest player. Lumo pauses, Questlight flickering. "That sounds huge. Let\'s read the carving before we believe it." What should the crew do?',
    'How do we check the rumour?',
    'The whisper spread quickly. Now the crew is at the rune. What is the right move?',
    [
      ['Read the rune together', '"The carving is the source. The whisper is somebody\'s version of it." Lumo traces the letters slowly with his Questlight. The real answer might be different.', 'thoughtful'],
      ['Ask what a friend actually saw', 'Nori remembers a different word. Two memories are a reason to look again. Checking with someone who was there is a good move.', 'curious'],
      ['Try one slow step and watch', 'A careful test — one step at a time and see what happens. If the portal stays shut, the rumour might still be wrong.', 'calm'],
    ],
    'The rune says "Enter together." The rumour dropped the last word and added "fastest." Checking the carving changes the plan: the crew walks in side by side. An exciting story is not the same as the instruction.',
    'What would you want to check before believing a big rumour? You do not have to write anything. The idea can stay yours.',
    '"Crew first," Lumo says, stepping through the portal alongside everyone. The door only ever opened for all of them.',
  );

  // PIP 1 — The Upside-Down Map
  const upsideDownMap = story(
    'upside-down-map', 'pip', 'The Upside-Down Map',
    'Pip holds the leaf-map up proudly. The arrows point confidently to the left. Then Pip tilts their head sideways. "I announced the plan. Then I noticed the map was upside down." Traillight blinks kindly. "Second try?"',
    'What should the crew do now?',
    'The leaf-map was the wrong way up. There are a few good moves from here.',
    [
      ['Turn it and look again', 'Pip flips the map carefully. The leaf arrows now point toward the moss gate. "The second look is always part of the plan," Pip says, already moving.', 'excited'],
      ['Test the first path slowly', '"One careful step. If the moss thins out, we come back," Pip says. A test is still a plan. Noticing what happens is the whole point.', 'curious'],
      ['Ask what Nori notices', 'A second pair of eyes. Sprout does not have to spot everything alone. Nori squints at a small trail mark and points quietly in a different direction.', 'warm'],
    ],
    'The trail marks were leaves pointing toward the moss gate, not away from it. Pip\'s medal is for the second look. Traillight brightens when a plan gets repaired, not when it was perfect the first time.',
    'Tell about a second try that helped — or invent one. No need to write it down. Saying it to yourself counts.',
    '"Medal for the second look," Pip says, pinning an imaginary badge. "You earned it for trying again." Traillight glows emerald and then softly fades.',
  );

  // PIP 2 — Two Paths, One Puddle
  const twoPaths = story(
    'two-paths', 'pip', 'Two Paths, One Puddle',
    'A puddle sits right across the path. It is wide enough to matter. Pip examines both sides and grins. "New route. Same brave little feet. Which one shall we try?" Traillight traces two possible lines in the air.',
    'How will the crew cross?',
    'Every choice here is a good one. There is no punished path.',
    [
      ['Stepping stones', '"Look at each stone before a boot goes down," Pip says. "Slippery is information." The crew moves carefully, one step at a time, checking as they go.', 'curious'],
      ['A leaf boat', 'Small, slightly silly, and only for a very shallow puddle. Pip names it the S.S. Second-Attempt. "She sails on the first try. Mostly." Traillight giggles.', 'playful'],
      ['The drier pebbles', 'Nori points at a line of pebbles easy to miss near the edge. "You may change your mind," Nori says. "Noticing is allowed to happen late." Pip switches course cheerfully.', 'warm'],
    ],
    'Every choice was a kind plan. The drier pebbles were there the whole time. Traillight marks the way you pick, and it does not sulk if you switch. Noticing is allowed to happen late.',
    'On paper or in your head: draw a puddle and two ways around it. Circle the way that feels safest. What would you watch for?',
    '"Both paths led here," Pip says on the other side. "That means both paths worked." Traillight traces a small victory arc in the air.',
  );

  // PIP 3 — The Medal for Slow
  const medalForSlow = story(
    'medal-for-slow', 'pip', 'The Medal for Slow',
    'The moss gate asks which footprint is the thoughtful one. Pip reads the riddle twice and looks at the prints in the soft earth. "I almost sprinted. But this riddle wants the careful second attempt." Traillight waits.',
    'Which footprint is the thoughtful one?',
    'Three prints are pressed into the moss. Each one tells a different story.',
    [
      ['The fastest print', 'Speed is a guess here. The gate does not open for it — and that is all right. Not every door asks for the quickest move. "Interesting," Pip says, not embarrassed.', 'thoughtful'],
      ['The one that stopped to look', '"A pause left a deeper print beside a tiny trail mark," Pip says. The gate creaks open. Traillight glows emerald. The careful moment was the key.', 'excited'],
      ['The one that turned around', '"Going back, then trying again, is still a footprint," Pip says. The gate swings wide. Traillight sparkles. Returning counts as brave.', 'warm'],
    ],
    'The gate opened for the print that paused or turned around. Pip pins the medal on that second attempt. Fast was not wrong for every day. Today the riddle was about noticing.',
    'Try a tiny task twice: once in a rush, once slower. What did the slower try notice? You can tell someone, or keep the answer.',
    '"Traillight makes the medal glow emerald," Pip says, "then fades so nobody has to wear it forever." The mossy gate stays open for the whole crew.',
  );

  // LILA 1 — Weather Inside
  const weatherInside = story(
    'weather-inside', 'lila', 'Weather Inside',
    'A friend\'s feeling is stormy, and they do not want to say why. Lila finds them sitting with a cloudy look and a quiet Dreamlight. "You don\'t have to explain the sky. I can sit in it with you." What can Lila offer?',
    'What can Lila offer?',
    'There is no wrong answer here. Every option is a kind one.',
    [
      ['Quiet company', 'Sit nearby. No questions. Dreamlight stays low and steady, a small warm glow. Not helping is sometimes the whole help.', 'calm'],
      ['A story they can change', 'Lila offers a tale with a loose ending. "You may change the ending. Or close the book. Or leave it open." The story belongs to whoever holds it.', 'warm'],
      ['A drawing, no words', '"Weather on paper," Lila says, sliding over a pencil. "The reason can stay private." The pencil is an invitation, not a question.', 'thoughtful'],
    ],
    'None of these asks "why." Lila does not demand an explanation for a feeling. If words come later, there is room. If they do not, company was the whole help. Dreamlight does not dim when a feeling stays unnamed.',
    'If you want, draw today\'s feeling as weather. You may keep the reason to yourself. Blank paper is a finished drawing too.',
    '"The sky inside can stay yours," Lila says, closing the sketchbook. "I\'ll sit here." Dreamlight glows softly and does not ask for anything.',
  );

  // LILA 2 — The Library of Almosts
  const libraryOfAlmosts = story(
    'library-of-almosts', 'lila', 'The Library of Almosts',
    'A shelf in Lila\'s dream-library holds one sentence: "And then the moon…" The rest of the page is empty. Dreamlight shivers with possibility. "An unfinished page is a door left kindly open. How might it go?"',
    'How might the moon\'s sentence end?',
    'All three endings belong here. Pick the one that feels right, or invent your own.',
    [
      ['…lent us a lantern', '"A borrowed light. Very polite of the moon." Lila writes it carefully. Dreamlight paints a small crescent beside the words.', 'playful'],
      ['…waited while we thought', '"No rush in the margin," Lila says. "The moon can hover." Dreamlight agrees, drifting slowly overhead.', 'calm'],
      ['…asked nothing and glowed', '"Some lights do not need a speech," Lila says softly. Dreamlight dims to a comfortable glow, and that is the whole ending.', 'warm'],
    ],
    'All three endings are kind. Lila used to hide unfinished stories because they felt not-wonderful-enough. Dreamlight shows that a beginning can be the gift. Stopping is part of writing, not a hole in it.',
    'Write one sentence and stop. You do not have to read it to anyone. You do not have to finish it tomorrow. Blank is also fine.',
    '"An almost is a real thing," Lila says, placing the book back on the shelf. "The shelf is for keeping them." Dreamlight holds the door open.',
  );

  // LILA 3 — The Scarf Offer
  const scarfOffer = story(
    'scarf-offer', 'lila', 'The Scarf Offer',
    'Lila\'s comet scarf drifts nearby, its ends curling softly. "Words are an invitation, not a test," Lila says. "If you want, the scarf can hold a feeling-word. Or it can rest." There is no hurry.',
    'What would you like?',
    'Any answer is fine. Not-today is a complete answer.',
    [
      ['I\'ll pick a word', '"Any word," Lila says. "I\'m not going to grade it or ask you to explain it." Dreamlight traces the word softly into the air, then lets it drift away.', 'warm'],
      ['Not today', '"A complete answer," Lila says immediately, letting the scarf rest. Dreamlight does not dim. The offer was the whole kindness.', 'calm'],
      ['A colour instead', '"Violet, moss, gold, moon-blue, rose." Lila offers them like swatches. "A colour can be the whole reply." Dreamlight matches it, glowing gently.', 'thoughtful'],
    ],
    '"Not today" does not need a follow-up question. Lila does not chase a feeling to make the story neat. Dreamlight stays soft either way. An invitation can be declined and still have been kind.',
    'If you like, match three feelings to three colours. Skip any you\'d rather not name. The scarf is patient.',
    '"The scarf stays folded," Lila says. "It will offer again another time, if you want." Dreamlight glows once, softly, and rests.',
  );

  // NORI 1 — Lowbeam's Offer
  const lowbeamOffer = story(
    'lowbeam-offer', 'nori', 'Lowbeam\'s Offer',
    'Nori holds up a small lantern named Lowbeam. "We could notice three quiet things," Nori says. "And it might not help. That\'s all right." Tidelight stays gentle, waiting without urgency.',
    'What would you like to do?',
    'Any of these is the right answer. Nori will follow your lead.',
    [
      ['Yes — three quiet things', '"One you can see. One you can hear. One you can touch," Nori says. "Stop if you want." Lowbeam glows steadily for each one, not rushing.', 'calm'],
      ['No — it doesn\'t feel helpful', 'Nori accepts that immediately. Tidelight does not droop. "The offer is over," Nori says. "We can sit instead." No follow-up question.', 'warm'],
      ['Something else', '"A sip of water. A stretch. Or just sitting," Nori suggests. "I\'ll follow your lead." Tidelight dims gently, ready to go wherever the choice goes.', 'thoughtful'],
    ],
    'A calming activity is an offer, not a rule. Nori used to think Lowbeam should always soothe. Some nights it does not, and the friendship still holds. You can say no without owing a better idea.',
    'Only if you want: name one thing you see, one you hear, one you can touch. If that feels wrong, stop. Stopping is the activity working.',
    '"Lowbeam goes back in the pocket," Nori says quietly. "It will offer again if you want it." The tidepool stays still and quiet.',
  );

  // NORI 2 — Three Small Things
  const threeSmallThings = story(
    'three-small-things', 'nori', 'Three Small Things',
    'The tidepool glitters with tiny details. Nori crouches down to look at one pebble. "That pebble has a stripe like a tiny river." Tidelight flickers with gentle curiosity. "What else do you notice?"',
    'How do we look?',
    'One small wonder is the whole adventure. There is no need to catalogue everything.',
    [
      ['A stripe or a mark', 'Pick one pattern on one thing. Nori waits, Tidelight soft. "You do not have to catalogue the whole pool," Nori says. One detail is enough to wonder about.', 'curious'],
      ['The quietest sound', '"A drip, a sleeve, a far bird," Nori says. "Name one, then rest." Tidelight matches the colour of whatever small sound arrives. One is enough.', 'calm'],
      ['One question, not ten', '"Wonder about a single thing," Nori says. "Let the other questions wait." Tidelight glows for the one question and stays quiet about the rest.', 'thoughtful'],
    ],
    'Nori once rehearsed a question so carefully that a beetle walked away. Tidelight prefers a small wonder, spoken in time. Three details, then one question, is a complete adventure.',
    'With a grown-up if you leave the room: notice three tiny details on one cup, leaf, or stone. Wonder about only one of them.',
    '"Three small things," Nori says, naming them quietly. Tidelight reflects each one and then dims, the pool still and complete.',
  );

  // NORI 3 — The Trusted Door
  const trustedDoor = story(
    'trusted-door', 'nori', 'The Trusted Door',
    'Lowbeam cannot answer this one. The lantern glows gently but stays quiet. "Some questions are too big for a lantern," Nori says. "We can practise asking a person. But you choose who." Tidelight waits, patient.',
    'Who could help with the big question?',
    'The story does not pick the person for you. You know who feels safe.',
    [
      ['A grown-up at home', '"Nori helps with the sentence, not with the secret," Nori says. A sentence you can borrow: "Can I tell you something that\'s been sitting with me?" You choose when to use it.', 'warm'],
      ['A teacher or another trusted adult', '"You choose the person," Nori says. "I won\'t pick them for you." Tidelight glows gently for whoever feels safest.', 'thoughtful'],
      ['I\'ll think, and not write a name', '"Deciding privately still counts," Nori says. "The page does not need the name." Tidelight accepts this completely.', 'calm'],
    ],
    'A sentence you can borrow: "Can I tell you something that\'s been sitting with me?" Nori does not ask what the something is. Heartlights are not people, and they are not a place for secrets. Asking someone you trust is the step that matters.',
    'Practise the sentence with a toy if you want. Later, if it feels right, say it to a person you trust. You choose whether that happens.',
    '"Lowbeam cannot open this door," Nori says. "A person can." Tidelight stays steady, a small reminder that asking is brave.',
  );

  // MOKI 1 — After the Drumroll
  const afterTheDrumroll = story(
    'after-the-drumroll', 'moki', 'After the Drumroll',
    'Moki planned an impressive entrance. There was an imaginary drumroll, confetti, and a big jump. Then Moki tripped on the drumroll and knocked something over. Sparklight flickered sheepishly. "I\'m sorry. I\'ll give you a little space."',
    'What would feel okay?',
    'There is room for whatever the answer is. Moki is patient.',
    [
      ['A bit of space', 'Moki steps back and keeps the confetti in a pocket. The joke waits. Sparklight stays in the room without crowding. Space is a real choice, not a trick to hurry forgiveness.', 'calm'],
      ['A small laugh later', '"Not now. Later, if you want it," Moki says. "I\'m not scheduling the laugh." Sparklight dims politely, ready whenever — or never, if that\'s what fits.', 'warm'],
      ['I accept — let\'s fix the mess', 'Pick up what fell. Fixing is allowed to be quiet. Moki helps without filling the silence with jokes. Sparklight glows steadily, not bright, just present.', 'thoughtful'],
    ],
    'The apology comes before the joke. Space is a real choice, not a trick to hurry forgiveness. Sparklight stays in the room without crowding. Moki used to fill every silence. Today the silence was part of being kind.',
    'Practise a short sorry you might actually use: what happened, that you are sorry, and one way to help. Then wait. Don\'t add a joke unless the other person does.',
    '"The confetti stays in the pocket," Moki says. Sparklight glows once, softly. Then it waits, in case it is wanted.',
  );

  // MOKI 2 — Captain Teaspoon
  const captainTeaspoon = story(
    'captain-teaspoon', 'moki', 'Captain Teaspoon',
    'Moki stands at attention. "CAPTAIN TEASPOON REPORTS: triangles have four sides!" Sparklight spins with delight. Then Moki grins. "Shall we check the captain\'s maths? This could be interesting."',
    'How do we check the claim?',
    'Every method leads to an answer. The checking is the fun part.',
    [
      ['Count the sides', '"Draw one and touch each side as you count," Moki says. "The drawing is the evidence." Sparklight watches, absolutely delighted to see what happens.', 'playful'],
      ['Ask what the word means', '"Tri means three," Moki says, eyes wide. "The word itself is a clue. Then the drawing checks it." Captain Teaspoon has been wrong before.', 'curious'],
      ['Compare with four sides', '"Draw a square too," Moki says. "Set them side by side." Sparklight glows for both shapes. Different shapes, different counts — very clear evidence.', 'amused'],
    ],
    'A triangle has three sides. Captain Teaspoon mixed it up with a square, which has four. The wrong guess was not embarrassing once it was checked. Oops. Plot twist. Sparklight likes the moment the idea gets corrected, kindly.',
    'Draw a triangle and a square. Count the sides out loud. Then invent one wrong-on-purpose fact and correct it together.',
    '"Captain Teaspoon is relieved," Moki says. "Wrong guesses are excellent once you check them." Sparklight bows to the corrected triangle.',
  );

  // MOKI 3 — The Moon Behind the Cloud
  const moonBehindCloud = story(
    'moon-behind-cloud', 'moki', 'The Moon Behind the Cloud',
    'Moki rushes in with dramatic news. "THE MOON IS GONE. I looked up. Nothing. Crisis." Sparklight spins anxiously. Then Nori squints at the sky. There is a very large cloud. What should the crew do?',
    'What should we do before we agree?',
    'A careful look is not a slow look. It is a useful one.',
    [
      ['Wait and watch the cloud', '"Clouds move," Nori says. "A minute of looking is a fair test." The cloud drifts slowly. Moki watches, suddenly less certain.', 'curious'],
      ['Ask what clouds do', '"Nori has watched this before," Moki says. "A friend can be a source, then you still look." Nori explains cloud movement, carefully. Then everyone looks.', 'thoughtful'],
      ['Check the other clues', '"Stars are still there," someone says. "The sky did not pack up. Something may be in the way." Moki counts three clues that suggest the moon is still around somewhere.', 'calm'],
    ],
    'The moon was behind a cloud. Moki\'s announcement was confident and unfinished. Evidence was the sky, watched for a little while. A missing moon did not need a rescue — it needed a second look.',
    'Next time something seems to have vanished, list two other explanations before deciding it is gone. A sock, a pencil, a moon.',
    'The cloud moved. The moon emerged. "The announcement was early," Moki says happily. "But the crisis was very well delivered." Sparklight agrees.',
  );

  // ── Legacy story (the original Constellation Gate, preserved for any saved state) ──
  const constellationGate = {
    id: 'constellation-gate', version: 1, characterId: 'lumo',
    title: 'The Constellation Gate', start: 'arrival',
    nodes: {
      arrival:    { type: 'narration',   title: 'A very dramatic door',           text: 'Lumo swept his ruby-red quiff away from his eyes. His Questlight scattered gold stars over a locked gate. "Captain\'s log: extremely dramatic door. Suspiciously ordinary maths."', mood: 'curious', next: 'puzzle' },
      puzzle:     { type: 'choice',      title: 'Choose our first move',           text: 'Four constellations hung above the gate. Each held six stars. "Twenty?" Lumo guessed. Nothing happened. "I rushed. Your turn to choose our strategy."', mood: 'excited', hint: 'Imagine four separate groups. You can draw them, count aloud, or just listen.', choices: [{ id: 'count', label: 'Count in sixes', next: 'count' }, { id: 'split', label: 'Split six into five and one', next: 'split' }, { id: 'draw', label: 'Imagine or draw four groups', next: 'draw' }], skipNext: 'explain' },
      count:      { type: 'narration',   title: 'One group at a time',             text: '"Six… twelve… eighteen… twenty-four." Lumo lit one constellation with each number. "Four groups. Four steps. We checked every star."', mood: 'excited', next: 'explain' },
      split:      { type: 'narration',   title: 'Two smaller quests',              text: '"Four groups of five make twenty," Lumo said. "Each group has one more star. Four extra ones make four. Twenty plus four makes twenty-four!"', mood: 'excited', next: 'explain' },
      draw:       { type: 'narration',   title: 'Make the stars visible',          text: 'Imagine or draw four circles, with six dots in each. Count the dots if you want. "A picture can help us see what the numbers mean," Lumo said. There is no need to share your drawing.', mood: 'thoughtful', next: 'explain' },
      explain:    { type: 'narration',   title: 'Different routes, same stars',    text: 'There are 24 stars: four equal groups of six. The gate opened onto a room of floating books. "You checked my guess," Lumo said. "That\'s co-op leadership."', mood: 'warm', next: 'practice' },
      practice:   { type: 'choice',      title: 'An optional little quest',        text: 'On a desk were three groups of four crystal keys. How many keys altogether? Choose an answer, use a drawing, or skip to the explanation.', mood: 'curious', hint: 'Count four, then add four, then add four again.', choices: [{ id: 'seven', label: '7 keys', next: 'seven' }, { id: 'twelve', label: '12 keys', next: 'twelve' }, { id: 'sixteen', label: '16 keys', next: 'sixteen' }], skipNext: 'keys' },
      seven:      { type: 'narration',   title: 'Let\'s check the groups',         text: 'Seven is three plus four. Here, three tells us how many groups there are, and each group has four keys. Try counting: four, eight, twelve. Noticing the difference is useful.', mood: 'thoughtful', next: 'reflection' },
      twelve:     { type: 'narration',   title: 'A strategy that fits',            text: 'Yes: four, eight, twelve. Three groups of four make 12. "You used the groups," Lumo said. "Want to show me your route with words or a picture? You can also keep it to yourself."', mood: 'excited', next: 'reflection' },
      sixteen:    { type: 'narration',   title: 'One group too many',              text: 'Sixteen would be four groups of four. We have three groups: four, eight, twelve. "Excellent moment to count the groups again," Lumo said. "Changing our answer is part of learning."', mood: 'warm', next: 'reflection' },
      keys:       { type: 'narration',   title: 'The key explanation',             text: 'Three groups of four make 12: four plus four plus four. You can draw the groups or come back to this idea another time.', mood: 'thoughtful', next: 'reflection' },
      reflection: { type: 'reflection',  title: 'What shall we carry?',            text: 'Which helped you: counting, splitting, drawing, or listening? Tell someone, point, or imagine your answer. There is no correct preference, and you don\'t have to answer.', mood: 'thoughtful', next: 'closing', skipNext: 'closing' },
      closing:    { type: 'closing',     title: 'Quest complete. Crew first.',     text: '"A discovery, another question, or a quiet goodbye?" Lumo asked. Every choice was welcome. If schoolwork still feels confusing, ask a teacher or trusted adult to try another explanation with you.', mood: 'warm' }
    }
  };

  // ── Story catalogue ─────────────────────────────────────────────────────
  // Ordered: Lumo × 3 → Pip × 3 → Lila × 3 → Nori × 3 → Moki × 3
  const stories = [
    gateOfSixes, savePointBridge, rumourRune,
    upsideDownMap, twoPaths, medalForSlow,
    weatherInside, libraryOfAlmosts, scarfOffer,
    lowbeamOffer, threeSmallThings, trustedDoor,
    afterTheDrumroll, captainTeaspoon, moonBehindCloud,
    // Legacy — preserved so any in-progress constellation-gate session still works
    constellationGate,
  ];

  // Default story for the first-run sample experience (constellation-gate kept for test compatibility)
  const story0 = constellationGate;

  const api = { characters, aliases, story: story0, stories };
  if (typeof module !== 'undefined') module.exports = api;
  else root.LummingContent = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
