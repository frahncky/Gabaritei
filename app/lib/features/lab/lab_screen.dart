import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../shared/format.dart';
import 'circuit.dart';

/// Laboratório de eletricidade: um circuito "vivo", com elétrons andando,
/// amperímetro, controles e gráfico no tempo.
class LabScreen extends StatefulWidget {
  const LabScreen({super.key, this.initialMode = LabMode.ohm});

  final LabMode initialMode;

  @override
  State<LabScreen> createState() => _LabScreenState();
}

/// Escala do amperímetro e do gráfico: o limite fica em 62,5% do fundo.
const _scaleOverLimit = 1.6;

class _LabScreenState extends State<LabScreen>
    with SingleTickerProviderStateMixin {
  late LabMode _mode = widget.initialMode;
  CircuitInput _input = const CircuitInput();
  final _motion = _LabMotion();
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  CircuitReading get _reading => CircuitReading.solve(_mode, _input);

  double get _gaugeTarget =>
      (_reading.watched / (_mode.limit * _scaleOverLimit)).clamp(0.0, 1.05);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _ticker?.dispose();
      _ticker = null;
      _motion.snap(_gaugeTarget);
    } else {
      _ticker ??= _startTicker();
    }
  }

  Ticker _startTicker() => createTicker(_onTick)..start();

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    final r = _reading;
    final currents = _mode == LabMode.paralelo
        ? [r.total, r.i1, r.i2, r.total]
        : [r.total, r.total, r.total, r.total];
    _motion.advance(dt.clamp(0, 0.1), currents, _gaugeTarget);
  }

  void _update(CircuitInput input) {
    setState(() => _input = input);
    if (_ticker == null) _motion.snap(_gaugeTarget);
  }

  void _setMode(LabMode mode) {
    if (mode == _mode) return;
    HapticFeedback.selectionClick();
    setState(() => _mode = mode);
    _motion.resetHistory();
    if (_ticker == null) _motion.snap(_gaugeTarget);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = _reading;
    final mode = _mode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text(
            'LABORATÓRIO',
            style: TextStyle(
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedOnInk,
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Painel fixo: o circuito e o medidor ficam sempre à vista
                // enquanto o aluno mexe nos controles lá embaixo.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    children: [
                      _FormulaBox(formula: mode.formula),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 190,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _CircuitPainter(
                            mode: mode,
                            input: _input,
                            reading: reading,
                            motion: _motion,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _Readout(reading: reading, motion: _motion),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.inkLine),
                Expanded(child: _panel(mode, reading)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel(LabMode mode, CircuitReading reading) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _ModeTabs(selected: mode, onSelect: _setMode),
        const SizedBox(height: 18),
        Text(
          '${mode.index + 1} · ${mode.title.toUpperCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.amberOnInk,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          mode.idea,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          mode.tip,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.mutedOnInk,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 18),
        ..._controls(mode),
        const SizedBox(height: 10),
        for (final row in _outputs(mode, reading)) ...[
          row,
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        _HistoryChart(mode: mode, motion: _motion),
      ],
    );
  }

  List<Widget> _controls(LabMode mode) {
    final volts = _LabSlider(
      label: 'Tensão da fonte',
      value: _input.volts,
      min: 0,
      max: LabLimits.maxVolts,
      divisions: 48,
      unit: 'V',
      digits: 1,
      onChanged: (v) => _update(_input.copyWith(volts: v)),
    );
    _LabSlider ohms(String label, double value, ValueChanged<double> set) =>
        _LabSlider(
          label: label,
          value: value,
          min: LabLimits.minOhms,
          max: LabLimits.maxOhms,
          divisions: 19,
          unit: 'Ω',
          digits: 0,
          onChanged: set,
        );

    return switch (mode) {
      LabMode.ohm => [
          volts,
          ohms(
              'Resistência', _input.r1, (v) => _update(_input.copyWith(r1: v))),
        ],
      LabMode.potencia => [
          volts,
          ohms('Resistência da lâmpada', _input.r1,
              (v) => _update(_input.copyWith(r1: v))),
        ],
      LabMode.serie || LabMode.paralelo => [
          volts,
          ohms('R₁', _input.r1, (v) => _update(_input.copyWith(r1: v))),
          ohms('R₂', _input.r2, (v) => _update(_input.copyWith(r2: v))),
        ],
    };
  }

  List<Widget> _outputs(LabMode mode, CircuitReading r) {
    const ampScale = LabLimits.fuseAmps * _scaleOverLimit;
    String amps(double a) => '${formatDecimal(a, 2)} A';
    String volts(double v) => '${formatDecimal(v, 1)} V';
    String ohms(double o) => '${formatDecimal(o, o < 10 ? 1 : 0)} Ω';

    return switch (mode) {
      LabMode.ohm => [
          _OutputBar('Corrente', r.total / ampScale, amps(r.total),
              AppColors.amberOnInk),
          _OutputBar('Potência no resistor', r.power / 60,
              '${formatDecimal(r.power, 1)} W', Colors.white),
        ],
      LabMode.serie => [
          _OutputBar('Tensão em R₁', _ratio(r.v1, _input.volts), volts(r.v1),
              AppColors.skyOnInk),
          _OutputBar('Tensão em R₂', _ratio(r.v2, _input.volts), volts(r.v2),
              AppColors.skyOnInk),
          _OutputBar('Resistência equivalente', r.req / 200, ohms(r.req),
              Colors.white),
          _OutputBar('Corrente', r.total / ampScale, amps(r.total),
              AppColors.amberOnInk),
        ],
      LabMode.paralelo => [
          _OutputBar('Corrente em R₁', r.i1 / ampScale, amps(r.i1),
              AppColors.skyOnInk),
          _OutputBar('Corrente em R₂', r.i2 / ampScale, amps(r.i2),
              AppColors.skyOnInk),
          _OutputBar('Resistência equivalente', r.req / 100, ohms(r.req),
              Colors.white),
          _OutputBar('Corrente total', r.total / ampScale, amps(r.total),
              AppColors.amberOnInk),
        ],
      LabMode.potencia => [
          _OutputBar(
              'Corrente', r.total / ampScale, amps(r.total), Colors.white),
          _OutputBar(
              'Potência',
              r.power / (LabLimits.lampWatts * _scaleOverLimit),
              '${formatDecimal(r.power, 1)} W',
              AppColors.amberOnInk),
          _OutputBar(
              'Brilho',
              r.power / LabLimits.lampWatts,
              formatPercent(math.min(r.power / LabLimits.lampWatts, 1)),
              AppColors.skyOnInk),
        ],
    };
  }

  static double _ratio(double a, double b) => b == 0 ? 0 : a / b;
}

/// Estado animado: posição dos elétrons em cada trecho, ponteiro do
/// amperímetro (com inércia) e histórico para o gráfico.
class _LabMotion extends ChangeNotifier {
  static const historyLength = 120; // 6 s, uma amostra a cada 50 ms
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
    while (_sampleClock >= 0.05) {
      _sampleClock -= 0.05;
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

class _FormulaBox extends StatelessWidget {
  const _FormulaBox({required this.formula});

  final String formula;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.skyOnInk, width: 1.5),
        color: AppColors.skyOnInk.withValues(alpha: 0.06),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Text(
          formula,
          key: ValueKey(formula),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.skyOnInk,
          ),
        ),
      ),
    );
  }
}

