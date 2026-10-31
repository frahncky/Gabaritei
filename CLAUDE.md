# Gabaritei

App Flutter (Android) de gamificação de estudos para o ensino médio técnico e regular: trilhas, desafios, XP, ranking e painel do professor. Protótipo **sem servidor**: o progresso fica salvo no aparelho com `shared_preferences`.

## Comandos

Rodar dentro de `app/`:

```bash
flutter pub get
flutter analyze                      # precisa terminar com "No issues found!"
flutter test                         # suíte completa
flutter test test/<arquivo>_test.dart
dart format lib test
flutter build apk                    # build/app/outputs/flutter-apk/
```

Marca (ícone e splash), nesta ordem: `flutter test tool/brand_assets_test.dart` → `dart run flutter_launcher_icons` → `dart run flutter_native_splash:create`.

Screenshots das telas com as fontes reais, em `build/screenshots/`: `flutter test tool/screenshots_test.dart` (ou `--name "<grupo>"`). O kit `tool/screenshot_kit.dart` também gera folhas de quadros de animações (`shootFrames`). Nas imagens, texto em bloco sólido = texto sem `fontFamily`; `□` = caractere ausente nas fontes do app; faixas amarelas e pretas = overflow.

## Arquitetura

| Pasta | Conteúdo |
| --- | --- |
| `app/lib/app` | Tokens (`tokens.dart`: `AppColors`, `AppFonts`, `AppRadii`...), tema (`AppTheme`), fundo de grade das rotas (`page_transitions.dart`), `AppDependencies` e raiz do app |
| `app/lib/domain` | Modelos, regras (XP, nível, sequência), `QuestionGenerator` e contratos de repositório |
| `app/lib/data` | `memory/` (repositórios em memória + `SampleContent`) e `local/` (`LocalStore`) |
| `app/lib/features` | Telas: start, student (shell), home, trails, quiz, lab, ranking, profile, teacher |
| `app/lib/shared` | Marca, widgets reutilizáveis e formatação pt-BR |
| `app/test` | Testes de tela, regras e persistência |

Regras que não se quebram:

- **Telas dependem só dos contratos** de `domain/repositories/repositories.dart`, obtidos com `Dependencies.of(context)`. `features/` e `shared/` nunca importam `data/`.
- **`domain/` é Dart puro**: não importa Flutter nem pacotes.
- **Regras de jogo ficam em `domain/rules/`**, puras e testadas. Tela não recalcula XP, nível nem sequência.
- **Dado novo persistido** passa por `LocalStore` (serialização ida e volta). Se o formato mudar de forma incompatível, versione a chave (`gabaritei.student.v1` → `.v2`) e trate a migração.
- **Backend futuro** = novas classes que implementam os contratos + uma fábrica em `AppDependencies`. As telas não mudam.

## Convenções

- Identificadores em inglês; comentários `///`, textos de interface, testes e docs em pt-BR.
- Comentários curtos, explicando o porquê, na densidade do código ao redor.
- Cores e fontes só via `AppColors` e `AppFonts`. Exceção: cores físicas reais (bandas de resistor em `color_code_view.dart`).
- App todo escuro e calmo, estilo "planta técnica" (grade atrás das rotas, fundo `#0F1D33`, cartões tonais `#182841` sem borda). Um acento forte por bloco: azul cheio só no botão principal, âmbar só para XP e conquistas; borda só para estado (selecionado, "hoje"). Texto em `CustomPainter` com `AppFonts.body` ou `fontFamilyFallback: AppFonts.fallback`.
- Reaproveite `shared/widgets.dart`: `AsyncView` para dados assíncronos (com `onRetry`), `ProgressBar`, `StatTile`, `SectionHeader`, `Avatar`.
- Estado: `StatefulWidget` + `setState` nas telas; `ChangeNotifier` + `ListenableBuilder` quando o fluxo precisa ser testável sem widgets (ex.: `QuizController`). Sem pacote de gerência de estado.
- Números e datas em pt-BR com `shared/format.dart` (sem `intl`).
- Lints: `flutter_lints` + `prefer_const_constructors` + `prefer_final_locals`.
- `design/mockup/` é inspiração de conteúdo e clima, não especificação.
- Números de gamificação em `domain/rules/` e em `docs/gamificacao.md` (e na tabela do README) andam juntos.

## Testes

- Nomes de teste em pt-BR descrevendo o comportamento (`'aluno navega pelas quatro abas'`).
- Testes de tela usam `GabariteiApp(dependencies: AppDependencies.inMemory())` com `tester.view.physicalSize` definido.
- Regras, serviços e `LocalStore` têm testes unitários (relógio injetável via `Clock` onde houver data).

## Git

- Nunca commitar direto em `main`: crie uma branch (`feat/...`, `fix/...`).
- Mensagens no padrão `feat: ...`, `fix: ...`, `docs: ...`, em pt-BR e minúsculas.

## Agentes

Equipe em `.claude/agents/`, coordenada pela skill `/orquestrar`:

- código: `dominio` (regras e dados), `telas` (estrutura e fluxo), `conteudo` (questões e trilhas);
- visual: `designer` (cores, layout, tema), `animacoes` (movimento e efeitos), `ilustrador` (circuitos, plantas, gráficos, imagens);
- qualidade: `qa` (testes), `revisor` (código e visual, só leitura), `release` (versão e APK).
