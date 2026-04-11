import '../../core/config/app_environment.dart';
import '../models/anamnesis.dart';
import '../models/client.dart';
import '../repositories/anamnesis_repository.dart';
import '../repositories/client_repository.dart';
import 'mock_models.dart';

class DevelopmentSeeder {
  final ClientRepository _clientRepository;
  final AnamnesisRepository _anamnesisRepository;

  DevelopmentSeeder({
    ClientRepository? clientRepository,
    AnamnesisRepository? anamnesisRepository,
  })  : _clientRepository = clientRepository ?? ClientRepository(),
        _anamnesisRepository = anamnesisRepository ?? AnamnesisRepository();

  Future<void> seed() async {
    if (!AppEnvironment.devToolsEnabled) {
      return;
    }

    final client = await _ensureDevClient();
    final anamneses = await _anamnesisRepository.findByClientId(client.id!);

    if (anamneses.isEmpty) {
      await _anamnesisRepository.save(
        DevMockModels.buildAnamnesis(clientId: client.id!),
      );
      return;
    }

    final first = anamneses.first;
    await _anamnesisRepository.update(
      Anamnesis(
        id: first.id,
        clientId: first.clientId,
        createdAt: first.createdAt,
        updatedAt: DateTime.now(),
        answers: DevMockModels.sampleAnswers(),
      ),
    );
  }

  Future<Client> _ensureDevClient() async {
    final clients = await _clientRepository.findAll();
    for (final client in clients) {
      if (DevMockModels.isDevMockClient(client)) {
        return client;
      }
    }

    final id = await _clientRepository.save(
      DevMockModels.buildClient(name: 'Cliente Seed Dev'),
    );

    return Client(
      id: id,
      name: 'Cliente Seed Dev',
      phone: '(11) 99999-0000',
      notes: '${DevMockModels.notesMarker} Gerado para laboratorio de CRUD.',
    );
  }
}