/// Desenha o circuito do modo atual e os elétrons andando pelos fios
/// (no sentido convencional da corrente: do + para o −).
class _CircuitPainter extends CustomPainter {
  _CircuitPainter({
    required this.mode,
    required this.input,
    required this.reading,
    required this.motion,
  }) : super(repaint: motion);

  final LabMode mode;
  final CircuitInput input;
  final CircuitReading reading;
  final _LabMotion motion;

  static const _gap = 11.0;

  @override
  void paint(Canvas canvas, Size size) {
    const l = 34.0, t = 26.0;
    final r = size.width - 30;
    final b = size.height - 26;
    final my = (t + b) / 2;
    final cx = (l + r) / 2;
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

    final wire = Paint()
      ..color = AppColors.mutedOnInk.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final p in paths) {
      canvas.drawPath(p, wire);
    }

    // Lâmpada: o brilho vem antes, para ficar atrás dos fios e elétrons.
    final glow = (reading.power / LabLimits.lampWatts).clamp(0.0, 1.4);
    if (mode == LabMode.potencia && glow > 0.01) {
      final burning = reading.status == LabStatus.over;
      final color = burning ? AppColors.errorOnInk : AppColors.amberOnInk;
      canvas.drawCircle(
        Offset(cx, t),
        18 + 46 * glow,
        Paint()
          ..shader = RadialGradient(colors: [
            color.withValues(alpha: 0.55 * math.min(glow, 1)),
            color.withValues(alpha: 0),
          ]).createShader(
              Rect.fromCircle(center: Offset(cx, t), radius: 18 + 46 * glow)),
      );
    }

