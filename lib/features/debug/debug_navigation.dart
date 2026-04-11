import 'package:flutter/material.dart';

import '../../core/config/app_environment.dart';
import 'screens/crud_test_page.dart';

class DebugNavigation {
  const DebugNavigation._();

  static Future<void> openCrudLab(BuildContext context) async {
    if (!AppEnvironment.devToolsEnabled) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CrudTestPage()),
    );
  }
}
