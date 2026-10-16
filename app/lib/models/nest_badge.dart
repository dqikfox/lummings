/// Nest Badges — collectible stickers kids earn for milestones.
/// Soft collectible loop: unlock once, show forever, never expire, never punish miss.
class NestBadge {
  final String id;
  final String name;
  final String blurb;
  final String emoji;
  final String category; // bond | care | adventure | social | special
  final int minBondLevel;
  final int minStreak;
  final int minCharms;
  final int minAdventures; // tracked via memories or dedicated counter
  final bool requiresFestivalClaim;
  final bool requiresBedtime;

  const NestBadge({
    required this.id,
    required this.name,
    required this.blurb,
    required this.emoji,
    required this.category,
    this.minBondLevel = 0,
    this.minStreak = 0,
    this.minCharms = 0,
    this.minAdventures = 0,
    this.requiresFestivalClaim = false,
    this.requiresBedtime = false,
  });

  static const catalog = <NestBadge>[
    NestBadge(
      id: 'first_glow',
      name: 'First Glow',
      blurb: 'You completed your first Care ritual. Heartlight woke up.',
      emoji: '💡',
      category: 'care',
      minStreak: 1,
    ),
    NestBadge(
      id: 'three_day_spark',
      name: 'Three-Day Spark',
      blurb: 'Three care days in a row — soft streak, never burned by missing.',
      emoji: '🔥',
      category: 'care',
      minStreak: 3,
    ),
    NestBadge(
      id: 'week_of_warmth',
      name: 'Week of Warmth',
      blurb: 'Seven care days. Your friend feels known.',
      emoji: '💛',
      category: 'care',
      minStreak: 7,
    ),
    NestBadge(
      id: 'bond_sprout',
      name: 'Bond Sprout',
      blurb: 'Reached Bond Level 2 with any Lumming.',
      emoji: '🌱',
      category: 'bond',
      minBondLevel: 2,
    ),
    NestBadge(
      id: 'bond_bloom',
      name: 'Bond Bloom',
      blurb: 'Reached Bond Level 5 — essence growing bright.',
      emoji: '🌸',
      category: 'bond',
      minBondLevel: 5,
    ),
    NestBadge(
      id: 'charm_collector',
      name: 'Charm Collector',
      blurb: 'Unlocked 3 Heartlight Charms (memorabilia, not creatures).',
      emoji: '💎',
      category: 'social',
      minCharms: 3,
    ),
    NestBadge(
      id: 'pathfinder',
      name: 'Pathfinder',
      blurb: 'Finished your first Growing Together adventure.',
      emoji: '🗺️',
      category: 'adventure',
      minAdventures: 1,
    ),
    NestBadge(
      id: 'story_weaver',
      name: 'Story Weaver',
      blurb: 'Finished 3 adventures. The Nest remembers.',
      emoji: '📖',
      category: 'adventure',
      minAdventures: 3,
    ),
    NestBadge(
      id: 'festival_friend',
      name: 'Festival Friend',
      blurb: 'Claimed a weekly Festival glow once.',
      emoji: '🎉',
      category: 'special',
      requiresFestivalClaim: true,
    ),
    NestBadge(
      id: 'moon_tucker',
      name: 'Moon Tucker',
      blurb: 'Completed a Bedtime Nest wind-down once.',
      emoji: '🌙',
      category: 'special',
      requiresBedtime: true,
    ),
    NestBadge(
      id: 'crew_heart',
      name: 'Crew Heart',
      blurb: 'Bond Level 2+ with three different Lummings.',
      emoji: '❤️',
      category: 'social',
      minBondLevel: 2, // checked specially across crew
    ),
  ];

  static NestBadge? byId(String id) {
    for (final b in catalog) {
      if (b.id == id) return b;
    }
    return null;
  }
}
