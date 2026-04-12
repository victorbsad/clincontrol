part of 'db_helper.dart';

extension DbHelperUserOperations on DbHelper {
  AppUser _userFromDbRow(Map<String, Object?> row) {
    return AppUser(
      id: row['id'] as int?,
      name: (row['name'] as String?) ?? '',
      email: (row['email'] as String?) ?? '',
      passwordHash: (row['password_hash'] as String?) ?? '',
      isCurrent: ((row['is_current'] as num?)?.toInt() ?? 0) == 1,
      createdAt:
          DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((row['updated_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Future<void> _ensureUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        is_current INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        CHECK (is_current IN (0, 1))
      )
    ''');

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_users_is_current ON users(is_current)',
    );
  }

  Future<AppUser?> fetchUserByEmail(String email) async {
    final db = await database;
    await _ensureUsersTable(db);

    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _userFromDbRow(rows.first);
  }

  Future<int> insertUser(AppUser user) async {
    final db = await database;
    await _ensureUsersTable(db);

    return await db.insert('users', {
      'name': user.name,
      'email': user.email,
      'password_hash': user.passwordHash,
      'is_current': user.isCurrent ? 1 : 0,
      'created_at': user.createdAt.toIso8601String(),
      'updated_at': user.updatedAt.toIso8601String(),
    });
  }

  Future<int> updateUser(AppUser user) async {
    final db = await database;
    await _ensureUsersTable(db);

    return await db.update(
      'users',
      {
        'name': user.name,
        'email': user.email,
        'password_hash': user.passwordHash,
        'is_current': user.isCurrent ? 1 : 0,
        'updated_at': user.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> clearCurrentUser() async {
    final db = await database;
    await _ensureUsersTable(db);

    await db.update(
      'users',
      {'is_current': 0, 'updated_at': DateTime.now().toIso8601String()},
    );
  }

  Future<int> setCurrentUserById(int userId) async {
    final db = await database;
    await _ensureUsersTable(db);

    return await db.transaction((txn) async {
      final nowIso = DateTime.now().toIso8601String();
      await txn.update('users', {'is_current': 0, 'updated_at': nowIso});
      return await txn.update(
        'users',
        {'is_current': 1, 'updated_at': nowIso},
        where: 'id = ?',
        whereArgs: [userId],
      );
    });
  }

  Future<AppUser?> fetchCurrentUser() async {
    final db = await database;
    await _ensureUsersTable(db);

    final rows = await db.query(
      'users',
      where: 'is_current = 1',
      orderBy: 'updated_at DESC, id DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _userFromDbRow(rows.first);
  }
}
