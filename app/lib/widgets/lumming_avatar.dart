import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/heartlight_state.dart';
import '../models/lumming.dart';

class LummingAvatar extends StatelessWidget {
  final Lumming lumming;
  final double size;
  final bool glowing;
  final HeartlightPhase? phase;

  const LummingAvatar({
    super.key,
    required this.lumming,
    this.size = 120,
    this.glowing = true,
    this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final accent = lumming.heartlight.accent;
    final isDim = phase == HeartlightPhase.dimmed || !glowing;

    final portrait = ClipOval(
      child: Image.asset(
        lumming.crewAsset,
        width: size * 0.88,
        height: size * 0.88,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Text(
          lumming.emoji,
          style: TextStyle(fontSize: size * 0.38, height: 1),
        ),
      ),
    );

    final core = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accent.withOpacity(isDim ? 0.28 : 0.72),
            accent.withOpacity(0.14),
            const Color(0xFF0B1020).withOpacity(0.95),
          ],
          stops: const [0.0, 0.52, 1.0],
        ),
        boxShadow: isDim
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 14,
                ),
              ]
            : [
                BoxShadow(
                  color: accent.withOpacity(0.55),
                  blurRadius: size * 0.32,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: accent.withOpacity(0.22),
                  blurRadius: size * 0.55,
                  spreadRadius: 8,
                ),
              ],
        border: Border.all(
          color: accent.withOpacity(isDim ? 0.35 : 0.95),
          width: size * 0.022,
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  accent.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          portrait,
        ],
      ),
    );

    if (isDim) return core;

    return core
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.975, 0.975),
          end: const Offset(1.025, 1.025),
          duration: 2000.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .shimmer(
          duration: 2800.ms,
          color: accent.withOpacity(0.18),
        );
  }
}
