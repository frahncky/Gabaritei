import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Cores das plantas elétricas: arquitetura em azul de planta técnica,
/// instalação em tom claro e neutro, e âmbar só para o que está energizado
/// (cargas andando nos eletrodutos e a lâmpada acesa).
abstract final class PlanColors {
  /// Faces das paredes, batentes e janela.
  static const wall = AppColors.skyOnInk;

  /// Preenchimento da faixa das paredes.
  static final wallFill =
      Color.lerp(AppColors.surface, AppColors.skyOnInk, .3)!;

  /// Símbolos de pontos elétricos (luz, interruptor, tomadas, quadro).
  static const symbol = AppColors.text;

  /// Traço do eletroduto.
  static const conduit = AppColors.muted;

  /// Lâmpada acesa.
  static const lit = AppColors.amber;

  /// Cargas andando pelos eletrodutos (a mesma cor da corrente nos
  /// circuitos).
  static const current = AppColors.amberText;
}

/// Símbolos tradicionais de plantas de instalações prediais, os ensinados nos
/// cursos técnicos (simbologia tradicional de plantas prediais), adaptados para tela pequena. A planta e a
/// legenda usam as mesmas funções, para que o símbolo explicado seja sempre o
/// símbolo desenhado.
abstract final class PlanSymbols {
  /// Ponto de luz no teto: círculo com a potência (VA) em cima e, embaixo, o
  /// circuito (à esquerda) e o comando (à direita). Os textos ficam com quem
  /// chama, porque dependem do tamanho e do estado da lâmpada.
  static void ceilingLight(
    Canvas canvas,
    Offset center,
    double radius, {
    required Color line,
    required Color fill,
    double strokeWidth = 1.6,
  }) {
    canvas.drawCircle(center, radius, Paint()..color = fill);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
    final divider = Paint()
      ..color = line
      ..strokeWidth = strokeWidth * .75;
    canvas.drawLine(
        center - Offset(radius, 0), center + Offset(radius, 0), divider);
    canvas.drawLine(center, center + Offset(0, radius), divider);
  }

  /// Interruptor simples (uma seção): círculo cheio junto à parede.
  static void simpleSwitch(
      Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(center, radius, Paint()..color = color);
  }

  /// Tomada: triângulo com a base na face da parede ([base]) e a ponta para
  /// dentro do cômodo ([inward], vetor unitário). Vazado = baixa; cheio = alta.
  static void outlet(
    Canvas canvas, {
    required Offset base,
    required Offset inward,
    required double size,
    required bool high,
    required Color color,
    required Color background,
    double strokeWidth = 1.5,
  }) {
    final half = Offset(-inward.dy, inward.dx) * (size / 2);
    final tip = base + inward * (size * .8);
    final path = Path()
      ..moveTo((base + half).dx, (base + half).dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo((base - half).dx, (base - half).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = high ? color : background);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Traço do eletroduto embutido no teto ou na parede (linha contínua).
  static Paint conduit({double width = 1.6}) => Paint()
    ..color = PlanColors.conduit
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round;
}

/// Símbolos que a legenda das plantas sabe mostrar.
enum PlanSymbol { ceilingLight, simpleSwitch, lowOutlet, highOutlet, conduit }

/// Ícone de legenda com o mesmo traço da planta.
class PlanSymbolIcon extends StatelessWidget {
  const PlanSymbolIcon(this.symbol, {super.key, this.size = 18});

  final PlanSymbol symbol;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _PlanSymbolIconPainter(symbol),
      );
}

class _PlanSymbolIconPainter extends CustomPainter {
  const _PlanSymbolIconPainter(this.symbol);

  final PlanSymbol symbol;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = size.center(Offset.zero);
    // Tomadas e interruptor aparecem presos a um trecho de parede, como na
    // planta.
    final wallY = s * .2;
    final wall = Paint()
      ..color = PlanColors.wall
      ..strokeWidth = 2;
    switch (symbol) {
      case PlanSymbol.ceilingLight:
        PlanSymbols.ceilingLight(canvas, center, s * .44,
            line: PlanColors.symbol, fill: AppColors.surface, strokeWidth: 1.3);
      case PlanSymbol.simpleSwitch:
        canvas.drawLine(Offset(0, wallY), Offset(s, wallY), wall);
        PlanSymbols.simpleSwitch(canvas, Offset(center.dx, wallY + s * .22),
            s * .2, PlanColors.symbol);
      case PlanSymbol.lowOutlet || PlanSymbol.highOutlet:
        canvas.drawLine(Offset(0, wallY), Offset(s, wallY), wall);
        PlanSymbols.outlet(
          canvas,
          base: Offset(center.dx, wallY + 1),
          inward: const Offset(0, 1),
          size: s * .72,
          high: symbol == PlanSymbol.highOutlet,
          color: PlanColors.symbol,
          background: AppColors.surface,
          strokeWidth: 1.3,
        );
      case PlanSymbol.conduit:
        canvas.drawLine(Offset(1, center.dy), Offset(s - 1, center.dy),
            PlanSymbols.conduit());
    }
  }

  @override
  bool shouldRepaint(_PlanSymbolIconPainter old) => old.symbol != symbol;
}
