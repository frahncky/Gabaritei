import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../shared/drawings/circuit_symbols.dart';
import '../../shared/format.dart';
import 'circuit.dart';

/// Escala do amperímetro e do gráfico: o limite fica em 62,5% do fundo.
const labScaleOverLimit = 1.6;

/// Estado animado: posição dos elétrons em cada trecho, ponteiro do
/// amperímetro (com inércia) e histórico para o gráfico.
class LabMotion extends ChangeNotifier {
  static const historyLength = 120; // 6 s, uma amostra a cada 50 ms
  static const sampleSeconds = 0.05;
  static const pixelsPerAmp = 70.0;

  final phases = List<double>.filled(4, 0);
  double needle = 0;
  final history = <double>[];
  double _sampleClock = 0;

  void advance(double dt, List<double> currents, double target) {
    for (var i = 0; i < phases.length; i++) {
      phases[i] += math.min(currents[i] * pixelsPerAmp, 320) * dt;
    }
    // Aproxima o ponteiro do valor certo, como um instrumento de verdade.
    needle += (target - needle) * (1 - math.exp(-dt * 5));
    _sampleClock += dt;
    while (_sampleClock >= sampleSeconds) {
      _sampleClock -= sampleSeconds;
      history.add(needle);
      if (history.length > historyLength) history.removeAt(0);
    }
    notifyListeners();
  }

  void snap(double target) {
    needle = target;
    history
      ..clear()
      ..addAll(List.filled(historyLength, target));
    notifyListeners();
  }

  void resetHistory() {
    history.clear();
    notifyListeners();
  }
}

/// Desenha o circuito do modo atual e os elétrons andando pelos fios
/// (no sentido convencional da corrente: do + para o −), com os símbolos da
/// IEC 60617. Repinta a cada quadro pelo [LabMotion].
class CircuitPainter extends CustomPainter {
  CircuitPainter({
    required this.mode,
    required this.input,
    required this.reading,
    required this.motion,
  }) : super(repaint: motion);

  final LabMode mode;
  final CircuitInput input;
  final CircuitReading reading;
  final LabMotion motion;

  /// Meia distância entre as pontas do fio na fonte.
  static const _gap = 11.0;

  /// Fundo da tela, que o corpo dos componentes usa para cobrir o fio.
  static const _background = AppColors.ground;

  /// Trechos de fio e as medidas deles, refeitos só quando o tamanho muda
  /// (o modo não muda num mesmo painter: trocar de modo cria outro).
  Size? _wiresSize;
  late List<(Path, PathMetric)> _wires;

  List<(Path, PathMetric)> _wiresFor(Size size) {
    if (size == _wiresSize) return _wires;
    const l = 34.0, t = 26.0;
    final r = size.width - 30;
    final b = size.height - 26;
    final my = (t + b) / 2;
    final x1 = r - 78;

    Path line(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      return path;
    }

    // Trechos de fio; no paralelo, cada um tem a sua corrente.
    final paths = mode == LabMode.paralelo
        ? [
            line([Offset(l, my - _gap), const Offset(l, t), Offset(x1, t)]),
            line([Offset(x1, t), Offset(x1, b)]),
            line([Offset(x1, t), Offset(r, t), Offset(r, b), Offset(x1, b)]),
            line([Offset(x1, b), Offset(l, b), Offset(l, my + _gap)]),
          ]
        : [
            line([
              Offset(l, my - _gap),
              const Offset(l, t),
              Offset(r, t),
              Offset(r, b),
              Offset(l, b),
              Offset(l, my + _gap),
            ]),
          ];
    _wiresSize = size;
    return _wires = [for (final p in paths) (p, p.computeMetrics().first)];
  }

