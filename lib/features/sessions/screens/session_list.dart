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
  String? _statusFilter;
  DateTimeRange? _dateRangeFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await _repository.findByClientId(
      widget.client.id!,
      status: _statusFilter,
      startDate: _dateRangeFilter != null
          ? AppDateFormatter.toDatabaseIsoDate(_dateRangeFilter!.start)
          : null,
      endDate: _dateRangeFilter != null
          ? AppDateFormatter.toDatabaseIsoDate(_dateRangeFilter!.end)
          : null,
    );
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 10, 12, 31),
      initialDateRange: _dateRangeFilter,
      locale: const Locale('pt', 'BR'),
    );

    if (!mounted) return;
    if (picked == null) return;

    setState(() {
      _dateRangeFilter = DateTimeRange(
        start: DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: DateTime(picked.end.year, picked.end.month, picked.end.day),
      );
      _loading = true;
    });
    await _load();
  }

  void _setStatusFilter(String? value) async {
    setState(() {
      _statusFilter = value;
      _loading = true;
    });
    await _load();
  }

  void _clearFilters() async {
    setState(() {
      _statusFilter = null;
      _dateRangeFilter = null;
      _loading = true;
    });
    await _load();
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
    final hasFilters = _statusFilter != null || _dateRangeFilter != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sessões · ${widget.client.name}'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F4FF),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6A1B9A)))
          : Column(
              children: [
                // ── Filtros ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              decoration: InputDecoration(
                                labelText: 'Status',
                                labelStyle: const TextStyle(
                                    color: Color(0xFF6A1B9A)),
                                filled: true,
                                fillColor: const Color(0xFFF3E5F5),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFCE93D8)),
                                ),
                              ),
                              value: _statusFilter,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(10),
                              items: const [
                                DropdownMenuItem(
                                    value: null, child: Text('Todos')),
                                DropdownMenuItem(
                                    value: Session.statusScheduled,
                                    child: Text('Agendado')),
                                DropdownMenuItem(
                                    value: Session.statusPaid,
                                    child: Text('Pago')),
                                DropdownMenuItem(
                                    value: Session.statusCanceled,
                                    child: Text('Cancelado')),
                              ],
                              onChanged: _setStatusFilter,
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: _pickDateRange,
                            icon: const Icon(Icons.date_range,
                                color: Color(0xFF6A1B9A), size: 18),
                            label: const Text('Período',
                                style: TextStyle(color: Color(0xFF6A1B9A))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                  color: Color(0xFF6A1B9A)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          if (hasFilters) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              tooltip: 'Limpar filtros',
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.close,
                                  color: Color(0xFFC62828), size: 20),
                            ),
                          ],
                        ],
                      ),
                      if (_dateRangeFilter != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 14, color: Colors.black45),
                              const SizedBox(width: 4),
                              Text(
                                '${AppDateFormatter.toPtBr(_dateRangeFilter!.start)} → ${AppDateFormatter.toPtBr(_dateRangeFilter!.end)}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Lista ──
                Expanded(
                  child: _sessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy_outlined,
                                  size: 52,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Nenhuma sessão encontrada',
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 88),
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final session = _sessions[index];
                            final date = _parseDate(session.date);
                            final statusColor =
                                _statusColor(session.status);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border(
                                  left: BorderSide(
                                      color: statusColor, width: 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () => _openForm(session),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                session.procedure,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                AppDateFormatter.toPtBr(date),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'R\$ ${_formatMoney(session.amount)}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF2E7D32),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: statusColor
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                session.status,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,
                                          iconSize: 18,
                                          onSelected: (action) {
                                            if (action == 'edit') {
                                              _openForm(session);
                                            } else if (action == 'delete') {
                                              _delete(session);
                                            }
                                          },
                                          itemBuilder: (_) => const [
                                            PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Editar')),
                                            PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Excluir',
                                                    style: TextStyle(
                                                        color: Colors.red))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openForm,
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper de cor por status
  Color _statusColor(String status) {
    switch (status) {
      case Session.statusScheduled:
        return const Color(0xFF1565C0);
      case Session.statusPaid:
        return const Color(0xFF2E7D32);
      case Session.statusCanceled:
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }
}
