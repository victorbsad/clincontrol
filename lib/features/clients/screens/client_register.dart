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
  final _maritalStatusController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _addressController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _ageController = TextEditingController();
  final _professionController = TextEditingController();

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
      _maritalStatusController.text = widget.client!.maritalStatus;
      _nationalityController.text = widget.client!.nationality;
      _addressController.text = widget.client!.address;
      _whatsappController.text = widget.client!.whatsapp;
      _emailController.text = widget.client!.email;
      _dateOfBirthController.text = widget.client!.dateOfBirth;
      _ageController.text = widget.client!.age;
      _professionController.text = widget.client!.profession;
    }
  }

  //Libera os controllers da memória quando a tela fechar
  @override
  void dispose(){
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _maritalStatusController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _ageController.dispose();
    _professionController.dispose();
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
      maritalStatus: _maritalStatusController.text.trim(),
      nationality: _nationalityController.text.trim(),
      address: _addressController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      email: _emailController.text.trim(),
      dateOfBirth: _dateOfBirthController.text.trim(),
      age: _ageController.text.trim(),
      profession: _professionController.text.trim(),
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

              const Text('Estado civil', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _maritalStatusController,
                decoration: InputDecoration(
                  hintText: 'Ex: Solteira',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Nacionalidade', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nationalityController,
                decoration: InputDecoration(
                  hintText: 'Ex: Brasileira',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Endereço', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Ex: Rua Exemplo, 123 - Bairro',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneFormatter],
                decoration: InputDecoration(
                  hintText: 'Ex: (54) 99999-1234',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Ex: nome@email.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final email = value.trim();
                  final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                  if (!emailRegex.hasMatch(email)) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text('Data de nascimento', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: InputDecoration(
                  hintText: 'Ex: 1994-05-20',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Idade', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Ex: 31',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text('Profissão', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _professionController,
                decoration: InputDecoration(
                  hintText: 'Ex: Esteticista',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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