  @override
  void paint(Canvas canvas, Size size) {
    const l = 34.0, t = 26.0;
    final r = size.width - 30;
    final b = size.height - 26;
    final my = (t + b) / 2;
    final cx = (l + r) / 2;
    final x1 = r - 78;

    final wires = _wiresFor(size);
    final wire = CircuitSymbols.wire(
        color: CircuitColors.wire.withValues(alpha: .55), width: 3);
    for (final (path, _) in wires) {
      canvas.drawPath(path, wire);
    }

    // Lâmpada: o brilho vem antes, para ficar atrás dos fios e elétrons.
    // Âmbar = acesa; vermelho = acima da potência nominal.
    final glow = (reading.power / LabLimits.lampWatts).clamp(0.0, 1.4);
    if (mode == LabMode.potencia && glow > 0.01) {
      final burning = reading.status == LabStatus.over;
      final color = burning ? AppColors.error : CircuitColors.current;
      final halo =
          Rect.fromCircle(center: Offset(cx, t), radius: 18 + 46 * glow);
      canvas.drawCircle(
        halo.center,
        halo.width / 2,
        Paint()
          ..shader = RadialGradient(colors: [
            color.withValues(alpha: 0.45 * math.min(glow, 1)),
            color.withValues(alpha: 0),
          ]).createShader(halo),
      );
    }

    // Elétrons.
    if (reading.total > 0.0005) {
      for (var i = 0; i < wires.length; i++) {
        CircuitSymbols.current(canvas, wires[i].$2,
            shift: motion.phases[i], spacing: 17);
      }
    }

    _battery(canvas, Offset(l, my));

    switch (mode) {
      case LabMode.ohm:
        _resistor(canvas, Offset(cx, t),
            horizontal: true, label: 'R = ${_ohms(input.r1)}');
      case LabMode.potencia:
        _lamp(canvas, Offset(cx, t), glow);
      case LabMode.serie:
        _resistor(canvas, Offset(cx, t),
            horizontal: true,
            label: 'R₁ = ${_ohms(input.r1)}',
            detail: '${formatDecimal(reading.v1, 1)} V');
        _resistor(canvas, Offset(r, my),
            horizontal: false,
            label: 'R₂',
            detail: _ohms(input.r2),
            labelLeft: true);
        _text(canvas, '${formatDecimal(reading.v2, 1)} V',
            Offset(r - 30, my + 26),
            color: CircuitColors.value, size: 11);
      case LabMode.cores:
        break;
      case LabMode.paralelo:
        for (final node in [Offset(x1, t), Offset(x1, b)]) {
          CircuitSymbols.node(canvas, node, radius: 4.5);
        }
        _resistor(canvas, Offset(x1, my),
            horizontal: false,
            label: 'R₁',
            detail: _ohms(input.r1),
            labelLeft: true);
        _resistor(canvas, Offset(r, my),
            horizontal: false,
            label: 'R₂',
            detail: _ohms(input.r2),
            labelLeft: true);
        _text(canvas, '${formatDecimal(reading.i1, 2)} A',
            Offset(x1 - 34, my + 32),
            color: CircuitColors.value, size: 11);
        _text(canvas, '${formatDecimal(reading.i2, 2)} A',
            Offset(r - 34, my + 32),
            color: CircuitColors.value, size: 11);
    }

    _text(canvas, 'sentido da corrente →', Offset(cx, b + 14),
        color: AppColors.muted, size: 10, italic: true);
  }

  static String _ohms(double o) => '${formatDecimal(o, 0)} Ω';

  void _battery(Canvas canvas, Offset c) {
    CircuitSymbols.cell(canvas, c, gap: 2 * (_gap - 4));
    _text(canvas, '+', c + const Offset(-22, -_gap),
        color: CircuitColors.component, size: 12);
    _text(canvas, '${formatDecimal(input.volts, 1)} V', c + const Offset(36, 0),
        color: CircuitColors.component, size: 13, bold: true);
  }

  void _resistor(
    Canvas canvas,
    Offset c, {
    required bool horizontal,
    required String label,
    String? detail,
    bool labelLeft = false,
  }) {
    CircuitSymbols.resistor(canvas, c,
        horizontal: horizontal,
        background: _background,
        length: 50,
        thickness: 18,
        strokeWidth: 2.4);

    if (horizontal) {
      _text(canvas, label, c + const Offset(0, 22),
          color: CircuitColors.component, size: 12);
      if (detail != null) {
        _text(canvas, detail, c + const Offset(0, 37),
            color: CircuitColors.value, size: 11);
      }
    } else {
      final dx = labelLeft ? -34.0 : 34.0;
      _text(canvas, label, c + Offset(dx, -8),
          color: CircuitColors.component, size: 12);
      if (detail != null) {
        _text(canvas, detail, c + Offset(dx, 8),
            color: AppColors.muted, size: 11);
      }
    }
  }

