import 'package:flutter/material.dart';

import '../../../core/utils/app_date_formatter.dart';
import '../../../data/models/client.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/session_repository.dart';
import 'session_form.dart';

class SessionList extends StatefulWidget {
  final Client client;

  const SessionList({super.key, required this.client});

  @override
  State<SessionList> createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  final SessionRepository _repository = SessionRepository();

  List<Session> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await _repository.findByClientId(widget.client.id!);
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _openForm([Session? session]) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SessionForm(clientId: widget.client.id, session: session),
      ),
    );

    if (result == true) {
      await _load();
    }
  }

  DateTime _parseDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return DateTime(1970);
    final year = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final day = int.tryParse(match.group(3) ?? '');
    if (year == null || month == null || day == null) return DateTime(1970);
    return DateTime(year, month, day);
  }

  String _formatMoney(double amount) {
    return amount.toStringAsFixed(2).replaceAll('.', ',');
  }

  Future<void> _delete(Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir sessao'),
        content: const Text('Deseja excluir esta sessao de atendimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _repository.delete(session.id!);
    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sessao excluida.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sessoes - ${widget.client.name}'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
          ? const Center(
              child: Text('Nenhuma sessao cadastrada para este cliente.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                final date = _parseDate(session.date);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.shade100,
                      child: Text(
                        '${index + 1}a',
                        style: const TextStyle(color: Colors.purple),
                      ),
                    ),
                    title: Text(session.procedure),
                    subtitle: Text(
                      '${AppDateFormatter.toPtBr(date)}  •  R\$ ${_formatMoney(session.amount)}\n${session.notes}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          _openForm(session);
                        } else if (action == 'delete') {
                          _delete(session);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
