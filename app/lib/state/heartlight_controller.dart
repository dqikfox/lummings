import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/heartlight_state.dart';
import '../models/charm.dart';
import '../models/daily_quest.dart';
import '../models/festival.dart';
import '../models/heartlight_plus.dart';
import '../models/nest_badge.dart';
import '../models/lumming.dart';

/// Owns Heartlight essence state, bond XP, care streak, and gentle hooks.
///
/// Design rules:
/// - Missing a day never punishes — only soft "I missed you" dim + return bonus.
/// - Core bond is never paywalled.
/// - Heartlight is essence/soul of the Lumming, not a separate creature.
class HeartlightController extends ChangeNotifier {
  static const _kActive = 'active_lumming';
  static const _kOnboarded = 'onboarded';
  static const _kParentPin = 'parent_pin';

  LummingId activeId = LummingId.lumo;
  bool onboarded = false;
  String? parentPin;
  final Map<String, CompanionState> _companions = {};

  /// Soft daily quests (gentle FOMO — incomplete never punishes).
  DailyQuestProgress quests = DailyQuestProgress.emptyToday();

  /// Parent soft screen-time minutes (0 = off).
  int screenTimeLimitMinutes = 90;
  bool contentFiltersOn = true;

  /// Parent-gated soft bedtime wind-down reminder preference (no hard lock).
  bool softBedtimeReminder = true;

  /// Soft bedtime window (local hour 0-23). Reminder only — never hard-locks app.
  int bedtimeWindowStartHour = 19;
  int bedtimeWindowEndHour = 21;

  /// Heartlight Plus tier: free | plus | family (mock IAP until store hooks).
  String plusTierId = HeartlightPlusTier.free.id;
  FestivalProgress festival = FestivalProgress.emptyThisWeek();

  /// Global Nest Badges (stickers) — unlocked once, never expire.
  Set<String> ownedBadges = {};

  /// Adventures completed (any ending) — drives Pathfinder badges.
  int adventuresCompleted = 0;

  /// Last bedtime nest completion day key (yyyy-mm-dd). Once per night soft ritual.
  String? lastBedtimeDay;


  CompanionState get active =>
      _companions[activeId.name] ?? _fresh(activeId.name);

  Lumming get activeLumming => Lumming.byId(activeId);

  bool get isPlus =>
      plusTierId == HeartlightPlusTier.plus.id ||
      plusTierId == HeartlightPlusTier.family.id;

  NestFestival get currentFestival => NestFestival.forWeek();

  CompanionState companionOf(LummingId id) =>
      _companions[id.name] ?? _fresh(id.name);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    onboarded = prefs.getBool(_kOnboarded) ?? false;
    parentPin = prefs.getString(_kParentPin);
    final idName = prefs.getString(_kActive) ?? 'lumo';
    activeId = LummingId.values.firstWhere(
      (e) => e.name == idName,
      orElse: () => LummingId.lumo,
    );

    // Daily quests — reset if day rolled over
    final today = DailyQuestProgress.todayKey();
    final qDay = prefs.getString('quest_day') ?? today;
    final qDone = prefs.getStringList('quest_done') ?? <String>[];
    final qBonus = prefs.getBool('quest_bonus') ?? false;
    if (qDay == today) {
      quests = DailyQuestProgress(
        dayKey: today,
        completedIds: qDone.toSet(),
        bonusClaimed: qBonus,
      );
    } else {
      quests = DailyQuestProgress.emptyToday();
      await prefs.setString('quest_day', today);
      await prefs.setStringList('quest_done', []);
      await prefs.setBool('quest_bonus', false);
    }

    screenTimeLimitMinutes = prefs.getInt('screen_time_limit') ?? 90;
    contentFiltersOn = prefs.getBool('content_filters') ?? true;
    softBedtimeReminder = prefs.getBool('soft_bedtime') ?? true;
    bedtimeWindowStartHour = prefs.getInt('bedtime_start_h') ?? 19;
    bedtimeWindowEndHour = prefs.getInt('bedtime_end_h') ?? 21;
    plusTierId = prefs.getString('plus_tier') ?? HeartlightPlusTier.free.id;
    ownedBadges = (prefs.getStringList('nest_badges') ?? <String>[]).toSet();
    adventuresCompleted = prefs.getInt('adventures_completed') ?? 0;
    lastBedtimeDay = prefs.getString('last_bedtime_day');

