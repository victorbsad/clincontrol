import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../data/repositories/anamnesis_repository.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/services/anamnesis_pdf_service.dart';
import '../../clients/screens/client_list.dart';
import '../../debug/screens/crud_test_page.dart';
import '../../services/screens/new_service.dart';

// ─── DASHBOARD ───────────────────────────────────────
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final ServiceRepository _repository = ServiceRepository();
  final ClientRepository _clientRepository = ClientRepository();
  final AnamnesisRepository _anamnesisRepository = AnamnesisRepository();
  final AnamnesisPdfService _pdfService = const AnamnesisPdfService();
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
    final total = await _repository.getMonthlyTotal(now.month, now.year);
    final count = await _repository.getMonthlyCount(now.month, now.year);

    setState(() {
      _total = total;
      _count = count;
      _isLoading = false;
    });
  }

  Future<void> _openSeedPdf() async {
    try {
      final client = await _clientRepository.findById(1);
      final anamneses = await _anamnesisRepository.findByClientId(1);
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
        name: 'anamnese-cliente-1.pdf',
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
          if (kDebugMode)
            IconButton(
              tooltip: 'Gerar PDF de teste',
              icon: const Icon(Icons.picture_as_pdf_outlined),
              onPressed: _openSeedPdf,
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
                          MaterialPageRoute(builder: (_) => const NewService()),
                        );
                        _loadData();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Novo Atendimento'),
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CrudTestPage(),
                          ),
                        );
                      },
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
