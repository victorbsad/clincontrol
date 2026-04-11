import 'package:flutter/material.dart';

import '../../../data/models/anamnesis.dart';
import '../../../data/models/client.dart';
import '../../../data/models/service.dart';
import '../../../data/repositories/anamnesis_repository.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/service_repository.dart';

class CrudTestPage extends StatefulWidget {
  const CrudTestPage({super.key});

  @override
  State<CrudTestPage> createState() => _CrudTestPageState();
}

class _CrudTestPageState extends State<CrudTestPage> {
  final ClientRepository _clientRepository = ClientRepository();
  final ServiceRepository _serviceRepository = ServiceRepository();
  final AnamnesisRepository _anamnesisRepository = AnamnesisRepository();

  bool _isRunning = false;
  final List<String> _logs = [];

  String get _output {
    if (_logs.isEmpty) {
      return 'Nenhum teste executado ainda.';
    }
    return _logs.join('\n\n');
  }

  void _addLog(String text) {
    final now = DateTime.now();
    final stamp =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    setState(() {
      _logs.insert(0, '[$stamp] $text');
    });
  }

  String _formatJson(dynamic obj) {
    if (obj == null) return 'null';
    if (obj is String || obj is num || obj is bool) return obj.toString();
    if (obj is List) {
      return '[\n  ${obj.map((item) => _formatJson(item)).join(',\n  ')}\n]';
    }
    if (obj is Map) {
      final entries = obj.entries
          .map((e) => '"${e.key}": ${_formatJson(e.value)}')
          .join(',\n  ');
      return '{\n  $entries\n}';
    }
    return obj.toString();
  }

  Future<void> _runAction(
    String methodName,
    Future<String> Function() action,
  ) async {
    if (_isRunning) return;

    setState(() => _isRunning = true);
    _addLog('Executando $methodName...');

    try {
      final result = await action();
      _addLog('Sucesso em $methodName\n$result');
    } catch (e) {
      _addLog('Erro em $methodName\n$e');
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }

  Future<String> _saveClient() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await _clientRepository.save(
      Client(
        name: 'Cliente Teste $now',
        phone: '(11) 99999-0000',
        notes: 'Criado pela tela de teste',
      ),
    );

    return 'ID criado: $id';
  }

  Future<String> _findAllClients() async {
    final clients = await _clientRepository.findAll();

    if (clients.isEmpty) {
      return 'findAll retornou lista vazia';
    }

    final output = StringBuffer();
    output.writeln('Total de clientes: ${clients.length}');
    output.writeln('');
    for (final c in clients) {
      output.writeln('---');
      output.writeln('ID: ${c.id}');
      output.writeln('Nome: ${c.name}');
      output.writeln('Telefone: ${c.phone}');
      output.writeln('Notas: ${c.notes}');
      output.writeln('');
    }

    return output.toString();
  }

  Future<String> _updateFirstClient() async {
    final clients = await _clientRepository.findAll();
    if (clients.isEmpty) {
      return 'Não há clientes para atualizar';
    }

    final first = clients.first;
    final updated = Client(
      id: first.id,
      name: '${first.name} (editado)',
      phone: first.phone,
      notes: '${first.notes} | atualizado na tela de teste',
    );

    final rows = await _clientRepository.update(updated);
    return 'Linhas afetadas: $rows | Cliente id=${first.id}';
  }

  Future<String> _deleteLastClient() async {
    final clients = await _clientRepository.findAll();
    if (clients.isEmpty) {
      return 'Não há clientes para remover';
    }

    final last = clients.last;
    final rows = await _clientRepository.delete(last.id!);

    return 'Linhas afetadas: $rows | Cliente removido id=${last.id}';
  }

  Future<String> _saveService() async {
    var clients = await _clientRepository.findAll();
    if (clients.isEmpty) {
      final id = await _clientRepository.save(
        Client(
          name: 'Cliente Base Serviço',
          phone: '(11) 90000-0000',
          notes: 'Criado automaticamente para teste de serviço',
        ),
      );
      _addLog('Cliente base criado automaticamente: id=$id');
      clients = await _clientRepository.findAll();
    }

    final client = clients.first;
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final id = await _serviceRepository.save(
      Service(
        clientId: client.id!,
        procedure: 'Procedimento Teste',
        amount: 100.0,
        date: date,
      ),
    );

    return 'Atendimento criado: id=$id para client_id=${client.id}';
  }

  Future<String> _getMonthlyTotal() async {
    final now = DateTime.now();
    final total = await _serviceRepository.getMonthlyTotal(now.month, now.year);

    return 'Total do mês ${now.month}/${now.year}: R\$ ${total.toStringAsFixed(2)}';
  }

  Future<String> _getMonthlyCount() async {
    final now = DateTime.now();
    final count = await _serviceRepository.getMonthlyCount(now.month, now.year);

    return 'Quantidade de atendimentos do mês ${now.month}/${now.year}: $count';
  }

  Future<String> _saveAnamnesis() async {
    var clients = await _clientRepository.findAll();
    if (clients.isEmpty) {
      final id = await _clientRepository.save(
        Client(
          name: 'Cliente Base Anamnese',
          phone: '(11) 98888-0000',
          notes: 'Criado automaticamente para teste de anamnese',
        ),
      );
      _addLog('Cliente base criado automaticamente: id=$id');
      clients = await _clientRepository.findAll();
    }

    final client = clients.first;
    final anamnesis = Anamnesis(
      clientId: client.id!,
      answers: {
        'estadoCivil': 'Solteira',
        'nacionalidade': 'Brasileira',
        'profissao': 'Teste Profissão',
        'idade': 30,
      },
    );

    final id = await _anamnesisRepository.save(anamnesis);
    return 'Anamnese criada: id=$id para client_id=${client.id}';
  }

