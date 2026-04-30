# SmartList 🛒

> Projeto desenvolvido com **vibe-coding** — desenvolvimento guiado por intenção, onde a ideia lidera e a IA executa em tempo real.

Aplicativo de lista de compras inteligente com infraestrutura **AWS Serverless**. O usuário adiciona itens pelo app, acompanha preços e totais em tempo real, registra o custo real da compra e consulta análises de gasto e histórico por mês.

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Mobile | Flutter + Riverpod + GoRouter |
| Backend | AWS Lambda (Node.js 20, arm64) + API Gateway HTTP v2 |
| Banco | DynamoDB (single-table design) |
| Auth | Amazon Cognito (User Pool + JWT) |
| Infra | Serverless Framework v3 + esbuild |

---

## Arquitetura AWS

```
┌─────────────────────────────────────────────────────┐
│                   Flutter App                       │
│          Amplify Auth (Cognito User Pool)           │
└──────────────────────┬──────────────────────────────┘
                       │ JWT Bearer token
                       ▼
          ┌────────────────────────┐
          │  API Gateway HTTP v2   │
          │  JWT Authorizer        │
          └──────────┬─────────────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
   Lambda        Lambda       Lambda
  ingestItem   getHistory  closePurchase
  removeItem  getMonthlyList  manageCatalog
        │
        └──────────────▶ DynamoDB
```

### Modelo DynamoDB (single-table)

| Entidade         | PK                  | SK                  |
|------------------|---------------------|---------------------|
| Lista mensal     | `USER#<userId>`     | `LIST#YYYY-MM`      |
| Snapshot fechado | `USER#<userId>`     | `HISTORY#<uuid>`    |
| Catálogo         | `CATALOG#<name>`    | `META`              |

---

## Funcionalidades

### App
- [x] Autenticação completa (cadastro → confirmação por e-mail → login)
- [x] Dashboard com card do mês atual (total calculado ou custo real)
- [x] Iniciar lista do próximo mês quando o mês atual está fechado
- [x] Registrar compras de meses anteriores
- [x] Lista de compras com ordenação alfabética
- [x] Adicionar item com nome, quantidade, unidade e preço
- [x] Sugestão de nome ao digitar (baseada no histórico de compras)
- [x] Preenchimento automático de preço ao selecionar sugestão
- [x] Excluir item da lista
- [x] Busca de itens na lista (ativa e fechada)
- [x] Calculadora embutida (painel lateral)
- [x] Custo real informado no fechamento + diferença destacada
- [x] Fechar compra do mês (com total real obrigatório)
- [x] Histórico de meses fechados com totais
- [x] Análise de gastos: gráfico de barras + KPI valor médio
- [x] Top 5 produtos mais caros do histórico
- [x] Gráfico de variação de preço (últimos 3 meses)

### Backend
- [x] `POST /items` — adiciona item à lista (mês atual ou anterior)
- [x] `DELETE /items/{itemId}` — remove item da lista
- [x] `GET /list/{yearMonth}` — retorna lista do mês
- [x] `POST /list/{yearMonth}/close` — fecha compra + gera snapshot + salva custo real
- [x] `GET /history` — lista todos os snapshots fechados do usuário
- [x] `GET /catalog` / `POST /catalog` — catálogo de produtos canônicos

---

## Fluxo de navegação

```
/                  Welcome
├── /login         Login
├── /register      Cadastro
├── /confirm       Confirmação de e-mail
└── /home          Dashboard
    ├── /list/:yearMonth   Lista de compras
    └── /history           Histórico
        └── /history/:yearMonth  Detalhe do mês
```

---

## Estrutura do projeto

```
app-compras/
├── mobile/          # App Flutter
│   ├── lib/
│   │   ├── core/
│   │   │   ├── config/       # Amplify + API config
│   │   │   ├── router/       # GoRouter com auth guard
│   │   │   ├── services/     # ApiClient (JWT automático)
│   │   │   └── utils/        # Formatação de moeda e datas
│   │   └── features/
│   │       ├── auth/         # Login, cadastro, confirmação
│   │       ├── dashboard/    # Home com analytics
│   │       ├── history/      # Histórico de compras
│   │       ├── monthly_list/ # Lista do mês + calculadora
│   │       └── welcome/      # Tela inicial
│   └── pubspec.yaml
├── backend/         # Lambdas Node.js + Serverless Framework
│   ├── functions/
│   │   ├── ingest-item/
│   │   ├── remove-item/
│   │   ├── get-monthly-list/
│   │   ├── close-purchase/
│   │   ├── get-history/
│   │   └── manage-catalog/
│   ├── shared/
│   │   ├── models/      # Tipos TypeScript
│   │   └── utils/       # DynamoDB, auth, response helpers
│   └── serverless.yml
└── android/         # Plataforma Android (build do APK)
```

---

## Rodar localmente

### Backend
```bash
cd backend
npm install
npx sls deploy
```

### App (web para desenvolvimento)
```bash
cd mobile
flutter pub get
flutter run -d edge
```

### Gerar APK Android
```bash
# A partir da raiz do projeto
flutter pub get
flutter build apk --release
# Saída: build/app/outputs/flutter-apk/app-release.apk
```

---

## Vibe-coding

Este projeto é um experimento de **vibe-coding**: o desenvolvedor define a intenção e o fluxo do produto, enquanto a IA (Claude) gera, refatora e evolui o código em tempo real durante a conversa. O resultado é um ciclo de desenvolvimento acelerado onde a criatividade do produto não é bloqueada pela execução técnica.
