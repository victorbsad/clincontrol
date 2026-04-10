import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/client.dart';
import '../models/service.dart';

class DbHelper {

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = kIsWeb
        ? 'clincontrol.db'
        : join(await getDatabasesPath(), 'clincontrol.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clients (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE services (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL,
            procedure TEXT NOT NULL,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            FOREIGN KEY (client_id) REFERENCES clients(id)
          )
        ''');
      },
    );
  }

  // ----------CLIENTS--------------------------------------------------

  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', {
      'name': client.name,
      'phone': client.phone,
      'notes': client.notes,
    });
  }


  Future<List<Client>> fetchClients() async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query('clients');

    return rows.map((map) => Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      notes: map['notes'],
    )).toList();
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      {
        'name': client.name,
        'phone': client.phone,
        'notes': client.notes,
      },
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── SERVICES ─────────────────────────────────────

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
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM services
      WHERE strftime('%m', date) = ?
      AND strftime('%Y', date) = ?
    ''', [month.toString().padLeft(2, '0'), year.toString()]);

    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> fetchMonthlyCount(int month, int year) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM services
      WHERE strftime('%m', date) = ?
      AND strftime('%Y', date) = ?  
    ''', [month.toString().padLeft(2, '0'), year.toString()]);

    return result.first['count'] as int? ?? 0;
  }

}