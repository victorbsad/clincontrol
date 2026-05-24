# ClinControl - Sumário Técnico do Projeto

## 📋 Índice
1. [Estrutura de Pastas e Features](#estrutura-de-pastas-e-features)
2. [Modelos de Dados](#modelos-de-dados)
3. [Padrões de UI](#padrões-de-ui)
4. [Navegação](#navegação)
5. [Banco de Dados](#banco-de-dados)
6. [Formatação de Datas](#formatação-de-datas)
7. [Tema e Cores](#tema-e-cores)
8. [Padrões de Repositório (CRUD)](#padrões-de-repositório-crud)
9. [Dependências](#dependências)

---

## 1. Estrutura de Pastas e Features

### Estrutura Principal
```
lib/
├── core/                          # Configurações globais
│   ├── config/
│   │   └── app_environment.dart   # Configuração de ambiente (dev tools)
│   ├── constants/
│   │   ├── anamnesis_enums.dart   # Enums para Anamnese
│   │   ├── anamnesis_keys.dart    # Chaves dos campos de Anamnese
│   │   └── anamnesis_field_specs.dart # Especificações dos campos
│   ├── theme/
│   │   └── app_theme.dart         # Tema, cores e estilo global
│   └── utils/
│       └── app_date_formatter.dart # Formatação de datas
│
├── data/                          # Camada de dados
│   ├── database/
│   │   ├── database_config.dart   # Configuração plataforma-específica
│   │   ├── database_config_io.dart # Configuração para Desktop/Mobile
│   │   ├── database_config_web.dart # Configuração para Web
│   │   ├── db_helper.dart         # Gerenciador principal do banco
│   │   ├── db_helper_clients.dart # CRUD de Clientes
│   │   ├── db_helper_sessions.dart # CRUD de Sessões
│   │   ├── db_helper_anamnesis.dart # CRUD de Anamnese
│   │   └── db_helper_users.dart   # CRUD de Usuários
│   │
│   ├── models/                    # Classes de domínio
│   │   ├── client.dart            # Modelo de Cliente
│   │   ├── session.dart           # Modelo de Sessão
│   │   ├── user.dart              # Modelo de Usuário
│   │   └── anamnesis.dart         # Modelo de Anamnese
│   │
│   ├── repositories/              # Acesso aos dados (Repository Pattern)
│   │   ├── client_repository.dart
│   │   ├── session_repository.dart
│   │   ├── anamnesis_repository.dart
│   │   └── user_repository.dart
│   │
│   ├── services/                  # Serviços de negócio
│   │   ├── session_history_pdf_service.dart
│   │   ├── anamnesis_pdf_service.dart
│   │   └── pdf/
│   │
│   └── dev/                       # Dados de desenvolvimento
│       ├── development_seeder.dart # Popula banco com dados de teste
│       └── mock_models.dart       # Modelos mock para testes
│
└── features/                      # Features (telas)
    ├── dashboard/
    │   └── screens/
    │       └── dashboard.dart     # Tela inicial (resumo mensal)
    ├── clients/
    │   └── screens/
    │       ├── client_list.dart   # Listagem de clientes
    │       └── client_register.dart # Cadastro/edição de cliente
    ├── sessions/
    │   └── screens/
    │       ├── session_list.dart  # Listagem de sessões (por cliente)
    │       └── session_form.dart  # Formulário de sessão
    ├── anamnesis/
    │   └── screens/
    │       └── anamnesis.dart     # Formulário de anamnese
    ├── users/
    │   └── screens/
    │       └── user_profile_screen.dart # Perfil do usuário
    └── debug/
        ├── debug_navigation.dart  # Acesso ao modo debug
        └── screens/
            └── crud_test_page.dart # Tela de testes CRUD (dev)
```

### Features Implementadas

| Feature | Descrição | Telas |
|---------|-----------|-------|
| **Dashboard** | Resumo mensal de atendimentos e faturamento | dashboard.dart |
| **Clientes** | CRUD completo de clientes | client_list.dart, client_register.dart |
| **Sessões** | Registro de atendimentos/procedimentos por cliente | session_list.dart, session_form.dart |
| **Anamnese** | Formulário de histórico clínico do cliente | anamnesis.dart |
| **Usuário** | Gerenciamento de perfil do usuário | user_profile_screen.dart |
| **Debug** | Testes de CRUD em desenvolvimento | crud_test_page.dart |

---

## 2. Modelos de Dados

### 2.1 Client (Cliente)
```dart
class Client {
  int? id;                    // ID da base de dados (auto-increment)
  String name;                // Nome completo (obrigatório)
  String phone;               // Telefone
  String notes;               // Notas gerais
  String maritalStatus;       // Estado civil (ex: "Solteira")
  String nationality;         // Nacionalidade (ex: "Brasileira")
  String address;             // Endereço completo
  String whatsapp;            // Número do WhatsApp
  String email;               // E-mail
  String dateOfBirth;         // Data de nascimento (formato: dd/mm/yyyy)
  String age;                 // Idade
  String profession;          // Profissão
  DateTime? deletedAt;        // Data de exclusão (soft delete)
}
```

**Padrão de Exclusão:** Soft delete (usa campo `deletedAt`). Clientes "deletados" podem ser restaurados.

### 2.2 Session (Sessão de Atendimento)
```dart
class Session {
  int? id;
  int clientId;               // FK para Client
  String procedure;           // Nome do procedimento
  String notes;               // Notas sobre o atendimento
  double amount;              // Valor do atendimento
  String status;              // Status (AGENDADO, PAGO, CANCELADO)
  String date;                // Data no formato ISO (YYYY-MM-DD)
  DateTime createdAt;         // Criado em
  DateTime updatedAt;         // Atualizado em
  
  // Constantes de Status
  static const String statusScheduled = 'AGENDADO';
  static const String statusPaid = 'PAGO';
  static const String statusCanceled = 'CANCELADO';
  static const List<String> allowedStatuses = [
    statusScheduled,
    statusPaid,
    statusCanceled,
  ];
}
```

**Validações:**
- Valor (`amount`) deve ser >= 0
- Status deve estar em `allowedStatuses`
- Data armazenada em ISO format (YYYY-MM-DD)

### 2.3 AppUser (Usuário do App)
```dart
class AppUser {
  int? id;
  String name;                // Nome do profissional
  String email;               // E-mail único
  String passwordHash;        // Hash SHA-256 da senha
  bool isCurrent;             // Indica se é o usuário atual
  DateTime createdAt;
  DateTime updatedAt;
}
```

**Segurança:** Senhas são armazenadas como hash SHA-256 (using `crypto` package).

### 2.4 Anamnesis (Histórico Clínico)
```dart
class Anamnesis {
  int? id;
  int clientId;               // FK para Client
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> answers; // Dicionário de respostas tipadas
  
  // Getters/Setters com type safety para enums
  AnamnesisVisitReasonOption? get visitReasonOption
  AnamnesisSmokingStatus? get smokingStatus
  AnamnesisPressureStatus? get hypertensionStatus
  // ... mais campos
}
```

**Estrutura Flexível:** Usa padrão key-value com suporte a múltiplos tipos:
- `bool`, `int`, `decimal`, `date`, `enum`, `json`, `text`

**Armazenamento:** Tabelas `anamneses` + `anamnesis_answers` (normalizado).

---

## 3. Padrões de UI

### 3.1 Estrutura Geral das Telas

Todas as telas seguem padrão Material 3:

```dart
Scaffold(
  appBar: AppBar(
    title: Text('Título'),
    backgroundColor: Colors.purple,        // Cor primária (roxo)
    foregroundColor: Colors.white,
  ),
  body: // Conteúdo principal,
  floatingActionButton: // Botão de ação (FAB) - opcional,
)
```

### 3.2 Componentes Comuns

#### AppBar Padrão
- **Cor:** `Colors.purple` (roxo principal)
- **Texto:** Branco
- **Ações:** Ícones no topo direito

#### Botões

**FloatingActionButton (FAB) - Criar/Adicionar**
```dart
FloatingActionButton(
  onPressed: () { /* Navega para formulário */ },
  backgroundColor: Colors.purple,
  child: const Icon(Icons.add, color: Colors.white),
)
```

**TextButton - Cancelar**
```dart
TextButton(
  onPressed: () => Navigator.pop(context),
  child: const Text('Cancelar'),
)
```

**TextButton - Deletar (Vermelho)**
```dart
TextButton(
  onPressed: () => /* ação */ ,
  child: const Text('Deletar', style: TextStyle(color: Colors.red)),
)
```

#### Formulários

**TextFormField Padrão**
```dart
TextFormField(
  controller: _controller,
  decoration: InputDecoration(
    labelText: 'Rótulo',
    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    hintText: 'Ex: Exemplo',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12), // Borda arredondada
    ),
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  },
)
```

**DropdownButtonFormField**
```dart
DropdownButtonFormField<String?>(
  decoration: InputDecoration(
    labelText: 'Status',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    isDense: true,
  ),
  items: [
    DropdownMenuItem(value: 'AGENDADO', child: Text('AGENDADO')),
    // ... mais opções
  ],
  onChanged: (value) { /* atualiza estado */ },
)
```

**Seletor de Data**
```dart
GestureDetector(
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('pt', 'BR'), // Português Brasil
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  },
  child: InputDecorator(
    decoration: InputDecoration(/* ... */),
    child: Text(AppDateFormatter.toPtBr(_selectedDate)),
  ),
)
```

#### Cards (Listas)

**Card de Cliente (ClientList)**
```dart
Card(
  child: ListTile(
    title: Text(client.name),
    subtitle: Text(client.phone),
    trailing: IconButton(
      icon: Icon(Icons.more_vert),
      onPressed: () { /* Menu de ações */ },
    ),
    onTap: () { /* Abre detalhes ou menu */ },
  ),
)
```

#### Diálogos

**AlertDialog - Confirmação de Exclusão**
```dart
AlertDialog(
  title: Text('Confirmar exclusão'),
  content: Text('Tem certeza que deseja deletar?'),
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
)
```

#### Bottom Sheet (Menu Modal)

Usado para exibir opções contextuais (ex: editar, deletar, gerar PDF):

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Container(
    padding: EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text('Editar'),
          onTap: () { /* ação */ },
        ),
        ListTile(
          title: Text('Gerar PDF'),
          onTap: () { /* ação */ },
        ),
        // ...
      ],
    ),
  ),
)
```

#### Telas Vazias

Quando não há dados:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.people_outline, size: 72, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      const Text('Nenhum cliente cadastrado', style: TextStyle(fontSize: 16)),
      const SizedBox(height: 8),
      const Text('Toque no + para adicionar', style: TextStyle(fontSize: 14)),
    ],
  ),
)
```

#### Filtros e Pickers

**Filtro por Status + Intervalo de Data**
```dart
Row(
  children: [
    Expanded(
      child: DropdownButtonFormField<String?>(
        // ... configuração de status
      ),
    ),
    const SizedBox(width: 8),
    OutlinedButton.icon(
      onPressed: _pickDateRange,
      icon: const Icon(Icons.date_range),
      label: const Text('Data'),
    ),
  ],
)
```

### 3.3 Padrões de Layout

**SingleChildScrollView** - Para formulários longos:
```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [ /* campos */ ],
  ),
)
```

**ListView.builder** - Para listas:
```dart
ListView.builder(
  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
  itemCount: _items.length,
  itemBuilder: (context, index) => /* item */,
)
```

---

## 4. Navegação

### 4.1 Padrão de Navegação

O projeto usa **Material Navigation** com `Navigator.push()` e `Navigator.pop()`.

### 4.2 Fluxo de Navegação

```
Dashboard (Inicial)
├── → ClientList (lista de clientes)
│   ├── → ClientRegister (criar novo)
│   ├── → ClientRegister (editar cliente)
│   └── → Menu Modal
│       ├── → SessionList (sessões do cliente)
│       │   ├── → SessionForm (criar sessão)
│       │   └── → SessionForm (editar sessão)
│       ├── → Anamnesis (preencher anamnese)
│       ├── Gerar PDF (Sessões)
│       └── Gerar PDF (Anamnese)
├── → SessionForm (criar sessão rápido)
├── → UserProfileScreen (perfil do usuário)
└── → DebugNavigation → CrudTestPage (desenvolvimento)
```

### 4.3 Padrões de Navegação

#### Push (Abrir nova tela)
```dart
await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ProximaTela()),
);
```

#### Pop com resultado
```dart
Navigator.pop(context, true); // Retorna valor para tela anterior
```

Na tela anterior:
```dart
final result = await Navigator.push<bool>(
  context,
  MaterialPageRoute(builder: (_) => const Formulario()),
);

if (result == true) {
  _reload(); // Atualiza dados se houver mudança
}
```

#### Pop sem resultado
```dart
Navigator.pop(context); // Volta para tela anterior
```

#### Modal Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => /* conteúdo */,
)
```

---

## 5. Banco de Dados

### 5.1 Estratégia de Persistência

- **SQLite** (sqflite package)
- **Plataforma:** Desktop (Linux, macOS, Windows) e Mobile (Android, iOS)
- **Web:** Suporte via `sqflite_common_ffi_web`

### 5.2 Configuração

**Platform-specific:**
```
database_config.dart (exports conditional)
  ├── database_config_io.dart (Desktop/Mobile)
  └── database_config_web.dart (Web)
```

**IO Setup:**
```dart
void configureDatabaseFactory() {
  if (!(Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    return;
  }
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
```

### 5.3 Banco de Dados (`clincontrol.db`)

#### Tabela: `users`
```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  is_current INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  CHECK (is_current IN (0, 1))
);
CREATE INDEX idx_users_is_current ON users(is_current);
```

#### Tabela: `clients`
```sql
CREATE TABLE clients (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  notes TEXT,
  marital_status TEXT,
  nationality TEXT,
  address TEXT,
  whatsapp TEXT,
  email TEXT,
  date_of_birth TEXT,
  age TEXT,
  profession TEXT,
  deleted_at TEXT
);
```

#### Tabela: `sessions`
```sql
CREATE TABLE sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  client_id INTEGER NOT NULL,
  procedure TEXT NOT NULL,
  notes TEXT,
  amount REAL NOT NULL,
  status TEXT NOT NULL DEFAULT 'AGENDADO',
  date TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
  CHECK (status IN ('AGENDADO', 'PAGO', 'CANCELADO')),
  CHECK (amount >= 0)
);
CREATE INDEX idx_sessions_client_id ON sessions(client_id);
CREATE INDEX idx_sessions_date ON sessions(date);
```

#### Tabela: `anamneses`
```sql
CREATE TABLE anamneses (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  client_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);
```

#### Tabela: `anamnesis_answers` (Respostas da Anamnese)
```sql
CREATE TABLE anamnesis_answers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  anamnesis_id INTEGER NOT NULL,
  field_key TEXT NOT NULL,
  value_type TEXT NOT NULL,
  value_text TEXT,
  value_int INTEGER,
  value_real REAL,
  value_bool INTEGER,
  value_date TEXT,
  value_enum TEXT,
  value_json TEXT,
  FOREIGN KEY (anamnesis_id) REFERENCES anamneses(id) ON DELETE CASCADE,
  CHECK (value_type IN ('bool', 'int', 'decimal', 'date', 'enum', 'json', 'text')),
  CHECK (value_bool IS NULL OR value_bool IN (0, 1)),
  UNIQUE(anamnesis_id, field_key)
);
```

#### Tabela: `anamnesis_field_defs` (Definições de Campos)
```sql
CREATE TABLE anamnesis_field_defs (
  field_key TEXT PRIMARY KEY,
  value_type TEXT NOT NULL,
  is_required INTEGER NOT NULL DEFAULT 0,
  enum_values_json TEXT,
  CHECK (value_type IN ('bool', 'int', 'decimal', 'date', 'enum', 'json', 'text')),
  CHECK (is_required IN (0, 1))
);
```

### 5.4 Foreign Keys

- **ON DELETE CASCADE** ativado por padrão
- **PRAGMA foreign_keys = ON** executado no `onConfigure`
- Deletar um cliente deleta automaticamente suas sessões e anamneses

### 5.5 Soft Delete

Clientes são "deletados" apenas logicamente:
- Campo `deleted_at` é preenchido com timestamp
- Queries usam `WHERE deleted_at IS NULL` como filtro

---

## 6. Formatação de Datas

### 6.1 AppDateFormatter (Utility)

Localizado em: `lib/core/utils/app_date_formatter.dart`

```dart
class AppDateFormatter {
  const AppDateFormatter._();

  // Formato brasileiro (dd/mm/yyyy)
  static String toPtBr(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // Formato ISO para banco de dados (yyyy-mm-dd)
  static String toDatabaseIsoDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
```

### 6.2 Padrões de Uso

**Armazenamento no banco:**
```dart
date: AppDateFormatter.toDatabaseIsoDate(_selectedDate) // "2024-05-24"
```

**Exibição na UI:**
```dart
Text(AppDateFormatter.toPtBr(_selectedDate)) // "24/05/2024"
```

**Locale para DatePicker:**
```dart
showDatePicker(
  context: context,
  locale: const Locale('pt', 'BR'), // Português Brasil
  initialDate: DateTime.now(),
  firstDate: DateTime(2024),
  lastDate: DateTime.now().add(const Duration(days: 3650)),
)
```

### 6.3 ISO 8601 para DateTime

Parsing de datas ISO armazenadas:
```dart
DateTime? _parseDatabaseDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) return null;
  
  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  
  if (year == null || month == null || day == null) return null;
  return DateTime(year, month, day);
}
```

---

## 7. Tema e Cores

### 7.1 Configuração do Tema (`lib/core/theme/app_theme.dart`)

```dart
class AppTheme {
  static const Color primary = Colors.purple;        // Roxo principal
  static const Color primaryDark = Color(0xFF6A1B9A); // Roxo escuro
  static const Color background = Color(0xFFF5F5F5);  // Cinza claro

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,      // Roxo
        foregroundColor: Colors.white, // Texto branco
      ),
    );
  }
}
```

### 7.2 Cores Principais

| Elemento | Cor | Código |
|----------|-----|--------|
| **Primária (Botões, AppBar)** | Roxo | `Colors.purple` |
| **Primária Escura** | Roxo Escuro | `#6A1B9A` |
| **Background (Fundo)** | Cinza Claro | `#F5F5F5` |
| **Texto Primário** | Preto/Cinza | Material default |
| **Texto em Elementos Roxos** | Branco | `Colors.white` |
| **Erro (Botão Deletar)** | Vermelho | `Colors.red` |
| **Ícones Vazios (sem dados)** | Cinza Claro | `Colors.grey.shade300` |
| **Texto Secundário** | Cinza | `Colors.grey` |

