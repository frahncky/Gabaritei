# 🖼️ Questões visuais

## Cobertura e dados

O banco mantém 464 questões. Delas, 137 possuem figuras parametrizadas próprias, distribuídas pelas 26 disciplinas. Cada disciplina tem pelo menos três questões ilustradas; isso não significa que todas as questões ou todos os módulos tenham figuras.

Os vínculos são explícitos por ID em `app/lib/data/memory/question_figure_catalog.dart`. Dados numéricos não são extraídos automaticamente do texto nem do gabarito. O modelo `QuestionFigure` guarda componentes, curvas, escalas, rótulos e células de tabela.

## Recursos

- **Circuitos:** conexões reais de série, paralelo e misto, com fontes e componentes identificados. Ramos paralelos compartilham os mesmos nós e não são desenhados como resistores em série.
- **Eletrônica:** símbolos de resistor, capacitor, indutor e diodo; faixas de resistores e diagramas funcionais.
- **CA:** formas de onda com eixos e unidades, atrasos temporais, amplitude normalizada quando aplicável e componentes ortogonais.
- **Digital e CLP:** tabelas-verdade com saídas desconhecidas, contatos NA/NF, bobinas e gráficos de temporização.
- **Processos e instrumentação:** curvas de escala, gráficos de SP/PV e malhas com realimentação.
- **Mecânica e pneumática:** engrenagens, forças axiais, alavancas, cilindros e braço planar.
- **Demais áreas:** desenhos de escala, topologias de comunicação, tabelas de dados, fluxos e comparações em barras.

As figuras não são projetos executivos. Desenhos mecânicos e de escala são esquemáticos; não se deve inferir dimensão física medindo pixels. Gráficos normalizados e tendências qualitativas são identificados como tais, sem apresentar números ilustrativos como dados medidos do exercício.

## Leitura e acessibilidade

O cartão usa título, figura e descrição textual acessível. As tabelas usam células nativas e permitem rolagem horizontal. Legendas de curvas ficam fora do desenho. A opção “Descrição da figura” apresenta os dados e as convenções utilizadas.

As figuras são estáticas e não mantêm animação contínua durante a leitura. Questões antigas sem dados específicos usam representações conceituais sem valores numéricos inventados.

## Persistência e compatibilidade

O campo `figure` é opcional. Questões antigas sem esse campo continuam abrindo. Figuras de questões salvas pelo professor são serializadas junto do enunciado, alternativas e explicação. Adicionar uma figura não altera ID, gabarito, XP, notas ou medalhas.

## Validação

A suíte verifica cobertura das 26 disciplinas, vínculos válidos, serialização, escalas e pontos de curvas, valores selecionados de circuitos, atraso de fase e representação de contatos NF. Também verifica que anexar uma figura não muda alternativas ou gabarito.

Os testes de interface renderizam as figuras em tela de 320 pixels de largura e em 400 pixels com texto ampliado. O workflow gera amostras PNG para inspeção visual no artefato `question-figure-previews`.

O banco ainda precisa de revisão pedagógica por docentes. A cobertura atual é uma base para ampliar figuras a mais exercícios, especialmente com novos dados experimentais e gráficos específicos de cada aplicação.
