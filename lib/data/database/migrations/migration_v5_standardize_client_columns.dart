import 'package:sqflite/sqflite.dart';

import 'database_migration.dart';

class MigrationV5StandardizeClientColumns implements DatabaseMigration {
  @override
  int get targetVersion => 5;

  @override
  Future<void> apply(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');

    try {
      final clientColumns = await db.rawQuery('PRAGMA table_info(clients)');
      final existingColumns = clientColumns
          .map((column) => column['name'] as String)
          .toSet();

      final hasCanonicalColumns =
          existingColumns.contains('marital_status') &&
          existingColumns.contains('date_of_birth');

      if (hasCanonicalColumns) {
        return;
      }

      final maritalStatusSource = _resolveSourceColumn(
        existingColumns,
        ['marital_status', 'maritalStatus'],
      );
      final dateOfBirthSource = _resolveSourceColumn(
        existingColumns,
        ['date_of_birth', 'dateOfBirth'],
      );

      await db.execute('''
        CREATE TABLE clients_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          notes TEXT,
          marital_status TEXT,
          nationality TEXT,
          address TEXT,
          whatsapp TEXT,
          email TEXT,
          date_of_birth TEXT,
          age TEXT,
          profession TEXT,
          deleted_at TEXT
        )
      ''');

      await db.execute('''
        INSERT INTO clients_new (
          id,
          name,
          phone,
          notes,
          marital_status,
          nationality,
          address,
          whatsapp,
          email,
          date_of_birth,
          age,
          profession,
          deleted_at
        )
        SELECT
          id,
          name,
          phone,
          notes,
          $maritalStatusSource,
          nationality,
          address,
          whatsapp,
          email,
          $dateOfBirthSource,
          age,
          profession,
          deleted_at
        FROM clients
      ''');

      await db.execute('DROP TABLE clients');
      await db.execute('ALTER TABLE clients_new RENAME TO clients');
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  String _resolveSourceColumn(
    Set<String> existingColumns,
    List<String> candidateColumns,
  ) {
    for (final column in candidateColumns) {
      if (existingColumns.contains(column)) {
        return column;
      }
    }

    return 'NULL';
  }
}