  Future<String> _findAnamnesisForFirstClient() async {
    final clients = await _clientRepository.findAll();
    if (clients.isEmpty) {
      return 'Não há clientes para buscar anamneses';
    }

    final anamneses = await _anamnesisRepository.findByClientId(
      clients.first.id!,
    );
    if (anamneses.isEmpty) {
      return 'Nenhuma anamnese encontrada para cliente id=${clients.first.id}';
    }

    final output = StringBuffer();
    output.writeln('Total de anamneses encontradas: ${anamneses.length}');
    output.writeln('');
    for (final a in anamneses) {
      output.writeln('---');
      output.writeln('ID: ${a.id}');
      output.writeln('Cliente ID: ${a.clientId}');
      output.writeln('Criado em: ${a.createdAt}');
      output.writeln('Atualizado em: ${a.updatedAt}');
      output.writeln('Respostas: ${_formatJson(a.answers)}');
      output.writeln('');
    }

    return output.toString();
  }

  Future<String> _findAnamnesisById() async {
    final anamneses = await _anamnesisRepository.findByClientId(1);
    if (anamneses.isEmpty) {
      return 'Nenhuma anamnese encontrada';
    }

    final first = anamneses.first;
    final found = await _anamnesisRepository.findById(first.id!);
    if (found == null) {
      return 'Anamnese não encontrada com id=${first.id}';
    }

    final output = StringBuffer();
    output.writeln('Anamnese encontrada:');
    output.writeln('ID: ${found.id}');
    output.writeln('Cliente ID: ${found.clientId}');
    output.writeln('Criado em: ${found.createdAt}');
    output.writeln('Atualizado em: ${found.updatedAt}');
    output.writeln('Respostas:');
    output.writeln(_formatJson(found.answers));

    return output.toString();
  }

  Future<String> _updateAnamnesis() async {
    final anamneses = await _anamnesisRepository.findByClientId(1);
    if (anamneses.isEmpty) {
      return 'Não há anamneses para atualizar';
    }

    final first = anamneses.first;
    final updated = Anamnesis(
      id: first.id,
      clientId: first.clientId,
      createdAt: first.createdAt,
      answers: {
        ...first.answers,
        'profissao': 'Profissão Atualizada',
        'atualizadoEm': 'Lab Teste',
      },
    );

    final rows = await _anamnesisRepository.update(updated);
    return 'Linhas afetadas: $rows | Anamnese id=${first.id}';
  }

  Future<String> _deleteAnamnesis() async {
    final anamnese = await _anamnesisRepository.findByClientId(1);
    if (anamnese.isEmpty) {
      return 'Não há anamneses para remover';
    }

    final last = anamnese.last;
    final rows = await _anamnesisRepository.delete(last.id!);

    return 'Linhas afetadas: $rows | Anamnese removida id=${last.id}';
  }

  Widget _methodCard({
    required String title,
    required String method,
    required Future<String> Function() onRun,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            SelectableText(
              method,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _isRunning ? null : () => _runAction(method, onRun),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Executar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab de CRUD'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isRunning
                ? null
                : () {
                    setState(_logs.clear);
                  },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpar saída',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Métodos disponíveis para teste',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                _methodCard(
                  title: 'Clientes: criar',
                  method: 'ClientRepository.save(Client client)',
                  onRun: _saveClient,
                ),
                _methodCard(
                  title: 'Clientes: listar',
                  method: 'ClientRepository.findAll()',
                  onRun: _findAllClients,
                ),
                _methodCard(
                  title: 'Clientes: atualizar primeiro registro',
                  method: 'ClientRepository.update(Client client)',
                  onRun: _updateFirstClient,
                ),
                _methodCard(
                  title: 'Clientes: remover último registro',
                  method: 'ClientRepository.delete(int id)',
                  onRun: _deleteLastClient,
                ),
                _methodCard(
                  title: 'Atendimentos: criar',
                  method: 'ServiceRepository.save(Service atendimento)',
                  onRun: _saveService,
                ),
                _methodCard(
                  title: 'Atendimentos: total mensal',
                  method:
                      'ServiceRepository.getMonthlyTotal(int month, int year)',
                  onRun: _getMonthlyTotal,
                ),
                _methodCard(
                  title: 'Atendimentos: quantidade mensal',
                  method:
                      'ServiceRepository.getMonthlyCount(int month, int year)',
                  onRun: _getMonthlyCount,
                ),
                const Divider(height: 24),
                const Text(
                  'ANAMNESE',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _methodCard(
                  title: 'Anamnese: criar',
                  method: 'AnamnesisRepository.save(Anamnesis anamnesis)',
                  onRun: _saveAnamnesis,
                ),
                _methodCard(
                  title: 'Anamnese: listar por cliente',
                  method: 'AnamnesisRepository.findByClientId(int clientId)',
                  onRun: _findAnamnesisForFirstClient,
                ),
                _methodCard(
                  title: 'Anamnese: buscar por ID',
                  method: 'AnamnesisRepository.findById(int id)',
                  onRun: _findAnamnesisById,
                ),
                _methodCard(
                  title: 'Anamnese: atualizar primeira',
                  method: 'AnamnesisRepository.update(Anamnesis anamnesis)',
                  onRun: _updateAnamnesis,
                ),
                _methodCard(
                  title: 'Anamnese: remover última',
                  method: 'AnamnesisRepository.delete(int id)',
                  onRun: _deleteAnamnesis,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade100,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Saída',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (_isRunning)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _output,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
