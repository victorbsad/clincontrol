import 'package:sqflite/sqflite.dart';

import 'database_migration.dart';
import 'migration_v2_anamnesis_schema.dart';
import 'migration_v3_soft_delete_and_fk.dart';
import 'migration_v5_standardize_client_columns.dart';
import 'migration_v6_rebuild_anamnesis_schema.dart';
import 'migration_v7_create_sessions_schema.dart';
import 'migration_v8_add_paid_to_sessions.dart';
import 'migration_v9_add_status_to_sessions.dart';

class DatabaseMigrationRunner {
  const DatabaseMigrationRunner._();

  static final List<DatabaseMigration> _migrations = [
    MigrationV2AnamnesisSchema(),
    MigrationV3SoftDeleteAndFk(),
    MigrationV5StandardizeClientColumns(),
    MigrationV6RebuildAnamnesisSchema(),
    MigrationV7CreateSessionsSchema(),
    MigrationV8AddPaidToSessions(),
    MigrationV9AddStatusToSessions(),
  ];

  static Future<void> run(Database db, int oldVersion, int newVersion) async {
    final pending =
        _migrations
            .where(
              (migration) =>
                  migration.targetVersion > oldVersion &&
                  migration.targetVersion <= newVersion,
            )
            .toList()
          ..sort((a, b) => a.targetVersion.compareTo(b.targetVersion));

    for (final migration in pending) {
      await migration.apply(db);
    }
  }
}
