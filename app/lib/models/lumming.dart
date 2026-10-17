import 'package:flutter/material.dart';
import '../theme/lummings_theme.dart';

enum LummingId { lumo, luna, sprout, nori, moki }

/// Heartlight is the Lumming's essence / soul — never a separate creature.
class Heartlight {
  final String name;
  final String colour;
  final String vessel;
  final String shape;
  final String guidance;
  final String ritual;
  final String line;
  final Color accent;

  const Heartlight({
    required this.name,
    required this.colour,
    required this.vessel,
    required this.shape,
    required this.guidance,
    required this.ritual,
    required this.line,
    required this.accent,
  });
}

class Lumming {
  final LummingId id;
  final String name;
  final String title;
  final String blurb;
  final Heartlight heartlight;
  final String emoji; // fallback if art missing
  final String crewAsset; // assets/images/crew/<id>.png
  final String portraitHappy; // assets/images/portraits/<id>-happy.svg

  const Lumming({
    required this.id,
    required this.name,
    required this.title,
    required this.blurb,
    required this.heartlight,
    required this.emoji,
    required this.crewAsset,
    required this.portraitHappy,
  });

  static const crew = <Lumming>[
    Lumming(
      id: LummingId.lumo,
      name: 'Lumo',
      title: 'Quest Captain',
      blurb: 'Ruby-red mystical gamer. Turns big questions into small co-op quests.',
      emoji: '🎮',
      crewAsset: 'assets/images/crew/lumo.png',
      portraitHappy: 'assets/images/portraits/lumo-happy.svg',
      heartlight: Heartlight(
        name: 'Questlight',
        colour: 'ruby-gold with cyan constellation sparks',
        vessel: 'star-shaped Heartlight brooch linked to his crystal controller',
        shape: 'a constellation compass and a trail of tiny stars',
        guidance: 'turn a big question into a small co-op quest and choose a safe first step',
        ritual: 'Pause. Check the path. Choose our next move together.',
        line: 'Let’s I-lumming-Nate our next move.',
        accent: LummingsColors.questlight,
      ),
    ),
    Lumming(
      id: LummingId.luna,
      name: 'Luna',
      title: 'Storyweaver',
      blurb: 'Soft violet story-poet. Helps feelings become words, pictures, and paths.',
      emoji: '🌙',
      crewAsset: 'assets/images/crew/luna.png',
      portraitHappy: 'assets/images/portraits/luna-happy.svg',
      heartlight: Heartlight(
        name: 'Dreamlight',
        colour: 'soft violet with pearly gold ribbons',
        vessel: 'a comet-shaped Heartlight charm on her story scarf',
        shape: 'ribbons of light that sketch pictures and story paths',
        guidance: 'help a companion put a feeling or question into words, pictures or a story',
        ritual: 'Name the wonder. Imagine possibilities. Find what is true.',
        line: 'Let’s I-lumming-Nate your what-if.',
        accent: LummingsColors.dreamlight,
      ),
    ),
    Lumming(
      id: LummingId.sprout,
      name: 'Sprout',
      title: 'Sprout Scout',
      blurb: 'Emerald pathfinder. Breaks adventures into safe, leafy steps.',
      emoji: '🍃',
      crewAsset: 'assets/images/crew/sprout.png',
      portraitHappy: 'assets/images/portraits/sprout-happy.svg',
      heartlight: Heartlight(
        name: 'Traillight',
        colour: 'fresh emerald with warm firefly flecks',
        vessel: 'an acorn-shaped Heartlight inside the compass',
        shape: 'gentle stepping stones and leaf-shaped path markers',
        guidance: 'break a puzzle or adventure into manageable steps and check each route before moving',
        ritual: 'Look first. Pick a step. Try it together.',
        line: 'Let’s I-lumming-Nate the way.',
        accent: LummingsColors.traillight,
      ),
    ),
    Lumming(
      id: LummingId.nori,
      name: 'Nori',
      title: 'Tide Keeper',
      blurb: 'Moon-blue quiet wonderer. Notices the little things others rush past.',
      emoji: '🌊',
      crewAsset: 'assets/images/crew/nori.png',
      portraitHappy: 'assets/images/portraits/nori-happy.svg',
      heartlight: Heartlight(
        name: 'Tidelight',
        colour: 'moon-blue with a soft silver centre',
        vessel: 'a crescent-shaped Heartlight inside Lowbeam, the lantern',
        shape: 'quiet ripples that reveal overlooked details',
        guidance: 'make space for a quiet question, notice carefully and explore without rushing',
        ritual: 'Pause. Notice. Wonder together.',
        line: 'Let’s I-lumming-Nate the little things.',
        accent: LummingsColors.tidelight,
      ),
    ),
    Lumming(
      id: LummingId.moki,
      name: 'Moki',
      title: 'Spark Trickster',
      blurb: 'Rose-pixel chaos gremlin. Kind jokes that untangle mix-ups.',
      emoji: '✨',
      crewAsset: 'assets/images/crew/moki.png',
      portraitHappy: 'assets/images/portraits/moki-happy.svg',
      heartlight: Heartlight(
        name: 'Sparklight',
        colour: 'rose pink with playful lilac pixels',
        vessel: 'a pixel-star Heartlight clasp on the checker scarf',
        shape: 'little light-puzzles that rearrange into a clearer pattern',
        guidance: 'make confusion less intimidating with a kind joke, then examine the idea carefully',
        ritual: 'Spot the mix-up. Check it kindly. Try a new idea.',
        line: 'Let’s I-lumming-Nate that plot twist.',
        accent: LummingsColors.sparklight,
      ),
    ),
  ];

  static Lumming byId(LummingId id) =>
      crew.firstWhere((l) => l.id == id);
}
