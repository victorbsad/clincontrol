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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
            primary: Color(0xFF6A1B9A), // Cor roxa para o header
            onPrimary: Colors.white, // Cor do
            surface: Colors.white,
            onSurface: Colors.black87,    
            ),
          ),
          child: child!,
        );
      },  
    );

    if (!mounted) return;
    if (picked != null) setState(() => _selectedDate = picked);
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
    InputDecoration fieldDeco(String label, {Widget? prefixIcon, String? hintText}) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black38),
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCE93D8), width: 1), 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6A1B9A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC62828), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar Sessão' : 'Nova Sessão'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 253, 247, 255),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Loading clientes ──
              if (_loadingClients)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(
                    color: Color(0xFF6A1B9A),
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),

              // ── Cliente ──
              if (widget.clientId == null) ...[
                Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: const InputDecorationTheme(
                      constraints:BoxConstraints(maxHeight: 48),
                    ),
                  ),
                
                  child: DropdownButtonFormField<int>(
                    decoration: fieldDeco('Cliente',
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.black54),
                      hintText: 'Selecione o cliente'),
                    initialValue: _selectedClientId,
                    isExpanded: true,
                    menuMaxHeight: 250,
                    borderRadius: BorderRadius.circular(12),
                    items: _clients.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedClientId = v),
                  ),
                ),  
                const SizedBox(height: 16),
              ],

              // ── Data ──
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: fieldDeco('Data', 
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.black54)),
                  child: Text(
                    AppDateFormatter.toPtBr(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Procedimento ──
              TextFormField(
                controller: _procedureController,
                decoration: fieldDeco('Procedimento',
                  prefixIcon: const Icon(Icons.medical_services_outlined, color: Colors.black54),
                  hintText: 'Ex: Massagem Relaxante',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o procedimento' : null,
              ),
              const SizedBox(height: 16),

              // ── Observações ──
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: fieldDeco('Observações',
                  prefixIcon: const Icon(Icons.note_outlined, color: Colors.black54),
                  hintText: 'Ex: Cliente apresentou sintomas de gripe',
                ),
              ),
              const SizedBox(height: 16),

              // ── Valor ──
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
                decoration: fieldDeco('Valor cobrado',
                  prefixIcon: const Icon(Icons.attach_money, color: Colors.black54),
                  hintText: 'Ex: 150,00',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o valor';
                  final amount = double.tryParse(v.replaceAll(',', '.'));
                  if (amount == null || amount < 0) return 'Valor inválido';
                  if (amount > 10000) return 'Valor máximo: R\$ 10.000,00';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Status ──
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    constraints:BoxConstraints(maxHeight: 48),
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: fieldDeco('Status',
                    prefixIcon: const Icon(Icons.flag_outlined, color: Colors.black54),
                    hintText: 'Selecione o status',
                  ),
                  initialValue: _status,
                  isExpanded: true,
                  menuMaxHeight: 180,
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    _statusItem(Session.statusScheduled, 'Agendado', const Color(0xFF1565C0)),
                    _statusItem(Session.statusPaid, 'Pago', const Color(0xFF2E7D32)),
                    _statusItem(Session.statusCanceled, 'Cancelado', const Color(0xFFC62828)),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _status = v);
                  },
                ),
              ),  
              const SizedBox(height: 32),

              // ── Botão salvar ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isEdit ? 'Atualizar Sessão' : 'Salvar Sessão',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para os itens coloridos do status
  DropdownMenuItem<String> _statusItem(
      String value, String label, Color color) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
