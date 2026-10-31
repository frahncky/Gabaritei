import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme.dart';
import '../../shared/drawings/circuit_symbols.dart';
import 'lab_screen.dart' show labSliderTheme;

/// Laboratório de automação: uma malha fechada simples de nível.
class ProcessLabScreen extends StatefulWidget {
  const ProcessLabScreen({super.key});

  @override
  State<ProcessLabScreen> createState() => _ProcessLabScreenState();
}

class _ProcessLabScreenState extends State<ProcessLabScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick)..start();
  Duration _last = Duration.zero;
  double _level = .28;
  double _setpoint = .65;
  double _manualValve = .35;
  bool _automatic = true;

  double get _valve => _automatic
      ? (_manualValve + (_setpoint - _level) * .9).clamp(0.0, 1.0)
      : _manualValve;

  void _tick(Duration elapsed) {
    final dt =
        ((elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond)
            .clamp(0.0, .08);
    _last = elapsed;
    final next =
        (_level + ((_valve * .76) - (_level * .48)) * dt).clamp(0.0, 1.0);
    if ((next - _level).abs() > .0001 && mounted) {
      setState(() => _level = next);
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _setpoint - _level;
    String percent(double v) => '${(v * 100).round()}%';
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratório de processo')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const Text(
              'Malha de nível',
              style: TextStyle(
                color: AppColors.skyOnInk,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Sensor → CLP → válvula → tanque',
              style: TextStyle(
                color: AppColors.text,
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ajuste a referência e veja o controlador compensar a saída.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            Semantics(
              label: 'Malha de controle de nível: o transmissor de nível LT '
                  'mede ${percent(_level)} no tanque e manda o sinal de 4 a '
                  '20 mA ao CLP, em modo '
                  '${_automatic ? 'automático' : 'manual'}; o CLP abre a '
                  'válvula de entrada em ${percent(_valve)}. A referência '
                  'está em ${percent(_setpoint)}.',
              excludeSemantics: true,
              child: SizedBox(
                height: 250,
                // Muda a cada quadro do ticker: isolado do resto da página.
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: ProcessPainter(
                      level: _level,
                      setpoint: _setpoint,
                      valve: _valve,
                      automatic: _automatic,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ValueRow('Nível medido', percent(_level), AppColors.skyOnInk),
            _ValueRow('Referência', percent(_setpoint), AppColors.text),
            _ValueRow('Abertura da válvula', percent(_valve), AppColors.text),
            const SizedBox(height: 18),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _automatic,
              title: const Text('Controle automático',
                  style: TextStyle(
                      color: AppColors.text, fontWeight: FontWeight.w600)),
              subtitle: Text(
                _automatic
                    ? 'O CLP ajusta a válvula pelo erro de nível.'
                    : 'Você controla diretamente a abertura da válvula.',
                style: const TextStyle(color: AppColors.muted),
              ),
              onChanged: (value) => setState(() => _automatic = value),
            ),
            const SizedBox(height: 10),
            _ControlSlider(
              label: 'Referência do nível',
              value: _setpoint,
              onChanged: (value) => setState(() => _setpoint = value),
            ),
            if (!_automatic) ...[
              const SizedBox(height: 12),
              _ControlSlider(
                label: 'Abertura manual da válvula',
                value: _manualValve,
                onChanged: (value) => setState(() => _manualValve = value),
              ),
            ],
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.medium),
              ),
              child: Text(
                error.abs() < .04
                    ? 'Processo estabilizado: o nível está próximo da referência.'
                    : error > 0
                        ? 'O nível está abaixo da referência; o CLP abre mais a válvula.'
                        : 'O nível está acima da referência; o CLP reduz a abertura.',
                style: const TextStyle(color: AppColors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlSlider extends StatelessWidget {
  const _ControlSlider(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(color: AppColors.muted))),
            Text('${(value * 100).round()}%',
                style: const TextStyle(
                    color: AppColors.text, fontWeight: FontWeight.w700)),
          ]),
          SliderTheme(
            data: labSliderTheme(context),
            child: Slider(
              value: value,
              semanticFormatterCallback: (v) => '${(v * 100).round()}%',
              onChanged: onChanged,
            ),
          ),
        ],
      );
}

class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
              child:
                  Text(label, style: const TextStyle(color: AppColors.muted))),
          Text(value,
              style: TextStyle(
                  fontFamily: AppFonts.display,
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

/// Malha de nível com a simbologia da ISA 5.1: tubulação de processo em
/// linha cheia, sinal elétrico tracejado, instrumentos em círculo (LT =
/// transmissor de nível), válvula de controle em "gravata" com atuador de
/// diafragma e o CLP em retângulo. Só a água tem cor.
class ProcessPainter extends CustomPainter {
  const ProcessPainter({
    required this.level,
    required this.setpoint,
    required this.valve,
    required this.automatic,
  });

  /// Nível, referência e abertura da válvula, de 0 a 1.
  final double level, setpoint, valve;
  final bool automatic;

  static const _pipe = AppColors.muted;
  static const _signal = AppColors.skyOnInk;
  static const _instrument = AppColors.text;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final layout = ProcessLayout(size);
    final tank = layout.tank;

    final pipe = Paint()
      ..color = _pipe
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Água (cor física) e tanque.
    final waterHeight = (tank.height - 6) * level.clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
          Rect.fromLTWH(tank.left + 3, tank.bottom - waterHeight - 3,
              tank.width - 6, waterHeight),
          bottomLeft: const Radius.circular(6),
          bottomRight: const Radius.circular(6)),
      Paint()..color = AppColors.skyOnInk.withValues(alpha: .45),
    );
    canvas.drawRRect(
        RRect.fromRectAndRadius(tank, const Radius.circular(8)), pipe);

    // Referência: tracejada, para não depender da cor.
    final setY = tank.bottom - tank.height * setpoint.clamp(0.0, 1.0);
    _dashed(
        canvas,
        Offset(tank.left - 6, setY),
        Offset(tank.right + 6, setY),
        Paint()
          ..color = AppColors.text
          ..strokeWidth = 1.6);
    paintText(canvas, _label('SP', size: 11), Offset(tank.right + 9, setY),
        Alignment.centerLeft);

    // Entrada: tubulação passando pela válvula até o topo do tanque.
    final valve = layout.valve;
    final inletY = valve.dy;
    canvas.drawPath(
      Path()
        ..moveTo(4, inletY)
        ..lineTo(valve.dx - 13, inletY)
        ..moveTo(valve.dx + 13, inletY)
        ..lineTo(tank.left + tank.width * .3, inletY)
        ..lineTo(tank.left + tank.width * .3, tank.top + 2),
      pipe,
    );
    paintText(canvas, _label('entrada', size: 10, color: AppColors.muted),
        Offset(4, inletY - 6), Alignment.bottomLeft);

    // Saída pelo fundo do tanque.
    final outY = tank.bottom - 12;
    canvas.drawLine(
        Offset(tank.right, outY), Offset(w - 2, outY), pipe..strokeWidth = 3);

    _controlValve(canvas, valve);
    paintText(
        canvas,
        _label('${(this.valve * 100).round()}%',
            size: 10, color: AppColors.muted),
        valve + const Offset(0, 12),
        Alignment.topCenter);

    // Transmissor de nível no costado do tanque.
    final lt = layout.transmitter;
    canvas.drawLine(Offset(lt.dx + 14, lt.dy), Offset(tank.left, lt.dy),
        pipe..strokeWidth = 2);
    _bubble(canvas, lt, 'LT');

    // CLP.
    final clp = layout.clp;
    canvas.drawRRect(RRect.fromRectAndRadius(clp, const Radius.circular(6)),
        Paint()..color = AppColors.surface);
    canvas.drawRRect(
        RRect.fromRectAndRadius(clp, const Radius.circular(6)),
        Paint()
          ..color = _instrument
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6);
    paintText(canvas, _label('CLP', size: 13, weight: FontWeight.w700),
        clp.center - const Offset(0, 8));
    paintText(
        canvas,
        _label(automatic ? 'auto' : 'manual',
            size: 10.5, color: AppColors.skyOnInk),
        clp.center + const Offset(0, 10));

    // Sinais elétricos (4–20 mA): do LT ao CLP e do CLP ao atuador.
    final signal = Paint()
      ..color = _signal
      ..strokeWidth = 1.6;
    final toClp = [
      Offset(lt.dx - 14, lt.dy),
      Offset(clp.center.dx, lt.dy),
      Offset(clp.center.dx, clp.bottom),
    ];
    final toValve = [
      Offset(clp.center.dx, clp.top),
      Offset(clp.center.dx, layout.actuatorTop.dy),
      layout.actuatorTop - const Offset(11, 0),
    ];
    for (final line in [toClp, toValve]) {
      for (var i = 0; i < line.length - 1; i++) {
        _dashed(canvas, line[i], line[i + 1], signal);
      }
    }
    CircuitSymbols.arrowHead(canvas, clp.bottomCenter, const Offset(0, -1),
        color: _signal, size: 6);
    CircuitSymbols.arrowHead(
        canvas, layout.actuatorTop - const Offset(11, 0), const Offset(1, 0),
        color: _signal, size: 6);
    paintText(canvas, _label('4–20 mA', size: 10, color: AppColors.skyOnInk),
        Offset((lt.dx + clp.center.dx) / 2, lt.dy + 5), Alignment.topCenter);

    paintText(canvas, _label('tanque', size: 10, color: AppColors.muted),
        Offset(tank.center.dx, h - 2), Alignment.bottomCenter);
  }

  /// Válvula de controle: gravata (dois triângulos) com haste e atuador de
  /// diafragma em cima.
  void _controlValve(Canvas canvas, Offset c) {
    const s = 10.0;
    final body = Path()
      ..moveTo(c.dx - s * 1.3, c.dy - s)
      ..lineTo(c.dx + s * 1.3, c.dy + s)
      ..lineTo(c.dx + s * 1.3, c.dy - s)
      ..lineTo(c.dx - s * 1.3, c.dy + s)
      ..close();
    final stroke = Paint()
      ..color = _instrument
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round;
    canvas
      ..drawPath(body, Paint()..color = AppColors.surface)
      ..drawPath(body, stroke)
      ..drawLine(c, c - const Offset(0, 18), stroke);
    final dome =
        Rect.fromCenter(center: c - const Offset(0, 18), width: 24, height: 20);
    canvas
      ..drawArc(
          dome, math.pi, math.pi, true, Paint()..color = AppColors.surface)
      ..drawArc(dome, math.pi, math.pi, true, stroke);
  }

  void _bubble(Canvas canvas, Offset c, String tag) {
    canvas
      ..drawCircle(c, 14, Paint()..color = AppColors.surface)
      ..drawCircle(
          c,
          14,
          Paint()
            ..color = _instrument
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6);
    paintText(canvas, _label(tag, size: 10.5, weight: FontWeight.w700), c);
  }

  static TextPainter _label(String text,
          {double size = 12,
          FontWeight weight = FontWeight.w600,
          Color color = AppColors.text}) =>
      drawingText(text, size: size, weight: weight, color: color);

  static void _dashed(Canvas canvas, Offset a, Offset b, Paint paint) {
    final length = (b - a).distance;
    if (length == 0) return;
    final dir = (b - a) / length;
    for (var d = 0.0; d < length; d += 8) {
      final end = d + 4.5 > length ? length : d + 4.5;
      canvas.drawLine(a + dir * d, a + dir * end, paint);
    }
  }

  @override
  bool shouldRepaint(ProcessPainter old) =>
      old.level != level ||
      old.setpoint != setpoint ||
      old.valve != valve ||
      old.automatic != automatic;
}

/// Posições da malha de nível para um tamanho, escaladas pela largura.
class ProcessLayout {
  ProcessLayout(this.size);

  final Size size;

  /// O topo fica abaixo da tubulação de entrada, que desce para dentro dele.
  Rect get tank => Rect.fromLTWH(
      size.width * .6, 72, size.width * .25, size.height - 72 - 22);

  Offset get valve => Offset(size.width * .4, 52);

  /// Topo do atuador da válvula, onde chega o sinal do CLP.
  Offset get actuatorTop => valve - const Offset(0, 28);

  Offset get transmitter =>
      Offset(tank.left - 30, tank.bottom - tank.height * .22);

  Rect get clp => Rect.fromCenter(
      center: Offset(size.width * .16, size.height * .52),
      width: (size.width * .22).clamp(64.0, 96.0),
      height: 52);
}
