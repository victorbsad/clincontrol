import '../database/db_helper.dart';
import '../models/client.dart';

class ClientRepository {
  final DbHelper _db = DbHelper();

  Future<int> save(Client client) => _db.insertClient(client);
  Future<List<Client>> findAll() => _db.fetchClients();
  Future<int> update(Client client) => _db.updateClient(client);
  Future<int> delete(int id) => _db.deleteClient(id);
}