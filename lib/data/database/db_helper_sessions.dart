part of 'db_helper.dart';

extension DbHelperSessionOperations on DbHelper {
  Session _sessionFromDbRow(Map<String, Object?> row) {
    return Session(
      id: row['id'] as int?,
      clientId: row['client_id'] as int,
      procedure: (row['procedure'] as String?) ?? '',
      notes: (row['notes'] as String?) ?? '',
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      date: (row['date'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((row['updated_at'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Future<int> insertSession(Session session) async {
    final db = await database;
    return await db.insert('sessions', {
      'client_id': session.clientId,
      'procedure': session.procedure,
      'notes': session.notes,
      'amount': session.amount,
      'date': session.date,
      'created_at': session.createdAt.toIso8601String(),
      'updated_at': session.updatedAt.toIso8601String(),
    });
  }

  Future<List<Session>> fetchSessionsByClient(int clientId) async {
    final db = await database;
    final rows = await db.query(
      'sessions',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'date DESC, id DESC',
    );

    return rows.map(_sessionFromDbRow).toList();
  }

  Future<Session?> fetchSessionById(int id) async {
    final db = await database;
    final rows = await db.query(
      'sessions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _sessionFromDbRow(rows.first);
  }

  Future<int> updateSession(Session session) async {
    final db = await database;
    return await db.update(
      'sessions',
      {
        'client_id': session.clientId,
        'procedure': session.procedure,
        'notes': session.notes,
        'amount': session.amount,
        'date': session.date,
        'updated_at': session.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return await db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }
}
