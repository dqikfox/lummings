import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'state/adventure_controller.dart';
import 'state/heartlight_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final heartlight = HeartlightController();
  await heartlight.load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: heartlight),
        ChangeNotifierProvider(create: (_) => AdventureController()),
      ],
      child: const LummingsApp(),
    ),
  );
}
