import '../models/anamnesis.dart';
import '../models/client.dart';
import '../models/service.dart';
import '../../core/constants/anamnesis_keys.dart';

class DevMockModels {
  const DevMockModels._();

  static const String notesMarker = '[DEV-MOCK]';

  static Client buildClient({String? name}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return Client(
      name: name ?? 'Cliente Dev $timestamp',
      phone: '(11) 99999-0000',
      notes: '$notesMarker Gerado para laboratorio de CRUD.',
    );
  }

  static Service buildService({
    required int clientId,
    DateTime? date,
    double amount = 100.0,
    String procedure = 'Procedimento Teste',
  }) {
    final targetDate = date ?? DateTime.now();
    final dbDate = '${targetDate.year}-'
        '${targetDate.month.toString().padLeft(2, '0')}-'
        '${targetDate.day.toString().padLeft(2, '0')}';

    return Service(
      clientId: clientId,
      procedure: procedure,
      amount: amount,
      date: dbDate,
    );
  }

  static Anamnesis buildAnamnesis({
    required int clientId,
    DateTime? now,
  }) {
    final createdAt = now ?? DateTime.now();
    return Anamnesis(
      clientId: clientId,
      createdAt: createdAt,
      updatedAt: createdAt,
      answers: sampleAnswers(),
    );
  }

  static Map<String, dynamic> sampleAnswers() {
    return {
      AnamnesisKeys.maritalStatus: 'Solteira',
      AnamnesisKeys.nationality: 'Brasileira',
      AnamnesisKeys.profession: 'Profissao de Teste',
      AnamnesisKeys.age: 30,
      AnamnesisKeys.hasAllergies: false,
      AnamnesisKeys.visitReason: 'Validacao de fluxo em desenvolvimento',
    };
  }

  static bool isDevMockClient(Client client) {
    return client.notes.contains(notesMarker);
  }
}
