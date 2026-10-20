import 'package:flutter/material.dart';

import '../app/theme.dart';

/// Símbolo do Gabaritei: a bolha do gabarito marcada, com um ✓.
///
/// O mesmo desenho gera o ícone do app e o splash
/// (`flutter test tool/brand_assets_test.dart`).
class GabariteiMark extends StatelessWidget {
  const GabariteiMark({super.key, this.size = 72, this.withBackground = true});

  final double size;

  /// Com o quadrado escuro atrás (ícone) ou só a bolha (sobre fundo escuro).
  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Gabaritei',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: GabariteiMarkPainter(withBackground: withBackground),
      ),
    );
  }
}

class GabariteiMarkPainter extends CustomPainter {
  const GabariteiMarkPainter({
    this.withBackground = true,
    this.fullBleed = false,
    this.bubbleScale = 0.6,
  });

  final bool withBackground;

  /// Fundo ocupando o quadrado inteiro, sem cantos arredondados (ícone legado).
  final bool fullBleed;

  /// Diâmetro da bolha em relação ao lado do quadrado.
  final double bubbleScale;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final center = size.center(Offset.zero);

    if (withBackground) {
      final rect = Offset.zero & size;
      final paint = Paint()..color = AppColors.ink;
      if (fullBleed) {
        canvas.drawRect(rect, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(side * 0.24)),
          paint,
        );
      }
    }

    final radius = side * bubbleScale / 2;

    // Trilhas e nós: o conhecimento se conecta até fechar o gabarito.
    final trace = Paint()
      ..color = AppColors.skyOnInk.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = side * 0.025
      ..strokeCap = StrokeCap.round;
    final node = Paint()..color = AppColors.skyOnInk;
    final paths = [
      Path()
        ..moveTo(side * 0.06, center.dy)
        ..lineTo(center.dx - radius, center.dy),
      Path()
        ..moveTo(center.dx + radius * 0.72, center.dy - radius * 0.7)
        ..lineTo(side * 0.82, side * 0.2)
        ..lineTo(side * 0.94, side * 0.2),
      Path()
        ..moveTo(center.dx, center.dy + radius)
        ..lineTo(center.dx, side * 0.9),
    ];
    for (final path in paths) {
      canvas.drawPath(path, trace);
    }
    canvas.drawCircle(Offset(side * 0.06, center.dy), side * 0.04, node);
    canvas.drawCircle(Offset(side * 0.94, side * 0.2), side * 0.04, node);
    canvas.drawCircle(Offset(center.dx, side * 0.9), side * 0.04, node);

    canvas.drawCircle(center, radius, Paint()..color = AppColors.amber);

    // ✓ desenhado em coordenadas relativas ao raio da bolha.
    Offset at(double dx, double dy) =>
        center + Offset(dx * radius, dy * radius);
    final check = Path()
      ..moveTo(at(-0.44, 0.04).dx, at(-0.44, 0.04).dy)
      ..lineTo(at(-0.12, 0.36).dx, at(-0.12, 0.36).dy)
      ..lineTo(at(0.48, -0.30).dx, at(0.48, -0.30).dy);
    canvas.drawPath(
      check,
      Paint()
        ..color = AppColors.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(GabariteiMarkPainter oldDelegate) =>
      oldDelegate.withBackground != withBackground ||
      oldDelegate.fullBleed != fullBleed ||
      oldDelegate.bubbleScale != bubbleScale;
}
