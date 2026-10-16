import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/heartlight_plus.dart';
import '../services/feedback.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/nest_section_header.dart';

/// Mock storefront for Heartlight Plus. Core bond never paywalled.
class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: LummingsColors.nestGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Heartlight Plus')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const NestSectionHeader(
              title: 'Grow gently',
              accent: LummingsColors.starYellow,
            ),
            const SizedBox(height: 8),
            const Text(
              'Core bond, Care, Talk, Adventures, and Charms stay free forever. '
              'Plus only adds cosmetic glow and early stories.',
              style: TextStyle(color: LummingsColors.muted, height: 1.4),
            ),
            const SizedBox(height: 18),
            ...HeartlightPlusTier.catalog.map((tier) {
              final selected = hl.plusTierId == tier.id;
              final accent = tier.id == 'free'
                  ? LummingsColors.dreamTeal
                  : tier.id == 'plus'
                      ? LummingsColors.starYellow
                      : LummingsColors.futurePurple;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GlassCard(
                  accent: selected ? accent : null,
                  elevated: selected,
                  onTap: () async {
                    await NestFeedback.softSelect();
                    await hl.setPlusTier(tier.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            tier.id == 'free'
                                ? 'Nest Free active — full Heartlight forever ✨'
                                : '${tier.title} selected (mock IAP — store hooks in Phase 1.1)',
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tier.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: accent.withOpacity(0.18),
                              border: Border.all(color: accent.withOpacity(0.4)),
                            ),
                            child: Text(
                              tier.priceLabel,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tier.blurb,
                        style: const TextStyle(
                          color: LummingsColors.muted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...tier.perks.map(
                        (perk) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 16, color: accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  perk,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (selected) ...[
                        const SizedBox(height: 8),
                        Text(
                          '✓ Current plan',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            GlassCard(
              elevated: false,
              child: Text(
                'Kids never see hard paywalls mid-Care or mid-story. '
                'Parent unlocks Plus from this screen or Parent Dashboard.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
