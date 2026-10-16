import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/lummings_theme.dart';

/// Premium 7-day care streak visual — soft FOMO only (empty days never punish).
class StreakFlame extends StatelessWidget {
  final int streak;
  final bool caredToday;
  final Color accent;

  const StreakFlame({
    super.key,
    required this.streak,
    required this.caredToday,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    // Show last 7 day slots; light the trailing [streak] days (capped at 7).
    final lit = streak.clamp(0, 7); // runtime
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    // Align "today" to end of row for a clear progress narrative.
    const todayIdx = 6;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.withOpacity(0.18),
            LummingsColors.surfaceHi.withOpacity(0.9),
          ],
        ),
        border: Border.all(color: Colors.orange.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                streak > 0 ? '🔥' : '🕯️',
                style: const TextStyle(fontSize: 22),
              )
                  .animate(onPlay: streak > 0 ? (c) => c.repeat(reverse: true) : null)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1.08, 1.08),
                    duration: 900.ms,
                  ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      streak > 0
                          ? '$streak-day care streak'
                          : 'Start a care streak',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caredToday
                          ? 'Heartlight is warm today — keep the glow tomorrow'
                          : 'A soft hug lights today\'s spark. Miss a day? No loss, just “I missed you.”',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              // Light the last [lit] slots ending at today.
              final isLit = i >= (7 - lit);
              final isToday = i == todayIdx;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isLit
                          ? RadialGradient(
                              colors: [
                                Colors.orange.withOpacity(0.85),
                                Colors.deepOrange.withOpacity(0.55),
                              ],
                            )
                          : null,
                      color: isLit ? null : Colors.white.withOpacity(0.06),
                      border: Border.all(
                        color: isToday
                            ? accent
                            : isLit
                                ? Colors.orange.withOpacity(0.7)
                                : Colors.white.withOpacity(0.1),
                        width: isToday ? 2 : 1,
                      ),
                      boxShadow: isLit
                          ? [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.45),
                                blurRadius: 10,
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      isLit ? '🔥' : '·',
                      style: TextStyle(
                        fontSize: isLit ? 14 : 16,
                        color: Colors.white38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                      color: isToday ? accent : LummingsColors.muted,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
