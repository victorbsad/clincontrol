import 'package:flutter/material.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../../../data/models/client.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/schedule_detail_modal.dart';

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
      final clients = await _clientRepository.findAll();
      _clientsMap = {for (var c in clients) c.id!: c};

      final firstDay =
          DateTime(_currentDate.year, _currentDate.month, 1);
      final lastDay =
          DateTime(_currentDate.year, _currentDate.month + 1, 0);

      _allSessions = await _sessionRepository.findByDateRange(
        AppDateFormatter.toDatabaseIsoDate(firstDay),
        AppDateFormatter.toDatabaseIsoDate(lastDay),
      );

      _sessionsByDate = {};
      for (final session in _allSessions) {
        _sessionsByDate
            .putIfAbsent(session.date, () => [])
            .add(session);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar agendamentos: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDateSelected(DateTime date) {
    final sessions =
        _sessionsByDate[AppDateFormatter.toDatabaseIsoDate(date)] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(77),
      isDismissible: true,
      enableDrag: true,
      builder: (_) => ScheduleDetailModal(
        date: date,
        sessions: sessions,
        clientsMap: _clientsMap,
        onScheduleAdded: _loadData,
        onScheduleEdited: _loadData,
        onScheduleDeleted: _loadData,
      ),
    ).whenComplete(_loadData); // Recarrega os dados ao fechar o modal
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
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        child: CalendarWidget(
                          initialDate: _currentDate,
                          onDateSelected: _onDateSelected,
                          sessionsByDate: _sessionsByDate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: _buildSummary(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSummary() {
    final scheduled = _allSessions
        .where((s) => s.status == Session.statusScheduled)
        .length;
    final paid = _allSessions
        .where((s) => s.status == Session.statusPaid)
        .length;
    final canceled = _allSessions
        .where((s) => s.status == Session.statusCanceled)
        .length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _chip('Agendados', scheduled, const Color(0xFF1565C0)),
        _chip('Pagos', paid, const Color(0xFF2E7D32)),
        _chip('Cancelados', canceled, const Color(0xFFC62828)),
      ],
    );
  }

  Widget _chip(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}