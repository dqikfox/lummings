import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Short burst of Heartlight particles after a successful Care ritual.
class CareSparkleOverlay extends StatefulWidget {
  final Color accent;
  final bool play;
  final VoidCallback? onDone;

  const CareSparkleOverlay({
    super.key,
    required this.accent,
    required this.play,
    this.onDone,
  });

  @override
  State<CareSparkleOverlay> createState() => _CareSparkleOverlayState();
}

class _CareSparkleOverlayState extends State<CareSparkleOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    if (widget.play) {
      _c.forward().whenComplete(() => widget.onDone?.call());
    }
  }

  @override
  void didUpdateWidget(CareSparkleOverlay old) {
    super.didUpdateWidget(old);
    if (widget.play && !old.play) {
      _c.forward(from: 0).whenComplete(() => widget.onDone?.call());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.play && !_c.isAnimating) return const SizedBox.shrink();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _SparklePainter(
              t: _c.value,
              color: widget.accent,
            ),
          );
        },
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double t;
  final Color color;
  _SparklePainter({required this.t, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.38;
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 18; i++) {
      final angle = (i / 18) * math.pi * 2 + t * 0.8;
      final dist = 28 + (i % 5) * 18.0 + t * 90;
      final x = cx + math.cos(angle) * dist;
      final y = cy + math.sin(angle) * dist * 0.72;
      final life = (1.0 - t).clamp(0.0, 1.0);
      final r = 2.5 + rng.nextDouble() * 3.5;
      paint.color = color.withOpacity(0.15 + 0.7 * life);
      canvas.drawCircle(Offset(x, y), r * life, paint);
      // soft outer glow
      paint.color = color.withOpacity(0.12 * life);
      canvas.drawCircle(Offset(x, y), r * 2.2 * life, paint);
    }

    // central flash
    final flash = (1.0 - (t * 1.6).clamp(0.0, 1.0));
    paint.color = Colors.white.withOpacity(0.35 * flash);
    canvas.drawCircle(Offset(cx, cy), 40 * flash, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter old) => old.t != t || old.color != color;
}
