# ClinControl

Aplicativo mobile de gestão de atendimentos e clientes para profissionais da área estética.

---

## Tecnologias

- Flutter 3.41+
- Dart
- SQLite (sqflite)

---

## Pré-requisitos

- Sistema operacional: Windows, macOS ou Linux
- Git instalado
- Conexão com internet para baixar dependências

---

## Instalando o Flutter

### 1. Baixe o Flutter SDK

Acesse [flutter.dev/get-started](https://docs.flutter.dev/get-started/install) e escolha seu sistema operacional.

### 2. Extraia e configure o PATH

**Linux/macOS** — adicione ao seu `~/.bashrc` ou `~/.zshrc`:
```bash
export PATH="$PATH:/caminho/para/flutter/bin"
```

**Windows** — adicione a pasta `flutter/bin` nas variáveis de ambiente do sistema.

### 3. Verifique a instalação
```bash
flutter doctor
```

Todos os itens necessários devem aparecer com ✓.

---

## Dependências do projeto (Linux)

Se estiver no Linux, instale as dependências de compilação:
```bash
sudo apt install clang cmake ninja-build libgtk-3-dev pkg-config libstdc++-14-dev lld
```

Habilite o suporte a Linux desktop:
```bash
flutter config --enable-linux-desktop
```

---

## Clonando e rodando o projeto

### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/clincontrol.git
cd clincontrol
```

### 2. Instale as dependências do projeto
```bash
flutter pub get
```

### 3. Rode o projeto

**Linux desktop:**
```bash
flutter run -d linux
```

**Android** (com emulador ou dispositivo conectado):
```bash
flutter run -d android
```

---

## Estrutura do projeto
```
lib/
├── core/                  # Tema e constantes globais
├── data/
│   ├── database/          # Configuração do SQLite
│   ├── models/            # Classes Client e Service
│   └── repositories/      # Lógica de acesso ao banco
└── features/
    ├── dashboard/          # Tela inicial com resumo do mês
    ├── clients/            # Cadastro e listagem de clientes
    └── services/           # Registro de atendimentos
```

---

## Comandos úteis

| Comando | Descrição |
|---|---|
| `flutter run -d linux` | Roda no Linux desktop |
| `flutter pub get` | Instala dependências |
| `flutter clean` | Limpa o cache de build |
| `r` no terminal | Hot reload |
| `R` no terminal | Hot restart |