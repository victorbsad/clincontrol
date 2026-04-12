import 'package:sqflite/sqflite.dart';

import 'database_migration.dart';

class MigrationV8AddPaidToSessions implements DatabaseMigration {
  @override
  int get targetVersion => 8;

  @override
  Future<void> apply(Database db) async {
    final tableInfo = await db.rawQuery("PRAGMA table_info('sessions')");
    final hasPaidColumn = tableInfo.any((row) => row['name'] == 'paid');

    if (!hasPaidColumn) {
      await db.execute(
        'ALTER TABLE sessions ADD COLUMN paid INTEGER NOT NULL DEFAULT 0 CHECK (paid IN (0, 1))',
      );
    }
  }
}
