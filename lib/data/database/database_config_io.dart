import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void configureDatabaseFactory() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}