    final fWeek = prefs.getString('festival_week') ?? NestFestival.weekKey();
    final thisWeek = NestFestival.weekKey();
    if (fWeek == thisWeek) {
      festival = FestivalProgress(
        weekKey: fWeek,
        claimed: prefs.getBool('festival_claimed') ?? false,
        engaged: prefs.getBool('festival_engaged') ?? false,
      );
    } else {
      festival = FestivalProgress.emptyThisWeek();
      await prefs.setString('festival_week', thisWeek);
      await prefs.setBool('festival_claimed', false);
      await prefs.setBool('festival_engaged', false);
    }

    for (final l in Lumming.crew) {
      final key = l.id.name;
      final level = prefs.getInt('bond_level_$key') ?? 1;
      final xp = prefs.getInt('bond_xp_$key') ?? 0;
      final streak = prefs.getInt('streak_$key') ?? 0;
      final lastMs = prefs.getInt('last_care_$key');
      final shards = prefs.getInt('shards_$key') ?? 0;
      final last = lastMs != null
          ? DateTime.fromMillisecondsSinceEpoch(lastMs)
          : null;

      var phase = HeartlightPhase.glowing;
      final state = CompanionState(
        lummingId: key,
        phase: phase,
        bond: BondProgress(
          level: level,
          xp: xp,
          xpToNext: BondProgress.xpForLevel(level),
        ),
        careStreak: streak,
        lastCareAt: last,
        essenceShards: shards,
        ownedCharms: prefs.getStringList('charms_$key') ?? const [],
        memoryHighlights: prefs.getStringList('memories_$key') ?? const [],
        equippedCharmId: prefs.getString('equipped_$key'),
      );
      _companions[key] = _applyDailyPhase(state);
    }
    notifyListeners();
  }

  CompanionState _fresh(String id) => CompanionState(
        lummingId: id,
        phase: HeartlightPhase.glowing,
        bond: BondProgress(level: 1, xp: 0, xpToNext: BondProgress.xpForLevel(1)),
        careStreak: 0,
        lastCareAt: null,
        essenceShards: 0,
        ownedCharms: const [],
        memoryHighlights: const [],
      );

  CompanionState _applyDailyPhase(CompanionState s) {
    if (s.caredToday) {
      return s.copyWith(phase: HeartlightPhase.glowing);
    }
    if (s.missedYesterday || s.lastCareAt == null) {
      return s.copyWith(phase: HeartlightPhase.dimmed);
    }
    return s.copyWith(phase: HeartlightPhase.glowing);
  }

  Future<void> setActive(LummingId id) async {
    activeId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActive, id.name);
    notifyListeners();
  }

  Future<void> completeOnboarding(LummingId firstFriend, {String? pin}) async {
    activeId = firstFriend;
    onboarded = true;
    parentPin = pin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarded, true);
    await prefs.setString(_kActive, firstFriend.name);
    if (pin != null && pin.isNotEmpty) {
      await prefs.setString(_kParentPin, pin);
    }
    notifyListeners();
  }

  /// Daily Care Ritual — hug / talk / story all route here.
  Future<CareResult> performCare({String kind = 'hug'}) async {
    final key = activeId.name;
    var s = _companions[key] ?? _fresh(key);

    if (s.caredToday) {
      return CareResult(
        alreadyDone: true,
        message: '${activeLumming.name} is already glowing with you today. '
            'Come back tomorrow to keep the streak!',
        state: s,
      );
    }

    final missed = s.missedYesterday && s.lastCareAt != null;
    final streak = missed ? 1 : s.careStreak + 1;
    final returnBonus = missed ? 15 : 0;
    final baseXp = 20 + (kind == 'story' ? 5 : 0);
    final xpGain = baseXp + returnBonus;

    s = s.copyWith(
      phase: HeartlightPhase.caring,
      careStreak: streak,
      lastCareAt: DateTime.now(),
    );
    _companions[key] = s;
    notifyListeners();

    // Brief "caring" pulse then glow / radiant
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final levelBefore = s.bond.level;
    s = await _addXp(s, xpGain, shards: 1);
    final didLevel = s.bond.level > levelBefore;
    // Keep radiant on level-up for a beat; otherwise settle to glowing.
    if (!didLevel) {
      s = s.copyWith(phase: HeartlightPhase.glowing);
    }
    if (missed) {
      s = s.copyWith(
        memoryHighlights: [
          ...s.memoryHighlights,
          'Came back after a quiet day — ${activeLumming.name} was so happy.',
        ],
      );
    }
    _companions[key] = s;
    await _persist(s);
    await markFestivalEngaged();
    await _evaluateBadges();
    notifyListeners();

    final missLine = missed
        ? ' I missed you… thank you for coming back. Your return lit an extra spark!'
        : '';
    final questNote = await completeQuest(QuestKind.care);
    return CareResult(
      alreadyDone: false,
      message:
          '${activeLumming.heartlight.ritual}$missLine Heartlight brighter. +$xpGain bond.'
          '${questNote != null ? ' · $questNote' : ''}',
      state: _companions[key] ?? s,
      xpGained: xpGain,
      streak: streak,
      leveledUp: didLevel,
    );
  }

  Future<CompanionState> _addXp(CompanionState s, int amount,
      {int shards = 0}) async {
    var level = s.bond.level;
    var xp = s.bond.xp + amount;
    var need = s.bond.xpToNext;
    var leveled = false;
    while (xp >= need) {
      xp -= need;
      level += 1;
      need = BondProgress.xpForLevel(level);
      leveled = true;
    }
    var phase = s.phase;
    if (leveled) phase = HeartlightPhase.radiant;
    return s.copyWith(
      phase: phase,
      bond: BondProgress(level: level, xp: xp, xpToNext: need),
      essenceShards: s.essenceShards + shards,
    );
  }

  Future<void> rewardAdventure({
    required int bondXp,
    required int shards,
    List<String> memories = const [],
  }) async {
    final key = activeId.name;
    var s = _companions[key] ?? _fresh(key);
    s = await _addXp(s, bondXp, shards: shards);
    if (memories.isNotEmpty) {
      s = s.copyWith(memoryHighlights: [...s.memoryHighlights, ...memories]);
    }
    s = s.copyWith(phase: HeartlightPhase.radiant);
    _companions[key] = s;
    await _persist(s);
    await markFestivalEngaged();
    adventuresCompleted += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('adventures_completed', adventuresCompleted);
    await _evaluateBadges();
    notifyListeners();
    await completeQuest(QuestKind.adventure);
  }

  Future<void> _persist(CompanionState s) async {
    final prefs = await SharedPreferences.getInstance();
    final key = s.lummingId;
    await prefs.setInt('bond_level_$key', s.bond.level);
    await prefs.setInt('bond_xp_$key', s.bond.xp);
    await prefs.setInt('streak_$key', s.careStreak);
    await prefs.setInt('shards_$key', s.essenceShards);
    if (s.lastCareAt != null) {
      await prefs.setInt(
          'last_care_$key', s.lastCareAt!.millisecondsSinceEpoch);
    }
    await prefs.setStringList('charms_$key', s.ownedCharms);
    await prefs.setStringList('memories_$key', s.memoryHighlights);
    if (s.equippedCharmId != null) {
      await prefs.setString('equipped_$key', s.equippedCharmId!);
    } else {
      await prefs.remove('equipped_$key');
    }
  }


  /// Global owned charms (shared across crew) stored under active companion list
  /// plus a global key for "all" charms.
  List<String> get allOwnedCharms {
    final set = <String>{};
    for (final s in _companions.values) {
      set.addAll(s.ownedCharms);
    }
    return set.toList()..sort();
  }

  bool ownsCharm(String charmId) => allOwnedCharms.contains(charmId);

  /// Spend essence shards to unlock a charm. Core bond is never paywalled —
  /// charms are cosmetic collectibles only.
  Future<CharmPurchaseResult> purchaseCharm(String charmId) async {
    final charm = Charm.byId(charmId);
    if (charm == null) {
      return CharmPurchaseResult(ok: false, message: 'Unknown charm.');
    }
    if (ownsCharm(charmId)) {
      return CharmPurchaseResult(ok: false, message: 'You already own ${charm.name}!');
    }
    final key = activeId.name;
    var s = _companions[key] ?? _fresh(key);
    if (s.bond.level < charm.minBondLevel) {
      return CharmPurchaseResult(
        ok: false,
        message:
            'Need Bond Level ${charm.minBondLevel} for ${charm.name}. Keep glowing!',
      );
    }
    if (s.essenceShards < charm.shardCost) {
      return CharmPurchaseResult(
        ok: false,
        message:
            'Need ${charm.shardCost} shards (you have ${s.essenceShards}). Care & Adventures earn more!',
      );
    }
    s = s.copyWith(
      essenceShards: s.essenceShards - charm.shardCost,
      ownedCharms: [...s.ownedCharms, charmId],
      memoryHighlights: [
        ...s.memoryHighlights,
        'Unlocked ${charm.name} — a spark of ${activeLumming.name}\'s Heartlight.',
      ],
      phase: HeartlightPhase.radiant,
    );
    _companions[key] = s;
    await _persist(s);
    await markFestivalEngaged();
    notifyListeners();
    await completeQuest(QuestKind.collect);
    await _evaluateBadges();
    return CharmPurchaseResult(
      ok: true,
      message: '${charm.emoji} ${charm.name} unlocked! Collection grows brighter.',
      state: _companions[key] ?? s,
    );
  }

  /// Soft Talk XP — never more than once-light reward; does not replace daily Care.
  Future<CareResult> rewardTalk({
    required int bondXp,
    required int shards,
    String memory = '',
  }) async {
    final key = activeId.name;
    var s = _companions[key] ?? _fresh(key);
    s = await _addXp(s, bondXp, shards: shards);
    if (memory.isNotEmpty) {
      s = s.copyWith(memoryHighlights: [...s.memoryHighlights, memory]);
    }
    s = s.copyWith(phase: HeartlightPhase.glowing);
    _companions[key] = s;
    await _persist(s);
    await markFestivalEngaged();
    notifyListeners();
    await completeQuest(QuestKind.talk);
    return CareResult(
      alreadyDone: false,
      message: activeLumming.heartlight.line,
      state: _companions[key] ?? s,
      xpGained: bondXp,
      streak: (_companions[key] ?? s).careStreak,
    );
  }


  Future<void> setScreenTimeLimit(int minutes) async {
    screenTimeLimitMinutes = minutes.clamp(0, 240);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('screen_time_limit', screenTimeLimitMinutes);
    notifyListeners();
  }

  Future<void> setContentFilters(bool on) async {
    contentFiltersOn = on;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('content_filters', on);
    notifyListeners();
  }

  Future<void> setSoftBedtimeReminder(bool on) async {
    softBedtimeReminder = on;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soft_bedtime', on);
    notifyListeners();
  }

  Future<void> setBedtimeWindow({int? startHour, int? endHour}) async {
    if (startHour != null) bedtimeWindowStartHour = startHour.clamp(0, 23);
    if (endHour != null) bedtimeWindowEndHour = endHour.clamp(0, 23);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bedtime_start_h', bedtimeWindowStartHour);
    await prefs.setInt('bedtime_end_h', bedtimeWindowEndHour);
    notifyListeners();
  }

  /// True when local time is inside soft bedtime window (for gentle UI nudge).
  bool get isInBedtimeWindow {
    final h = DateTime.now().hour;
    final a = bedtimeWindowStartHour;
    final b = bedtimeWindowEndHour;
    if (a <= b) return h >= a && h < b;
    // overnight window e.g. 21–7
    return h >= a || h < b;
  }

  /// One-line parent weekly digest (local, no cloud).
  String weeklyDigestLine() {
    final s = active;
    final badges = ownedBadges.length;
    final care = s.caredToday ? 'cared today' : 'care waiting (no pressure)';
    return 'This week with ${activeLumming.name}: Bond L${s.bond.level} · '
        '${s.careStreak}d streak · ${s.essenceShards} shards · '
        '$badges badges · $care · Festival ${festival.claimed ? "claimed" : (festival.engaged ? "ready to claim" : "open")}.';
  }

  /// Equip an owned charm as a cosmetic badge on the active Lumming.
  /// Core bond is never gated — this is pure collectible flair.
  Future<String> equipCharm(String? charmId) async {
    final key = activeId.name;
    var s = _companions[key] ?? _fresh(key);
    if (charmId == null) {
      s = s.copyWith(clearEquipped: true);
      _companions[key] = s;
      await _persist(s);
      notifyListeners();
      return 'Charm badge tucked away — Heartlight still shines.';
    }
    if (!ownsCharm(charmId) && !s.ownedCharms.contains(charmId)) {
      return 'Unlock this charm first in Collection.';
    }
    final charm = Charm.byId(charmId);
    if (charm == null) return 'Unknown charm.';
    s = s.copyWith(equippedCharmId: charmId);
    _companions[key] = s;
    await _persist(s);
    notifyListeners();
    return '${charm.emoji} ${charm.name} equipped on ${activeLumming.name}!';
  }

  Future<void> _persistQuests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('quest_day', quests.dayKey);
    await prefs.setStringList('quest_done', quests.completedIds.toList());
    await prefs.setBool('quest_bonus', quests.bonusClaimed);
  }

  /// Mark a daily quest done. Idempotent. Never punishes incomplete days.
  Future<String?> completeQuest(QuestKind kind) async {
    final today = DailyQuestProgress.todayKey();
    if (quests.dayKey != today) {
      quests = DailyQuestProgress.emptyToday();
    }
    final def = DailyQuest.roster.firstWhere((q) => q.kind == kind);
    if (quests.completedIds.contains(def.id)) return null;

    final next = {...quests.completedIds, def.id};
    quests = quests.copyWith(completedIds: next);

    final key = activeId.name;
    var s = _companions[key] ?? _fresh(key);
    if (def.bondXpReward > 0 || def.shardReward > 0) {
      s = await _addXp(s, def.bondXpReward, shards: def.shardReward);
    }
    String? bonusMsg;
    if (quests.allDone && !quests.bonusClaimed) {
      s = await _addXp(s, 10, shards: 2);
      quests = quests.copyWith(bonusClaimed: true);
      s = s.copyWith(
        phase: HeartlightPhase.radiant,
        memoryHighlights: [
          ...s.memoryHighlights,
          'All four daily sparks complete — Heartlight festival glow!',
        ],
      );
      bonusMsg = '🎉 All daily sparks complete! +10 bond · +2 shards.';
    }
    _companions[key] = s;
    await _persist(s);
    await _persistQuests();
    notifyListeners();
    return bonusMsg ?? 'Quest done: ${def.title} ✨';
  }


  bool get bedtimeDoneToday {
    final today = DailyQuestProgress.todayKey();
    return lastBedtimeDay == today;
  }

  /// Soft Bedtime Nest — once per evening. Dims glow gently, never locks app.
  Future<CareResult> performBedtime({String note = ''}) async {
    final today = DailyQuestProgress.todayKey();
    if (lastBedtimeDay == today) {
      return CareResult(
        alreadyDone: true,
        message: 'Bedtime Nest already shared tonight. Sleep well — glow waits kindly.',
        state: active,
      );
    }
    final key = activeId.name;
    var s = _companions[key] ?? _fresh(key);
    s = await _addXp(s, 12, shards: 1);
    final mem = note.isEmpty
        ? 'Bedtime Nest with ${activeLumming.name} — soft wind-down glow.'
        : 'Bedtime Nest: $note';
    s = s.copyWith(
      phase: HeartlightPhase.glowing,
      memoryHighlights: [...s.memoryHighlights, mem],
    );
    lastBedtimeDay = today;
    _companions[key] = s;
    await _persist(s);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_bedtime_day', today);
    await markFestivalEngaged();
    await _evaluateBadges();
    notifyListeners();
    return CareResult(
      alreadyDone: false,
      message:
          '🌙 Bedtime Nest complete. ${activeLumming.heartlight.name} tucks soft light away until morning. +12 bond · +1 shard.',
      state: _companions[key] ?? s,
      xpGained: 12,
      streak: s.careStreak,
    );
  }

  Future<void> _persistBadges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('nest_badges', ownedBadges.toList()..sort());
  }

  /// Unlock any newly earned Nest Badges. Idempotent. Never removes.
  Future<List<NestBadge>> _evaluateBadges() async {
    final newly = <NestBadge>[];
    final s = active;
    final crewBond2 = Lumming.crew
        .where((l) => companionOf(l.id).bond.level >= 2)
        .length;

    for (final b in NestBadge.catalog) {
      if (ownedBadges.contains(b.id)) continue;
      var earn = false;
      if (b.id == 'crew_heart') {
        earn = crewBond2 >= 3;
      } else if (b.requiresFestivalClaim) {
        earn = festival.claimed;
      } else if (b.requiresBedtime) {
        earn = lastBedtimeDay != null;
      } else if (b.minAdventures > 0) {
        earn = adventuresCompleted >= b.minAdventures;
      } else if (b.minCharms > 0) {
        earn = s.ownedCharms.length >= b.minCharms;
      } else if (b.minStreak > 0) {
        earn = s.careStreak >= b.minStreak;
      } else if (b.minBondLevel > 0) {
        earn = s.bond.level >= b.minBondLevel;
      }
      if (earn) {
        ownedBadges = {...ownedBadges, b.id};
        newly.add(b);
      }
    }
    if (newly.isNotEmpty) {
      await _persistBadges();
      final key = activeId.name;
      var st = _companions[key] ?? _fresh(key);
      for (final b in newly) {
        st = st.copyWith(
          memoryHighlights: [
            ...st.memoryHighlights,
            '${b.emoji} Badge unlocked: ${b.name}',
          ],
          phase: HeartlightPhase.radiant,
        );
      }
      _companions[key] = st;
      await _persist(st);
    }
    return newly;
  }

  /// Public hook after major actions (tests + UI can await).
  Future<List<NestBadge>> refreshBadges() => _evaluateBadges();

  Future<void> setPlusTier(String tierId) async {
    plusTierId = tierId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plus_tier', tierId);
    notifyListeners();
  }

  Future<void> markFestivalEngaged() async {
    final week = NestFestival.weekKey();
    if (festival.weekKey != week) {
      festival = FestivalProgress.emptyThisWeek();
    }
    if (festival.engaged) return;
    festival = festival.copyWith(engaged: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('festival_week', festival.weekKey);
    await prefs.setBool('festival_engaged', true);
    notifyListeners();
  }

  /// Soft festival claim — requires any engage this week. Never punishes miss.
  Future<String> claimFestivalBonus() async {
    final week = NestFestival.weekKey();
    if (festival.weekKey != week) {
      festival = FestivalProgress.emptyThisWeek();
    }
    if (festival.claimed) {
      return 'Festival glow already claimed this week — see you next weekend ✨';
    }
    if (!festival.engaged) {
      return 'Do one Care, Talk, Adventure, or Charm first — then claim Festival glow!';
    }
    final fest = NestFestival.forWeek();
    final key = activeId.name;
    var s = _companions[key] ?? _fresh(key);
    final bonusShards = fest.bonusShards + (isPlus ? 2 : 0);
    final bonusXp = fest.bonusXp + (isPlus ? 5 : 0);
    s = await _addXp(s, bonusXp, shards: bonusShards);
    s = s.copyWith(
      phase: HeartlightPhase.radiant,
      memoryHighlights: [
        ...s.memoryHighlights,
        '${fest.emoji} ${fest.title} — Heartlights celebrated together.',
      ],
    );
    festival = festival.copyWith(claimed: true);
    _companions[key] = s;
    await _persist(s);
    await _evaluateBadges();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('festival_week', festival.weekKey);
    await prefs.setBool('festival_claimed', true);
    await prefs.setBool('festival_engaged', true);
    notifyListeners();
    return '${fest.emoji} ${fest.title}! +$bonusXp bond · +$bonusShards shards'
        '${isPlus ? ' (Plus bonus)' : ''}.';
  }

  bool verifyParentPin(String attempt) =>
      parentPin == null || parentPin!.isEmpty || parentPin == attempt;
}

class CareResult {
  final bool alreadyDone;
  final String message;
  final CompanionState state;
  final int xpGained;
  final int streak;
  final bool leveledUp;

  CareResult({
    required this.alreadyDone,
    required this.message,
    required this.state,
    this.xpGained = 0,
    this.streak = 0,
    this.leveledUp = false,
  });
}


class CharmPurchaseResult {
  final bool ok;
  final String message;
  final CompanionState? state;

  CharmPurchaseResult({
    required this.ok,
    required this.message,
    this.state,
  });
}
