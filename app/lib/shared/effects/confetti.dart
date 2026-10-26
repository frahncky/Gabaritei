import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum _ShotKind { burst, sparks, cannon }

enum _Shape { strip, dot, triangle, spark }

/// Um disparo de confete ou de faíscas, com hora marcada.
///
/// A origem é [anchor] (posição relativa na área do efeito) mais [offset] em
/// pixels, para mirar em algo de posição conhecida, como o anel do resultado.
class ConfettiShot {
  /// Estouro em todas as direções, saindo de um círculo de raio [startRadius].
  const ConfettiShot.burst({
    required this.anchor,
    this.offset = Offset.zero,
    this.count = 40,
    this.startRadius = 0,
    this.delay = Duration.zero,
  })  : _kind = _ShotKind.burst,
        direction = 0,
        spread = math.pi * 2;

  /// Faíscas: riscos curtos e rápidos, em linha reta para fora.
  const ConfettiShot.sparks({
    required this.anchor,
    this.offset = Offset.zero,
    this.count = 14,
    this.startRadius = 0,
    this.delay = Duration.zero,
  })  : _kind = _ShotKind.sparks,
        direction = 0,
        spread = math.pi * 2;

  /// Canhão: jato em leque na [direction], em radianos (−π/2 aponta para
  /// cima), aberto em [spread].
  const ConfettiShot.cannon({
    required this.anchor,
    required this.direction,
    this.offset = Offset.zero,
    this.count = 18,
    this.spread = 0.7,
    this.delay = Duration.zero,
  })  : _kind = _ShotKind.cannon,
        startRadius = 0;

  final _ShotKind _kind;
  final Alignment anchor;
  final Offset offset;
  final int count;
  final double startRadius;
  final double direction;
  final double spread;
  final Duration delay;
}

/// Partículas de um conjunto de disparos, sorteadas uma vez (com semente
/// fixa, para as capturas saírem iguais) e reaproveitadas em todo quadro.
class ConfettiPlan {
  factory ConfettiPlan(List<ConfettiShot> shots, {int seed = 7}) {
    final random = math.Random(seed);
    final particles = [
      for (final shot in shots)
        for (var i = 0; i < shot.count; i++) _Particle(shot, i, random),
    ];
    assert(
      particles.length <= maxParticles,
      'Confete demais (${particles.length}) para celular simples.',
    );
    var end = 0.0;
    for (final p in particles) {
      end = math.max(end, p.start + p.life);
    }
    return ConfettiPlan._(
      List.unmodifiable(particles),
      Duration(milliseconds: (end * 1000).ceil()),
    );
  }

  const ConfettiPlan._(this._particles, this.duration);

  /// Teto de partículas somando todos os disparos.
  static const maxParticles = 120;

  final List<_Particle> _particles;

  /// Quando a última partícula some, contando do início do plano.
  final Duration duration;

  bool get isEmpty => _particles.isEmpty;
}

class _Particle {
  factory _Particle(ConfettiShot shot, int index, math.Random r) {
    final sparks = shot._kind == _ShotKind.sparks;
    // Faíscas saem espaçadas por igual; o resto, no sorteio.
    final angle = switch (shot._kind) {
      _ShotKind.sparks =>
        (index + r.nextDouble() * 0.5) * shot.spread / shot.count,
      _ShotKind.burst => r.nextDouble() * shot.spread,
      _ShotKind.cannon => shot.direction + (r.nextDouble() - 0.5) * shot.spread,
    };
    final speed = switch (shot._kind) {
      _ShotKind.burst => 420 + r.nextDouble() * 520,
      _ShotKind.sparks => 380 + r.nextDouble() * 260,
      _ShotKind.cannon => 950 + r.nextDouble() * 550,
    };
    final dx = math.cos(angle);
    final dy = math.sin(angle);
    final shape = sparks
        ? _Shape.spark
        : const [
            _Shape.strip,
            _Shape.strip,
            _Shape.dot,
            _Shape.triangle
          ][r.nextInt(4)];
    final colors = sparks ? _sparkColors : _confettiColors;
    return _Particle._(
      anchor: shot.anchor,
      ox: shot.offset.dx + dx * shot.startRadius,
      oy: shot.offset.dy + dy * shot.startRadius,
      dx: dx,
      dy: dy,
      // O estouro puxa um pouco para cima, como se saísse do anel.
      vx: dx * speed,
      vy: dy * speed - (shot._kind == _ShotKind.burst ? 120 : 0),
      start: shot.delay.inMicroseconds / 1e6 +
          (sparks ? 0 : r.nextDouble() * 0.06),
      life: sparks ? 0.32 + r.nextDouble() * 0.18 : 1.3 + r.nextDouble() * 0.5,
      drag: sparks ? 4.5 : 2.4 + r.nextDouble() * 1.4,
      gravity: sparks ? 0 : 560 + r.nextDouble() * 120,
      angle: r.nextDouble() * math.pi,
      spin: (r.nextDouble() - 0.5) * 12,
      flip: 4 + r.nextDouble() * 8,
      wobble: sparks ? 0 : 6 + r.nextDouble() * 10,
      phase: r.nextDouble() * math.pi * 2,
      size: sparks ? 10 + r.nextDouble() * 6 : 7 + r.nextDouble() * 4,
      shape: shape,
      color: colors[r.nextInt(colors.length)],
    );
  }

