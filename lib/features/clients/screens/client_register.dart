import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/models/client.dart';

class ClientRegister extends StatefulWidget{
  final Client? client; // null = new, filled = edition
  
  const ClientRegister({super.key, this.client});

  @override
  State<ClientRegister> createState() => _ClientRegisterState();
}

class _ClientRegisterState extends State<ClientRegister> {
  final ClientRepository _clientRepository = ClientRepository();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  //Controllers capturam o que o usuário digita
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  //Regex numero telefone
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  
  bool get _editing => widget.client != null;

  @override
  void initState() {
    super.initState();
    //Se for edição vai preencher os campos com os dados existentes
    if(_editing) {
      _nameController.text = widget.client!.name;
      _phoneController.text = widget.client!.phone;
      _notesController.text = widget.client!.notes;
    }
  }

  //Libera os controllers da memória quando a tela fechar
  @override
  void dispose(){
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if(!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final client = Client(
      id: widget.client?.id, //Vai manter o mesmo ID se for edição
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      notes: _notesController.text.trim(),
    );

    if(_editing) {
      await _clientRepository.update(client);
    } else {
      await _clientRepository.save(client);
    }

    // Volta para a tela anterior
    if(mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Campo Nome
              const Text('Nome', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
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
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneFormatter],
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
                controller: _notesController,
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
                      ? const CircularProgressIndicator()
                      : Text(
                        _editing? 'Salvar alterações' : 'Salvar',
                        style: const TextStyle(fontSize: 16),
                      ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}