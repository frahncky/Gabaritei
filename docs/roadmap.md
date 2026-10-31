# 🗺️ Roadmap do Gabaritei

Atualizado em 31/10/2026.

**Objetivo:** evoluir do protótipo local para uma plataforma de aprendizagem com turmas reais, acompanhamento docente e progresso sincronizado, começando por um piloto de Eletrotécnica.

## 📍 Ponto de partida

A base atual reúne o protótipo navegável, catálogo de cursos e disciplinas, persistência local e interface adaptativa. Os simuladores de eletricidade e automação permanecem no código, mas seus cards foram removidos da tela inicial. Ranking e painel docente usam dados demonstrativos e ainda precisam ser validados com usuários reais.

As melhorias de interface e animação foram publicadas na `main` no [commit 49034ec](https://github.com/frahncky/Gabaritei/commit/49034ec). A análise estática passou e cinco testes direcionados foram aprovados; a suíte completa ainda tem falhas conhecidas após a integração. Isso não certifica prontidão para produção.

As caixas abertas abaixo representam trabalho planejado ou validação pendente. Nenhum recurso futuro deve ser anunciado como entregue apenas por ter uma tela.

## 🎯 Marcos e ordem de execução

| Marco | Prioridade | Dependência | Resultado esperado | Situação |
| --- | --- | --- | --- | --- |
| M0 — Validar a base | P0 | Base existente | Protótipo reproduzível e regras verificadas | Em andamento |
| M1 — Contas, backend e turmas | P0 | M0 | Aluno e professor acessam somente seus dados autorizados | A fazer |
| M2 — Conteúdo e atividades reais | P0 | M1 | Professor publica atividade e aluno recebe conteúdo revisado | A fazer |
| M3 — Sincronização e gamificação real | P0 | M2 | Tentativas, progresso e XP consistentes entre aparelhos | A fazer |
| M4 — Acompanhamento e preparação do piloto | P1 | M3 | Professor acompanha resultados reais; versão pronta para teste | A fazer |
| M5 — Piloto de Eletrotécnica | P1 | M4 | Uso em turma e avaliação documentada | A fazer |
| M6 — Publicação e expansão | P2 | M5 | Distribuição estável e expansão gradual | A fazer |

P0 = necessário para o fluxo principal; P1 = necessário para o piloto; P2 = posterior à validação. Os marcos indicam sequência, sem prometer datas antes da definição de capacidade, infraestrutura e responsáveis.

## 🧪 M0 — Validar a base

- [x] Executar `flutter analyze` sem apontamentos na atualização de interface ([commit 49034ec](https://github.com/frahncky/Gabaritei/commit/49034ec)).
- [x] Validar navegação adaptativa, sequência do splash, repetição da animação e desenho da marca com cinco testes direcionados aprovados no mesmo commit.
- [ ] Corrigir as falhas conhecidas em testes de conteúdo, gerador e telas; executar a suíte completa e registrar o resultado na CI.
- [ ] Gerar e instalar um build Android da versão atual; registrar versão, commit e resultado.
- [ ] Percorrer início, cursos, disciplinas, quiz, resultado, ranking, perfil e professor no aparelho.
- [ ] Validar a tela de entrada em abertura completa do app, retorno do segundo plano e preferência por reduzir animações.
- [ ] Revisar testes e documentação que ainda pressupõem os atalhos de laboratórios na tela inicial.
- [ ] Conferir XP, dicas, combos, níveis, medalhas, sequência diária e desbloqueio de módulos com as [regras de gamificação](gamificacao.md).
- [ ] Verificar persistência após fechar e reabrir o app; definir como preservar ou migrar o progresso local na entrada de uma conta.
- [ ] Identificar dados demonstrativos na interface e documentar limitações do protótipo.
- [ ] Registrar defeitos e separar bloqueios do piloto de melhorias posteriores.

**Critério de conclusão:** build instalável, verificações sem falhas bloqueadoras e fluxo local completo validado, com evidências registradas no repositório.

## 🔐 M1 — Contas, backend e turmas

- [ ] Registrar decisão de arquitetura: autenticação, banco de dados, hospedagem, custos esperados e ambientes de desenvolvimento/teste/produção.
- [ ] Implementar entrada, saída e recuperação de acesso; definir vínculo de conta e papel.
- [ ] Criar modelos de usuário, turma, matrícula e vínculo docente, com identificadores estáveis.
- [ ] Permitir ao professor criar turma e gerenciar entrada de alunos por convite ou código.
- [ ] Aplicar autorização no backend: aluno acessa seus dados; professor acessa as turmas sob sua responsabilidade.
- [ ] Impedir que o cliente conceda a si mesmo papel docente ou acesso a outra turma.
- [ ] Definir coleta mínima de dados, retenção, exclusão de conta e controles adequados ao público escolar.
- [ ] Preparar backup e testar restauração antes de cadastrar a turma piloto.

**Critério de conclusão:** duas contas de alunos e uma de professor completam o fluxo de turma; testes de acesso negam leitura e alteração entre usuários ou turmas sem vínculo.

## 📚 M2 — Conteúdo e atividades reais

- [ ] Modelar disciplina, trilha, módulo, questão, alternativas, resposta, explicação, dificuldade e tópico.
- [ ] Versionar questões e guardar a versão respondida em cada tentativa.
- [ ] Separar rascunho, revisão e publicação; restringir gabaritos e ações de edição no backend.
- [ ] Permitir criação e edição de questões pelo professor, incluindo recursos visuais necessários ao piloto.
- [ ] Montar banco inicial revisado de Eletrotécnica: eletricidade básica, Lei de Ohm, potência, associações de resistores e leis de Kirchhoff.
- [ ] Conferir cálculos, unidades, desenhos e explicações; revisar também as questões geradas automaticamente usadas no piloto.
- [ ] Publicar desafios para uma turma com instruções e prazo, quando aplicável.
- [ ] Exibir ao aluno atividades atribuídas e estados de início, conclusão e encerramento.

**Critério de conclusão:** professor publica uma atividade com questões revisadas; aluno matriculado a recebe e conclui; aluno de outra turma não acessa conteúdo restrito. Questões publicadas mantêm histórico de versão.

## 🔄 M3 — Sincronização e gamificação real

- [ ] Armazenar tentativas, respostas, datas, conclusão de módulos e histórico de progresso.
- [ ] Manter conteúdo previamente baixado e atividades elegíveis disponíveis offline.
- [ ] Mostrar estado de conexão, envio pendente, erro e nova tentativa de sincronização.
- [ ] Usar identificador único por tentativa e processamento idempotente para evitar duplicação ao reenviar.
- [ ] Definir conflitos entre aparelhos, horários de referência, virada do dia e fechamento semanal.
- [ ] Validar pontuação no backend; não aceitar XP arbitrário informado pelo cliente.
- [ ] Aplicar missões, conquistas e recompensas com regras explícitas de repetição.
- [ ] Implementar ranking semanal, mensal e geral com participantes reais da turma e regras verificáveis de liga.
- [ ] Migrar o progresso local conforme a política definida em M0, sem importar dados de demonstração como resultados reais.

**Critério de conclusão:** atividade offline sincroniza ao reconectar; reenvio não duplica tentativa nem XP; outro aparelho recupera o progresso confirmado; ranking respeita turma, período e pontuação validada.

## 🧑‍🏫 M4 — Acompanhamento e preparação do piloto

- [ ] Substituir dados demonstrativos do painel por resultados reais.
- [ ] Exibir participação, conclusão e acerto por tópico, identificando ausência de dados.
- [ ] Permitir consultar resultados de atividades e alunos que precisam de apoio.
- [ ] Validar legibilidade, contraste, ampliação de texto, áreas de toque e telas pequenas.
- [ ] Verificar rede instável, sessão expirada, falha de envio e recuperação após reiniciar o app.
- [ ] Disponibilizar política de privacidade e fluxo de exclusão de conta correspondente ao comportamento implementado.
- [ ] Preparar APK de teste identificado por versão e commit, notas da versão e instruções curtas.
- [ ] Definir canal de feedback, responsáveis pelo piloto e procedimento para incidentes e recuperação de dados.

**Critério de conclusão:** professor acompanha uma atividade real do início ao fim; fluxos críticos e recuperação de falhas estão validados; versão de teste e instruções estão disponíveis.

## 🏫 M5 — Piloto com uma turma de Eletrotécnica

- [ ] Definir turma, professor responsável, duração, conteúdo e objetivos pedagógicos.
- [ ] Definir previamente métricas e metas: adesão, conclusão, desempenho por tópico, falhas de sincronização e satisfação.
- [ ] Confirmar orientações institucionais e de participação antes de cadastrar estudantes.
- [ ] Orientar participantes e verificar acesso nos aparelhos usados pela turma.
- [ ] Executar atividades, acompanhar dúvidas e registrar problemas sem expor dados pessoais.
- [ ] Recolher feedback de alunos e professor, incluindo clareza das questões e utilidade das explicações.
- [ ] Comparar resultados com as metas e registrar limitações da avaliação.
- [ ] Corrigir bloqueios e decidir, em relatório, entre ampliar, repetir o piloto ou rever o produto.

**Critério de conclusão:** relatório com métricas, feedback, defeitos encontrados, correções prioritárias e decisão fundamentada sobre a próxima etapa.

## 🚀 M6 — Publicação e expansão

- [ ] Preparar assinatura e distribuição Android com processo reproduzível e segredos fora do repositório.
- [ ] Preparar ficha da loja, imagens reais e declarações coerentes com os dados efetivamente coletados.
- [ ] Automatizar análise, testes e build; vincular artefatos à versão e ao commit.
- [ ] Monitorar erros e custos com coleta mínima de dados e acesso restrito.
- [ ] Documentar operação, restauração, suporte e atualização do app.
- [ ] Ampliar primeiro para outras turmas; depois avaliar Eletrônica, Automação e ensino médio regular.
- [ ] Priorizar novos laboratórios e conteúdos conforme evidências do piloto.

**Critério de conclusão:** distribuição estável validada, operação documentada e expansão sustentada por resultados do piloto.

## ✅ Regra para marcar uma entrega como concluída

Cada item deve ter implementação ou documento correspondente, validação proporcional ao risco e referência à evidência (PR, commit, teste ou relatório). Alterações de código exigem análise e testes pertinentes; alterações apenas documentais exigem revisão de conteúdo e links.

Uma etapa só termina quando seu critério de conclusão for atendido. Ao iniciar trabalho, vincular uma issue ao item; ao encerrar, atualizar este arquivo no mesmo ciclo da entrega.

## 📌 Avanços locais em M2

- Banco curricular: 464 questões, com 141 figuras nas 26 disciplinas ([PR #12](https://github.com/frahncky/Gabaritei/pull/12)). O desafio adicional da planta do quarto acrescenta cinco questões: total atual de 469.
- Autoria assistida: prévia da figura, explicação e dica antes de salvar; modelos aplicados de Ohm e paralelo com figuras parametrizadas ([issue #13](https://github.com/frahncky/Gabaritei/issues/13)).

Esses avanços não concluem M2: edição completa, revisão docente, versionamento e publicação para turmas ainda estão pendentes.

## 🎨 Interface e abertura entregues

Implementação no [commit 49034ec](https://github.com/frahncky/Gabaritei/commit/49034ec):

- [x] Barra inferior em celulares e navegação lateral a partir de 840 px lógicos, preservando a aba selecionada ao redimensionar.
- [x] Conteúdo centralizado com largura limitada em telas grandes.
- [x] Cartões de cursos com ícones destacados, espaçamento e altura flexível; cabeçalhos preparados para textos longos.
- [x] Destaque visual para a próxima atividade, mantendo a identidade azul-marinho e âmbar.
- [x] Remoção dos cards de laboratórios da tela inicial.
- [x] Abertura direta: o splash nativo estático leva à tela de entrada, sem etapa animada intermediária.
- [x] Giro periódico na tela de entrada: elementos orbitam o círculo e o ✓ se traça ao final, com pausas de seis segundos e respeito à preferência por reduzir animações.

A navegação adaptativa e a sequência de animação têm testes automatizados. A conferência em aparelho, a ampliação de texto nas demais telas e os fluxos completos de acessibilidade continuam pendentes em M0 e M4.

## ⏭️ Próxima entrega

### Andamento da estabilização de M0 — 31/10/2026

- Diagnóstico inicial da suíte integrada: 216 testes aprovados e 37 falhas.
- Restaurada a geração de questões de instalações com a planta do quarto e IDs determinísticos; removidos desenhos sem relação com o assunto, preservando figuras parametrizadas de Ohm e paralelo.
- Validada a deduplicação ao gerar novamente a mesma questão, com persistência e salvamentos concorrentes.
- Corrigido o vínculo do avatar da tela inicial com a aba Perfil.
- Atualizada a contagem para 469 questões e preservada a atividade curricular `q-ie-1`, independente do desafio adicional da planta.
- Validação do conjunto de conteúdo, gerador, banco e salvamento: 80 testes aprovados. Mais sete testes aprovados para avatar, acessibilidade do avatar, tema, navegação adaptativa e splash: total de 87 verificações direcionadas. `flutter analyze` sem apontamentos.
- Teste de tema atualizado para usar o botão inicial “Começar”, preservando a verificação do fundo das rotas.
- Build `flutter build apk --debug` iniciado e interrompido após vários minutos sem conclusão do Gradle. O APK existente era anterior à tentativa; não há novo build validado nem instalação em aparelho nesta etapa.
- Pendências: adaptar os testes de telas à navegação curso → disciplina → módulos e à remoção dos laboratórios; tratar esperas de animação contínua nos testes; executar novamente a suíte completa. M0 permanece em andamento.

**M0 — Estabilizar e validar a base integrada.** Priorizar as falhas da suíte completa, atualizar os testes afetados pela navegação atual e gerar um APK para validar interface e abertura em aparelho. A primeira decisão técnica subsequente é a arquitetura do backend em M1. A escolha deve considerar custo, autenticação, autorização, operação offline e capacidade de manutenção; este roadmap não pressupõe fornecedor contratado.

## 🧭 Fora do primeiro piloto

Expansão para múltiplas instituições, novas plataformas, funcionalidades sociais amplas e monetização ficam para avaliação posterior. O primeiro piloto concentra-se em aprender, responder atividades e acompanhar uma turma com dados consistentes.
