import 'package:flutter/material.dart';
import '../models/lumming.dart';
import '../theme/lummings_theme.dart';

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
      return AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Bond Level $newLevel!',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: LummingsColors.starYellow,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lumming.emoji,
              style: const TextStyle(fontSize: 56),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '${lumming.name}\'s ${lumming.heartlight.name} radiates brighter.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              lumming.heartlight.line,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: lumming.heartlight.accent,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'New memories, charms, and plush LED patterns unlock as you grow together.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep glowing'),
          ),
        ],
      );
    },
  );
}
