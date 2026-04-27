# SmartList 🛒

> Projeto desenvolvido com **vibe-coding** — desenvolvimento guiado por intenção, onde a ideia lidera e a IA executa em tempo real.

Aplicativo de lista de compras inteligente com integração à **Alexa** e infraestrutura **AWS Serverless**. O usuário adiciona itens por voz (via Alexa) ou pelo app, acompanha preços e totais em tempo real, e consulta o histórico de compras por mês.

---

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Mobile | Flutter + Riverpod + GoRouter |
| Voice | Amazon Alexa (Custom Skill) |
| Backend | AWS Lambda + API Gateway |
| Banco | DynamoDB |
| Auth | Amazon Cognito |
| Infra | AWS Serverless (CDK) |

---

## Funcionalidades

- [x] Tela de boas-vindas (SmartList)
- [x] Dashboard com card do mês atual e placeholder de gráficos
- [x] Lista de compras do mês corrente
- [x] Preço por item, subtotal e total calculado
- [x] Total real informado pelo usuário + destaque de diferença
- [x] Fechar compra do mês
- [x] Histórico de meses anteriores com totais e diferença
- [ ] Integração com Alexa (Fase 2)
- [ ] Backend AWS real (Fase 3)
- [ ] Gráficos de gastos (Fase 4)
- [ ] Autenticação com Cognito (Fase 5)

---

## Fluxo de navegação

```
Welcome → Dashboard → Lista do mês atual
                    → Histórico → Detalhe do mês
```

---

## Regra de negócio — troca de mês

Quando a lista do mês corrente é **fechada**, novos itens (via app ou Alexa) criam automaticamente a lista do próximo mês. O backend (Lambda) é responsável por essa lógica, garantindo consistência entre os dois canais de entrada.

---

## Rodar localmente

```bash
cd mobile
flutter pub get
flutter run -d edge      # web (Edge)
flutter run -d windows   # desktop
```

---

## Vibe-coding

Este projeto é um experimento de **vibe-coding**: o desenvolvedor define a intenção e o fluxo do produto, enquanto a IA (Claude) gera, refatora e evolui o código em tempo real durante a conversa. O resultado é um ciclo de desenvolvimento acelerado onde a criatividade do produto não é bloqueada pela execução técnica.
