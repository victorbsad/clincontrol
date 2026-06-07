import 'package:flutter/material.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../../../data/models/client.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../sessions/screens/session_form.dart';

class SchedulesCalendar extends StatefulWidget {
  const SchedulesCalendar({super.key});

  @override
  State<SchedulesCalendar> createState() => _SchedulesCalendarState();
}

class _SchedulesCalendarState extends State<SchedulesCalendar>
    with WidgetsBindingObserver {
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
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      // Se a data mudou, recarregar o calendário
      if (_currentDate.year != now.year ||
          _currentDate.month != now.month ||
          _currentDate.day != now.day) {
        setState(() {
          _currentDate = now;
          _loadData();
        });
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox (
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CalendarWidget(
                        initialDate: _currentDate,
                        onDateSelected: _onDateSelected,
                        sessionsByDate: _sessionsByDate,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildSchedulesSummary(),
                      ),
                    ],
                  ),
                ),
              ),
            ),  
    );
  }

  Widget _buildSchedulesSummary() {
    final scheduled = _allSessions.where((s) => s.status == Session.statusScheduled).length;
    final paid = _allSessions.where((s) => s.status == Session.statusPaid).length;
    final canceled = _allSessions.where((s) => s.status == Session.statusCanceled).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildChip('Agendados', scheduled, Color(0xFF1565C0)),
        _buildChip('Pagos', paid, Color(0xFF2E7D32)),
        _buildChip('Cancelados', canceled, Color(0xFFC62828)),
      ],
    );
  }

  Widget _buildChip(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text('$label: $count', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
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
                          builder: (_) => SessionForm(initialDate: widget.date),
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
// ─── CALENDAR WIDGET ───────────────────────────────────────
class CalendarWidget extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final Map<String, List<Session>> sessionsByDate;

  const CalendarWidget({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    required this.sessionsByDate,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _currentDate;
  bool _showingMonthPicker = false;

  final List<String> _monthNamesShort = [
    'Jan','Fev','Mar','Abr','Mai','Jun',
    'Jul','Ago','Set','Out','Nov','Dez'
  ];

  final List<String> _monthNamesUpper = [
    'JAN','FEV','MAR','ABR','MAI','JUN',
    'JUL','AGO','SET','OUT','NOV','DEZ'
  ];

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
  }

  // ── Grid dos 12 meses (month picker in-place) ──
  Widget _buildMonthPickerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
        children: List.generate(12, (index) {
          final isSelected = _currentDate.month == index + 1;
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentDate = DateTime(_currentDate.year, index + 1, 1);
                _showingMonthPicker = false;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6A1B9A) : const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6A1B9A).withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  _monthNamesShort[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Grid dos dias do mês ──
  Widget _buildDaysGrid() {
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7; // domingo=0, seg=1 ... sab=6
    final totalCells = ((firstWeekday + daysInMonth) / 7).ceil() * 7;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.75,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final weekdayIndex = index % 7;
          int dayOfMonth = index - firstWeekday + 1;
          bool isOtherMonth = dayOfMonth < 1 || dayOfMonth > daysInMonth;

          DateTime dateForDay;
          int displayDay;

          if (dayOfMonth < 1) {
            final prevMonthLastDay =
                DateTime(_currentDate.year, _currentDate.month, 0).day;
            displayDay = prevMonthLastDay + dayOfMonth;
            dateForDay = DateTime(
                _currentDate.year, _currentDate.month - 1, displayDay);
          } else if (dayOfMonth > daysInMonth) {
            displayDay = dayOfMonth - daysInMonth;
            dateForDay = DateTime(
                _currentDate.year, _currentDate.month + 1, displayDay);
          } else {
            displayDay = dayOfMonth;
            dateForDay =
                DateTime(_currentDate.year, _currentDate.month, displayDay);
          }

          final dateString =
              '${dateForDay.year}-${dateForDay.month.toString().padLeft(2, '0')}-${dateForDay.day.toString().padLeft(2, '0')}';
          final sessions = widget.sessionsByDate[dateString] ?? [];
          final isSunday = weekdayIndex == 0; // domingo é índice 0

          return GestureDetector(
            onTap: isOtherMonth
                ? null
                : () => widget.onDateSelected(dateForDay),
            child: Container(
              decoration: BoxDecoration(
                color: isOtherMonth
                    ? Colors.transparent
                    : isSunday
                        ? const Color(0xFFFCE4EC)
                        : Colors.white,
                border: Border.all(
                  color: isOtherMonth
                      ? Colors.grey.shade200
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Opacity(
                opacity: isOtherMonth ? 0.3 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$displayDay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSunday ? Colors.red : Colors.black,
                        ),
                      ),
                      if (sessions.isNotEmpty && !isOtherMonth)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            sessions.length == 1
                                ? sessions[0].procedure.split(' ').first
                                : '+${sessions.length}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF6A1B9A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header com setas e botão central ──
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Seta esquerda: mês anterior OU ano anterior
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.purple),
                onPressed: () {
                  setState(() {
                    if (_showingMonthPicker) {
                      _currentDate =
                          DateTime(_currentDate.year - 1, _currentDate.month);
                    } else {
                      _currentDate = DateTime(
                          _currentDate.year, _currentDate.month - 1);
                    }
                  });
                },
              ),

              // Botão central: alterna entre calendário e month picker
              InkWell(
                onTap: () =>
                    setState(() => _showingMonthPicker = !_showingMonthPicker),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF6A1B9A), width: 1.5),
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _showingMonthPicker
                        ? '${_currentDate.year}'
                        : '${_monthNamesUpper[_currentDate.month - 1]} ${_currentDate.year}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A1B9A),
                    ),
                  ),
                ),
              ),

              // Seta direita: mês seguinte OU ano seguinte
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Color(0xFF6A1B9A)),
                onPressed: () {
                  setState(() {
                    if (_showingMonthPicker) {
                      _currentDate =
                          DateTime(_currentDate.year + 1, _currentDate.month);
                    } else {
                      _currentDate = DateTime(
                          _currentDate.year, _currentDate.month + 1);
                    }
                  });
                },
              ),
            ],
          ),
        ),

        // ── Conteúdo: meses ou dias ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation, 
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOut,
                )),
                child: child,
              ),
            );
          },
          child: _showingMonthPicker
              ? KeyedSubtree(
                  key: const ValueKey('months'),
                  child: _buildMonthPickerGrid(),
                )
              : KeyedSubtree(
                  key: const ValueKey('days'),
                  child: _buildDaysGrid(),
                ),
        ),
      ],
    );
  }
}