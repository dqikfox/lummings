import 'package:flutter/foundation.dart';

/// Lets any screen request a bottom-nav tab without tight coupling.
class NavController extends ChangeNotifier {
  int index = 0;

  void go(int i) {
    if (i == index) return;
    index = i.clamp(0, 4);
    notifyListeners();
  }

  void home() => go(0);
  void adventures() => go(1);
  void collection() => go(2);
  void care() => go(3);
  void parent() => go(4);
}