### 7.3 Material Design 3

Usa `ColorScheme.fromSeed()` para geração automática de cores complementares.

---

## 8. Padrões de Repositório (CRUD)

### 8.1 Arquitetura - Repository Pattern

```
Tela (StatefulWidget)
  ↓
Repository (ClientRepository, SessionRepository, etc)
  ↓
DbHelper (Database Operations)
  ↓
SQLite Database
```

### 8.2 Padrão CRUD Geral

Todos os repositórios seguem o mesmo padrão:

```dart
class EntityRepository {
  final DbHelper _db = DbHelper();
  
  // CREATE
  Future<int> save(Entity entity) => _db.insert(entity);
  
  // READ
  Future<Entity?> findById(int id) => _db.fetchById(id);
  Future<List<Entity>> findAll() => _db.fetchAll();
  Future<List<Entity>> findByFilter(...) => _db.fetchByFilter(...);
  
  // UPDATE
  Future<int> update(Entity entity) => _db.update(entity);
  
  // DELETE
  Future<int> delete(int id) => _db.delete(id);
}
```

### 8.3 ClientRepository

```dart
class ClientRepository {
  final DbHelper _db = DbHelper();

  // CREATE
  Future<int> save(Client client) => _db.insertClient(client);
  
  // READ
  Future<List<Client>> findAll({bool includeDeleted = false}) =>
      _db.fetchClients(includeDeleted: includeDeleted);
  Future<Client?> findById(int id) => _db.fetchClientById(id);
  
  // UPDATE
  Future<int> update(Client client) => _db.updateClient(client);
  
  // DELETE (Soft Delete)
  Future<int> delete(int id) => _db.deleteClient(id);
  
  // DELETE (Hard Delete - Permanente)
  Future<int> purge(int id) => _db.purgeClient(id);
}
```

