import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lumming.dart';
import '../state/heartlight_controller.dart';

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
            const Icon(Icons.shield_rounded, size: 48),
            const SizedBox(height: 12),
            Text('Parent Dashboard',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Safety First — enter your PIN'),
            const SizedBox(height: 16),
            TextField(
              controller: pinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Parent PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
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
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text('Parent Dashboard',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const Spacer(),
            const Chip(label: Text('Safety First')),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.local_fire_department),
            title: Text('Daily streak · ${hl.active.careStreak} days'),
            subtitle: Text('Bond Level ${hl.active.bond.level}'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.timer),
            title: Text('Gentle screen-time limit'),
            subtitle: Text('1h 30m / 2h (set in settings soon)'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text('Privacy & Content Filters'),
            subtitle: Text('ON by default · COPPA-minded'),
          ),
        ),
        const SizedBox(height: 12),
        Text('Crew bond overview',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...Lumming.crew.map((l) {
          final active = l.id == hl.activeId;
          return ListTile(
            leading: Text(l.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(l.name),
            subtitle: Text(l.heartlight.name),
            trailing: active
                ? const Icon(Icons.star_rounded, color: Colors.amber)
                : null,
          );
        }),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Data export / delete will call the privacy API (24h SLA).'),
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
