import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme.dart';

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
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('LABORATÓRIO DE PROCESSO'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            const Text('MALHA DE NÍVEL',
                style: TextStyle(
                    color: AppColors.amberOnInk,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5)),
            const SizedBox(height: 6),
            const Text(
              'Sensor → CLP → válvula → tanque',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ajuste a referência e veja o controlador compensar a saída.',
              style: TextStyle(color: AppColors.mutedOnInk),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 250,
              child: CustomPaint(
                painter: _ProcessPainter(
                  level: _level,
                  setpoint: _setpoint,
                  valve: _valve,
                  automatic: _automatic,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _ValueRow('Nível medido', '${(_level * 100).round()}%',
                AppColors.skyOnInk),
            _ValueRow('Referência', '${(_setpoint * 100).round()}%',
                AppColors.amberOnInk),
            _ValueRow('Abertura da válvula', '${(_valve * 100).round()}%',
                Colors.white),
            const SizedBox(height: 18),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _automatic,
              activeTrackColor: AppColors.amber,
              title: const Text('Controle automático',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              subtitle: Text(
                _automatic
                    ? 'O CLP ajusta a válvula pelo erro de nível.'
                    : 'Você controla diretamente a abertura da válvula.',
                style: const TextStyle(color: AppColors.mutedOnInk),
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
                color: AppColors.inkRaised,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.inkLine),
              ),
              child: Text(
                error.abs() < .04
                    ? 'Processo estabilizado: o nível está próximo da referência.'
                    : error > 0
                        ? 'O nível está abaixo da referência; o CLP abre mais a válvula.'
                        : 'O nível está acima da referência; o CLP reduz a abertura.',
                style: const TextStyle(color: Colors.white),
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
                    style: const TextStyle(color: AppColors.mutedOnInk))),
            Text('${(value * 100).round()}%',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ]),
          Slider(
            value: value,
            activeColor: AppColors.amber,
            inactiveColor: AppColors.inkLine,
            onChanged: onChanged,
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
              child: Text(label,
                  style: const TextStyle(color: AppColors.mutedOnInk))),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w800)),
        ]),
      );
}

class _ProcessPainter extends CustomPainter {
  const _ProcessPainter(
      {required this.level,
      required this.setpoint,
      required this.valve,
      required this.automatic});
  final double level, setpoint, valve;
  final bool automatic;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.mutedOnInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final tank =
        Rect.fromLTWH(size.width * .58, 25, size.width * .27, size.height - 54);
    canvas.drawRRect(
        RRect.fromRectAndRadius(tank, const Radius.circular(10)), line);
    final waterHeight = (tank.height - 6) * level;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(tank.left + 3, tank.bottom - waterHeight - 3,
              tank.width - 6, waterHeight),
          const Radius.circular(7)),
      Paint()..color = AppColors.skyOnInk.withValues(alpha: .68),
    );
    final setY = tank.bottom - tank.height * setpoint;
    canvas.drawLine(
        Offset(tank.left - 8, setY),
        Offset(tank.right + 8, setY),
        Paint()
          ..color = AppColors.amberOnInk
          ..strokeWidth = 2);
    _label(
        canvas, 'SP', Offset(tank.right + 18, setY - 7), AppColors.amberOnInk);

    final clp = Rect.fromLTWH(
        size.width * .08, size.height * .36, size.width * .25, 62);
    canvas.drawRRect(RRect.fromRectAndRadius(clp, const Radius.circular(10)),
        Paint()..color = AppColors.inkRaised);
    canvas.drawRRect(
        RRect.fromRectAndRadius(clp, const Radius.circular(10)), line);
    _label(canvas, 'CLP', clp.center - const Offset(0, 8), Colors.white,
        center: true);
    _label(canvas, automatic ? 'AUTO' : 'MANUAL',
        clp.center + const Offset(0, 13), AppColors.amberOnInk,
        center: true, size: 10);

    final valveCenter = Offset(size.width * .47, size.height * .25);
    canvas.drawCircle(valveCenter, 19, Paint()..color = AppColors.inkRaised);
    canvas.drawCircle(valveCenter, 19, line);
    canvas.drawLine(
        valveCenter - const Offset(12, 0),
        valveCenter + const Offset(12, 0),
        Paint()
          ..color = AppColors.amberOnInk
          ..strokeWidth = 4 + valve * 4);
    _label(canvas, 'Válvula', valveCenter + const Offset(0, 34), Colors.white,
        center: true, size: 11);

    final signal = Paint()
      ..color = AppColors.successOnInk
      ..strokeWidth = 2;
    canvas.drawLine(Offset(clp.right, clp.center.dy),
        Offset(valveCenter.dx - 20, valveCenter.dy), signal);
    canvas.drawLine(Offset(valveCenter.dx + 20, valveCenter.dy),
        Offset(tank.left, valveCenter.dy), signal);
    canvas.drawLine(Offset(tank.left, tank.bottom - 15),
        Offset(clp.right, clp.bottom + 24), signal);
    _label(canvas, 'sensor 4–20 mA', Offset(size.width * .24, size.height - 17),
        AppColors.skyOnInk,
        center: true, size: 10);
  }

  static void _label(Canvas canvas, String text, Offset at, Color color,
      {bool center = false, double size = 12}) {
    final painter = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: size, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas,
        center ? at - Offset(painter.width / 2, painter.height / 2) : at);
  }

  @override
  bool shouldRepaint(_ProcessPainter old) =>
      old.level != level ||
      old.setpoint != setpoint ||
      old.valve != valve ||
      old.automatic != automatic;
}
