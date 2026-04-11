import '../database/db_helper.dart';
import '../models/client.dart';

class ClientRepository {
  final DbHelper _db = DbHelper();

  Future<int> save(Client client) => _db.insertClient(client);
  Future<List<Client>> findAll({bool includeDeleted = false}) =>
      _db.fetchClients(includeDeleted: includeDeleted);
  Future<Client?> findById(int id) => _db.fetchClientById(id);
  Future<int> update(Client client) => _db.updateClient(client);
  Future<int> delete(int id) => _db.deleteClient(id);
  Future<int> purge(int id) => _db.purgeClient(id);
}