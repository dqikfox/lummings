import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/shell.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'state/heartlight_controller.dart';
import 'theme/lummings_theme.dart';

class LummingsApp extends StatelessWidget {
  const LummingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lummings',
      debugShowCheckedModeBanner: false,
      theme: LummingsTheme.dark,
      home: Consumer<HeartlightController>(
        builder: (context, hl, _) {
          if (!hl.onboarded) return const OnboardingFlow();
          return const AppShell();
        },
      ),
    );
  }
}