  const _Particle._({
    required this.anchor,
    required this.ox,
    required this.oy,
    required this.dx,
    required this.dy,
    required this.vx,
    required this.vy,
    required this.start,
    required this.life,
    required this.drag,
    required this.gravity,
    required this.angle,
    required this.spin,
    required this.flip,
    required this.wobble,
    required this.phase,
    required this.size,
    required this.shape,
    required this.color,
  });

  /// Âmbar = conquista; branco e azul claro de apoio. Nada de arco-íris.
  static const _confettiColors = [
    AppColors.amber,
    AppColors.amberOnInk,
    AppColors.amber,
    AppColors.skyOnInk,
    AppColors.text,
  ];
  static const _sparkColors = [
    AppColors.amberOnInk,
    AppColors.text,
    AppColors.amberOnInk,
  ];

  final Alignment anchor;
  final double ox, oy; // origem relativa à âncora, em px
  final double dx, dy; // direção do disparo (faíscas)
  final double vx, vy; // px/s
  final double start, life; // s
  final double drag; // 1/s: o ar freia o estouro
  final double gravity; // px/s²
  final double angle, spin, flip, wobble, phase;
  final double size;
  final _Shape shape;
  final Color color;
}

/// Desenha um [ConfettiPlan] no tempo de [clock]: de 0 a 1 percorre [span].
///
/// Não recebe toques nem aparece para leitores de tela. Quem usa decide se
/// mostra o efeito: com redução de movimento, não mostre.
class ConfettiField extends StatelessWidget {
  const ConfettiField({
    super.key,
    required this.plan,
    required this.clock,
    required this.span,
  });

  final ConfettiPlan plan;
  final Animation<double> clock;
  final Duration span;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(plan, clock, span),
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.plan, this.clock, this.span) : super(repaint: clock);

  final ConfettiPlan plan;
  final Animation<double> clock;
  final Duration span;

  final Paint _fill = Paint();
  final Paint _stroke = Paint()
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2.2;

  static final Path _triangle = Path()
    ..moveTo(0, -0.55)
    ..lineTo(0.5, 0.35)
    ..lineTo(-0.5, 0.35)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    final now = clock.value * span.inMicroseconds / 1e6;
    if (now <= 0) return;
    for (final p in plan._particles) {
      final s = now - p.start;
      if (s <= 0 || s >= p.life) continue;
      final f = s / p.life;

      // Queda com arrasto linear: o estouro freia e a peça desce flutuando.
      final e = math.exp(-p.drag * s);
      final travel = (1 - e) / p.drag;
      final terminal = p.gravity / p.drag;
      final origin = p.anchor.alongSize(size);
      final x = origin.dx +
          p.ox +
          p.vx * travel +
          p.wobble * math.sin(p.phase + s * 9) * (1 - e);
      final y = origin.dy + p.oy + terminal * s + (p.vy - terminal) * travel;

      if (p.shape == _Shape.spark) {
        final alpha = 1 - f * f;
        final length = p.size * (1 - f * 0.6);
        _stroke.color = p.color.withValues(alpha: alpha);
        canvas.drawLine(
          Offset(x - p.dx * length, y - p.dy * length),
          Offset(x, y),
          _stroke,
        );
        continue;
      }

      final alpha = f < 0.65 ? 1.0 : (1 - f) / 0.35;
      _fill.color = p.color.withValues(alpha: alpha);
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(p.angle + p.spin * s)
        // Cosseno no eixo vertical: a peça "vira" no ar como papel.
        ..scale(p.size, p.size * math.cos(p.phase + p.flip * s));
      switch (p.shape) {
        case _Shape.strip:
          canvas.drawRect(
              Rect.fromCenter(center: Offset.zero, width: 1, height: 0.45),
              _fill);
        case _Shape.dot:
          canvas.drawCircle(Offset.zero, 0.32, _fill);
        case _Shape.triangle:
          canvas.drawPath(_triangle, _fill);
        case _Shape.spark:
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.plan != plan ||
      oldDelegate.clock != clock ||
      oldDelegate.span != span;
}
