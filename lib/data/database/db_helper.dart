import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/client.dart';
import '../models/anamnesis.dart';
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
      version: 3,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createBaseSchema(db);
        await _createAnamnesisSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createAnamnesisSchema(db);
        }
        if (oldVersion < 3) {
          await _migrateToV3(db);
        }
      },
    );
  }

  Future<void> _createBaseSchema(Database db) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        notes TEXT,
        deleted_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        procedure TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createAnamnesisSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS anamneses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS anamnesis_answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        anamnesis_id INTEGER NOT NULL,
        field_key TEXT NOT NULL,
        value TEXT NOT NULL,
        value_type TEXT NOT NULL,
        FOREIGN KEY (anamnesis_id) REFERENCES anamneses(id) ON DELETE CASCADE,
        UNIQUE(anamnesis_id, field_key)
      )
    ''');
  }

  Future<void> _migrateToV3(Database db) async {
    await db.execute('PRAGMA foreign_keys = OFF');

    try {
      final clientColumns = await db.rawQuery("PRAGMA table_info(clients)");
      final hasDeletedAt = clientColumns.any((column) => column['name'] == 'deleted_at');

      if (!hasDeletedAt) {
        await db.execute('ALTER TABLE clients ADD COLUMN deleted_at TEXT');
      }

      await db.execute('''
        CREATE TABLE services_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          client_id INTEGER NOT NULL,
          procedure TEXT NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        INSERT INTO services_new (id, client_id, procedure, amount, date)
        SELECT id, client_id, procedure, amount, date
        FROM services
      ''');

      await db.execute('DROP TABLE services');
      await db.execute('ALTER TABLE services_new RENAME TO services');

      final anamnesesTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'anamneses'",
      );

      if (anamnesesTable.isNotEmpty) {
        await db.execute('''
          CREATE TABLE anamneses_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            client_id INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          INSERT INTO anamneses_new (id, client_id, created_at, updated_at)
          SELECT id, client_id, created_at, updated_at
          FROM anamneses
        ''');

        await db.execute('DROP TABLE anamneses');
        await db.execute('ALTER TABLE anamneses_new RENAME TO anamneses');
      }
    } finally {
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  // ----------ANAMNESIS----------------------------------------------

  Future<int> insertAnamnesis(Anamnesis anamnesis) async {
    final db = await database;
    final createdAt = anamnesis.createdAt;
    final normalizedUpdatedAt = anamnesis.updatedAt.isBefore(createdAt)
        ? createdAt
        : anamnesis.updatedAt;

    return await db.transaction((txn) async {
      final anamnesisId = await txn.insert('anamneses', {
        'client_id': anamnesis.clientId,
        'created_at': createdAt.toIso8601String(),
        'updated_at': normalizedUpdatedAt.toIso8601String(),
      });

      for (final entry in _normalizeAnswers(anamnesis.answers)) {
        await txn.insert('anamnesis_answers', {
          'anamnesis_id': anamnesisId,
          'field_key': entry.key,
          'value': entry.value.value,
          'value_type': entry.value.type,
        });
      }

      return anamnesisId;
    });
  }

  Future<List<Anamnesis>> fetchAnamnesesByClient(int clientId) async {
    final db = await database;
    final anamnesisRows = await db.query(
      'anamneses',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );

    if (anamnesisRows.isEmpty) return [];

    final ids = anamnesisRows.map((row) => row['id'] as int).toList();
    final answerRows = await db.query(
      'anamnesis_answers',
      where: 'anamnesis_id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );

    final answersByAnamnesisId = <int, Map<String, dynamic>>{};
    for (final row in answerRows) {
      final anamnesisId = row['anamnesis_id'] as int;
      answersByAnamnesisId.putIfAbsent(anamnesisId, () => {});
      answersByAnamnesisId[anamnesisId]![row['field_key'] as String] =
          _decodeStoredValue(row['value'] as String, row['value_type'] as String);
    }

    return anamnesisRows.map((row) {
      final anamnesisId = row['id'] as int;
      return Anamnesis(
        id: anamnesisId,
        clientId: row['client_id'] as int,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
        answers: answersByAnamnesisId[anamnesisId] ?? {},
      );
    }).toList();
  }

  Future<Anamnesis?> fetchAnamnesis(int id) async {
    final db = await database;
    final rows = await db.query(
      'anamneses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final answers = await db.query(
      'anamnesis_answers',
      where: 'anamnesis_id = ?',
      whereArgs: [id],
    );

    final map = <String, dynamic>{};
    for (final row in answers) {
      map[row['field_key'] as String] =
          _decodeStoredValue(row['value'] as String, row['value_type'] as String);
    }

    final row = rows.first;
    return Anamnesis(
      id: row['id'] as int,
      clientId: row['client_id'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
      answers: map,
    );
  }

  Future<int> updateAnamnesis(Anamnesis anamnesis) async {
    if (anamnesis.id == null) {
      throw ArgumentError('Anamnesis ID is required for update');
    }

    final db = await database;
    final updatedAt = DateTime.now().toIso8601String();

    return await db.transaction((txn) async {
      await txn.update(
        'anamneses',
        {
          'client_id': anamnesis.clientId,
          'updated_at': updatedAt,
        },
        where: 'id = ?',
        whereArgs: [anamnesis.id],
      );

      await txn.delete(
        'anamnesis_answers',
        where: 'anamnesis_id = ?',
        whereArgs: [anamnesis.id],
      );

      for (final entry in _normalizeAnswers(anamnesis.answers)) {
        await txn.insert('anamnesis_answers', {
          'anamnesis_id': anamnesis.id,
          'field_key': entry.key,
          'value': entry.value.value,
          'value_type': entry.value.type,
        });
      }

      return anamnesis.id!;
    });
  }

  Future<int> deleteAnamnesis(int id) async {
    final db = await database;
    return await db.transaction((txn) async {
      await txn.delete('anamnesis_answers', where: 'anamnesis_id = ?', whereArgs: [id]);
      return await txn.delete('anamneses', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<void> seedDevelopmentData() async {
    final db = await database;

    final existingClient = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (existingClient.isEmpty) {
      await db.insert('clients', {
        'id': 1,
        'name': 'Cliente Teste',
        'phone': '(54) 99999-1234',
        'notes': 'Seed criada para teste do PDF de anamnese.',
      });
    }

    final sampleAnswers = <String, dynamic>{
      'estadoCivil': 'Solteira',
      'nacionalidade': 'Brasileira',
      'endereco': 'Rua das Flores, 123 - Centro',
      'telefone': '(54) 99999-1234',
      'whatsapp': '(54) 99999-1234',
      'email': 'cliente.teste@exemplo.com',
      'dataNascimento': '1991-07-18',
      'idade': 34,
      'profissao': 'Empresária',
      'motivoVisita': 'Acne, Manchas e Linhas de expressão',
      'tratamentoEstetico': true,
      'qualTratamentoEstetico': 'Limpeza de pele mensal',
      'cicatrizacaoQuelóide': false,
      'cicatrizacaoComentario': 'Cicatrização normal',
      'usaMedicamento': true,
      'qualMedicamento': 'Vitamina D',
      'isotretinoina6m': false,
      'isotretinoina6mObs': 'Sem uso nos últimos 6 meses',
      'tratamentoMedico': true,
      'qualProblemaSaude': 'Acompanhamento dermatológico',
      'trombose': false,
      'localTrombose': '',
      'cirurgia': true,
      'qualCirurgia': 'Apêndice',
      'oncologico': false,
      'oncologicoObs': 'Sem antecedentes oncológicos',
      'infectocontagiosa': false,
      'qualInfectocontagiosa': '',
      'esporte': true,
      'esporteObs': 'Pilates 3x por semana',
      'alimentacaoBalanceada': true,
      'alimentacaoObs': 'Predomínio de alimentos naturais e baixo ultraprocessado',
      'agua2l': true,
      'quantosLitrosAgua': '2,5 litros',
      'alcool': false,
      'frequenciaAlcool': '',
      'drogas': false,
      'qualSubstancia': '',
      'disturbioHormonal': false,
      'qualDisturbioHormonal': '',
      'fumaOuFumou': 'Nunca fumou',
      'tempoTabagismo': '',
      'dormeBem': true,
      'horasSono': '7 horas',
      'intestinoRegular': true,
      'intestinoObs': 'Regular',
      'pressao': 'SIM',
      'pressaoCompensada': 'Hipotensão compensada',
      'diabetes': false,
      'diabetesCompensada': 'não se aplica',
      'cardiaco': false,
      'qualCardiaco': '',
      'depressao': false,
      'tratamentoDepressao': false,
      'epilepsia': false,
      'epilepsiaObs': 'Sem histórico',
      'placasPinos': false,
      'ondePlacasPinos': '',
      'protesesDentarias': false,
      'protesesObs': 'Não utiliza',
      'lentesContato': true,
      'lentesObs': 'Lentes gelatinosas diárias',
      'acidosPele': true,
      'qualAcido': 'Ácido glicólico',
      'cosmeticos': true,
      'quaisCosmeticos': 'Hidratante facial e sérum antioxidante',
      'protetorSolar': true,
      'qualProtetorSolar': 'FPS 70 oil free',
      'frequenciaProtetorSolar': 'Diariamente',
      'tomaSol': false,
      'frequenciaSol': '',
      'maquiagemDefinitiva': false,
      'localMaquiagemDefinitiva': '',
      'toxinaBotulinica': true,
      'localToxina': 'Testa e glabela',
      'alergias': 'Frutos do mar e níquel',
      'gestante': false,
      'mesesGestacao': '',
      'filhos': true,
      'quantidadeFilhos': '2',
      'cicloRegular': true,
      'obsCiclo': 'Sem queixas relevantes',
      'herpes': true,
      'tempoHerpes': '2 anos',
      'anticoncepcional': true,
      'qualAnticoncepcional': 'Pílula combinada',
      'hormonio': false,
      'qualHormônio': '',
      'autorizacaoFoto': true,
      'autorizacaoFotoObs': 'Autorização apenas para prontuário interno',
      'estrogenioObs': 'Paciente relata não usar estrogênio',
      'peleOleosaSensivel': true,
      'peleOleosaResistente': false,
      'peleOleosaPigmentada': true,
      'peleOleosaNaoPigmentada': false,
      'peleOleosaFirme': true,
      'peleOleosaRugas': false,
      'peleSecaSensivel': false,
      'peleSecaResistente': false,
      'peleSecaPigmentada': false,
      'peleSecaNaoPigmentada': false,
      'peleSecaFirme': false,
      'peleSecaRugas': false,
      'peleMistaSensivel': false,
      'peleMistaResistente': true,
      'peleMistaPigmentada': true,
      'peleMistaNaoPigmentada': false,
      'peleMistaFirme': true,
      'peleMistaRugas': false,
      'comedao': true,
      'pustula': false,
      'papula': true,
      'nodulo': false,
      'hiperqueratinizacao': true,
      'milium': false,
      'microcisto': false,
      'acneInflamatoria': false,
      'acneNaoInflamatoria': true,
      'telangiectasiaNevo': false,
      'queratoseActinica': false,
      'nevoMelanocitico': true,
      'dermatosePapulosaNigra': false,
      'papiloma': false,
      'acrocordon': false,
      'outrasLesoes': 'Sem outras lesões relevantes',
      'hiperpigmentacaoInflamatoria': true,
      'fotoenvelhecimento': true,
      'melasma': true,
      'efelides': false,
      'hiperpigmentacaoOrbicular': true,
      'hipocromia': false,
      'discromiaJustificativa': 'Aumento após exposição solar sem reaplicação de protetor',
      'fototipo': 'III - Moreno Claro - bronzeia moderadamente',
      'dermatite': false,
      'psoriase': false,
      'tratamentoIndicado': 'Protocolo clareador + controle de oleosidade',
      'numeroSessoes': '8',
      'sessao1Data': '10/04/2026',
      'sessao1': 'Avaliação inicial e higienização profunda',
      'sessao2Data': '17/04/2026',
      'sessao2': 'Peeling enzimático suave',
      'sessao3Data': '24/04/2026',
      'sessao3': 'LED âmbar + máscara calmante',
      'sessao4Data': '01/05/2026',
      'sessao4': 'Peeling químico superficial',
      'sessao5Data': '08/05/2026',
      'sessao5': 'Extração de comedões',
      'sessao6Data': '15/05/2026',
      'sessao6': 'Máscara despigmentante',
      'sessao7Data': '22/05/2026',
      'sessao7': 'Laser de baixa intensidade',
      'sessao8Data': '29/05/2026',
      'sessao8': 'Hidratação profunda',
      'sessao9Data': '05/06/2026',
      'sessao9': 'Reforço clareador',
      'sessao10Data': '12/06/2026',
      'sessao10': 'Avaliação final e manutenção',
      'prescricaoCosmetica': 'Sabonete glicólico noturno, sérum vitamina C manhã e FPS 70 reaplicar 3x/dia',
    };

    final existingAnamnesis = await fetchAnamnesesByClient(1);
    if (existingAnamnesis.isNotEmpty) {
      final current = existingAnamnesis.first;
      await updateAnamnesis(
        Anamnesis(
          id: current.id,
          clientId: 1,
          createdAt: current.createdAt,
          updatedAt: DateTime.now(),
          answers: sampleAnswers,
        ),
      );
      return;
    }

    await insertAnamnesis(
      Anamnesis(
        clientId: 1,
        createdAt: DateTime(2026, 4, 10, 9, 30),
        updatedAt: DateTime(2026, 4, 10, 9, 30),
        answers: sampleAnswers,
      ),
    );
  }

  Iterable<MapEntry<String, StoredAnamnesisAnswer>> _normalizeAnswers(Map<String, dynamic> answers) sync* {
    for (final entry in answers.entries) {
      final value = entry.value;

      if (value == null) continue;
      if (value is String && value.trim().isEmpty) continue;
      if (value is Iterable && value.isEmpty) continue;
      if (value is Map && value.isEmpty) continue;

      if (value is bool) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toString(), 'bool'));
      } else if (value is int) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toString(), 'int'));
      } else if (value is double) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toString(), 'double'));
      } else if (value is DateTime) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toIso8601String(), 'datetime'));
      } else if (value is Iterable) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(jsonEncode(value.toList()), 'json'));
      } else if (value is Map) {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(jsonEncode(value), 'json'));
      } else {
        yield MapEntry(entry.key, StoredAnamnesisAnswer(value.toString(), 'text'));
      }
    }
  }

  dynamic _decodeStoredValue(String value, String type) {
    switch (type) {
      case 'bool':
        return value == 'true';
      case 'int':
        return int.tryParse(value);
      case 'double':
        return double.tryParse(value);
      case 'datetime':
        return DateTime.tryParse(value);
      case 'json':
        return jsonDecode(value);
      default:
        return value;
    }
  }

  // ----------CLIENTS--------------------------------------------------

  Future<int> insertClient(Client client) async {
    final db = await database;
    return await db.insert('clients', {
      'name': client.name,
      'phone': client.phone,
      'notes': client.notes,
      'deleted_at': client.deletedAt?.toIso8601String(),
    });
  }


  Future<List<Client>> fetchClients({bool includeDeleted = false}) async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query(
      'clients',
      where: includeDeleted ? null : 'deleted_at IS NULL',
    );

    return rows.map((map) => Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      notes: map['notes'],
      deletedAt: map['deleted_at'] != null
          ? DateTime.tryParse(map['deleted_at'] as String)
          : null,
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