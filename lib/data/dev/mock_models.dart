import '../models/anamnesis.dart';
import '../models/client.dart';
import '../models/service.dart';
import '../../core/constants/anamnesis_keys.dart';
import '../../core/utils/app_date_formatter.dart';

class DevMockModels {
  const DevMockModels._();

  static const String notesMarker = '[DEV-MOCK]';

  static Client buildClient({String? name}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return Client(
      name: name ?? 'Cliente Dev $timestamp',
      phone: '(11) 99999-0000',
      notes: '$notesMarker Gerado para laboratorio de CRUD.',
      maritalStatus: 'Solteira',
      nationality: 'Brasileira',
      address: 'Rua Exemplo, 123 - Centro',
      whatsapp: '(11) 98888-0000',
      email: 'cliente.dev.$timestamp@example.com',
      dateOfBirth: '1994-05-20',
      age: '31',
      profession: 'Profissao de Teste',
    );
  }

  static Service buildService({
    required int clientId,
    DateTime? date,
    double amount = 100.0,
    String procedure = 'Procedimento Teste',
  }) {
    final targetDate = date ?? DateTime.now();
    final dbDate = AppDateFormatter.toDatabaseIsoDate(targetDate);

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
      AnamnesisKeys.hasAllergies: false,
      AnamnesisKeys.visitReason: 'Validacao de fluxo em desenvolvimento',
    };
  }

  static bool isDevMockClient(Client client) {
    return client.notes.contains(notesMarker);
  }
}
