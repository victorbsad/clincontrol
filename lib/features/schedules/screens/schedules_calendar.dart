import 'package:flutter/material.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../../../data/models/client.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../sessions/screens/session_form.dart';
import '../widgets/calendar_widget.dart';

class SchedulesCalendar extends StatefulWidget {
  const SchedulesCalendar({super.key});

  @override
  State<SchedulesCalendar> createState() => _SchedulesCalendarState();
}

class _SchedulesCalendarState extends State<SchedulesCalendar> {
  final SessionRepository _sessionRepository = SessionRepository();
  final ClientRepository _clientRepository = ClientRepository();

  late DateTime _currentDate;
  List<Session> _allSessions = [];
  Map<String, List<Session>> _sessionsByDate = {};
  Map<int, Client> _clientsMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Carregar clientes
      final clients = await _clientRepository.findAll();
      _clientsMap = {for (var client in clients) client.id!: client};

      // Carregar agendamentos do mês inteiro
      final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
      final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);

      final startDate = AppDateFormatter.toDatabaseIsoDate(firstDay);
      final endDate = AppDateFormatter.toDatabaseIsoDate(lastDay);

      _allSessions = await _sessionRepository.findByDateRange(startDate, endDate);

      // Agrupar por data
      _sessionsByDate = {};
      for (final session in _allSessions) {
        if (!_sessionsByDate.containsKey(session.date)) {
          _sessionsByDate[session.date] = [];
        }
        _sessionsByDate[session.date]!.add(session);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onDateSelected(DateTime date) {
    final dateString = AppDateFormatter.toDatabaseIsoDate(date);
    final sessions = _sessionsByDate[dateString] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ScheduleDetailModal(
        date: date,
        sessions: sessions,
        clientsMap: _clientsMap,
        onScheduleAdded: _loadData,
        onScheduleEdited: _loadData,
        onScheduleDeleted: _loadData,
      ),
    );
  }

  Future<void> _addNewSchedule() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SessionForm()),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  CalendarWidget(
                    initialDate: _currentDate,
                    onDateSelected: _onDateSelected,
                    sessionsByDate: _sessionsByDate,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSchedulesSummary(),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSchedule,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSchedulesSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo dos Agendamentos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildStatusCard(
          'Agendados',
          _allSessions
              .where((s) => s.status == Session.statusScheduled)
              .length
              .toString(),
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildStatusCard(
          'Pagos',
          _allSessions.where((s) => s.status == Session.statusPaid).length.toString(),
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildStatusCard(
          'Cancelados',
          _allSessions
              .where((s) => s.status == Session.statusCanceled)
              .length
              .toString(),
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatusCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SCHEDULE DETAIL MODAL ───────────────────────────────────────
class _ScheduleDetailModal extends StatefulWidget {
  final DateTime date;
  final List<Session> sessions;
  final Map<int, Client> clientsMap;
  final VoidCallback onScheduleAdded;
  final VoidCallback onScheduleEdited;
  final VoidCallback onScheduleDeleted;

  const _ScheduleDetailModal({
    required this.date,
    required this.sessions,
    required this.clientsMap,
    required this.onScheduleAdded,
    required this.onScheduleEdited,
    required this.onScheduleDeleted,
  });

  @override
  State<_ScheduleDetailModal> createState() => _ScheduleDetailModalState();
}

class _ScheduleDetailModalState extends State<_ScheduleDetailModal> {
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
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _deleteSchedule(Session session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este agendamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _sessionRepository.delete(session.id!);
      widget.onScheduleDeleted();
      if (mounted) {
        Navigator.pop(context);
      }
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
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agendamentos de $dateString',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_sessions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'Nenhum agendamento neste dia',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Lista de agendamentos
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

                      return _SessionCard(
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
                        Icon(
                          Icons.event_available_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum agendamento',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Botão de novo agendamento
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SessionForm(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Novo Agendamento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

// ─── SESSION CARD ───────────────────────────────────────
class _SessionCard extends StatelessWidget {
  final Session session;
  final Client? client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.client,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case Session.statusScheduled:
        return Colors.blue;
      case Session.statusPaid:
        return Colors.green;
      case Session.statusCanceled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cliente e status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client?.name ?? 'Cliente não encontrado',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(session.status)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          session.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(session.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Editar'),
                      onTap: onEdit,
                    ),
                    PopupMenuItem(
                      child: const Text(
                        'Deletar',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Procedimento
            Row(
              children: [
                const Icon(Icons.medical_services_outlined,
                    size: 16, color: Colors.purple),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.procedure,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Valor
            Row(
              children: [
                const Icon(Icons.attach_money,
                    size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'R\$ ${session.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (session.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.note_outlined,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.notes,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
