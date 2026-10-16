import 'package:flutter/material.dart';
import '../theme/lummings_theme.dart';

/// Premium section title used across Nest screens.
class NestSectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final Color? accent;

  const NestSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = accent ?? LummingsColors.starYellow;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: a,
            boxShadow: [
              BoxShadow(
                color: a.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: a,
              fontSize: 13,
            ),
          ),
      ],
    );
  }
}
