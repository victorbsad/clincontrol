import 'package:flutter/material.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../../../data/models/client.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/session_repository.dart';
import '../../sessions/screens/session_form.dart';
import 'session_card.dart';

class ScheduleDetailModal extends StatefulWidget {
  final DateTime date;
  final List<Session> sessions;
  final Map<int, Client> clientsMap;
  final VoidCallback onScheduleAdded;
  final VoidCallback onScheduleEdited;
  final VoidCallback onScheduleDeleted;

  const ScheduleDetailModal({
    super.key,
    required this.date,
    required this.sessions,
    required this.clientsMap,
    required this.onScheduleAdded,
    required this.onScheduleEdited,
    required this.onScheduleDeleted,
  });

  @override
  State<ScheduleDetailModal> createState() => _ScheduleDetailModalState();
}

class _ScheduleDetailModalState extends State<ScheduleDetailModal> {
  final SessionRepository _sessionRepository = SessionRepository();
  late List<Session> _sessions;

  @override
  void initState() {
    super.initState();
    _sessions = List.from(widget.sessions);
  }

  void _editSchedule(Session session) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => SessionForm(session: session)),
    );
    if (result == true) {
      widget.onScheduleEdited();
      if (mounted) Navigator.pop(context);
    }
  }

  void _deleteSchedule(Session session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content:
            const Text('Tem certeza que deseja deletar este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _sessionRepository.delete(session.id!);
      widget.onScheduleDeleted();
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = AppDateFormatter.toPtBr(widget.date);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agendamentos de $dateString',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (_sessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Nenhum agendamento neste dia',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              if (_sessions.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      final client =
                          widget.clientsMap[session.clientId];
                      return SessionCard(
                        session: session,
                        client: client,
                        onEdit: () => _editSchedule(session),
                        onDelete: () => _deleteSchedule(session),
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_available_outlined,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Nenhum agendamento',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      final result = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionForm(initialDate: widget.date),
                        ),
                      );
                      if (result == true) {
                        widget.onScheduleAdded();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Agendamento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}