import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lummings_app/app.dart';
import 'package:lummings_app/models/heartlight_state.dart';
import 'package:lummings_app/models/lumming.dart';
import 'package:lummings_app/screens/shell.dart';
import 'package:lummings_app/state/adventure_controller.dart';
import 'package:lummings_app/state/nav_controller.dart';
import 'package:lummings_app/state/heartlight_controller.dart';
import 'package:lummings_app/widgets/heartlight_bar.dart';
import 'package:lummings_app/widgets/lumming_avatar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Avoid network font fetch hanging tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Onboarding shows Welcome to Lummings', (tester) async {
    final hl = HeartlightController();
    await hl.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: hl),
          ChangeNotifierProvider(create: (_) => AdventureController()),
          ChangeNotifierProvider(create: (_) => NavController()),
        ],
        child: const LummingsApp(),
      ),
    );
    await tester.pump(); // one frame — avoid pumpAndSettle (infinite anims)
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Welcome to Lummings'), findsOneWidget);
    expect(find.text('Meet Your Crew'), findsOneWidget);
  });

  testWidgets('Onboarding flow reaches parent gate then home', (tester) async {
    final hl = HeartlightController();
    await hl.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: hl),
          ChangeNotifierProvider(create: (_) => AdventureController()),
          ChangeNotifierProvider(create: (_) => NavController()),
        ],
        child: const LummingsApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.text('Meet Your Crew'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Pick your first friend'), findsOneWidget);

    await tester.tap(find.textContaining('Lumo'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('Parents & Safety'), findsOneWidget);

    await tester.tap(find.text('Start Growing Together'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(hl.onboarded, isTrue);
    expect(find.textContaining('Heartlight Nest'), findsOneWidget);
  });

  testWidgets('AppShell tabs exist when onboarded', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarded': true});
    final hl = HeartlightController();
    await hl.load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: hl),
          ChangeNotifierProvider(create: (_) => AdventureController()),
          ChangeNotifierProvider(create: (_) => NavController()),
        ],
        child: const MaterialApp(home: AppShell()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Care'), findsWidgets);
    expect(find.text('Adventures'), findsWidgets);
    expect(find.text('Parent'), findsWidgets);
  });

  testWidgets('HeartlightBar and LummingAvatar render', (tester) async {
    final l = Lumming.byId(LummingId.lumo);
    final state = CompanionState(
      lummingId: 'lumo',
      phase: HeartlightPhase.glowing,
      bond: const BondProgress(level: 2, xp: 10, xpToNext: 100),
      careStreak: 3,
      lastCareAt: DateTime.now(),
      essenceShards: 5,
      ownedCharms: const [],
      memoryHighlights: const [],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              HeartlightBar(
                state: state,
                heartlightName: l.heartlight.name,
                accent: l.heartlight.accent,
              ),
              LummingAvatar(lumming: l),
            ],
          ),
        ),
      ),
    );
    await tester.pump(); // draw once
    expect(find.textContaining('Questlight'), findsOneWidget);
    expect(find.textContaining('Bond Level 2'), findsOneWidget);
    // Tear down: dispose infinite flutter_animate timers cleanly
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  });
}
