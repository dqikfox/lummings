/// Visual / gameplay state of a companion's Heartlight essence.
enum HeartlightPhase {
  /// Soft dim after a missed care day — never a punishment.
  dimmed,

  /// Mid daily care ritual.
  caring,

  /// Bright, healthy daily glow.
  glowing,

  /// Celebration pulse after bond level-up or adventure complete.
  radiant,
}

class BondProgress {
  final int level;
  final int xp;
  final int xpToNext;

  const BondProgress({
    required this.level,
    required this.xp,
    required this.xpToNext,
  });

  double get fraction => xpToNext == 0 ? 1.0 : (xp / xpToNext).clamp(0.0, 1.0);

  BondProgress copyWith({int? level, int? xp, int? xpToNext}) => BondProgress(
        level: level ?? this.level,
        xp: xp ?? this.xp,
        xpToNext: xpToNext ?? this.xpToNext,
      );

  /// XP curve: gentle early, steeper later — keeps kids engaged without grind.
  static int xpForLevel(int level) => 40 + (level * 25) + (level * level * 3);
}

class CompanionState {
  final String lummingId;
  final HeartlightPhase phase;
  final BondProgress bond;
  final int careStreak;
  final DateTime? lastCareAt;
  final int essenceShards;
  final List<String> ownedCharms;
  final List<String> memoryHighlights;

  const CompanionState({
    required this.lummingId,
    required this.phase,
    required this.bond,
    required this.careStreak,
    required this.lastCareAt,
    required this.essenceShards,
    required this.ownedCharms,
    required this.memoryHighlights,
  });

  CompanionState copyWith({
    HeartlightPhase? phase,
    BondProgress? bond,
    int? careStreak,
    DateTime? lastCareAt,
    int? essenceShards,
    List<String>? ownedCharms,
    List<String>? memoryHighlights,
  }) {
    return CompanionState(
      lummingId: lummingId,
      phase: phase ?? this.phase,
      bond: bond ?? this.bond,
      careStreak: careStreak ?? this.careStreak,
      lastCareAt: lastCareAt ?? this.lastCareAt,
      essenceShards: essenceShards ?? this.essenceShards,
      ownedCharms: ownedCharms ?? this.ownedCharms,
      memoryHighlights: memoryHighlights ?? this.memoryHighlights,
    );
  }

  bool get caredToday {
    if (lastCareAt == null) return false;
    final now = DateTime.now();
    final last = lastCareAt!;
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }

  bool get missedYesterday {
    if (lastCareAt == null) return true;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final last = lastCareAt!;
    final lastDay = DateTime(last.year, last.month, last.day);
    final yDay = DateTime(yesterday.year, yesterday.month, yesterday.day);
    return lastDay.isBefore(yDay);
  }
}
