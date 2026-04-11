import '../database/db_helper.dart';
import '../models/anamnesis.dart';

class AnamnesisRepository {
  final DbHelper _db = DbHelper();

  Future<int> save(Anamnesis anamnesis) => _db.insertAnamnesis(anamnesis);
  Future<int> update(Anamnesis anamnesis) => _db.updateAnamnesis(anamnesis);
  Future<List<Anamnesis>> findByClientId(int clientId) => _db.fetchAnamnesesByClient(clientId);
  Future<Anamnesis?> findById(int id) => _db.fetchAnamnesis(id);
  Future<int> delete(int id) => _db.deleteAnamnesis(id);
}