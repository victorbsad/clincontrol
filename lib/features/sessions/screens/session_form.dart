import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/app_date_formatter.dart';
import '../../../data/models/client.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/session_repository.dart';

class SessionForm extends StatefulWidget {
  final int? clientId;
  final Session? session;
  final DateTime? initialDate;

  const SessionForm({super.key, this.clientId, this.session, this.initialDate});

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final SessionRepository _repository = SessionRepository();
  final ClientRepository _clientRepository = ClientRepository();
  final _formKey = GlobalKey<FormState>();

  final _procedureController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  late DateTime _selectedDate;
  String _status = Session.statusScheduled;
  bool _saving = false;
  bool _loadingClients = false;
  int? _selectedClientId;
  List<Client> _clients = [];

  bool get _isEdit => widget.session != null;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedClientId = widget.clientId;
    final session = widget.session;
    if (session != null) {
      _selectedClientId ??= session.clientId;
      _procedureController.text = session.procedure;
      _notesController.text = session.notes;
      _amountController.text = session.amount.toStringAsFixed(2);
      _status = session.status;
      _selectedDate = _parseDatabaseDate(session.date) ?? DateTime.now();
    }
    _loadClients();
  }

  @override
  void dispose() {
    _procedureController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  DateTime? _parseDatabaseDate(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return null;

    final year = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final day = int.tryParse(match.group(3)!);
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('pt', 'BR'),
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _loadClients() async {
    if (!mounted) return;
    setState(() => _loadingClients = true);
    try {
      final clients = await _clientRepository.findAll();
      if (!mounted) return;
      setState(() {
        _clients = clients;
        if (_selectedClientId == null && clients.length == 1) {
          _selectedClientId = clients.first.id;
        }
      });
    } finally {
      if (mounted) setState(() => _loadingClients = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final clientId = _selectedClientId;
    if (clientId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um cliente')));
      return;
    }

    setState(() => _saving = true);
    try {
      // Considera tanto vírgula quanto ponto como separador decimal
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final now = DateTime.now();

      // Validar se a data é consistente com a data atual
      final monthDiff = (now.year - _selectedDate.year) * 12 +
          (now.month - _selectedDate.month);

      // Se está muito no passado (mais de 3 meses)
      if (monthDiff > 3) {
        if (!mounted) return;
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Data Antiga'),
            content: Text(
              'Você está criando sessão em '
              '${AppDateFormatter.toPtBr(_selectedDate)}, '
              'mas hoje é ${AppDateFormatter.toPtBr(now)}.\n\n'
              'Deseja continuar?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continuar'),
              ),
            ],
          ),
        );

        if (confirm != true) {
          setState(() => _saving = false);
          return;
        }
      }

      if (_isEdit) {
        final current = widget.session!;
        final updated = Session(
          id: current.id,
          clientId: clientId,
          procedure: _procedureController.text.trim(),
          notes: _notesController.text.trim(),
          amount: amount,
          status: _status,
          date: AppDateFormatter.toDatabaseIsoDate(_selectedDate),
          createdAt: current.createdAt,
          updatedAt: now,
        );
        await _repository.update(updated);
      } else {
        final session = Session(
          clientId: clientId,
          procedure: _procedureController.text.trim(),
          notes: _notesController.text.trim(),
          amount: amount,
          status: _status,
          date: AppDateFormatter.toDatabaseIsoDate(_selectedDate),
          createdAt: now,
          updatedAt: now,
        );
        await _repository.save(session);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Sessao' : 'Nova Sessao'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_loadingClients)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: LinearProgressIndicator(),
                ),
              if (widget.clientId == null) ...[
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Cliente',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  initialValue: _selectedClientId,
                  items: _clients
                      .map(
                        (client) => DropdownMenuItem<int>(
                          value: client.id,
                          child: Text(client.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedClientId = value);
                  },
                ),
                const SizedBox(height: 20),
              ],
              GestureDetector(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.purple),
                      const SizedBox(width: 12),
                      Text(AppDateFormatter.toPtBr(_selectedDate)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _procedureController,
                decoration: InputDecoration(
                  labelText: 'Procedimento',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o procedimento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Observacoes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                decoration: InputDecoration(
                  labelText: 'Valor cobrado (R\$)',
                  prefixText: 'R\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o valor';
                  }
                  final amount = double.tryParse(value.replaceAll(',', '.'));
                  if (amount == null || amount < 0) {
                    return 'Valor invalido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                initialValue: _status,
                items: const [
                  DropdownMenuItem(
                    value: Session.statusScheduled,
                    child: Text('AGENDADO'),
                  ),
                  DropdownMenuItem(
                    value: Session.statusPaid,
                    child: Text('PAGO'),
                  ),
                  DropdownMenuItem(
                    value: Session.statusCanceled,
                    child: Text('CANCELADO'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _status = value);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEdit ? 'Atualizar' : 'Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
