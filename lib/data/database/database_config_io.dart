import 'dart:io' show Platform;

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void configureDatabaseFactory() {
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}