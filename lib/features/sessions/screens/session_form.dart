import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/app_date_formatter.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/session_repository.dart';

class SessionForm extends StatefulWidget {
  final int clientId;
  final Session? session;

  const SessionForm({super.key, required this.clientId, this.session});

  @override
  State<SessionForm> createState() => _SessionFormState();
}

class _SessionFormState extends State<SessionForm> {
  final SessionRepository _repository = SessionRepository();
  final _formKey = GlobalKey<FormState>();

  final _procedureController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  bool get _isEdit => widget.session != null;

  @override
  void initState() {
    super.initState();
    final session = widget.session;
    if (session != null) {
      _procedureController.text = session.procedure;
      _notesController.text = session.notes;
      _amountController.text = session.amount.toStringAsFixed(2);
      _selectedDate = _parseDatabaseDate(session.date) ?? DateTime.now();
    }
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

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final amount = double.parse(_amountController.text.replaceAll(',', '.'));
      final now = DateTime.now();

      if (_isEdit) {
        final current = widget.session!;
        final updated = Session(
          id: current.id,
          clientId: widget.clientId,
          procedure: _procedureController.text.trim(),
          notes: _notesController.text.trim(),
          amount: amount,
          date: AppDateFormatter.toDatabaseIsoDate(_selectedDate),
          createdAt: current.createdAt,
          updatedAt: now,
        );
        await _repository.update(updated);
      } else {
        final session = Session(
          clientId: widget.clientId,
          procedure: _procedureController.text.trim(),
          notes: _notesController.text.trim(),
          amount: amount,
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
