# Gabaritei

App de gamificação de estudos para alunos do ensino médio — começando pelos cursos técnicos, com planos de atender também o ensino médio regular.

A ideia central: o aluno não só joga, ele **domina** o conteúdo. Cada desafio, trilha e medalha empurra o estudante da primeira faísca de curiosidade até o domínio da matéria.

## Status

Protótipo funcional em Flutter rodando no Android, com dados de exemplo em memória.

- [x] Mockup das telas do aluno (celular) e do painel do professor (desktop)
- [x] Definição da stack e da arquitetura (Flutter + camadas domínio/dados/telas)
- [x] Protótipo navegável: início, trilhas, desafio, resultado, ranking, perfil e painel do professor
- [ ] Banco de questões e XP salvos de verdade (backend)
- [ ] Piloto com uma turma de Eletrotécnica

## Instalar no celular (Android)

Baixe o `app-release.apk` na página de [Releases](https://github.com/frahncky/Gabaritei/releases/latest) e abra no celular. O Android vai pedir para permitir a instalação de fontes desconhecidas.

## Rodar o projeto

Requer [Flutter](https://docs.flutter.dev/get-started/install) 3.27 ou mais recente.

```bash
cd app
flutter pub get
flutter run            # roda no celular conectado ou no emulador
flutter test           # testes de tela
flutter build apk      # gera o APK em build/app/outputs/flutter-apk/
```

## Estrutura

```text
app/            App Flutter
  lib/
    app/        Tema, injeção de dependências e raiz do app
    domain/     Modelos, regras de XP, nível e sequência, contratos de repositório
    data/       Repositórios em memória e conteúdo de exemplo
    features/   Telas (início, trilhas, quiz, ranking, perfil, professor)
    shared/     Widgets e formatação reutilizáveis
  test/         Testes de tela
design/mockup/  Mockup das telas
docs/           Regras de gamificação
```

## Mecânicas de gamificação

| Mecânica | Como funciona |
|---|---|
| **XP** | Pontos por questão, lição, missão e desafio concluídos |
| **Níveis** | Faísca → Aprendiz → Afiado → Craque → Domínio, com subníveis (I, II, III) |
| **Sequência** | Dias seguidos estudando; perder um dia zera a sequência |
| **Missões diárias** | 2–3 tarefas curtas que renovam a cada dia |
| **Desafios relâmpago** | Quizzes cronometrados, com combo por acertos seguidos e dica que custa XP |
| **Trilhas** | Disciplinas divididas em módulos que se desbloqueiam em sequência, terminando numa prova final |
| **Medalhas** | Conquistas por domínio de tópicos e por constância |
| **Ranking e ligas** | Ranking semanal da turma; os 3 primeiros sobem de liga (Cobre → Prata → Ouro) |
| **Painel do professor** | Acerto por tópico, alunos que precisam de atenção, criação de desafios |

Detalhes em [`docs/gamificacao.md`](docs/gamificacao.md).

## Mockup

As telas estão em [`design/mockup/`](design/mockup/):

| # | Tela | Arquivo |
|---|---|---|
| 1 | Início do aluno | `Main.dc.html` |
| 2 | Trilhas | `Trilhas.dc.html` |
| 3 | Desafio (quiz) | `Quiz.dc.html` |
| 4 | Resultado do desafio | `Resultado.dc.html` |
| 5 | Ranking da turma | `Ranking.dc.html` |
| 6 | Perfil e medalhas | `Perfil.dc.html` |
| 7 | Painel do professor | `Professor.dc.html` |

Os arquivos `.dc.html` são o código-fonte do canvas de design feito no Claude; `canvas.json` guarda a disposição das telas. Eles servem como referência visual e de conteúdo para a implementação.

O mockup é uma inspiração: o app pode (e deve) ir além dele.

### Identidade visual

- Símbolo: a bolha do gabarito marcada — círculo âmbar com ✓ sobre fundo escuro. Desenhado em código (`app/lib/shared/brand.dart`), gera o ícone e o splash
- Fundo `#F3F5F1`, escuro da marca `#13211C`
- Ação: azul `#1D4ED8`
- XP, sequência e conquistas: âmbar `#F59E0B` / `#B45309`
- Tipografia: Bricolage Grotesque (títulos e números em destaque) e IBM Plex Sans (texto), embutidas no app

## Autor

Francisco
