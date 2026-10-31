import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Faixa de luz que atravessa [child] uma vez, na diagonal, enquanto
/// [progress] vai de 0 a 1. Nos extremos não desenha nada: a tela assenta
/// limpa.
class LightSweep extends StatelessWidget {
  const LightSweep({
    super.key,
    required this.progress,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  final Animation<double> progress;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _SweepPainter(progress, borderRadius),
      child: child,
    );
  }
}

class _SweepPainter extends CustomPainter {
  _SweepPainter(this.progress, this.borderRadius) : super(repaint: progress);

  final Animation<double> progress;
  final BorderRadius borderRadius;

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1) return;
    // A faixa entra pela esquerda e sai pela direita, mais forte no meio.
    final band = math.max(size.height, 80.0);
    final x = -band + t * (size.width + band * 2);
    final strength = math.sin(math.pi * t);
    _paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.text.withValues(alpha: 0),
        AppColors.text.withValues(alpha: 0.16 * strength),
        AppColors.text.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCenter(
      center: Offset(x, size.height / 2),
      width: band,
      height: size.height,
    ));
    canvas.drawRRect(borderRadius.toRRect(Offset.zero & size), _paint);
  }

  @override
  bool shouldRepaint(_SweepPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.borderRadius != borderRadius;
}

/// Halo redondo e suave atrás de [child], com força [intensity] (0 a 1).
/// Pode passar das bordas do widget.
class GlowSpot extends StatelessWidget {
  const GlowSpot({
    super.key,
    required this.intensity,
    this.radius = 48,
    this.color = AppColors.amber,
    this.child,
  });

  final Animation<double> intensity;
  final double radius;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GlowPainter(intensity, radius, color),
      child: child,
    );
  }
}

class _GlowPainter extends CustomPainter {
  _GlowPainter(this.intensity, this.radius, this.color)
      : super(repaint: intensity);

  final Animation<double> intensity;
  final double radius;
  final Color color;

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final v = intensity.value.clamp(0.0, 1.0);
    if (v <= 0) return;
    final center = size.center(Offset.zero);
    _paint.shader = RadialGradient(
      colors: [
        color.withValues(alpha: 0.5 * v),
        color.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, _paint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) =>
      oldDelegate.intensity != intensity ||
      oldDelegate.radius != radius ||
      oldDelegate.color != color;
}

/// Estrelinhas de quatro pontas que acendem e apagam uma vez em volta de
/// [child] enquanto [progress] vai de 0 a 1.
///
/// [points] são posições relativas ao [child]; valores além de ±1 ficam do
/// lado de fora.
class Twinkle extends StatelessWidget {
  const Twinkle({
    super.key,
    required this.progress,
    required this.child,
    this.points = const [
      Alignment(-1.12, -0.7),
      Alignment(1.1, -0.85),
      Alignment(1.18, 0.55),
      Alignment(-1.05, 0.8),
    ],
    this.size = 9,
  });

  final Animation<double> progress;
  final List<Alignment> points;
  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _TwinklePainter(progress, points, size),
      child: child,
    );
  }
}

class _TwinklePainter extends CustomPainter {
  _TwinklePainter(this.progress, this.points, this.starSize)
      : super(repaint: progress);

  final Animation<double> progress;
  final List<Alignment> points;
  final double starSize;

  final Paint _paint = Paint();

  static final Path _star = () {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final r = i.isEven ? 1.0 : 0.28;
      final a = -math.pi / 2 + i * math.pi / 4;
      final p = Offset(math.cos(a) * r, math.sin(a) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1) return;
    const stagger = 0.12;
    final window = 1 - stagger * (points.length - 1);
    for (var i = 0; i < points.length; i++) {
      final local = ((t - i * stagger) / window).clamp(0.0, 1.0);
      final scale = math.sin(math.pi * local);
      if (scale <= 0) continue;
      _paint.color = i.isEven ? AppColors.amberOnInk : AppColors.text;
      canvas
        ..save()
        ..translate(points[i].alongSize(size).dx, points[i].alongSize(size).dy)
        ..rotate(local * 0.8)
        ..scale(starSize * scale)
        ..drawPath(_star, _paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_TwinklePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.points != points ||
      oldDelegate.starSize != starSize;
}
