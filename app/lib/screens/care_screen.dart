import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/heartlight_controller.dart';
import '../widgets/heartlight_bar.dart';
import '../widgets/lumming_avatar.dart';
import '../widgets/bond_levelup_dialog.dart';

class CareScreen extends StatefulWidget {
  const CareScreen({super.key});

  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> {
  String? lastMessage;
  bool busy = false;

  Future<void> _care(String kind) async {
    setState(() => busy = true);
    final hl = context.read<HeartlightController>();
    final result = await hl.performCare(kind: kind);
    setState(() {
      busy = false;
      lastMessage = result.message;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    if (result.leveledUp) {
      await showBondLevelUpDialog(
        context,
        lumming: hl.activeLumming,
        newLevel: hl.active.bond.level,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hl = context.watch<HeartlightController>();
    final l = hl.activeLumming;
    final s = hl.active;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Care & Heartlight Ritual',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Text(l.heartlight.ritual,
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        HeartlightBar(
          state: s,
          heartlightName: l.heartlight.name,
          accent: l.heartlight.accent,
        ),
        const SizedBox(height: 24),
        Center(child: LummingAvatar(lumming: l, size: 140)),
        const SizedBox(height: 24),
        _CareButton(
          label: 'Hug',
          icon: Icons.favorite_rounded,
          onPressed: busy ? null : () => _care('hug'),
        ),
        const SizedBox(height: 10),
        _CareButton(
          label: 'Talk',
          icon: Icons.chat_bubble_rounded,
          onPressed: busy ? null : () => _care('talk'),
        ),
        const SizedBox(height: 10),
        _CareButton(
          label: 'Share a Story',
          icon: Icons.menu_book_rounded,
          onPressed: busy ? null : () => _care('story'),
        ),
        const SizedBox(height: 10),
        _CareButton(
          label: 'Sync Plush',
          icon: Icons.nfc_rounded,
          outlined: true,
          onPressed: busy
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Plush sync arrives in Phase 1.1 — NFC/BLE Heartlight LED.'),
                    ),
                  );
                },
        ),
        if (lastMessage != null) ...[
          const SizedBox(height: 20),
          Text(lastMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
        ],
      ],
    );
  }
}

class _CareButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool outlined;

  const _CareButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
      ),
    );
  }
}