  void _lamp(Canvas canvas, Offset c, double glow) {
    CircuitSymbols.lamp(canvas, c, 15, background: _background, glow: glow);
    _text(canvas, 'lâmpada ${formatDecimal(LabLimits.lampWatts, 0)} W',
        c + const Offset(0, 30),
        color: CircuitColors.component, size: 12);
    _text(canvas, _ohms(input.r1), c + const Offset(0, 45),
        color: AppColors.muted, size: 11);
  }

  static void _text(
    Canvas canvas,
    String text,
    Offset center, {
    required Color color,
    double size = 12,
    bool bold = false,
    bool italic = false,
  }) =>
      paintText(
        canvas,
        drawingText(text,
            size: size,
            color: color,
            weight: bold ? FontWeight.w700 : FontWeight.w500,
            italic: italic),
        center,
      );

  @override
  bool shouldRepaint(CircuitPainter oldDelegate) =>
      oldDelegate.mode != mode ||
      oldDelegate.input != input ||
      oldDelegate.motion != motion;
}

/// Amperímetro (ou wattímetro) analógico. O mostrador claro e o ponteiro
/// vermelho imitam o instrumento de bancada.
class GaugePainter extends CustomPainter {
  GaugePainter(this.motion, {required this.unit}) : super(repaint: motion);

  final LabMotion motion;
  final String unit;

  static const _start = math.pi * 0.75;
  static const _sweep = math.pi * 1.5;
  static const _needle = Color(0xFFD03A3A);
  static const _scaleInk = Color(0xFF4A5568);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(c, radius, Paint()..color = AppColors.text);
    canvas.drawCircle(
      c,
      radius - 1,
      Paint()
        ..color = AppColors.line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Faixa vermelha acima do limite.
    const limitFraction = 1 / labScaleOverLimit;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius - 10),
      _start + _sweep * limitFraction,
      _sweep * (1 - limitFraction),
      false,
      Paint()
        ..color = AppColors.error.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    final tick = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i <= 8; i++) {
      final a = _start + _sweep * i / 8;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * (radius - 18), c + dir * (radius - 24), tick);
    }

    final label =
        drawingText(unit, size: 14, weight: FontWeight.w700, color: _scaleInk);
    label.paint(canvas, c + Offset(-label.width / 2, radius * 0.38));

    final a = _start + _sweep * motion.needle.clamp(0.0, 1.03);
    final tip = c + Offset(math.cos(a), math.sin(a)) * (radius - 16);
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = _needle
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 6, Paint()..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(GaugePainter oldDelegate) =>
      oldDelegate.motion != motion || oldDelegate.unit != unit;
}

/// Geometria do gráfico da grandeza vigiada no tempo: área dos dados,
/// marcas dos eixos e conversão de valor para pixel. Separada do painter
/// para ser testada.
class HistoryChartScale {
  HistoryChartScale(this.size, {required this.limit});

  final Size size;

  /// Limite de segurança (3 A ou 15 W): o eixo vai até `limit × 1,6`.
  final double limit;

  /// Janela de tempo mostrada, em segundos.
  static const seconds =
      LabMotion.historyLength * LabMotion.sampleSeconds; // 6 s

  // Margens: valores do eixo y à esquerda, "t (s)" à direita, título do
  // eixo y em cima e marcas de tempo embaixo.
  static const _left = 30.0, _right = 34.0, _top = 24.0, _bottom = 18.0;

  Rect get plot =>
      Rect.fromLTRB(_left, _top, size.width - _right, size.height - _bottom);

  double get max => limit * labScaleOverLimit;

  /// Altura de uma fração da escala (0 = zero, 1 = [max]); um pouco acima do
  /// fundo é desenhado, para o pico não sumir.
  double yForFraction(double f) =>
      plot.bottom - plot.height * f.clamp(0.0, 1.05);

  double yForValue(double v) => yForFraction(v / max);