**Métodos:**
- `save()` → Retorna `id` do novo cliente
- `findAll()` → Retorna lista (pode incluir deletados)
- `findById()` → Retorna cliente ou null
- `update()` → Retorna linhas afetadas
- `delete()` → Soft delete (marca como deletado)
- `purge()` → Hard delete (remove permanentemente)

### 8.4 SessionRepository

```dart
class SessionRepository {
  final DbHelper _db = DbHelper();

  // CREATE
  Future<int> save(Session session) => _db.insertSession(session);
  
  // READ
  Future<Session?> findById(int id) => _db.fetchSessionById(id);
  Future<List<Session>> findByClientId(
    int clientId, {
    String? status,
    String? startDate,
    String? endDate,
  }) => _db.fetchSessionsByClient(clientId, status: status, ...);
  
  // READ - Analytics
  Future<double> getMonthlyTotal(int month, int year) =>
      _db.fetchSessionsMonthlyTotal(month, year);
  Future<int> getMonthlyCount(int month, int year) =>
      _db.fetchSessionsMonthlyCount(month, year);
  
  // UPDATE
  Future<int> update(Session session) => _db.updateSession(session);
  
  // DELETE
  Future<int> delete(int id) => _db.deleteSession(id);
}
```

**Métodos Adicionais:**
- `findByClientId()` → Com filtros opcionais (status, range de datas)
- `getMonthlyTotal()` → Soma de valores do mês
- `getMonthlyCount()` → Quantidade de sessões do mês

