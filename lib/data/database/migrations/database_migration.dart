import 'package:sqflite/sqflite.dart';

abstract class DatabaseMigration {
  int get targetVersion;

  Future<void> apply(Database db);
}
