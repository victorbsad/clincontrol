import 'package:flutter/foundation.dart';

class AppEnvironment {
  const AppEnvironment._();

  static bool get devToolsEnabled => kDebugMode;
}