### 8.5 AnamnesisRepository

```dart
class AnamnesisRepository {
  final DbHelper _db = DbHelper();

  // CREATE
  Future<int> save(Anamnesis anamnesis) => _db.insertAnamnesis(anamnesis);
  
  // READ
  Future<List<Anamnesis>> findByClientId(int clientId) =>
      _db.fetchAnamnesesByClient(clientId);
  Future<Anamnesis?> findById(int id) => _db.fetchAnamnesis(id);
  
  // UPDATE
  Future<int> update(Anamnesis anamnesis) => _db.updateAnamnesis(anamnesis);
  
  // DELETE
  Future<int> delete(int id) => _db.deleteAnamnesis(id);
}
```

### 8.6 UserRepository

```dart
class UserRepository {
  final DbHelper _db = DbHelper();

  // CREATE/UPDATE - Define usuário atual (login)
  Future<AppUser> defineCurrentUser({
    required String name,
    required String email,
    required String password,
  }) async {
    // Hash senha, verifica se existe, cria ou atualiza
    // Define como usuário atual (is_current = true)
  }
  
  // READ - Usuário atual
  Future<AppUser?> getCurrentUser() => _db.fetchCurrentUser();
}
```

### 8.7 Padrão de Uso em Telas

**Exemplo: ClientList**
```dart
class _ClientListState extends State<ClientList> {
  final ClientRepository _clientRepository = ClientRepository();
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

  Future<void> _deleteClient(int clientId) async {
    final confirm = await showDialog<bool>(/* ... */);
    if (confirm == true) {
      await _clientRepository.delete(clientId);
      await _loadClients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: _isLoading
          ? CircularProgressIndicator()
          : ListView.builder(/* ... */),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(
            builder: (_) => const ClientRegister(),
          ));
          _loadClients(); // Recarrega após criar
        },
      ),
    );
  }
}
```

