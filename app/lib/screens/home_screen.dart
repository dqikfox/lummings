import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_quest.dart';
import '../models/heartlight_state.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';
import '../state/nav_controller.dart';
import '../widgets/heartlight_bar.dart';
import '../widgets/lumming_avatar.dart';
import 'talk_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final nav = context.read<NavController>();
    final lumming = hl.activeLumming;
    final state = hl.active;
    final greeting = state.phase == HeartlightPhase.dimmed
        ? 'I missed you… my ${lumming.heartlight.name} is waiting.'
        : 'Your ${lumming.heartlight.name} is glowing today!';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Heartlight Nest',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                )),
        const SizedBox(height: 8),
        Text(greeting, style: Theme.of(context).textTheme.titleMedium),
        if (hl.screenTimeLimitMinutes > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Parent soft limit · ${hl.screenTimeLimitMinutes} min (gentle reminder only)',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54),
          ),
        ],
        const SizedBox(height: 16),
        HeartlightBar(
          state: state,
          heartlightName: lumming.heartlight.name,
          accent: lumming.heartlight.accent,
        ),
        const SizedBox(height: 20),
        Center(
          child: LummingAvatar(
            lumming: lumming,
            size: 150,
            glowing: state.phase != HeartlightPhase.dimmed,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            '${lumming.name} · ${lumming.title}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            lumming.heartlight.line,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TalkScreen()),
              ),
              icon: const Icon(Icons.mic_rounded),
              label: const Text('Talk'),
            ),
            FilledButton.tonalIcon(
              onPressed: nav.care,
              icon: const Icon(Icons.favorite_rounded),
              label: const Text('Care'),
            ),
            OutlinedButton.icon(
              onPressed: nav.adventures,
              icon: const Icon(Icons.auto_stories_rounded),
              label: const Text('Adventure'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Plush NFC/BLE sync lands in Phase 1.1 — for now your Heartlight lives fully in the app ✨',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.nfc_rounded),
              label: const Text('Sync Plush'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _DailyQuestsCard(hl: hl, nav: nav),
        const SizedBox(height: 24),
        Text('Your Crew',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: Lumming.crew.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final l = Lumming.crew[i];
              final selected = l.id == hl.activeId;
              return GestureDetector(
                onTap: () => hl.setActive(l.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? l.heartlight.accent : Colors.white24,
                      width: selected ? 2 : 1,
                    ),
                    color: selected
                        ? l.heartlight.accent.withOpacity(0.15)
                        : Colors.white10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(l.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DailyQuestsCard extends StatelessWidget {
  final HeartlightController hl;
  final NavController nav;
  const _DailyQuestsCard({required this.hl, required this.nav});

  void _jump(QuestKind k) {
    switch (k) {
      case QuestKind.care:
        nav.care();
        break;
      case QuestKind.talk:
        nav.home();
        break;
      case QuestKind.adventure:
        nav.adventures();
        break;
      case QuestKind.collect:
        nav.collection();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = hl.quests;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
        color: Colors.white10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Daily Sparks',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const Spacer(),
              Text('${q.doneCount}/${q.total}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: q.fraction,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: Colors.white12,
          ),
          const SizedBox(height: 4),
          Text(
            q.allDone
                ? 'All sparks lit — come back tomorrow for new ones ✨'
                : 'Soft hooks only. Miss a spark? No punishment — just try tomorrow.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 10),
          ...DailyQuest.roster.map((def) {
            final done = q.completedIds.contains(def.id);
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Text(done ? '✅' : def.emoji,
                  style: const TextStyle(fontSize: 22)),
              title: Text(
                def.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? Colors.white54 : Colors.white,
                ),
              ),
              subtitle: Text(def.blurb, style: const TextStyle(fontSize: 12)),
              trailing: done
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () => _jump(def.kind),
                    ),
            );
          }),
        ],
      ),
    );
  }
}
