import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cliente.dart';
import '../models/atendimento.dart';

class DbHelper {

  static Database? _banco;

  Future<Database> get banco async {
    if (_banco != null) return _banco!;
    _banco = await _inicarBanco();
    return _banco!;
  }

  Future<Database> _inicarBanco() async {
    String caminho = join(await getDatabasesPath(), 'meu_studio.db');

    return await openDatabase(
      caminho,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clientes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            telefone TEXT,
            observacao TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE atendimentos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cliente_id INTEGER NOT NULL,
            procedimento TEXT NOT NULL,
            valor REAL NOT NULL,
            data TEXT NOT NULL,
            FOREIGN KEY (cliente_id) REFERENCES clientes(id)
          )
        ''');
      },
    );
  }

  // ----------CLIENTES--------------------------------------------------

  Future<int> salvarCliente(Cliente cliente) async {
    final db = await banco;
    return await db.insert('clientes', {
      'nome': cliente.nome,
      'telefone': cliente.telefone,
      'observacao': cliente.observacao,
    });
  }


  Future<List<Cliente>> buscarClientes() async {
    final db = await banco;
    final List<Map<String, dynamic>> resultado = await db.query('clientes');

    return resultado.map((map) => Cliente(
      id: map['id'],
      nome: map['nome'],
      telefone: map['telefone'],
      observacao: map['observacao'],
    )).toList();
  }

  // ─── ATENDIMENTOS ─────────────────────────────────────

  Future<int> salvarAtendimento(Atendimento atendimento) async {
    final db = await banco;
    return await db.insert('atendimentos', {
      'cliente_id': atendimento.clienteId,
      'procedimento': atendimento.procedimento,
      'valor': atendimento.valor,
      'data': atendimento.data,
    });
  }

  Future<double> buscarTotalMes(int mes, int ano) async {
    final db = await banco;
    final resultado = await db.rawQuery('''
      SELECT SUM(valor) as total
      FROM atendimentos
      WHERE strftime('%m', data) = ?
      AND strftime('%Y', data) = ?
    ''', [mes.toString().padLeft(2, '0'), ano.toString()]);

    return resultado.first['total'] as double? ?? 0.0;
  }

  Future<int> buscarQuantidadeAtedimentosMes(int mes, int ano) async {
    final db = await banco;
    final resultado = await db.rawQuery('''
      SELECT COUNT(*) as quantidade
      FROM atendimentos
      WHERE strftime('%m', data) = ?
      AND strftime('%Y', data) = ?  
    ''', [mes.toString().padLeft(2, '0'), ano.toString()]);

    return resultado.first['quantidade'] as int? ?? 0;
  }

}