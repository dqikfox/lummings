import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/heartlight_state.dart';
import '../theme/lummings_theme.dart';

class HeartlightBar extends StatelessWidget {
  final CompanionState state;
  final String heartlightName;
  final Color accent;

  const HeartlightBar({
    super.key,
    required this.state,
    required this.heartlightName,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final phaseLabel = switch (state.phase) {
      HeartlightPhase.dimmed => 'I missed you…',
      HeartlightPhase.caring => 'Caring…',
      HeartlightPhase.glowing => 'Glowing',
      HeartlightPhase.radiant => 'Radiant!',
    };

    final glow = state.phase == HeartlightPhase.dimmed ? 0.35 : 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.25 * glow),
            LummingsColors.starYellow.withOpacity(0.15 * glow),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.45 * glow)),
        boxShadow: [
          if (state.phase != HeartlightPhase.dimmed)
            BoxShadow(
              color: accent.withOpacity(0.35),
              blurRadius: 16,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: accent, size: 22)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1.08, 1.08),
                    duration: 1200.ms,
                  ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$heartlightName · $phaseLabel',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (state.careStreak > 0)
                Text('🔥 ${state.careStreak}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: state.bond.fraction,
              minHeight: 10,
              backgroundColor: Colors.white12,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bond Level ${state.bond.level}  ·  ${state.bond.xp}/${state.bond.xpToNext} XP  ·  ✨ ${state.essenceShards} shards',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}
