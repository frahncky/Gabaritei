# Gabaritou

App de gamificação de estudos para alunos do ensino médio — começando pelos cursos técnicos de Eletroeletrônica (DEE) do IFMA – Campus São Luís – Monte Castelo, com planos de atender também o ensino médio regular.

A ideia central: o aluno não só joga, ele **domina** o conteúdo. Cada desafio, trilha e medalha empurra o estudante da primeira faísca de curiosidade até o domínio da matéria.

## Status

Fase de design. Este repositório guarda o conceito, as regras de gamificação e o mockup das telas.

- [x] Mockup das telas do aluno (celular) e do painel do professor (desktop)
- [ ] Definição da stack e da arquitetura
- [ ] Protótipo funcional (banco de questões + XP salvo)
- [ ] Piloto com uma turma de Eletrotécnica

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

### Identidade visual (provisória)

- Fundo `#F3F5F1`, texto `#13211C`
- Ação: azul `#1D4ED8`
- XP e sequência: âmbar `#F59E0B` / `#B45309`
- Tipografia: Bricolage Grotesque (títulos), IBM Plex Sans (texto), IBM Plex Mono (números)

## Autor

Francisco — Departamento de Eletroeletrônica (DEE-MTC), IFMA – Campus São Luís – Monte Castelo.
