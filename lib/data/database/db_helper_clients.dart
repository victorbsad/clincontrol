part of 'db_helper.dart';

extension DbHelperClientOperations on DbHelper {
  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', {
      'name': client.name,
      'phone': client.phone,
      'notes': client.notes,
      'maritalStatus': client.maritalStatus,
      'nationality': client.nationality,
      'address': client.address,
      'whatsapp': client.whatsapp,
      'email': client.email,
      'dateOfBirth': client.dateOfBirth,
      'age': client.age,
      'profession': client.profession,
      'deleted_at': client.deletedAt?.toIso8601String(),
    });
  }

  Future<List<Client>> fetchClients({bool includeDeleted = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'clients',
      where: includeDeleted ? null : 'deleted_at IS NULL',
    );

    return rows
        .map(
          (map) => Client(
            id: map['id'],
            name: map['name'],
            phone: map['phone'] ?? '',
            notes: map['notes'] ?? '',
            maritalStatus: map['maritalStatus'] ?? '',
            nationality: map['nationality'] ?? '',
            address: map['address'] ?? '',
            whatsapp: map['whatsapp'] ?? '',
            email: map['email'] ?? '',
            dateOfBirth: map['dateOfBirth'] ?? '',
            age: map['age'] ?? '',
            profession: map['profession'] ?? '',
            deletedAt: map['deleted_at'] != null
                ? DateTime.tryParse(map['deleted_at'] as String)
                : null,
          ),
        )
        .toList();
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
    final map = rows.first;
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'] ?? '',
      notes: map['notes'] ?? '',
      maritalStatus: map['maritalStatus'] ?? '',
      nationality: map['nationality'] ?? '',
      address: map['address'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      email: map['email'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      age: map['age'] ?? '',
      profession: map['profession'] ?? '',
      deletedAt: map['deleted_at'] != null
          ? DateTime.tryParse(map['deleted_at'] as String)
          : null,
    );
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      {
        'name': client.name,
        'phone': client.phone,
        'notes': client.notes,
        'maritalStatus': client.maritalStatus,
        'nationality': client.nationality,
        'address': client.address,
        'whatsapp': client.whatsapp,
        'email': client.email,
        'dateOfBirth': client.dateOfBirth,
        'age': client.age,
        'profession': client.profession,
      },
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
