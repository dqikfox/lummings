import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';
import '../theme/lummings_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/nest_section_header.dart';
import 'plus_screen.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen> {
  bool unlocked = false;
  final pinCtrl = TextEditingController();

  @override
  void dispose() {
    pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    if (!unlocked) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LummingsColors.starYellow.withOpacity(0.12),
                border: Border.all(
                  color: LummingsColors.starYellow.withOpacity(0.35),
                ),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 40,
                color: LummingsColors.starYellow,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Parent Dashboard',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Safety First — enter your PIN',
              style: TextStyle(color: LummingsColors.muted),
            ),
            const SizedBox(height: 20),
            GlassCard(
              elevated: false,
              child: TextField(
                controller: pinCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Parent PIN',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (hl.verifyParentPin(pinCtrl.text)) {
                    setState(() => unlocked = true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect PIN')),
                    );
                  }
                },
                child: const Text('Unlock'),
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Parent Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: LummingsColors.dreamTeal.withOpacity(0.15),
                border: Border.all(
                  color: LummingsColors.dreamTeal.withOpacity(0.4),
                ),
              ),
              child: const Text(
                '🛡️ Safety First',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: LummingsColors.dreamTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          accent: Colors.orange,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.local_fire_department, color: Colors.orange),
            title: Text(
              'Daily streak · ${hl.active.careStreak} days',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text('Bond Level ${hl.active.bond.level}'),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          accent: LummingsColors.starYellow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.timer,
                  color: LummingsColors.starYellow,
                ),
                title: const Text(
                  'Gentle screen-time limit',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  hl.screenTimeLimitMinutes == 0
                      ? 'Off — no soft reminder'
                      : '${hl.screenTimeLimitMinutes} minutes (soft reminder only, never locks mid-story)',
                ),
              ),
              Row(
                children: [
                  const Text('0', style: TextStyle(color: LummingsColors.muted)),
                  Expanded(
                    child: Slider(
                      value: hl.screenTimeLimitMinutes.toDouble(),
                      min: 0,
                      max: 180,
                      divisions: 12,
                      label: '${hl.screenTimeLimitMinutes}m',
                      onChanged: (v) => hl.setScreenTimeLimit(v.round()),
                    ),
                  ),
                  const Text('3h', style: TextStyle(color: LummingsColors.muted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          accent: LummingsColors.futurePurple,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(
              Icons.privacy_tip,
              color: LummingsColors.futurePurple,
            ),
            title: const Text(
              'Privacy & Content Filters',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'ON by default · COPPA-minded · Safety First',
            ),
            value: hl.contentFiltersOn,
            onChanged: (v) => hl.setContentFilters(v),
          ),
        ),
        const SizedBox(height: 18),
        const NestSectionHeader(
          title: 'Crew bond overview',
          accent: LummingsColors.futurePurple,
        ),
        const SizedBox(height: 10),
        ...Lumming.crew.map((l) {
          final active = l.id == hl.activeId;
          final cs = hl.companionOf(l.id);
          final bondLine =
              'Bond L${cs.bond.level} · 🔥 ${cs.careStreak} · ✨ ${cs.essenceShards}';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              accent: active ? l.heartlight.accent : null,
              elevated: active,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(l.emoji, style: const TextStyle(fontSize: 26)),
                title: Text(
                  l.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(bondLine),
                trailing: active
                    ? Icon(Icons.star_rounded, color: l.heartlight.accent)
                    : IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () => hl.setActive(l.id),
                      ),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        NestSectionHeader(
          title: 'Memories (${hl.active.memoryHighlights.length})',
          accent: LummingsColors.starYellow,
        ),
        const SizedBox(height: 10),
        if (hl.active.memoryHighlights.isEmpty)
          GlassCard(
            elevated: false,
            child: Text(
              'No memories yet — Care, Talk, and Adventures write soft highlights.',
              style: TextStyle(color: Colors.white.withOpacity(0.55)),
            ),
          )
        else
          ...hl.active.memoryHighlights.reversed.take(8).map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GlassCard(
                    elevated: false,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            size: 16, color: LummingsColors.starYellow),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            m,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlusScreen()),
            );
          },
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Heartlight Plus / Nest Family'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Data export / delete will call the privacy API (24h SLA).',
                ),
              ),
            );
          },
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Request data deletion'),
        ),
      ],
    );
  }
}
