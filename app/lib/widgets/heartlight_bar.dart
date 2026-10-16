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
    final glow = state.phase == HeartlightPhase.dimmed ? 0.45 : 1.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withOpacity(0.32 * glow),
            LummingsColors.surfaceHi.withOpacity(0.92),
            LummingsColors.starYellow.withOpacity(0.1 * glow),
          ],
        ),
        border: Border.all(color: accent.withOpacity(0.5 * glow), width: 1.4),
        boxShadow: [
          if (state.phase != HeartlightPhase.dimmed)
            BoxShadow(
              color: accent.withOpacity(0.32),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withOpacity(0.45),
                      accent.withOpacity(0.12),
                    ],
                  ),
                  border: Border.all(color: accent.withOpacity(0.5)),
                ),
                child: Icon(Icons.favorite_rounded, color: accent, size: 18)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1.14, 1.14),
                      duration: 1100.ms,
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heartlightName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phaseLabel,
                      style: TextStyle(
                        color: accent.withOpacity(0.95),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (state.careStreak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    '🔥 ${state.careStreak}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value: state.bond.fraction.clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: Colors.white.withOpacity(0.08),
                  color: accent,
                ),
                // Soft shine on progress
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.18),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: accent.withOpacity(0.18),
                ),
                child: Text(
                  'Bond L${state.bond.level}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: LummingsColors.warmWhite,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.bond.xp}/${state.bond.xpToNext} XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: LummingsColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: LummingsColors.starYellow.withOpacity(0.15),
                  border: Border.all(
                    color: LummingsColors.starYellow.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '✨ ${state.essenceShards}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: LummingsColors.starYellow,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
