import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/config/app_environment.dart';
import '../../../data/dev/mock_models.dart';
import '../../../data/models/client.dart';
import '../../../data/repositories/anamnesis_repository.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/services/anamnesis_pdf_service.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/services/session_history_pdf_service.dart';
import '../../clients/screens/client_list.dart';
import '../../debug/debug_navigation.dart';
import '../../sessions/screens/session_form.dart';

// ─── DASHBOARD ───────────────────────────────────────
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ClientRepository _clientRepository = ClientRepository();
  final AnamnesisRepository _anamnesisRepository = AnamnesisRepository();
  final AnamnesisPdfService _pdfService = const AnamnesisPdfService();
  final SessionRepository _sessionRepository = SessionRepository();
  final SessionHistoryPdfService _sessionPdfService =
      const SessionHistoryPdfService();
  double _total = 0;
  int _count = 0;
  bool _isLoading = true;

  //Roda automaticamente quando a tela abre
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final total = await _sessionRepository.getMonthlyTotal(now.month, now.year);
    final count = await _sessionRepository.getMonthlyCount(now.month, now.year);

    setState(() {
      _total = total;
      _count = count;
      _isLoading = false;
    });
  }

  Future<void> _openSeedPdf() async {
    try {
      final clients = await _clientRepository.findAll();
      Client? client;
      for (final item in clients) {
        if (DevMockModels.isDevMockClient(item)) {
          client = item;
          break;
        }
      }
      final anamneses = client == null
          ? const []
          : await _anamnesisRepository.findByClientId(client.id!);
      final anamnesis = anamneses.isNotEmpty ? anamneses.first : null;

      if (client == null || anamnesis == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seed de anamnese não encontrado.')),
        );
        return;
      }

      final bytes = await _pdfService.generate(
        client: client,
        anamnesis: anamnesis,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'anamnese-cliente-dev.pdf',
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gerar PDF: $error')));
    }
  }

  Future<void> _openSeedSessionsPdf() async {
    try {
      final clients = await _clientRepository.findAll();
      Client? client;
      for (final item in clients) {
        if (DevMockModels.isDevMockClient(item)) {
          client = item;
          break;
        }
      }

      if (client == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente seed não encontrado.')),
        );
        return;
      }

      final sessions = await _sessionRepository.findByClientId(client.id!);
      final bytes = await _sessionPdfService.generate(
        client: client,
        sessions: sessions,
      );

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
        name: 'historico-sessoes-cliente-dev.pdf',
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
        title: const Text('Meu Estúdio'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          if (AppEnvironment.devToolsEnabled)
            IconButton(
              tooltip: 'PDF de anamnese (teste)',
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: _openSeedPdf,
            ),
          if (AppEnvironment.devToolsEnabled)
            IconButton(
              tooltip: 'PDF de sessoes (teste)',
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: _openSeedSessionsPdf,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Olá! 👋',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Veja como está seu mês',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // Card total do mês
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total do mês',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'R\$ ${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Card atendimentos
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple.shade100),
                    ),
                    child: Row(
                      children: [
                        const Text('📆', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_count atendimentos',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'no mês atual',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botão Novo Atendimento
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SessionForm(),
                          ),
                        );
                        _loadData();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nova Sessao'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botão Clientes
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ClientList()),
                        );
                        _loadData();
                      },
                      icon: const Icon(Icons.people),
                      label: const Text('Clientes'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.purple,
                        side: const BorderSide(color: Colors.purple),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Botão Lab CRUD
                  if (AppEnvironment.devToolsEnabled)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => DebugNavigation.openCrudLab(context),
                        icon: const Icon(Icons.science_outlined),
                        label: const Text('Lab CRUD (teste)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
