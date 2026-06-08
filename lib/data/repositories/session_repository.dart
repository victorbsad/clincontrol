import '../database/db_helper.dart';
import '../models/session.dart';

class SessionRepository {
  final DbHelper _db = DbHelper();

  Future<int> save(Session session) => _db.insertSession(session);
  Future<Session?> findById(int id) => _db.fetchSessionById(id);
  Future<List<Session>> findByClientId(
    int clientId, {
    String? status,
    String? startDate,
    String? endDate,
  }) => _db.fetchSessionsByClient(
    clientId,
    status: status,
    startDate: startDate,
    endDate: endDate,
  );
  Future<double> getMonthlyTotal(int month, int year) =>
      _db.fetchSessionsMonthlyTotal(month, year);
  Future<int> getMonthlyCount(int month, int year) =>
      _db.fetchSessionsMonthlyCount(month, year);
  Future<int> update(Session session) => _db.updateSession(session);
  Future<int> delete(int id) => _db.deleteSession(id);
  
  Future<List<Session>> findByDateRange(String startDate, String endDate) =>
      _db.fetchSessionsByDateRange(startDate, endDate);
}
