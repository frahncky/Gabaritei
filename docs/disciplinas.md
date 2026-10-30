# 📚 Disciplinas e atividades iniciais

## Trilhas disponíveis

| Disciplina | Módulos de estudo | Prova final | Pré-requisito |
| --- | ---: | ---: | --- |
| Eletricidade Básica | 6 | 1 | Nenhum |
| Eletrônica Analógica | 5 | 1 | Nenhum |
| Eletrônica Digital | 4 | 1 | Nenhum |
| Instalações Elétricas | 4 | 1 | Nenhum |
| CLP e Automação | 4 | 1 | Concluir Eletrônica Digital, incluindo a prova final |

São 23 módulos de estudo e cinco provas finais. Todos possuem atividade associada. O banco inicial soma 56 questões distintas: 42 novas e 14 já existentes. As provas finais reutilizam as questões dos módulos da própria disciplina; não são questões inéditas.

O código de cores de resistores permanece disponível como desafio independente. Os módulos novos têm duas questões cada: são atividades introdutórias, não um banco completo nem certificação de domínio da disciplina.

## Como avançar

- Cada disciplina sem pré-requisito começa com apenas o primeiro módulo disponível.
- O próximo módulo é liberado após pelo menos 70% de acerto no anterior.
- A prova final é liberada após aprovação em todos os módulos de estudo.
- CLP é liberado após aprovação em todos os módulos e na prova final de Eletrônica Digital.
- A melhor nota de cada atividade permanece salva; repetir com resultado pior não bloqueia o avanço.
- Estrelas: uma a partir de 70%, duas a partir de 85%, três com 100%.
- Respostas ausentes contam como erro para a progressão.
- Recomeçar o progresso também zera as notas das trilhas.
- Instalações antigas sem notas salvas começam as trilhas no primeiro módulo; XP e demais dados salvos permanecem. Conclusões fictícias do catálogo de demonstração não são convertidas em notas.

A pontuação de XP mantém as regras existentes. O limite de aprovação da trilha (70%) é independente do bônus de conclusão do quiz e do limite de 80% para medalhas de desafio.

## Matriz curricular e limitações

O mapa de cursos continua apresentando 26 áreas, com ementas e objetivos. Essas áreas não equivalem a 26 disciplinas com lições completas. Nesta entrega, cinco trilhas têm atividades executáveis; as demais áreas permanecem como planejamento curricular.

O progresso é local, compartilhado com os repositórios usados pelo app e persistido com `shared_preferences`. Não há backend, turmas reais ou sincronização entre aparelhos nesta etapa.

## Verificação

A suíte `app/test/curriculum_test.dart` cobre integridade do catálogo, pré-requisitos, progresso inicial, nota mínima, repetição, desbloqueio de CLP, persistência e reset. O workflow Flutter executa análise e testes no GitHub.

## Próximo trabalho de conteúdo

Ampliar a quantidade e variedade de questões, incluir lições explicativas e diagramas específicos, revisar pedagogicamente com docentes e transformar as demais áreas do mapa curricular em trilhas. As provas finais devem receber um banco próprio antes de serem usadas como avaliação formal.
