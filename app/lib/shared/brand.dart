import 'dart:math' as math;

import 'package:flutter/material.dart';

const _brandInk = Color(0xFF0F1D33);
const _brandAmber = Color(0xFFF59E0B);
const _brandTrace = Color(0xFF93B4FA);

/// Símbolo do Gabaritei: a bolha do gabarito marcada, com um ✓, alimentada
/// pelos três pilares do domínio de um assunto.
///
/// O mesmo desenho gera o ícone do app e o splash
/// (`flutter test tool/brand_assets_test.dart`).
class GabariteiMark extends StatelessWidget {
  const GabariteiMark({super.key, this.size = 72, this.withBackground = true});

  final double size;

  /// Com o quadrado escuro atrás (ícone) ou só a bolha (sobre fundo escuro).
  final bool withBackground;

  static const semanticsLabel = 'Gabaritei: teoria, prática e contexto';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: GabariteiMarkPainter(withBackground: withBackground),
      ),
    );
  }
}

/// Desenha a marca: o ✓ no centro e, ligados a ele por trilhas de circuito,
/// os três pilares do domínio:
/// - **Teoria** (livro aberto, no alto): o que se estuda;
/// - **Prática** (duas engrenagens engrenadas, embaixo à direita): o que
///   se faz, as peças girando juntas;
/// - **Contexto** (lâmpada, embaixo à esquerda): a mentalidade, o porquê.
///
/// Tudo é medido em raios da bolha, então a composição inteira cresce e
/// encolhe com [bubbleScale].
class GabariteiMarkPainter extends CustomPainter {
  const GabariteiMarkPainter({
    this.withBackground = true,
    this.fullBleed = false,
    this.bubbleScale = defaultBubbleScale,
  });

  /// Bolha que deixa os três pilares dentro do quadrado do ícone.
  static const defaultBubbleScale = 0.44;

  /// Raio, em raios da bolha, do círculo que contém a composição inteira
  /// em volta do centro do quadrado (medido: 2,13). Serve para caber em
  /// máscaras redondas: zona segura do ícone adaptativo e círculo do splash
  /// do Android 12.
  static const extentInBubbleRadii = 2.14;

  /// [bubbleScale] que deixa a marca inteira num círculo de raio
  /// [radiusFraction] (fração do lado) em volta do centro.
  static double bubbleScaleToFit(double radiusFraction) =>
      2 * radiusFraction / extentInBubbleRadii;

  final bool withBackground;

  /// Fundo ocupando o quadrado inteiro, sem cantos arredondados (ícone legado).
  final bool fullBleed;

  /// Diâmetro da bolha em relação ao lado do quadrado.
  final double bubbleScale;

  /// A bolha desce um pouco do centro para equilibrar o livro no alto com
  /// os dois pilares de baixo.
  static const _drop = 0.16;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;

