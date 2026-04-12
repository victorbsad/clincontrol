import '../database/db_helper.dart';
import '../models/session.dart';

class SessionRepository {
  final DbHelper _db = DbHelper();

  Future<int> save(Session session) => _db.insertSession(session);
  Future<Session?> findById(int id) => _db.fetchSessionById(id);
  Future<List<Session>> findByClientId(int clientId) =>
      _db.fetchSessionsByClient(clientId);
  Future<int> update(Session session) => _db.updateSession(session);
  Future<int> delete(int id) => _db.deleteSession(id);
}