### 8.8 Padrão de Validação

**Exemplo: SessionForm**
```dart
Future<void> _save() async {
  // 1. Valida form
  if (!_formKey.currentState!.validate()) return;
  
  // 2. Valida campos específicos
  final clientId = _selectedClientId;
  if (clientId == null) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Selecione um cliente')));
    return;
  }
  
  // 3. Prepara dados
  setState(() => _saving = true);
  final amount = double.parse(_amountController.text.replaceAll(',', '.'));
  
  // 4. Executa CRUD
  if (_isEdit) {
    await _repository.update(sessionAtualizada);
  } else {
    await _repository.save(sessionNova);
  }
  
  // 5. Navega de volta
  if (!mounted) return;
  Navigator.pop(context, true);
}
```

---

## 9. Dependências

### `pubspec.yaml`

```yaml
name: flutter_application_1
version: 1.0.0+1

environment:
  sdk: ^3.11.1

dependencies:
  flutter:
    sdk: flutter
  
  # Localização
  flutter_localizations:
    sdk: flutter
  
  # PDF (Geração de relatórios)
  pdf: ^3.11.3
  printing: ^5.14.2
  
  # Database
  sqflite: ^2.3.0                    # SQLite (Mobile/Desktop)
  sqflite_common_ffi: ^2.3.0         # SQLite FFI para Desktop
  sqflite_common_ffi_web: ^1.1.1     # SQLite FFI para Web
  path: ^1.9.0                       # Path manipulation
  
  # UI Components
  mask_text_input_formatter: ^2.9.0  # Mascara de input (telefone, etc)
  dropdown_button2: ^2.3.9           # Dropdown avançado
  
  # Security
  crypto: ^3.0.6                     # Hashing de senhas (SHA-256)
  
  # Design
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

### Principais Packages Explicados

| Package | Versão | Uso |
|---------|--------|-----|
| **sqflite** | ^2.3.0 | Database SQLite para Flutter |
| **sqflite_common_ffi** | ^2.3.0 | Suporte a SQLite em Desktop (Linux, macOS, Windows) |
| **sqflite_common_ffi_web** | ^1.1.1 | Suporte a SQLite em Web |
| **pdf** + **printing** | ^3.11.3 + ^5.14.2 | Geração e preview de PDFs |
| **crypto** | ^3.0.6 | Hash SHA-256 para senhas |
| **mask_text_input_formatter** | ^2.9.0 | Mascaras em inputs (ex: telefone) |
| **dropdown_button2** | ^2.3.9 | Dropdowns customizados |

---

## 🎯 Resumo para Nova Feature: Agendamentos com Calendário

### Passos Recomendados:

1. **Criar Modelo de Dado:** `Scheduling` (herodando padrão de `Session`)
   - `clientId`, `date`, `time`, `status`, `notes`, etc.

2. **Criar Repository:** `SchedulingRepository`
   - Segue padrão CRUD
   - Métodos adicionais: `findByDate()`, `findByMonth()`, `isAvailable()`

3. **Criar Database Helper:**
   - Tabela `schedulings` com ForeignKey para `clients`
   - Indices em `date` e `client_id`

4. **Criar Screens:**
   - `scheduling_list.dart` - Calendário visual
   - `scheduling_form.dart` - Formulário de agendamento

5. **Seguir Padrões de UI:**
   - AppBar roxo com `Colors.purple`
   - TextFormField com borda arredondada
   - FAB roxo para novo agendamento
   - AlertDialog para confirmações

6. **Navegação:**
   - De `ClientList` → `SchedulingList`
   - De `SchedulingList` → `SchedulingForm`

7. **Formatação de Datas:**
   - Usar `AppDateFormatter.toDatabaseIsoDate()` para armazenar
   - Usar `AppDateFormatter.toPtBr()` para exibir

---

**Fim do Sumário** ✅
