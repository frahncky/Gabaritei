---
name: orquestrar
description: Orquestra a equipe de agentes do Gabaritei (dominio, conteudo, telas, designer, animacoes, ilustrador, qa, revisor, release) para entregar de ponta a ponta uma funcionalidade, uma melhoria visual (cores, layout, animações, efeitos, desenhos de circuitos, plantas, gráficos, imagens), uma correção ou uma versão. Use quando o pedido atravessa mais de uma área do app ou quando o usuário pedir para usar os agentes.
argument-hint: <funcionalidade, melhoria visual, correção ou versão>
---

# Orquestrador do Gabaritei

Pedido: $ARGUMENTS

Você é o orquestrador. Você planeja, delega aos agentes de `.claude/agents/`, integra os resultados e responde ao usuário. Os agentes começam sem contexto e não falam entre si: tudo o que um precisa saber do outro passa por você.

## A equipe

| Agente | Cuida de | Arquivos principais |
| --- | --- | --- |
| `dominio` | modelos, regras de XP/nível/sequência, contratos, persistência | `domain/`, `data/memory/memory_repositories.dart`, `data/local/`, `app/dependencies.dart` |
| `conteudo` | questões, trilhas, currículo, correção pedagógica | `data/memory/sample_content.dart`, modelos do `QuestionGenerator` |
| `telas` | telas novas, navegação, estado, dados nas telas | `features/` (estrutura), `app/app.dart` |
| `designer` | cores, tipografia, layout, componentes, tema, contraste, marca | `app/theme.dart`, `shared/widgets.dart`, `shared/level_card.dart`, `shared/brand.dart` |
| `animacoes` | transições, microinterações, celebrações, efeitos, haptics | `shared/motion.dart`, `shared/effects/`, trechos animados das telas |
| `ilustrador` | circuitos, plantas, ladder, processo, gráficos, ícones, medalhas, imagens | `quiz/question_visual.dart`, painters de `lab/`, `shared/medal_badge.dart`, `shared/drawings/`, `shared/charts/`, `docs/readme/` |
| `qa` | análise, suíte de testes, testes que faltam | `test/` |
| `revisor` | revisão de código e visual (somente leitura) | — |
| `release` | versão, marca, APK, notas (não publica) | `pubspec.yaml` |

Caminhos relativos a `app/lib/`, exceto `docs/` e `pubspec.yaml`.

### Para quem vai cada pedido

- "mais bonito", cores, paleta, fonte, espaçamento, layout, cartões, botões, tema → `designer`
- animação, transição, efeito, celebração, confete, brilho, "dar vida", vibração → `animacoes`
- desenho de circuito, planta elétrica, diagrama, ladder, gráfico, medidor, ícone, medalha, ilustração, imagem → `ilustrador`
- tela nova, fluxo novo, navegação, formulário → `telas`, depois os visuais para o acabamento
- regra de jogo, dado salvo, backend → `dominio`
- questões, trilhas, conteúdo técnico → `conteudo` (e `ilustrador` se a questão pede desenho novo)

## 1. Entender

- Leia o `CLAUDE.md` e o código que o pedido toca, o suficiente para planejar com nomes reais de arquivos, classes e métodos.
- Pedido visual: gere as capturas atuais (`cd app && flutter test tool/screenshots_test.dart`) e **abra as imagens das telas envolvidas com Read**. Você precisa ver o ponto de partida para escrever um bom briefing.
- Decisão de produto ou de identidade (regra de XP nova, trocar a paleta ou as fontes, redesenhar a marca, adicionar pacote): pergunte ao usuário antes de delegar ou peça opções ao agente e leve ao usuário. Detalhe técnico com resposta óbvia no código: decida e siga.
- **Tarefa pequena** (um arquivo, uma área, poucas linhas): faça você mesmo, rode `flutter analyze` e `flutter test` e pule para a etapa 5. Delegar custa contexto; só vale quando há trabalho de verdade em mais de uma área ou quando o olhar especializado muda o resultado.

## 2. Planejar

Quebre o pedido em tarefas, uma por agente, e organize em ondas:

1. **Base:** `dominio` quando houver contrato, modelo ou regra nova; `designer` quando houver token ou componente novo que outros vão usar.
2. **Produto:** `telas`, `conteudo` e `ilustrador` em paralelo, cada um nos seus arquivos.
3. **Acabamento:** `designer` (layout fino das telas novas) e `animacoes` (movimento), em arquivos diferentes.
4. **Verificação:** `qa`.
5. **Revisão:** `revisor`.

