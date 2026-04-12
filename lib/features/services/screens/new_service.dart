import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/app_date_formatter.dart';
import '../../../data/models/service.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/models/client.dart';

class NewService extends StatefulWidget {
  const NewService({super.key});

  @override
  State<NewService> createState() => _NewServiceState();
}

class _NewServiceState extends State<NewService> {
  final ServiceRepository _serviceRepository = ServiceRepository();
  final ClientRepository _clientRepository = ClientRepository();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  //Lista de clientes para dropdown
  List<Client> _clients = [];
  Client? _selectedClient;

  //Controllers
  final _procedureController = TextEditingController();
  final _amountController = TextEditingController();

  //Data começa com hoje
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _procedureController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    final clients = await _clientRepository.findAll();
    setState(() => _clients = clients);
  }

  //Abre o seletor de data
  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (selectedDate != null) {
      setState(() => _selectedDate = selectedDate);
    }
  }

  String get _formattedDate {
    return AppDateFormatter.toPtBr(_selectedDate);
  }

  String get _dateToDatabase {
    return AppDateFormatter.toDatabaseIsoDate(_selectedDate);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um cliente')));
      return;
    }

    setState(() => _saving = true);

    final service = Service(
      clientId: _selectedClient!.id!,
      procedure: _procedureController.text.trim(),
      amount: double.parse(_amountController.text.replaceAll(',', '.')),
      date: _dateToDatabase,
    );

    await _serviceRepository.save(service);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Atendimento'),
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
              //Campo Cliente
              DropdownButtonFormField<Client>(
                decoration: InputDecoration(
                  labelText: 'Cliente',
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                hint: const Text('Selecionar cliente...'),
                initialValue: _selectedClient,
                isExpanded: true,
                items: _clients.map((client) {
                  return DropdownMenuItem<Client>(
                    value: client,
                    child: Text(client.name),
                  );
                }).toList(),
                onChanged: (client) {
                  setState(() => _selectedClient = client);
                },
              ),

              const SizedBox(height: 20),

              //Campo data
              GestureDetector(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data',
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.purple,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formattedDate,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //Camo Procedimento
              TextFormField(
                controller: _procedureController,
                decoration: InputDecoration(
                  labelText: 'Procedimento',
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  hintText: 'Ex: Limpeza de pele, design de sobrancelha...',
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

              //Campo Valor
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
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  hintText: '0,00',
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
                  if (amount == null || amount <= 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              //Botão Salvar
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
                      : const Text('Salvar', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
