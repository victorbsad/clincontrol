import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/atendimento.dart';
import '../models/cliente.dart';
import '../database/db_helper.dart';

class NovoAtendimento extends StatefulWidget {
  const NovoAtendimento({super.key});

  @override
  State<NovoAtendimento> createState() => _NovoAtendimentoState();
}

class _NovoAtendimentoState extends State<NovoAtendimento> {
  final DbHelper _db = DbHelper();
  final _formKey = GlobalKey<FormState>();
  bool _salvando = false;

  //Lista de clientes para dropdown
  List<Cliente> _clientes = [];
  Cliente? _clienteSelecionado;

  //Controllers
  final _procedimentoController = TextEditingController();
  final _valorController = TextEditingController();

  //Data começa com hoje
  DateTime _dataSelecionada = DateTime.now();

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  @override
  void dispose() {
    _procedimentoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _carregarClientes() async {
    final clientes = await _db.buscarClientes();
    setState(() => _clientes = clientes);
  }

  //Abre o seletor de data
  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (data != null) {
      setState(() => _dataSelecionada = data);
    }
  }

  String get _dataFormatada {
    return '${_dataSelecionada.day.toString().padLeft(2, '0')}/'
        '${_dataSelecionada.month.toString().padLeft(2, '0')}/'
        '${_dataSelecionada.year}';
  }

  String get _dataParaBanco {
    return '${_dataSelecionada.year}-'
        '${_dataSelecionada.month.toString().padLeft(2, '0')}-'
        '${_dataSelecionada.day.toString().padLeft(2, '0')}';
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente')),
      );
      return;
    }

    setState(() => _salvando = true);

    final atendimento = Atendimento(
      clienteId: _clienteSelecionado!.id!,
      procedimento: _procedimentoController.text.trim(),
      valor: double.parse(_valorController.text.replaceAll(',', '.')),
      data: _dataParaBanco,
    );

    await _db.salvarAtendimento(atendimento);

    if(mounted) Navigator.pop(context);
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
              const Text('Cliente', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Cliente>(
                    hint: const Text('Selecionar cliente...'),
                    value: _clienteSelecionado,
                    isExpanded: true,
                    items: _clientes.map((cliente) {
                      return DropdownMenuItem<Cliente>(
                        value: cliente,
                        child: Text(cliente.nome),
                      );
                    }).toList(),
                    onChanged: (cliente) {
                      setState(() => _clienteSelecionado = cliente);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //Campo data
              const Text('Data', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selecionarData,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.purple, size: 20),
                      const SizedBox(width: 12),
                      Text(_dataFormatada, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //Camo Procedimento
              const Text('Procedimento', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _procedimentoController,
                decoration: InputDecoration(
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
              const Text('Valor cobrado (R\$)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                decoration: InputDecoration(
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
                  final valor = double.tryParse(value.replaceAll(',', '.'));
                  if (valor == null || valor <= 0) {
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
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _salvando
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