    // Elétrons.
    if (reading.total > 0.0005) {
      final dot = Paint()..color = AppColors.amberOnInk;
      for (var i = 0; i < paths.length; i++) {
        final metric = paths[i].computeMetrics().first;
        const spacing = 17.0;
        final offset = motion.phases[i] % spacing;
        for (var d = offset; d < metric.length; d += spacing) {
          final pos = metric.getTangentForOffset(d)!.position;
          canvas.drawCircle(pos, 2.6, dot);
        }
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
            color: AppColors.skyOnInk, size: 11);
      case LabMode.paralelo:
        for (final node in [Offset(x1, t), Offset(x1, b)]) {
          canvas.drawCircle(node, 4.5, Paint()..color = Colors.white);
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
            color: AppColors.skyOnInk, size: 11);
        _text(canvas, '${formatDecimal(reading.i2, 2)} A',
            Offset(r - 34, my + 32),
            color: AppColors.skyOnInk, size: 11);
    }

    _text(canvas, 'sentido da corrente →', Offset(cx, b + 14),
        color: AppColors.mutedOnInk.withValues(alpha: 0.7),
        size: 10,
        italic: true);
  }

  static String _ohms(double o) => '${formatDecimal(o, 0)} Ω';

  void _battery(Canvas canvas, Offset c) {
    final long = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final short = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c + const Offset(-13, -_gap + 4),
        c + const Offset(13, -_gap + 4), long);
    canvas.drawLine(
        c + const Offset(-7, _gap - 4), c + const Offset(7, _gap - 4), short);
    _text(canvas, '+', c + const Offset(-22, -_gap),
        color: Colors.white, size: 12);
    _text(canvas, '${formatDecimal(input.volts, 1)} V', c + const Offset(36, 0),
        color: AppColors.amberOnInk, size: 13, bold: true);
  }

  void _resistor(
    Canvas canvas,
    Offset c, {
    required bool horizontal,
    required String label,
    String? detail,
    bool labelLeft = false,
  }) {
    const len = 52.0, amp = 7.0, peaks = 6;
    final body = horizontal
        ? Rect.fromCenter(center: c, width: len + 6, height: 20)
        : Rect.fromCenter(center: c, width: 20, height: len + 6);
    canvas.drawRect(body, Paint()..color = AppColors.ink);

    final path = Path();
    for (var i = 0; i <= peaks * 2; i++) {
      final along = -len / 2 + len * i / (peaks * 2);
      final across = i == 0 || i == peaks * 2 ? 0.0 : (i.isOdd ? amp : -amp);
      final p =
          horizontal ? c + Offset(along, across) : c + Offset(across, along);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeJoin = StrokeJoin.round,
    );

    if (horizontal) {
      _text(canvas, label, c + const Offset(0, 22),
          color: Colors.white, size: 12);
      if (detail != null) {
        _text(canvas, detail, c + const Offset(0, 37),
            color: AppColors.skyOnInk, size: 11);
      }
    } else {
      final dx = labelLeft ? -34.0 : 34.0;
      _text(canvas, label, c + Offset(dx, -8), color: Colors.white, size: 12);
      if (detail != null) {
        _text(canvas, detail, c + Offset(dx, 8),
            color: AppColors.mutedOnInk, size: 11);
      }
    }
  }

  void _lamp(Canvas canvas, Offset c, double glow) {
    canvas.drawCircle(c, 15, Paint()..color = AppColors.ink);
    final filament = Color.lerp(
        AppColors.mutedOnInk, AppColors.amberOnInk, math.min(glow, 1))!;
    canvas.drawCircle(
      c,
      15,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
    final cross = Paint()
      ..color = filament
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        c + const Offset(-10, -10), c + const Offset(10, 10), cross);
    canvas.drawLine(
        c + const Offset(-10, 10), c + const Offset(10, -10), cross);
    _text(canvas, 'lâmpada ${formatDecimal(LabLimits.lampWatts, 0)} W',
        c + const Offset(0, 30),
        color: Colors.white, size: 12);
    _text(canvas, _ohms(input.r1), c + const Offset(0, 45),
        color: AppColors.mutedOnInk, size: 11);
  }

  static void _text(
    Canvas canvas,
    String text,
    Offset center, {
    required Color color,
    double size = 12,
    bool bold = false,
    bool italic = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
        canvas, center - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(_CircuitPainter oldDelegate) =>
      oldDelegate.mode != mode ||
      oldDelegate.input != input ||
      oldDelegate.motion != motion;
}

/// Amperímetro (ou wattímetro) com ponteiro, e a leitura ao lado.
class _Readout extends StatelessWidget {
  const _Readout({required this.reading, required this.motion});

  final CircuitReading reading;
  final _LabMotion motion;

  @override
  Widget build(BuildContext context) {
    final mode = reading.mode;
    final value = mode.watchesPower
        ? '${formatDecimal(reading.power, 1)} W'
        : '${formatDecimal(reading.total, 2)} A';
    final limit = mode.watchesPower
        ? 'nominal: ${formatDecimal(LabLimits.lampWatts, 0)} W'
        : 'fusível: ${formatDecimal(LabLimits.fuseAmps, 0)} A';
    final (statusText, statusColor) = switch (reading.status) {
      LabStatus.off => ('sem tensão', AppColors.mutedOnInk),
      LabStatus.safe => ('seguro', AppColors.successOnInk),
      LabStatus.near => ('perto do limite', AppColors.amberOnInk),
      LabStatus.over => (
          mode.watchesPower ? 'a lâmpada queimaria!' : 'o fusível queimaria!',
          AppColors.errorOnInk
        ),
    };

    return Row(
      children: [
        Semantics(
          label: '${mode.watchesPower ? 'Wattímetro' : 'Amperímetro'}: $value',
          excludeSemantics: true,
          child: CustomPaint(
            size: const Size.square(104),
            painter: _GaugePainter(motion, unit: mode.watchesPower ? 'W' : 'A'),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  fontSize: 34,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                limit,
                style: const TextStyle(
                  color: AppColors.amberOnInk,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: statusColor,
                ),
                child: Text(statusText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.motion, {required this.unit}) : super(repaint: motion);

  final _LabMotion motion;
  final String unit;

  static const _start = math.pi * 0.75;
  static const _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    canvas.drawCircle(c, radius, Paint()..color = const Color(0xFFF4F6FA));
    const needleRed = Color(0xFFDC2626);
    canvas.drawCircle(
      c,
      radius - 1,
      Paint()
        ..color = AppColors.inkLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Faixa vermelha acima do limite.
    const limitFraction = 1 / _scaleOverLimit;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: radius - 10),
      _start + _sweep * limitFraction,
      _sweep * (1 - limitFraction),
      false,
      Paint()
        ..color = AppColors.error.withValues(alpha: 0.75)
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

    final painter = TextPainter(
      text: TextSpan(
        text: unit,
        style: const TextStyle(
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          color: Color(0xFF556070),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, c + Offset(-painter.width / 2, radius * 0.38));

    final a = _start + _sweep * motion.needle.clamp(0.0, 1.03);
    final tip = c + Offset(math.cos(a), math.sin(a)) * (radius - 16);
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = needleRed
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 6, Paint()..color = AppColors.ink);
  }

  @override
  bool shouldRepaint(_GaugePainter oldDelegate) =>
      oldDelegate.motion != motion || oldDelegate.unit != unit;
}

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.selected, required this.onSelect});

  final LabMode selected;
  final ValueChanged<LabMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final mode in LabMode.values) ...[
          if (mode.index > 0) const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              selected: mode == selected,
              button: true,
              child: GestureDetector(
                onTap: () => onSelect(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: mode == selected
                        ? AppColors.amber
                        : AppColors.inkRaised,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: mode == selected
                          ? AppColors.amber
                          : AppColors.inkLine,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '${mode.index + 1} · ${mode.tab}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color:
                              mode == selected ? AppColors.ink : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _LabSlider extends StatelessWidget {
  const _LabSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.digits,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final int digits;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = '${formatDecimal(value, digits)} $unit';
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.mutedOnInk, fontSize: 14)),
            ),
            Text(
              text,
              style: const TextStyle(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.amber,
            inactiveTrackColor: AppColors.inkLine,
            thumbColor: AppColors.amberOnInk,
            overlayColor: AppColors.amber.withValues(alpha: 0.15),
            trackHeight: 5,
            tickMarkShape: SliderTickMarkShape.noTickMark,
            showValueIndicator: ShowValueIndicator.never,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            semanticFormatterCallback: (_) => text,
            onChanged: (v) {
              if (v != value) HapticFeedback.selectionClick();
              onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

/// Linha de resultado: nome, barra proporcional e valor.
class _OutputBar extends StatelessWidget {
  const _OutputBar(this.label, this.fraction, this.value, this.color);

  final String label;
  final double fraction;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: TextStyle(
              color: color == Colors.white ? Colors.white : color,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Container(
          width: 72,
          height: 14,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.inkLine),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fraction.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              builder: (context, f, _) => FractionallySizedBox(
                widthFactor: f,
                heightFactor: 1,
                child: ColoredBox(color: color),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// Gráfico da grandeza vigiada nos últimos 6 segundos.
class _HistoryChart extends StatelessWidget {
  const _HistoryChart({required this.mode, required this.motion});

  final LabMode mode;
  final _LabMotion motion;

  @override
  Widget build(BuildContext context) {
    final what = mode.watchesPower ? 'potência' : 'corrente';
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.inkRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inkLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$what – tempo',
            style: const TextStyle(
              color: AppColors.mutedOnInk,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 6),
          ExcludeSemantics(
            child: SizedBox(
              height: 96,
              width: double.infinity,
              child: CustomPaint(
                painter: _ChartPainter(
                  motion,
                  limitLabel: mode.watchesPower
                      ? 'nominal ${formatDecimal(LabLimits.lampWatts, 0)} W'
                      : 'fusível ${formatDecimal(LabLimits.fuseAmps, 0)} A',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter(this.motion, {required this.limitLabel})
      : super(repaint: motion);

  final _LabMotion motion;
  final String limitLabel;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 8.0;
    final bottom = size.height - 6;
    const top = 4.0;
    double yFor(double v) => bottom - (bottom - top) * v.clamp(0.0, 1.05);

    final axis = Paint()
      ..color = AppColors.mutedOnInk.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(left, top), Offset(left, bottom), axis);
    canvas.drawLine(Offset(left, bottom), Offset(size.width, bottom), axis);

    final limitY = yFor(1 / _scaleOverLimit);
    canvas.drawLine(
      Offset(left, limitY),
      Offset(size.width, limitY),
      Paint()
        ..color = AppColors.amber
        ..strokeWidth = 1.4,
    );
    final label = TextPainter(
      text: TextSpan(
        text: limitLabel,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          color: AppColors.amberOnInk,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(
        canvas, Offset(size.width - label.width, limitY - label.height - 2));

    final data = motion.history;
    if (data.length < 2) return;
    final step = (size.width - left) / (_LabMotion.historyLength - 1);
    final startX = size.width - step * (data.length - 1);
    final path = Path()..moveTo(startX, yFor(data.first));
    for (var i = 1; i < data.length; i++) {
      path.lineTo(startX + step * i, yFor(data[i]));
    }
    final over = data.last > 1 / _scaleOverLimit;
    final color = over ? AppColors.errorOnInk : const Color(0xFFFB7A5A);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(
        Offset(size.width, yFor(data.last)), 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) =>
      oldDelegate.motion != motion || oldDelegate.limitLabel != limitLabel;
}
