import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../models/cliente.dart';
import '../database/db_helper.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

class CadastroCliente extends StatefulWidget{
  const CadastroCliente({super.key});

  @override
  State<CadastroCliente> createState() => _CadastroClienteState();
}

class _CadastroClienteState extends State<CadastroCliente> {
  final DbHelper _db = DbHelper();
  final _formKey = GlobalKey<FormState>();
  bool _salvando = false;

  //Controllers capturam o que o usuário digita
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _observacaoController = TextEditingController();

  //Regex numero telefone
  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  //Libera os controllers da memória quando a tela fechar
  @override
  void dispose(){
    _nomeController.dispose();
    _telefoneController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    //Valida o formulário - se tiver erro, para aqui
    if(!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final cliente = Cliente(
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      observacao: _observacaoController.text.trim(),
    );

    await _db.salvarCliente(cliente);

    // Volta para a tela anterior
    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Cliente'),
        backgroundColor:  Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Campo Nome
              const Text('Nome', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomeController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZÀ-ÿ\s]')),
                ],
                decoration: InputDecoration(
                  hintText: 'Ex: Ana Silva',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nome é obrigatório';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              //Campo Telefone
              const Text('Telefone', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [_telefoneFormatter],
                decoration: InputDecoration(
                  hintText: 'Ex: (54) 99999-1234',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 15) {
                    return 'Telefone incompleto';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              //Campo Observação
              const Text('Observação', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _observacaoController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Pele sensível, alergias...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //Botão salvar
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