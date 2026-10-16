/// Collectible Heartlight Charms — soft engagement loop (earn, never punish).
/// Charms are memorabilia of bond growth, NOT separate creatures.
class Charm {
  final String id;
  final String name;
  final String blurb;
  final String lummingId; // 'lumo'|'lila'|'pip'|'nori'|'moki'|'all'
  final int shardCost;
  final int minBondLevel;
  final String rarity; // common | rare | seasonal | legendary
  final String emoji;

  const Charm({
    required this.id,
    required this.name,
    required this.blurb,
    required this.lummingId,
    required this.shardCost,
    required this.minBondLevel,
    required this.rarity,
    required this.emoji,
  });

  static const catalog = <Charm>[
    Charm(
      id: 'questlight_charm',
      name: 'Questlight Charm',
      blurb: 'A tiny constellation pin from Lumo\'s co-op quests.',
      lummingId: 'lumo',
      shardCost: 3,
      minBondLevel: 1,
      rarity: 'common',
      emoji: '⭐',
    ),
    Charm(
      id: 'dreamlight_charm',
      name: 'Dreamlight Charm',
      blurb: 'Soft violet ribbon that sketches feelings into pictures.',
      lummingId: 'lila',
      shardCost: 3,
      minBondLevel: 1,
      rarity: 'common',
      emoji: '🌙',
    ),
    Charm(
      id: 'traillight_charm',
      name: 'Traillight Charm',
      blurb: 'An acorn-shaped marker for safe next steps.',
      lummingId: 'pip',
      shardCost: 3,
      minBondLevel: 1,
      rarity: 'common',
      emoji: '🍃',
    ),
    Charm(
      id: 'tidelight_charm',
      name: 'Tidelight Charm',
      blurb: 'A crescent that glows when you notice quiet things.',
      lummingId: 'nori',
      shardCost: 3,
      minBondLevel: 1,
      rarity: 'common',
      emoji: '🌊',
    ),
    Charm(
      id: 'sparklight_charm',
      name: 'Sparklight Charm',
      blurb: 'Pixel-star that untangles mix-ups with a kind joke.',
      lummingId: 'moki',
      shardCost: 3,
      minBondLevel: 1,
      rarity: 'common',
      emoji: '✨',
    ),
    Charm(
      id: 'bonded_star',
      name: 'Bonded Star',
      blurb: 'Rare reward for reaching Bond Level 3 with any friend.',
      lummingId: 'all',
      shardCost: 8,
      minBondLevel: 3,
      rarity: 'rare',
      emoji: '🌟',
    ),
    Charm(
      id: 'night_forest_lantern',
      name: 'Night Forest Lantern',
      blurb: 'Memory of your first Growing Together adventure.',
      lummingId: 'all',
      shardCost: 5,
      minBondLevel: 2,
      rarity: 'rare',
      emoji: '🏮',
    ),
    Charm(
      id: 'seasonal_star',
      name: 'Seasonal Star',
      blurb: 'Limited sparkle — comes back each season with new glow.',
      lummingId: 'all',
      shardCost: 12,
      minBondLevel: 1,
      rarity: 'seasonal',
      emoji: '🎇',
    ),
    Charm(
      id: 'nest_pillow',
      name: 'Nest Pillow Charm',
      blurb: 'Cozy soft-hook collectible — kids want one for every Lumming nest.',
      lummingId: 'all',
      shardCost: 4,
      minBondLevel: 1,
      rarity: 'common',
      emoji: '🛏️',
    ),
    Charm(
      id: 'heartlight_crown',
      name: 'Heartlight Crown',
      blurb: 'Legendary set-completion glow. Equip to show your full bond.',
      lummingId: 'all',
      shardCost: 20,
      minBondLevel: 5,
      rarity: 'legendary',
      emoji: '👑',
    ),
  ];

  static Charm? byId(String id) {
    try {
      return catalog.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