    if (withBackground) {
      final rect = Offset.zero & size;
      final paint = Paint()..color = _brandInk;
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
    final center = size.center(Offset.zero) + Offset(0, radius * _drop);
    Offset polar(double degrees, double distance) {
      final a = degrees * math.pi / 180;
      return center + Offset(math.cos(a), math.sin(a)) * (distance * radius);
    }

    // Trilhas: cada pilar se conecta à bolha do gabarito.
    final trace = Paint()
      ..color = _brandTrace.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.09
      ..strokeCap = StrokeCap.round;
    final pillar = Paint()..color = _brandTrace;
    for (final p in _pillars) {
      canvas.drawLine(polar(p.angle, 1.0), polar(p.angle, p.traceEnd), trace);
      canvas.save();
      final at = polar(p.angle, p.distance);
      canvas.translate(at.dx, at.dy);
      canvas.scale(radius * p.scale);
      canvas.drawPath(p.icon(), pillar);
      canvas.restore();
    }

    canvas.drawCircle(center, radius, Paint()..color = _brandAmber);

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
        ..color = _brandInk
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

/// Um pilar: pictograma em coordenadas próprias (cerca de -1 a 1), posto a
/// [distance] raios da bolha na direção [angle] (graus, sentido horário a
/// partir da direita).
class _Pillar {
  const _Pillar({
    required this.angle,
    required this.distance,
    required this.scale,
    required this.traceEnd,
    required this.icon,
  });

  final double angle;
  final double distance;
  final double scale;
  final double traceEnd;
  final Path Function() icon;
}

const _pillars = [
  _Pillar(
    angle: -90,
    distance: 1.5,
    scale: 0.48,
    traceEnd: 1.18,
    icon: _bookIcon,
  ),
  _Pillar(
    angle: 38,
    distance: 1.62,
    scale: 0.62,
    traceEnd: 1.4,
    icon: _gearsIcon,
  ),
  _Pillar(
    angle: 142,
    distance: 1.6,
    scale: 0.52,
    traceEnd: 1.28,
    icon: _bulbIcon,
  ),
];

/// Une as formas sem depender do sentido em que cada uma foi traçada.
Path _union(List<Path> parts) =>
    parts.reduce((a, b) => Path.combine(PathOperation.union, a, b));

/// Teoria: livro aberto visto de frente, duas páginas separadas pela lombada.
Path _bookIcon() {
  Path page(double s) => Path()
    ..moveTo(s * 0.08, -0.38)
    ..quadraticBezierTo(s * 0.5, -0.66, s * 1.0, -0.56)
    ..lineTo(s * 1.0, 0.5)
    ..quadraticBezierTo(s * 0.5, 0.42, s * 0.08, 0.66)
    ..close();
  return _union([page(-1), page(1)]);
}

/// Engrenagem com [teeth] dentes trapezoidais largos (legíveis em 48 px),
/// o primeiro apontando para [firstToothDeg] graus, e furo no eixo.
Path _gear(
  Offset center, {
  required double body,
  required double tip,
  required int teeth,
  required double firstToothDeg,
  required double hole,
}) {
  final step = 2 * math.pi / teeth;
  // Dente: mais largo na raiz que na ponta, cobrindo ~55% do passo.
  final rootHalf = step * 0.29;
  final tipHalf = step * 0.2;
  Offset at(double angle, double r) =>
      center + Offset(math.cos(angle), math.sin(angle)) * r;
  final shape = _union([
    Path()..addOval(Rect.fromCircle(center: center, radius: body)),
    for (var i = 0; i < teeth; i++)
      () {
        final a = firstToothDeg * math.pi / 180 + i * step;
        return Path()
          ..addPolygon([
            at(a - rootHalf, body * 0.9),
            at(a - tipHalf, tip),
            at(a + tipHalf, tip),
            at(a + rootHalf, body * 0.9),
          ], true);
      }(),
  ]);
  return Path.combine(
    PathOperation.difference,
    shape,
    Path()..addOval(Rect.fromCircle(center: center, radius: hole)),
  );
}

/// Prática: duas engrenagens engrenadas, a maior embaixo e a menor no alto.
/// Um dente da maior entra no vão da menor, com uma fresta entre as duas
/// para que não se fundam numa mancha só.
Path _gearsIcon() {
  return _union([
    _gear(
      const Offset(-0.3, 0.3),
      body: 0.44,
      tip: 0.66,
      teeth: 6,
      firstToothDeg: -45,
      hole: 0.2,
    ),
    _gear(
      const Offset(0.5, -0.5),
      body: 0.34,
      tip: 0.52,
      teeth: 5,
      firstToothDeg: 135 + 36,
      hole: 0.15,
    ),
  ]);
}

/// Contexto: lâmpada acesa, a ideia que dá sentido ao que se estuda.
Path _bulbIcon() {
  return _union([
    Path()
      ..addOval(Rect.fromCircle(center: const Offset(0, -0.32), radius: 0.62)),
    Path()
      ..addPolygon(const [
        Offset(-0.4, 0.0),
        Offset(0.4, 0.0),
        Offset(0.28, 0.5),
        Offset(-0.28, 0.5),
      ], true),
    Path()
      ..addRRect(
          RRect.fromLTRBR(-0.3, 0.6, 0.3, 0.74, const Radius.circular(0.07))),
    Path()
      ..addRRect(
          RRect.fromLTRBR(-0.2, 0.84, 0.2, 0.98, const Radius.circular(0.07))),
  ]);
}
