import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/lumming.dart';

class LummingAvatar extends StatelessWidget {
  final Lumming lumming;
  final double size;
  final bool glowing;

  const LummingAvatar({
    super.key,
    required this.lumming,
    this.size = 120,
    this.glowing = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = lumming.heartlight.accent;
    final core = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            accent.withOpacity(glowing ? 0.72 : 0.28),
            accent.withOpacity(0.14),
            const Color(0xFF0B1020).withOpacity(0.95),
          ],
          stops: const [0.0, 0.52, 1.0],
        ),
        boxShadow: glowing
            ? [
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
                BoxShadow(
                  color: Colors.white.withOpacity(0.06),
                  blurRadius: 2,
                  spreadRadius: -1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 14,
                ),
              ],
        border: Border.all(
          color: accent.withOpacity(glowing ? 0.95 : 0.35),
          width: size * 0.022,
        ),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft inner Heartlight disc (essence — not a creature)
          Container(
            width: size * 0.44,
            height: size * 0.44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  accent.withOpacity(0.85),
                  accent.withOpacity(0.12),
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.4),
                  blurRadius: size * 0.12,
                ),
              ],
            ),
          ),
          Text(
            lumming.emoji,
            style: TextStyle(fontSize: size * 0.38, height: 1),
          ),
        ],
      ),
    );

    if (!glowing) return core;

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
          color: accent.withOpacity(0.2),
        );
  }
}
