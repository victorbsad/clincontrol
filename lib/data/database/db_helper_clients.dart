part of 'db_helper.dart';

extension DbHelperClientOperations on DbHelper {
  Map<String, Object?> _clientToDbMap(Client client, {bool includeDeletedAt = true}) {
    final map = <String, Object?>{
      'name': client.name,
      'phone': client.phone,
      'notes': client.notes,
      'marital_status': client.maritalStatus,
      'nationality': client.nationality,
      'address': client.address,
      'whatsapp': client.whatsapp,
      'email': client.email,
      'date_of_birth': client.dateOfBirth,
      'age': client.age,
      'profession': client.profession,
    };

    if (includeDeletedAt) {
      map['deleted_at'] = client.deletedAt?.toIso8601String();
    }

    return map;
  }

  Client _clientFromDbMap(Map<String, Object?> map) {
    return Client(
      id: map['id'] as int?,
      name: (map['name'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      notes: (map['notes'] as String?) ?? '',
      maritalStatus: (map['marital_status'] as String?) ?? '',
      nationality: (map['nationality'] as String?) ?? '',
      address: (map['address'] as String?) ?? '',
      whatsapp: (map['whatsapp'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      dateOfBirth: (map['date_of_birth'] as String?) ?? '',
      age: (map['age'] as String?) ?? '',
      profession: (map['profession'] as String?) ?? '',
      deletedAt: map['deleted_at'] != null
          ? DateTime.tryParse(map['deleted_at'] as String)
          : null,
    );
  }

  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', _clientToDbMap(client));
  }

  Future<List<Client>> fetchClients({bool includeDeleted = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'clients',
      where: includeDeleted ? null : 'deleted_at IS NULL',
    );

    return rows.map(_clientFromDbMap).toList();
  }

  Future<Client?> fetchClientById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'clients',
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _clientFromDbMap(rows.first);
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      _clientToDbMap(client, includeDeletedAt: false),
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.update(
      'clients',
      {'deleted_at': DateTime.now().toIso8601String()},
      where: 'id = ? AND deleted_at IS NULL',
      whereArgs: [id],
    );
  }

  Future<int> purgeClient(int id) async {
    final db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
