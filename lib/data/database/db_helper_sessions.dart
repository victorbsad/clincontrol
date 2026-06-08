part of 'db_helper.dart';

extension DbHelperSessionOperations on DbHelper {
  Session _sessionFromDbRow(Map<String, Object?> row) {
    final rawStatus = row['status'] as String?;
    final parsedStatus =
        rawStatus != null && Session.allowedStatuses.contains(rawStatus)
        ? rawStatus
        : Session.statusScheduled;

    return Session(
      id: row['id'] as int?,
      clientId: row['client_id'] as int,
      procedure: (row['procedure'] as String?) ?? '',
      notes: (row['notes'] as String?) ?? '',
      amount: (row['amount'] as num?)?.toDouble() ?? 0,
      status: parsedStatus,
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
      'status': session.status,
      'date': session.date,
      'created_at': session.createdAt.toIso8601String(),
      'updated_at': session.updatedAt.toIso8601String(),
    });
  }

  Future<List<Session>> fetchSessionsByClient(
    int clientId, {
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    final db = await database;

    final whereClauses = <String>['client_id = ?'];
    final whereArgs = <Object>[clientId];

    if (status != null && Session.allowedStatuses.contains(status)) {
      whereClauses.add('status = ?');
      whereArgs.add(status);
    }

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate);
    }

    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate);
    }

    final rows = await db.query(
      'sessions',
      where: whereClauses.join(' AND '),
      whereArgs: whereArgs,
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
        'status': session.status,
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

  Future<double> fetchSessionsMonthlyTotal(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM sessions
      WHERE strftime('%m', date) = ?
      AND strftime('%Y', date) = ?
    ''',
      [month.toString().padLeft(2, '0'), year.toString()],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> fetchSessionsMonthlyCount(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM sessions
      WHERE strftime('%m', date) = ?
      AND strftime('%Y', date) = ?
    ''',
      [month.toString().padLeft(2, '0'), year.toString()],
    );

    return result.first['count'] as int? ?? 0;
  }

  Future<List<Session>> fetchSessionsByDateRange(
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final rows = await db.query(
      'sessions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date ASC, id ASC',
    );

    return rows.map(_sessionFromDbRow).toList();
  }
}
