import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/services/session_history_pdf_service.dart';
import 'client_register.dart';
import '../../anamnesis/screens/anamnesis.dart';
import '../../sessions/screens/session_list.dart';

class ClientList extends StatefulWidget {
  const ClientList({super.key});

  @override
  State<ClientList> createState() => _ClientListState();
}

class _ClientListState extends State<ClientList> {
  final ClientRepository _clientRepository = ClientRepository();
  final SessionRepository _sessionRepository = SessionRepository();
  final SessionHistoryPdfService _sessionPdfService =
      const SessionHistoryPdfService();
  List<Client> _clients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await _clientRepository.findAll();
    if (!mounted) return;
    setState(() {
      _clients = clients;
      _isLoading = false;
    });
  }

  void _deleteClient(int clientId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja deletar este cliente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirm == true) {
      await _clientRepository.delete(clientId);
      await _loadClients();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Cliente deletado com sucesso!')));
    }
  }

  Future<void> _openSessionsPdf(Client client) async {
    try {
      final sessions = await _sessionRepository.findByClientId(client.id!);
      final bytes = await _sessionPdfService.generate(
        client: client,
        sessions: sessions,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'historico-sessoes-${client.name}.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gerar PDF: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clients.isEmpty
          ? _emptyScreen()
          : _clientList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ClientRegister()),
          );
          _loadClients();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _emptyScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Nenhum cliente cadastrado',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque no + para adicionar',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _clientList() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: _clients.length,
      itemBuilder: (context, index) {
        final client = _clients[index];

        return Material(
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Visualizar/Editar'),
                        onTap: () {
                          Navigator.pop(context);
                          //Editar cliente
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ClientRegister(client: client),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.description),
                        title: Text('Ficha de Anamnese'),
                        onTap: () {
                          Navigator.pop(context);
                          //Abrir ficha de anamnese
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AnamnesisScreen(client: client),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.event_note_outlined),
                        title: Text('Sessoes de Atendimento'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SessionList(client: client),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.picture_as_pdf_outlined),
                        title: Text('PDF de Sessoes'),
                        onTap: () {
                          Navigator.pop(context);
                          _openSessionsPdf(client);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text(
                          'Deletar',
                          style: TextStyle(color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          //Deletar cliente
                          _deleteClient(client.id!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade50,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text(
                      client.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          client.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.phone.isEmpty ? 'Sem telefone' : client.phone,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
