import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/models/content.dart';

/// Diagrama curto, animado e acessível para tornar questões técnicas visuais.
class QuestionVisualCard extends StatefulWidget {
  const QuestionVisualCard({super.key, required this.visual});

  final QuestionVisual visual;

  @override
  State<QuestionVisualCard> createState() => _QuestionVisualCardState();
}

class _QuestionVisualCardState extends State<QuestionVisualCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();
  bool _energized = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _label => switch (widget.visual) {
        QuestionVisual.circuitSeries =>
          'Circuito em série com fonte de 12 volts e resistor de 220 ohms',
        QuestionVisual.circuitParallel =>
          'Circuito em paralelo com dois resistores de 100 ohms',
        QuestionVisual.resistorBands =>
          'Resistor com faixas marrom, preto, vermelho e dourado',
        QuestionVisual.electricalPlan =>
          'Planta elétrica de uma sala com luminária, interruptor, tomadas e quadro de distribuição',
        QuestionVisual.processControl =>
          'Diagrama de controle de processo com sensor, controlador, atuador e tanque',
      };

  @override
  Widget build(BuildContext context) {
    final resistor = widget.visual == QuestionVisual.resistorBands;
    return Semantics(
      label: _label,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: resistor
                  ? const _ResistorBands()
                  : AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) =>
                          CustomPaint(painter: _painterFor(widget.visual)),
                    ),
            ),
            if (!resistor)
              TextButton.icon(
                onPressed: () => setState(() => _energized = !_energized),
                icon: Icon(_energized
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline),
                label: Text(
                  _energized ? 'Pausar animação' : 'Animar diagrama',
                ),
              ),
          ],
        ),
      ),
    );
  }

  CustomPainter _painterFor(QuestionVisual visual) => switch (visual) {
        QuestionVisual.circuitSeries ||
        QuestionVisual.circuitParallel =>
          _CircuitPainter(
            parallel: visual == QuestionVisual.circuitParallel,
            phase: _controller.value,
            energized: _energized,
          ),
        QuestionVisual.electricalPlan => _ElectricalPlanPainter(
            phase: _controller.value,
            energized: _energized,
          ),
        QuestionVisual.processControl => _ProcessControlPainter(
            phase: _controller.value,
            energized: _energized,
          ),
        QuestionVisual.resistorBands =>
          throw StateError('Resistor não usa painter.'),
      };
}

class _ResistorBands extends StatelessWidget {
  const _ResistorBands();

  @override
  Widget build(BuildContext context) {
    const bands = [
      Color(0xFF80502B),
      Color(0xFF111827),
      Color(0xFFDC2626),
      Color(0xFFF59E0B)
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 52,
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 36),
          decoration: BoxDecoration(
            color: const Color(0xFFD6B47B),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final band in bands) Container(width: 13, color: band)
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text('marrom · preto · vermelho · dourado',
            style: TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}

class _CircuitPainter extends CustomPainter {
  const _CircuitPainter(
      {required this.parallel, required this.phase, required this.energized});

  final bool parallel;
  final double phase;
  final bool energized;

  @override
  void paint(Canvas canvas, Size size) {
    final wire = Paint()
      ..color = AppColors.skyOnInk
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final resistor = Paint()..color = AppColors.amber;
    final rect = Rect.fromLTWH(20, 18, size.width - 40, size.height - 36);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)), wire);
    canvas.drawCircle(
        Offset(42, size.height / 2), 16, Paint()..color = AppColors.blueSoft);
    canvas.drawCircle(Offset(42, size.height / 2), 16, wire);
    _text(canvas, '+', Offset(36, size.height / 2 - 12), AppColors.text, 20);
    _text(canvas, '−', Offset(36, size.height / 2 + 1), AppColors.text, 18);
    if (parallel) {
      final x = size.width * .58;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), wire);
      for (final y in [size.height * .36, size.height * .66]) {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(center: Offset(x, y), width: 58, height: 18),
                const Radius.circular(4)),
            resistor);
      }
      _text(canvas, '100 Ω', Offset(x - 22, size.height * .26), AppColors.text,
          11);
      _text(canvas, '100 Ω', Offset(x - 22, size.height * .76), AppColors.text,
          11);
    } else {
      final center = Offset(size.width * .64, size.height / 2);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: center, width: 74, height: 22),
              const Radius.circular(4)),
          resistor);
      _text(canvas, '220 Ω', Offset(center.dx - 22, center.dy - 6),
          AppColors.ink, 12);
      _text(canvas, '12 V', const Offset(20, 4), AppColors.muted, 12);
    }
    if (energized) {
      final y = rect.top + (rect.height * phase);
      canvas.drawCircle(
          Offset(rect.left, y), 4, Paint()..color = AppColors.success);
    }
  }

  void _text(
      Canvas canvas, String text, Offset offset, Color color, double size) {
    final painter = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color, fontSize: size, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_CircuitPainter old) =>
      old.phase != phase ||
      old.energized != energized ||
      old.parallel != parallel;
}

