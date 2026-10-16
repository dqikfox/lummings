import 'package:flutter/services.dart';

/// Soft sensory feedback — kid-safe, never startling.
class NestFeedback {
  NestFeedback._();

  static Future<void> lightTap() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> carePulse() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.selectionClick();
  }

  static Future<void> levelUpBurst() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
  }

  static Future<void> softSelect() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> unlockCharm() async {
    await HapticFeedback.mediumImpact();
  }
}
