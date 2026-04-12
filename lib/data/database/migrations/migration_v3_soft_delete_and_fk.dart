import 'package:sqflite/sqflite.dart';

import 'database_migration.dart';

class MigrationV3SoftDeleteAndFk implements DatabaseMigration {
  @override
  int get targetVersion => 3;

  @override
  Future<void> apply(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');

    try {
      final clientColumns = await db.rawQuery('PRAGMA table_info(clients)');
      final hasDeletedAt = clientColumns.any(
        (column) => column['name'] == 'deleted_at',
      );

      if (!hasDeletedAt) {
        await db.execute('ALTER TABLE clients ADD COLUMN deleted_at TEXT');
      }

      await db.execute('''
        CREATE TABLE services_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER NOT NULL,
          procedure TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        INSERT INTO services_new (id, client_id, procedure, amount, date)
        SELECT id, client_id, procedure, amount, date
        FROM services
      ''');

      await db.execute('DROP TABLE services');
      await db.execute('ALTER TABLE services_new RENAME TO services');

      final anamnesesTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'anamneses'",
      );

      if (anamnesesTable.isNotEmpty) {
        await db.execute('''
          CREATE TABLE anamneses_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          INSERT INTO anamneses_new (id, client_id, created_at, updated_at)
          SELECT id, client_id, created_at, updated_at
          FROM anamneses
        ''');

        await db.execute('DROP TABLE anamneses');
        await db.execute('ALTER TABLE anamneses_new RENAME TO anamneses');
      }
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }
}
