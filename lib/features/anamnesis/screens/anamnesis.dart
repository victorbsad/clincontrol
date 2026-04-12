import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/anamnesis.dart';
import '../../../data/models/client.dart';
import '../../../data/database/db_helper.dart';

class AnamnesisScreen extends StatefulWidget {
  final Client client;

  const AnamnesisScreen({required this.client});

  @override
  State<AnamnesisScreen> createState() => _AnamnesisScreenState();
}

class _AnamnesisScreenState extends State<AnamnesisScreen> {
  late DbHelper dbHelper;
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, bool> _checkboxValues = {};

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();

    // Inicializa estado dos checkboxes
    for (var field in fields) {
      if (field['type'] == 'bool') {
        _checkboxValues[field['key']] = false;
      }
    }
  }

  final List<Map<String, dynamic>> fields = [
    {'key': 'estadoCivil', 'label': 'Estado Civil', 'type': 'text'},
    {'key': 'nacionalidade', 'label': 'Nacionalidade', 'type': 'text'},
  ];

  void saveData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await dbHelper.insertAnamnesis(
        Anamnesis(
          clientId: widget.client.id!,
          answers: _formData,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anamnese de ${widget.client.name} salva com sucesso!'),
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Anamnese - ${widget.client.name}')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            //Dados do cliente em read-only
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome: ${widget.client.name}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Telefone: ${widget.client.phone}'),
                    if (widget.client.notes.trim().isNotEmpty)
                      Text('Notas: ${widget.client.notes}'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            ...fields.map((field) {
              if (field['type'] == 'bool') {
                return CheckboxListTile(
                  title: Text(field['label']),
                  value: _checkboxValues[field['key']] ?? false,
                  onChanged: (value) {
                    setState(() {
                      _checkboxValues[field['key']] = value ?? false;
                      _formData[field['key']] = value;
                    });
                  },
                );
              } else if (field['type'] == 'number') {
                return TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: field['label']),
                  onSaved: (value) {
                    if (value?.isNotEmpty ?? false) {
                      _formData[field['key']] = int.tryParse(value!) ?? 0;
                    }
                  },
                );
              } else {
                return TextFormField(
                  decoration: InputDecoration(labelText: field['label']),
                  onSaved: (value) {
                    if (value?.isNotEmpty ?? false) {
                      _formData[field['key']] = value;
                    }
                  },
                );
              }
            }).toList(),

            SizedBox(height: 20),
            ElevatedButton(onPressed: saveData, child: Text('Salvar Anamnese')),
          ],
        ),
      ),
    );
  }
}
