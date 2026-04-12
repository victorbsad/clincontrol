import 'package:sqflite/sqflite.dart';

import 'database_migration.dart';

class MigrationV9AddStatusToSessions implements DatabaseMigration {
  @override
  int get targetVersion => 9;

  @override
  Future<void> apply(Database db) async {
    final tableInfo = await db.rawQuery("PRAGMA table_info('sessions')");
    final hasStatusColumn = tableInfo.any((row) => row['name'] == 'status');

    if (!hasStatusColumn) {
      await db.execute(
        "ALTER TABLE sessions ADD COLUMN status TEXT NOT NULL DEFAULT 'AGENDADO'",
      );

      await db.execute('''
        UPDATE sessions
        SET status = CASE
          WHEN paid = 1 THEN 'PAGO'
          ELSE 'AGENDADO'
        END
      ''');
    }
  }
}
