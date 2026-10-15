import 'package:flutter/material.dart';
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            lumming.heartlight.accent.withOpacity(glowing ? 0.55 : 0.2),
            lumming.heartlight.accent.withOpacity(0.05),
          ],
        ),
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: lumming.heartlight.accent.withOpacity(0.45),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ]
            : null,
        border: Border.all(
          color: lumming.heartlight.accent.withOpacity(0.7),
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        lumming.emoji,
        style: TextStyle(fontSize: size * 0.42),
      ),
    );
  }
}
