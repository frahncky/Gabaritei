# ❓ Banco de questões

## Cobertura

| Indicador | Quantidade |
| --- | ---: |
| Cursos | 4 |
| Disciplinas | 26 |
| Unidades de estudo | 86 |
| Questões de estudo | 354 |
| Questões exclusivas de prova | 110 |
| Total de questões distintas | 464 |
| Questões novas nesta ampliação | 282 |

Cada módulo de estudo recebeu duas questões novas, totalizando 172 questões adicionais de prática. Nenhum dos 86 módulos fica com menos de quatro questões. O desafio independente de código de cores permanece com cinco.

As 26 provas usam banco separado: quatro perguntas por disciplina, exceto Eletrônica Analógica, com dez. São 110 perguntas exclusivas, com IDs e enunciados diferentes dos de estudo. O banco de provas revisita os mesmos conceitos em outros problemas; a separação de conteúdo não representa sigilo ou controle antifraude.

## Tipos de exercício

- Cálculos com grandezas, unidades e conversões, incluindo circuitos CC/CA, potência, transformadores, motores e sinais de instrumentação.
- Interpretação de lógica, algoritmos, formas de representação e comportamento de componentes.
- Aplicações e diagnóstico em processos, redes, robótica, sistemas embarcados e manutenção.
- Casos de desenho, fabricação, metrologia, planejamento, qualidade e consumo de recursos.

Os enunciados numéricos especificam hipóteses relevantes, como componente ideal, condução contínua ou ausência de perdas. As explicações apresentam a relação utilizada e o resultado. As alternativas novas distribuem o gabarito entre posições sem mudar sua correspondência com a resposta.

## Organização e revisão

- `sample_content.dart`: catálogo de atividades, vínculos de disciplinas e medalhas.
- `curriculum_content.dart`: resumos e questões da base inicial das disciplinas complementares.
- `expanded_question_bank.dart`: acréscimos por ID de módulo e banco independente de avaliação.
- Revisão do banco: `2026.10.30.2`.
- IDs de questões novas de estudo: `bank-v2-...`.
- IDs de questões de avaliação: `exam-v2-...`.

Os exercícios novos são próprios deste projeto. A conferência de conteúdo e os testes automatizados não substituem revisão pedagógica e técnica independente por docentes. O banco não declara alinhamento formal a um PPC ou certificação de formação. Questões sobre segurança são conceituais e não substituem norma vigente, capacitação, autorização ou procedimento de trabalho.

## Histórico de progresso

IDs de atividades e medalhas foram preservados. Notas e conquistas anteriores continuam registradas como histórico; não são recalculadas nem apresentadas como novas respostas às questões adicionadas. Novas tentativas utilizam o banco ampliado, preservando a regra existente de melhor nota.

Não há novo pagamento de XP ou conclusão automática apenas por atualizar o conteúdo. A restauração de medalhas por notas antigas mantém a política anterior. Para uma futura avaliação formal, será necessário versionar tentativas e definir critérios de reavaliação; isso permanece no roadmap.

## Validação automática

A suíte verifica:

- Cobertura dos 86 módulos e mínimo de questões por atividade.
- Provas separadas do estudo, comparando IDs e enunciados.
- IDs únicos, alternativas distintas, gabaritos válidos e explicações presentes.
- Correspondência do gabarito após distribuir as posições das alternativas.
- Conversões e cálculos representativos contra fórmulas independentes.
- Preservação de notas, XP, medalhas, desbloqueios e persistência.

O gerador de Lei de Ohm usado no painel também recebeu correção para impedir que um distrator repita a alternativa correta.

## Figuras, gráficos e tabelas

137 questões possuem recursos visuais próprios, cobrindo as 26 disciplinas. Os dados são ligados ao ID da questão; as figuras não utilizam o gabarito para obter valores. Circuitos, formas de onda, tabelas-verdade, Ladder e gráficos de processo têm representação específica. [Ver recursos e validação](questoes_visuais.md).
