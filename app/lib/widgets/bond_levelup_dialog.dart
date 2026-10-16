import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/lumming.dart';
import '../theme/lummings_theme.dart';
import 'lumming_avatar.dart';

/// Celebration when a child levels their bond with a Lumming.
Future<void> showBondLevelUpDialog(
  BuildContext context, {
  required Lumming lumming,
  required int newLevel,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                LummingsColors.surfaceHi,
                LummingsColors.surface,
                lumming.heartlight.accent.withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: lumming.heartlight.accent.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: lumming.heartlight.accent.withOpacity(0.35),
                blurRadius: 40,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bond Level $newLevel!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: LummingsColors.starYellow,
                  letterSpacing: -0.3,
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
              const SizedBox(height: 18),
              LummingAvatar(lumming: lumming, size: 96, glowing: true)
                  .animate()
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                    duration: 500.ms,
                  ),
              const SizedBox(height: 16),
              Text(
                '${lumming.name}\'s ${lumming.heartlight.name} radiates brighter.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                lumming.heartlight.line,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: lumming.heartlight.accent,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'New memories, charms, and plush LED patterns unlock as you grow together.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Keep glowing ✨'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
