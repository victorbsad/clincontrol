import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/anamnesis_keys.dart';
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
      version: 2,
      onCreate: (db, version) async {
        await _createBaseSchema(db);
        await _createAnamnesisSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createAnamnesisSchema(db);
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
  }

  Future<void> _createAnamnesisSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS anamneses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id)
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

  // ----------ANAMNESIS----------------------------------------------

  Future<int> insertAnamnesis(Anamnesis anamnesis) async {
    final db = await database;
    final now = (anamnesis.createdAt).toIso8601String();

    return await db.transaction((txn) async {
      final anamnesisId = await txn.insert('anamneses', {
        'client_id': anamnesis.clientId,
        'created_at': now,
        'updated_at': now,
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
      final rawKey = row['field_key'] as String;
      final decodedValue = _decodeStoredValue(
        row['value'] as String,
        row['value_type'] as String,
      );

      answersByAnamnesisId.putIfAbsent(anamnesisId, () => {});
      answersByAnamnesisId[anamnesisId]![rawKey] = decodedValue;
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
      map[row['field_key'] as String] = _decodeStoredValue(
        row['value'] as String,
        row['value_type'] as String,
      );
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
        {'client_id': anamnesis.clientId, 'updated_at': updatedAt},
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
      await txn.delete(
        'anamnesis_answers',
        where: 'anamnesis_id = ?',
        whereArgs: [id],
      );
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
      AnamnesisKeys.maritalStatus: 'Solteira',
      AnamnesisKeys.nationality: 'Brasileira',
      AnamnesisKeys.address: 'Rua das Flores, 123 - Centro',
      AnamnesisKeys.phone: '(54) 99999-1234',
      AnamnesisKeys.whatsapp: '(54) 99999-1234',
      AnamnesisKeys.email: 'cliente.teste@exemplo.com',
      AnamnesisKeys.dateOfBirth: '1991-07-18',
      AnamnesisKeys.age: 34,
      AnamnesisKeys.profession: 'Empresária',
      AnamnesisKeys.visitReason: 'Acne, Manchas e Linhas de expressão',
      AnamnesisKeys.hadAestheticTreatment: true,
      AnamnesisKeys.aestheticTreatmentType: 'Limpeza de pele mensal',
      AnamnesisKeys.keloidScarring: false,
      AnamnesisKeys.scarringComment: 'Cicatrização normal',
      AnamnesisKeys.usesMedication: true,
      AnamnesisKeys.medicationType: 'Vitamina D',
      AnamnesisKeys.isotretinoin6Months: false,
      AnamnesisKeys.isotretinoin6MonthsComment: 'Sem uso nos últimos 6 meses',
      AnamnesisKeys.hadMedicalTreatment: true,
      AnamnesisKeys.healthProblemType: 'Acompanhamento dermatológico',
      AnamnesisKeys.thrombosis: false,
      AnamnesisKeys.thrombosisLocation: '',
      AnamnesisKeys.hadSurgery: true,
      AnamnesisKeys.surgeryType: 'Apêndice',
      AnamnesisKeys.hasOncologicalHistory: false,
      AnamnesisKeys.oncologicalComment: 'Sem antecedentes oncológicos',
      AnamnesisKeys.infectiousDiseaseHistory: false,
      AnamnesisKeys.infectiousDiseaseType: '',
      AnamnesisKeys.exercisesRegularly: true,
      AnamnesisKeys.exerciseType: 'Pilates 3x por semana',
      AnamnesisKeys.balancedDiet: true,
      AnamnesisKeys.dietComment:
          'Predomínio de alimentos naturais e baixo ultraprocessado',
      AnamnesisKeys.drinks2LitersWater: true,
      AnamnesisKeys.waterIntakeAmount: '2,5 litros',
      AnamnesisKeys.consumesAlcohol: false,
      AnamnesisKeys.alcoholFrequency: '',
      AnamnesisKeys.usesDrugs: false,
      AnamnesisKeys.drugType: '',
      AnamnesisKeys.hormoneImbalance: false,
      AnamnesisKeys.hormoneImbalanceType: '',
      AnamnesisKeys.smokeOrSmoked: 'Nunca fumou',
      AnamnesisKeys.smokingDuration: '',
      AnamnesisKeys.sleepsWell: true,
      AnamnesisKeys.sleepHours: '7 horas',
      AnamnesisKeys.regularBowelMovements: true,
      AnamnesisKeys.bowelComment: 'Regular',
      AnamnesisKeys.bloodPressure: 'SIM',
      AnamnesisKeys.bloodPressureControlled: 'Hipotensão compensada',
      AnamnesisKeys.hasDiabetes: false,
      AnamnesisKeys.diabetesControlled: 'não se aplica',
      AnamnesisKeys.hasCardiacCondition: false,
      AnamnesisKeys.cardiacConditionType: '',
      AnamnesisKeys.hasDepression: false,
      AnamnesisKeys.depressionTreatment: false,
      AnamnesisKeys.hasEpilepsy: false,
      AnamnesisKeys.epilepsyComment: 'Sem histórico',
      AnamnesisKeys.hasDentalImplants: false,
      AnamnesisKeys.dentalImplantLocation: '',
      AnamnesisKeys.hasDentures: false,
      AnamnesisKeys.denturesComment: 'Não utiliza',
      AnamnesisKeys.wearsContactLenses: true,
      AnamnesisKeys.contactLensesComment: 'Lentes gelatinosas diárias',
      AnamnesisKeys.usesAcids: true,
      AnamnesisKeys.acidType: 'Ácido glicólico',
      AnamnesisKeys.usesCosmeticProducts: true,
      AnamnesisKeys.cosmeticProductTypes:
          'Hidratante facial e sérum antioxidante',
      AnamnesisKeys.usesSunscreen: true,
      AnamnesisKeys.sunscreenType: 'FPS 70 oil free',
      AnamnesisKeys.sunscreenFrequency: 'Diariamente',
      AnamnesisKeys.exposedToSun: false,
      AnamnesisKeys.sunExposureFrequency: '',
      AnamnesisKeys.hasPermanentMakeup: false,
      AnamnesisKeys.permanentMakeupLocation: '',
      AnamnesisKeys.usedBotulinum: true,
      AnamnesisKeys.botulinumLocation: 'Testa e glabela',
      AnamnesisKeys.hasAllergies: 'Frutos do mar e níquel',
      AnamnesisKeys.isPregnant: false,
      AnamnesisKeys.pregnancyMonths: '',
      AnamnesisKeys.hasChildren: true,
      AnamnesisKeys.numberOfChildren: '2',
      AnamnesisKeys.regularMenstrualCycle: true,
      AnamnesisKeys.menstrualCycleComment: 'Sem queixas relevantes',
      AnamnesisKeys.hasHerpesHistory: true,
      AnamnesisKeys.herpesDuration: '2 anos',
      AnamnesisKeys.usesContraceptive: true,
      AnamnesisKeys.contraceptiveType: 'Pílula combinada',
      AnamnesisKeys.takesHormones: false,
      AnamnesisKeys.hormoneType: '',
      AnamnesisKeys.authorizedForPhotos: true,
      AnamnesisKeys.photoAuthorizationComment:
          'Autorização apenas para prontuário interno',
      AnamnesisKeys.estrogenComment: 'Paciente relata não usar estrogênio',
      AnamnesisKeys.oilySkinSensitive: true,
      AnamnesisKeys.oilySkinResistant: false,
      AnamnesisKeys.oilySkinPigmented: true,
      AnamnesisKeys.oilySkinNonPigmented: false,
      AnamnesisKeys.oilySkinFirm: true,
      AnamnesisKeys.oilySkinWrinkled: false,
      AnamnesisKeys.drySkinSensitive: false,
      AnamnesisKeys.drySkinResistant: false,
      AnamnesisKeys.drySkinPigmented: false,
      AnamnesisKeys.drySkinNonPigmented: false,
      AnamnesisKeys.drySkinFirm: false,
      AnamnesisKeys.drySkinWrinkled: false,
      AnamnesisKeys.combinationSkinSensitive: false,
      AnamnesisKeys.combinationSkinResistant: true,
      AnamnesisKeys.combinationSkinPigmented: true,
      AnamnesisKeys.combinationSkinNonPigmented: false,
      AnamnesisKeys.combinationSkinFirm: true,
      AnamnesisKeys.combinationSkinWrinkled: false,
      AnamnesisKeys.hasComedo: true,
      AnamnesisKeys.hasPustule: false,
      AnamnesisKeys.hasPapule: true,
      AnamnesisKeys.hasNodule: false,
      AnamnesisKeys.hasHyperkeratinization: true,
      AnamnesisKeys.hasMilium: false,
      AnamnesisKeys.hasMicrocyst: false,
      AnamnesisKeys.hasInflammatoryAcne: false,
      AnamnesisKeys.hasNonInflammatoryAcne: true,
      AnamnesisKeys.hasTelangiecatsiaNevus: false,
      AnamnesisKeys.hasActinicKeratosis: false,
      AnamnesisKeys.hasMelanocyticNevus: true,
      AnamnesisKeys.hasDermatosisPapulosa: false,
      AnamnesisKeys.hasPapilloma: false,
      AnamnesisKeys.hasAcrochordion: false,
      AnamnesisKeys.hasOtherLesions: 'Sem outras lesões relevantes',
      AnamnesisKeys.hasInflammatoryHyperpigmentation: true,
      AnamnesisKeys.hasPhotoaging: true,
      AnamnesisKeys.hasMelasma: true,
      AnamnesisKeys.hasFreckles: false,
      AnamnesisKeys.hasOrbicularHyperpigmentation: true,
      AnamnesisKeys.hasHypochromia: false,
      AnamnesisKeys.chromaticAbnormalityJustification:
          'Aumento após exposição solar sem reaplicação de protetor',
      AnamnesisKeys.skinPhototype:
          'III - Moreno Claro - bronzeia moderadamente',
      AnamnesisKeys.hasDermatitis: false,
      AnamnesisKeys.hasPsoriasis: false,
      AnamnesisKeys.treatmentIndicated:
          'Protocolo clareador + controle de oleosidade',
      AnamnesisKeys.numberOfSessions: '8',
      AnamnesisKeys.session1Date: '10/04/2026',
      AnamnesisKeys.session1: 'Avaliação inicial e higienização profunda',
      AnamnesisKeys.session2Date: '17/04/2026',
      AnamnesisKeys.session2: 'Peeling enzimático suave',
      AnamnesisKeys.session3Date: '24/04/2026',
      AnamnesisKeys.session3: 'LED âmbar + máscara calmante',
      AnamnesisKeys.session4Date: '01/05/2026',
      AnamnesisKeys.session4: 'Peeling químico superficial',
      AnamnesisKeys.session5Date: '08/05/2026',
      AnamnesisKeys.session5: 'Extração de comedões',
      AnamnesisKeys.session6Date: '15/05/2026',
      AnamnesisKeys.session6: 'Máscara despigmentante',
      AnamnesisKeys.session7Date: '22/05/2026',
      AnamnesisKeys.session7: 'Laser de baixa intensidade',
      AnamnesisKeys.session8Date: '29/05/2026',
      AnamnesisKeys.session8: 'Hidratação profunda',
      AnamnesisKeys.session9Date: '05/06/2026',
      AnamnesisKeys.session9: 'Reforço clareador',
      AnamnesisKeys.session10Date: '12/06/2026',
      AnamnesisKeys.session10: 'Avaliação final e manutenção',
      AnamnesisKeys.cosmeticPrescription:
          'Sabonete glicólico noturno, sérum vitamina C manhã e FPS 70 reaplicar 3x/dia',
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

  Iterable<MapEntry<String, StoredAnamnesisAnswer>> _normalizeAnswers(
    Map<String, dynamic> answers,
  ) sync* {
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
    });
  }

  Future<List<Client>> fetchClients() async {
    final db = await database;
    final List<Map<String, dynamic>> rows = await db.query('clients');

    return rows
        .map(
          (map) => Client(
            id: map['id'],
            name: map['name'],
            phone: map['phone'],
            notes: map['notes'],
          ),
        )
        .toList();
  }

  Future<int> updateClient(Client client) async {
    final db = await database;
    return await db.update(
      'clients',
      {'name': client.name, 'phone': client.phone, 'notes': client.notes},
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
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
