import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'models/cliente.dart';
import 'database/db_helper.dart';
import 'screens/cadastro_cliente.dart';
import 'screens/lista_clientes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/novo_atendimento.dart';

void main() {
  //Inicializa o SQLite para Linux/Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Estúdio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      ),
      home: const Dashboard(),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
    );
  }
}

// ─── DASHBOARD ───────────────────────────────────────
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DbHelper _db = DbHelper();
  double _total = 0;
  int _quantidade = 0;
  bool _carregando = true;

  //Roda automaticamente quando a tela abre
  @override
  void initState(){
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final agora = DateTime.now();
    final total = await _db.buscarTotalMes(agora.month, agora.year);
    final quantidade = await _db.buscarQuantidadeAtedimentosMes(agora.month, agora.year);

    setState(() {
      _total = total;
      _quantidade = quantidade;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Estúdio'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _carregando
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
                        style: TextStyle(
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
                            '${_quantidade} atendimentos',
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
                        MaterialPageRoute(builder: (_) => const NovoAtendimento()),
                      );
                      _carregarDados();
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ListaClientes()),
                      );
                      _carregarDados();
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

              ],
            ),
          ),
        );
  }
}

// ─── TELA 2: LISTA DE CLIENTES ────────────────────────────────
