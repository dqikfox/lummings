import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/heartlight_state.dart';
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

  CompanionState get active =>
      _companions[activeId.name] ?? _fresh(activeId.name);

  Lumming get activeLumming => Lumming.byId(activeId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    onboarded = prefs.getBool(_kOnboarded) ?? false;
    parentPin = prefs.getString(_kParentPin);
    final idName = prefs.getString(_kActive) ?? 'lumo';
    activeId = LummingId.values.firstWhere(
      (e) => e.name == idName,
      orElse: () => LummingId.lumo,
    );

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

    // Brief "caring" pulse then glow
    await Future<void>.delayed(const Duration(milliseconds: 600));
    s = await _addXp(s, xpGain, shards: 1);
    s = s.copyWith(phase: HeartlightPhase.glowing);
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
    notifyListeners();

    final missLine = missed
        ? ' I missed you… thank you for coming back. Your return lit an extra spark!'
        : '';
    return CareResult(
      alreadyDone: false,
      message:
          '${activeLumming.heartlight.ritual}$missLine Heartlight brighter. +$xpGain bond.',
      state: s,
      xpGained: xpGain,
      streak: streak,
      leveledUp: s.phase == HeartlightPhase.radiant,
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
    notifyListeners();
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