class _ElectricalPlanPainter extends CustomPainter {
  const _ElectricalPlanPainter({required this.phase, required this.energized});

  final double phase;
  final bool energized;

  @override
  void paint(Canvas canvas, Size size) {
    final wall = Paint()
      ..color = AppColors.skyOnInk
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final wire = Paint()
      ..color = AppColors.amberText
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final room = Rect.fromLTWH(24, 18, size.width - 48, size.height - 36);
    canvas.drawRect(room, wall);
    final panel = Rect.fromLTWH(room.left + 10, room.top + 12, 28, 34);
    canvas.drawRect(panel, Paint()..color = AppColors.blueSoft);
    canvas.drawRect(panel, wall);
    _paintLabel(
        canvas, 'QD', panel.bottomLeft + const Offset(2, 1), AppColors.text, 9);
    final lamp = Offset(size.width * .52, size.height * .4);
    canvas.drawCircle(lamp, 13,
        Paint()..color = energized ? AppColors.amber : AppColors.track);
    canvas.drawCircle(lamp, 16, wall);
    final switchPoint = Offset(room.left + 15, room.bottom - 18);
    canvas.drawCircle(switchPoint, 7, Paint()..color = AppColors.success);
    for (final point in [
      Offset(room.right - 16, room.top + 18),
      Offset(room.right - 16, room.bottom - 18)
    ]) {
      final outlet = Rect.fromCenter(center: point, width: 12, height: 8);
      canvas.drawRect(outlet, Paint()..color = AppColors.surface);
      canvas.drawRect(outlet, wall);
    }
    final path = Path()
      ..moveTo(panel.right, panel.center.dy)
      ..lineTo(lamp.dx, panel.center.dy)
      ..lineTo(lamp.dx, lamp.dy)
      ..lineTo(switchPoint.dx, lamp.dy)
      ..lineTo(switchPoint.dx, switchPoint.dy);
    canvas.drawPath(path, wire);
    if (energized) {
      final metric = path.computeMetrics().first;
      final dot = metric.getTangentForOffset(metric.length * phase)?.position;
      if (dot != null) {
        canvas.drawCircle(dot, 4, Paint()..color = AppColors.success);
      }
    }
    _paintLabel(canvas, 'PLANTA ELÉTRICA · SALA', const Offset(24, 2),
        AppColors.muted, 10);
  }

  @override
  bool shouldRepaint(_ElectricalPlanPainter old) =>
      old.phase != phase || old.energized != energized;
}

class _ProcessControlPainter extends CustomPainter {
  const _ProcessControlPainter({required this.phase, required this.energized});

  final double phase;
  final bool energized;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.skyOnInk
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final active = Paint()..color = AppColors.success;
    const labels = ['Sensor', 'CLP', 'Válvula', 'Tanque'];
    final xs = [
      size.width * .12,
      size.width * .38,
      size.width * .64,
      size.width * .88
    ];
    for (var i = 0; i < xs.length; i++) {
      final center = Offset(xs[i], size.height * .53);
      final box = Rect.fromCenter(center: center, width: 52, height: 42);
      canvas.drawRRect(RRect.fromRectAndRadius(box, const Radius.circular(7)),
          Paint()..color = AppColors.blueSoft);
      canvas.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(7)), line);
      _paintLabel(canvas, labels[i], Offset(center.dx - 21, center.dy - 5),
          AppColors.text, 10);
      if (i < xs.length - 1) {
        final from = Offset(center.dx + 27, center.dy);
        final to = Offset(xs[i + 1] - 27, center.dy);
        canvas.drawLine(from, to, line);
        if (energized && phase >= i / 3 && phase <= (i + 1) / 3) {
          final fraction = (phase * 3 - i).clamp(0.0, 1.0);
          canvas.drawCircle(Offset.lerp(from, to, fraction)!, 4, active);
        }
      }
    }
    _paintLabel(canvas, 'LAÇO DE CONTROLE DE PROCESSO', const Offset(18, 8),
        AppColors.muted, 10);
    _paintLabel(canvas, 'medição → decisão → ação → processo',
        const Offset(18, 108), AppColors.muted, 10);
  }

  @override
  bool shouldRepaint(_ProcessControlPainter old) =>
      old.phase != phase || old.energized != energized;
}

void _paintLabel(
    Canvas canvas, String text, Offset offset, Color color, double size) {
  final painter = TextPainter(
    text: TextSpan(
        text: text,
        style: TextStyle(
            color: color, fontSize: size, fontWeight: FontWeight.w600)),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(canvas, offset);
}
