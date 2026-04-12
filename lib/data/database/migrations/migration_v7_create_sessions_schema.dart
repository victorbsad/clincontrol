import 'package:sqflite/sqflite.dart';

import 'database_migration.dart';

class MigrationV7CreateSessionsSchema implements DatabaseMigration {
  @override
  int get targetVersion => 7;

  @override
  Future<void> apply(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        procedure TEXT NOT NULL,
        notes TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
        CHECK (amount >= 0)
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_client_id ON sessions(client_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_sessions_date ON sessions(date)',
    );
  }
}
