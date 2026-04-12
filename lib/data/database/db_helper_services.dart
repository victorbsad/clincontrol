part of 'db_helper.dart';

extension DbHelperServiceOperations on DbHelper {
  Future<int> insertService(Service service) async {
    final db = await database;
    return await db.insert('services', {
      'client_id': service.clientId,
      'procedure': service.procedure,
      'amount': service.amount,
      'date': service.date,
    });
  }

  Future<double> fetchMonthlyTotal(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM services
      WHERE strftime('%m', date) = ?
      AND strftime('%Y', date) = ?
    ''',
      [month.toString().padLeft(2, '0'), year.toString()],
    );

    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> fetchMonthlyCount(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM services
      WHERE strftime('%m', date) = ?
      AND strftime('%Y', date) = ?
    ''',
      [month.toString().padLeft(2, '0'), year.toString()],
    );

    return result.first['count'] as int? ?? 0;
  }
}