  /// Posição de um instante, em segundos antes de agora (0 = agora).
  double xForSecondsAgo(double s) =>
      plot.right - plot.width * (s / seconds).clamp(0.0, 1.0);

  /// Valores marcados no eixo y: zero, o limite e o fundo de escala.
  List<double> get yTicks => [0, limit, max];

  /// Instantes marcados no eixo x, em segundos antes de agora.
  static const xTicks = [6, 4, 2, 0];
}

/// Gráfico da grandeza vigiada (corrente ou potência) nos últimos 6 s, com a
/// linha tracejada do limite. A linha é âmbar como os elétrons e fica
/// vermelha acima do limite.
class HistoryChartPainter extends CustomPainter {
  HistoryChartPainter(
    this.motion, {
    required this.quantity,
    required this.unit,
    required this.limit,
    required this.limitLabel,
  }) : super(repaint: motion);

  final LabMotion motion;

  /// Símbolo e unidade da grandeza ("I" e "A", ou "P" e "W").
  final String quantity;
  final String unit;
  final double limit;
  final String limitLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = HistoryChartScale(size, limit: limit);
    final plot = scale.plot;

    final axis = Paint()
      ..color = AppColors.muted.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    canvas
      ..drawLine(plot.topLeft, plot.bottomLeft, axis)
      ..drawLine(plot.bottomLeft, plot.bottomRight, axis);

    TextPainter small(String text, {Color color = AppColors.muted}) =>
        drawingText(text, size: 10, weight: FontWeight.w500, color: color);

    // Eixo y: grandeza e unidade em cima; zero, limite e fundo de escala.
    paintText(canvas, small('$quantity ($unit)'), Offset(plot.left, 0),
        Alignment.topCenter);
    for (final v in scale.yTicks) {
      final y = scale.yForValue(v);
      canvas.drawLine(Offset(plot.left - 3, y), Offset(plot.left, y), axis);
      paintText(canvas, small(formatDecimal(v, v == v.roundToDouble() ? 0 : 1)),
          Offset(plot.left - 5, y), Alignment.centerRight);
    }

    // Eixo x: segundos antes de agora, e "t (s)" na ponta do eixo.
    for (final s in HistoryChartScale.xTicks) {
      final x = scale.xForSecondsAgo(s.toDouble());
      canvas.drawLine(Offset(x, plot.bottom), Offset(x, plot.bottom + 3), axis);
      paintText(canvas, small(s == 0 ? '0' : '−$s'), Offset(x, plot.bottom + 4),
          Alignment.topCenter);
    }
    paintText(canvas, small('t (s)'), Offset(plot.right + 8, plot.bottom),
        Alignment.centerLeft);

    // Limite: tracejado, na cor do aviso do medidor.
    final limitY = scale.yForValue(limit);
    final dash = Paint()
      ..color = AppColors.error
      ..strokeWidth = 1.4;
    for (var x = plot.left; x < plot.right; x += 9) {
      canvas.drawLine(
          Offset(x, limitY), Offset(math.min(x + 5, plot.right), limitY), dash);
    }
    paintText(canvas, small(limitLabel, color: AppColors.error),
        Offset(plot.right, limitY - 2), Alignment.bottomRight);

    final data = motion.history;
    if (data.length < 2) return;
    final step = plot.width / (LabMotion.historyLength - 1);
    final startX = plot.right - step * (data.length - 1);
    final path = Path()..moveTo(startX, scale.yForFraction(data.first));
    for (var i = 1; i < data.length; i++) {
      path.lineTo(startX + step * i, scale.yForFraction(data[i]));
    }
    final over = data.last > 1 / labScaleOverLimit;
    final color = over ? AppColors.error : CircuitColors.current;
    canvas
      ..drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeJoin = StrokeJoin.round,
      )
      ..drawCircle(Offset(plot.right, scale.yForFraction(data.last)), 4.5,
          Paint()..color = color);
  }

  @override
  bool shouldRepaint(HistoryChartPainter oldDelegate) =>
      oldDelegate.motion != motion ||
      oldDelegate.quantity != quantity ||
      oldDelegate.unit != unit ||
      oldDelegate.limit != limit ||
      oldDelegate.limitLabel != limitLabel;
}