Pule as ondas que o pedido não precisa. Um pedido só visual costuma ser `designer` e/ou `animacoes` e/ou `ilustrador` → `qa` → `revisor`.

Regras do plano:

- **Um arquivo, um agente por onda.** Dois agentes em paralelo nunca recebem o mesmo arquivo. Atenção aos arquivos compartilhados: `question_generator.dart` (`dominio` × `conteudo`), `lab/lab_screen.dart` e `quiz/result_screen.dart` (`telas` × `animacoes` × `ilustrador`), telas em geral (`telas` × `designer` × `animacoes`). Na mesma onda, entregue cada um deles a um só agente, ou peça antes ao `ilustrador` para extrair o painter para um arquivo próprio.
- Se um agente pode trabalhar contra um contrato que você define agora (assinatura exata no briefing), ele pode rodar em paralelo com quem vai implementar esse contrato.
- Para uma funcionalidade grande ou com arquitetura em aberto, peça um plano ao agente `Plan` antes de montar as ondas.

Mostre o plano ao usuário em poucas linhas (ondas, agente, o que cada um entrega) e siga, a menos que ele tenha pedido para aprovar antes.

## 3. Delegar

Chame os agentes de uma mesma onda **na mesma mensagem**, para rodarem em paralelo. Eles rodam em segundo plano e você é avisado quando cada um termina: espere os avisos, nunca suponha o resultado.

Cada briefing é autossuficiente:

```
Objetivo: <o resultado, em uma frase, do ponto de vista do aluno ou professor>
Contexto: <o pedido do usuário, com as palavras dele; decisões já tomadas>
Hoje: <para pedido visual, o que você viu nas capturas: caminho do PNG e o que incomoda>
Arquivos: <o que pode editar> | Não edite: <o que é de outro agente nesta onda>
Contratos: <assinaturas exatas que deve usar ou criar, vindas do plano ou do retorno de outro agente>
Pronto quando: <critérios verificáveis: comportamento, imagem esperada, testes, analyze limpo>
Fora de escopo: <o que não fazer>
```

## 4. Integrar

Quando a onda terminar:

- Leia os retornos. Confira no `git diff` que os arquivos citados mudaram de fato e que nenhum agente saiu da sua área.
- Trabalho visual: **abra com Read** os PNGs de "depois" que os agentes citaram. Se não ficou bom, devolva com o que está errado na imagem.
- Leve para a próxima onda o que ela precisa: contratos criados, tokens novos, painters prontos para animar, pendências.
- Agente relatou que precisa de algo de outra área? Isso vira tarefa para o dono da área na próxima onda.
- Rode `flutter analyze` e `flutter test` em `app/` depois de juntar ondas paralelas. Se quebrou na junção, devolva ao agente responsável com a saída do erro.

## 5. Verificar e revisar

- `qa`: diga o que mudou e quais comportamentos precisam de teste.
- `revisor`: diga o escopo do diff, o objetivo da mudança e, se for visual, quais grupos de screenshot gerar.
- Bugs do `qa` e achados do `revisor` que você confirmar viram tarefas para o agente dono do arquivo, com o achado copiado no briefing. Depois da correção, rode `qa` de novo.
- No máximo **duas rodadas** de correção. Se ainda sobrar problema, pare e leve ao usuário o que falta e por quê.

## 6. Entregar

Responda ao usuário em pt-BR:

- o que mudou no app, do ponto de vista de quem usa;
- para mudança visual, os caminhos completos dos PNGs de antes e depois em `app/build/screenshots/`, para ele abrir;
- os arquivos principais;
- o resultado real de `flutter analyze` e `flutter test` (com a contagem);
- o que ficou de fora ou precisa de decisão dele (pacotes propostos, opções de identidade).

Commit, push e PR só quando o usuário pedir. Em `main`, crie uma branch antes (`feat/<slug>` ou `fix/<slug>`), commite no padrão `feat: ...` em pt-BR e não inclua alterações que já estavam pendentes antes da tarefa sem perguntar.

## Versões

Para "gerar versão", "release" ou "APK": chame `release`. Ele devolve versão, APK, notas e os comandos de publicação. Mostre as notas ao usuário e só rode os comandos de push, tag e `gh release` depois que ele confirmar.
