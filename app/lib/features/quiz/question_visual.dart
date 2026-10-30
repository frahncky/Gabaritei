import 'package:flutter/material.dart';

import '../../domain/models/content.dart';
import '../../domain/models/question_figure.dart';
import 'figure_view.dart';

/// Compatibilidade com questões antigas; figuras novas têm prioridade.
class QuestionVisualCard extends StatelessWidget {
  const QuestionVisualCard({super.key, this.visual, this.figure})
      : assert(visual != null || figure != null);
  final QuestionVisual? visual;
  final QuestionFigure? figure;

  @override
  Widget build(BuildContext context) =>
      QuestionFigureView(figure: figure ?? _conceptual(visual!));

  static QuestionFigure _conceptual(QuestionVisual visual) => switch (visual) {
    QuestionVisual.circuitSeries => const QuestionFigure(
      kind: FigureKind.seriesCircuit, title: 'Conexão em série',
      description: 'Representação conceitual de elementos em série. Use os valores do enunciado.',
      sourceLabel: 'Fonte', elements: [CircuitElement('R1'), CircuitElement('R2')],
    ),
    QuestionVisual.circuitParallel => const QuestionFigure(
      kind: FigureKind.parallelCircuit, title: 'Conexão em paralelo',
      description: 'Dois ramos ligados aos mesmos nós. Use os valores do enunciado.',
      sourceLabel: 'Fonte', elements: [CircuitElement('R1'), CircuitElement('R2')],
    ),
    QuestionVisual.resistorBands => const QuestionFigure(
      kind: FigureKind.referenceTable, title: 'Código de cores',
      description: 'Tabela de dígitos. Leia as faixas e o multiplicador informados no enunciado.',
      headers: ['Cor','Dígito'],
      rows: [['preto','0'],['marrom','1'],['vermelho','2'],['laranja','3'],['amarelo','4'],
        ['verde','5'],['azul','6'],['violeta','7'],['cinza','8'],['branco','9']],
    ),
    QuestionVisual.electricalPlan => const QuestionFigure(
      kind: FigureKind.blocks, title: 'Organização conceitual',
      description: 'Quadro, circuitos e pontos da instalação. Este diagrama não é uma planta nem um projeto executivo.',
      labels: ['Quadro','Circuitos','Pontos'],
    ),
    QuestionVisual.processControl => const QuestionFigure(
      kind: FigureKind.blocks, title: 'Malha de processo',
      description: 'Sensor, controlador, atuador e planta com realimentação. Representação conceitual sem valores numéricos.',
      labels: ['Sensor','Controlador','Atuador','Planta'], feedback: true,
    ),
  };
}
