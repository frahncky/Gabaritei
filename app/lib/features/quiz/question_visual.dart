import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../domain/models/question_figure.dart';
import 'figure_view.dart';
import '../../shared/drawings/bedroom_plan.dart';
import '../../shared/drawings/circuit_symbols.dart';
import '../../shared/drawings/electrical_symbols.dart';
import '../../shared/motion.dart';

/// Diagrama curto, animado e acessível para tornar questões técnicas visuais.
///
/// Os desenhos recebem o controlador pelo `repaint:` e só ele anda a cada
/// quadro; pausado, o controlador para (sem gastar bateria) e o diagrama fica
/// desenergizado. Com menos movimento, fica energizado e parado.
class QuestionVisualCard extends StatefulWidget {
  const QuestionVisualCard({super.key, this.visual, this.figure});

  final QuestionVisual? visual;
  final QuestionFigure? figure;

  @override
  State<QuestionVisualCard> createState() => _QuestionVisualCardState();
}

class _QuestionVisualCardState extends State<QuestionVisualCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  bool _energized = true;

  /// O código de cores é uma foto: não tem o que animar.
  bool get _animated => widget.visual != QuestionVisual.resistorBands;

  /// Com "Remover animações" ligado, o controlador fica parado e o desenho
  /// mostra o circuito energizado (lâmpada acesa, cargas paradas).
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // O pedido de menos movimento pode mudar com a tela aberta.
    _reduced = AppMotion.reduced(context);
    _syncController();
  }

  @override
  void didUpdateWidget(QuestionVisualCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visual != widget.visual) _syncController();
  }

  void _syncController() {
    if (_animated && _energized && !_reduced) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  void _toggle() {
    setState(() => _energized = !_energized);
    _syncController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _label => switch (widget.visual) {
        null => '',
        QuestionVisual.circuitSeries =>
          'Circuito em série: fonte de 12 volts e resistor de 220 ohms',
        QuestionVisual.circuitParallel =>
          'Circuito em paralelo: fonte ligada a dois resistores de 100 ohms, '
              'cada um num ramo',
        QuestionVisual.resistorBands =>
          'Resistor com faixas marrom, preto, vermelho e dourado',
        QuestionVisual.electricalPlan =>
          'Planta elétrica de uma sala com quadro de distribuição, ponto de '
              'luz no teto, interruptor simples ao lado da porta e duas '
              'tomadas, ligados por eletrodutos',
        QuestionVisual.bedroomPlan => BedroomPlanSpec.semanticsLabel,
        QuestionVisual.processControl =>
          'Laço fechado de controle de processo: o sensor mede, o CLP decide, '
              'a válvula atua no tanque e o sensor volta a medir',
      };

  @override
  Widget build(BuildContext context) {
    if (widget.figure != null) return QuestionFigureView(figure: widget.figure!);
    return Semantics(
      label: _label,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.large),
        ),
        child: Column(
          children: [
            switch (widget.visual) {
              QuestionVisual.resistorBands => const SizedBox(
                  height: 132,
                  width: double.infinity,
                  child: _ResistorBands(),
                ),
              // A planta precisa de mais altura e repinta sozinha com o
              // controlador, sem reconstruir o cartão a cada quadro.
              QuestionVisual.bedroomPlan => RepaintBoundary(
                  child: BedroomPlan(
                    progress: _controller,
                    energized: _energized,
                  ),
                ),
              _ => ExcludeSemantics(
                  child: SizedBox(
                    height: 132,
                    width: double.infinity,
                    // Isola o repinte de cada quadro do resto da tela.
                    child: RepaintBoundary(
                      child: CustomPaint(painter: _painterFor(widget.visual!)),
                    ),
                  ),
                ),
            },
            // Sem movimento não há o que pausar: o diagrama fica energizado.
            if (_animated && !_reduced)
              TextButton.icon(
                onPressed: _toggle,
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
          QuestionCircuitPainter(
            parallel: visual == QuestionVisual.circuitParallel,
            progress: _controller,
            energized: _energized,
          ),
        QuestionVisual.electricalPlan => _RoomPlanPainter(
            progress: _controller,
            energized: _energized,
          ),
        QuestionVisual.processControl => _ProcessLoopPainter(
            progress: _controller,
            energized: _energized,
          ),
        QuestionVisual.resistorBands ||
        QuestionVisual.bedroomPlan =>
          throw StateError('$visual tem widget próprio.'),
      };
}

/// Resistor de 1 kΩ (marrom, preto, vermelho) com 5% de tolerância
/// (dourado), nas mesmas cores físicas do laboratório. A faixa de tolerância
/// fica afastada das outras, como no componente real, para indicar o sentido
/// de leitura.
class _ResistorBands extends StatelessWidget {
  const _ResistorBands();

  static const _marrom = Color(0xFF8B4A1C);
  static const _preto = Color(0xFF1B1B1B);
  static const _vermelho = Color(0xFFE53935);
  static const _dourado = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    Widget band(Color color) => Container(width: 13, color: color);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Terminais.
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8C2CF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 190,
                height: 56,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF3E2B8),
                      Color(0xFFD9BE85),
                      Color(0xFFB99A5E),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 32),
                    band(_marrom),
                    const SizedBox(width: 11),
                    band(_preto),
                    const SizedBox(width: 11),
                    band(_vermelho),
                    const Spacer(),
                    band(_dourado),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text('marrom · preto · vermelho · dourado',
            style: TextStyle(color: AppColors.muted, fontSize: 12)),
      ],
    );
  }
}

/// Geometria dos circuitos das questões: laço retangular com a fonte no
/// lado esquerdo e, no paralelo, um ramo no meio. Separada do painter para
/// ser testada.
class QuestionCircuitLayout {
  QuestionCircuitLayout(this.size);

  final Size size;

  /// Meia distância entre as pontas do fio na fonte.
  static const gap = 11.0;

  double get left => 36;
  double get right => size.width - 24;
  double get top => 22;
  double get bottom => size.height - 18;
  double get midY => (top + bottom) / 2;

  /// Fonte: centro do símbolo no lado esquerdo.
  Offset get source => Offset(left, midY);

  /// Série: o resistor fica no fio de cima.
  Offset get seriesResistor => Offset((left + right) / 2 + 12, top);

  /// Paralelo: ramo do meio (R₁) e o lado direito (R₂).
  double get branchX => left + (right - left) * .52;
  Offset get parallelR1 => Offset(branchX, midY);
  Offset get parallelR2 => Offset(right, midY);

  /// Nós onde a corrente se divide e volta a se juntar.
  List<Offset> get nodes => [Offset(branchX, top), Offset(branchX, bottom)];

  /// Trechos de fio no sentido convencional da corrente (saindo do + da
  /// fonte, em cima, e voltando pelo −). Série: um trecho. Paralelo: saída,
  /// ramo de R₁, ramo de R₂ e retorno.
  List<Path> wires({required bool parallel}) {
    Path line(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      return path;
    }

    final up = Offset(left, midY - gap);
    final down = Offset(left, midY + gap);
    if (!parallel) {
      return [
        line([
          up,
          Offset(left, top),
          Offset(right, top),
          Offset(right, bottom),
          Offset(left, bottom),
          down,
        ]),
      ];
    }
    final x = branchX;
    return [
      line([up, Offset(left, top), Offset(x, top)]),
      line([Offset(x, top), Offset(x, bottom)]),
      line([
        Offset(x, top),
        Offset(right, top),
        Offset(right, bottom),
        Offset(x, bottom)
      ]),
      line([Offset(x, bottom), Offset(left, bottom), down]),
    ];
  }
}

/// Circuito em série (12 V e 220 Ω) ou em paralelo (dois de 100 Ω) com
/// símbolos IEC 60617 e a corrente andando do + para o −.
class QuestionCircuitPainter extends CustomPainter {
  QuestionCircuitPainter({
    required this.parallel,
    required this.progress,
    required this.energized,
  }) : super(repaint: energized ? progress : null);

  final bool parallel;

  /// Ciclo de 0 a 1 que anda a corrente.
  final Animation<double> progress;
  final bool energized;

  static const _spacing = 18.0;
  static const _background = AppColors.surface;

  @override
  void paint(Canvas canvas, Size size) {
    final l = QuestionCircuitLayout(size);
    final wires = l.wires(parallel: parallel);
    final wire = CircuitSymbols.wire();
    for (final w in wires) {
      canvas.drawPath(w, wire);
    }

    if (energized) {
      // No paralelo, cada ramo leva metade da corrente: anda na metade da
      // velocidade. Múltiplos inteiros do espaçamento fecham o ciclo.
      final speeds = parallel ? [4, 2, 2, 4] : [3];
      for (var i = 0; i < wires.length; i++) {
        CircuitSymbols.current(canvas, wires[i].computeMetrics().first,
            shift: progress.value * _spacing * speeds[i], spacing: _spacing);
      }
    }

    CircuitSymbols.cell(canvas, l.source,
        gap: 2 * (QuestionCircuitLayout.gap - 4));
    _text(canvas, '+', l.source + const Offset(-20, -9), size: 13);
    _text(canvas, '−', l.source + const Offset(-20, 10), size: 13);

    if (parallel) {
      for (final node in l.nodes) {
        CircuitSymbols.node(canvas, node);
      }
      for (final (center, name) in [
        (l.parallelR1, 'R₁'),
        (l.parallelR2, 'R₂')
      ]) {
        CircuitSymbols.resistor(canvas, center,
            horizontal: false, background: _background, length: 42);
        _text(canvas, name, center + const Offset(-14, -8),
            alignment: Alignment.centerRight);
        _text(canvas, '100 Ω', center + const Offset(-14, 8),
            alignment: Alignment.centerRight,
            color: CircuitColors.value,
            size: 11);
      }
    } else {
      _text(canvas, '12 V', l.source + const Offset(14, 0),
          alignment: Alignment.centerLeft, size: 13);
      final r = l.seriesResistor;
      CircuitSymbols.resistor(canvas, r,
          horizontal: true, background: _background, length: 50);
      _text(canvas, '220 Ω', r + const Offset(0, 14),
          alignment: Alignment.topCenter, size: 13);
      // Sentido convencional da corrente, do + para o −.
      final arrow = Offset(l.right, l.midY + 6);
      CircuitSymbols.arrowHead(canvas, arrow, const Offset(0, 1));
      _text(canvas, 'I', arrow + const Offset(-10, -4),
          alignment: Alignment.centerRight,
          color: CircuitColors.value,
          italic: true);
    }
  }

  static void _text(
    Canvas canvas,
    String text,
    Offset at, {
    Alignment alignment = Alignment.center,
    Color color = CircuitColors.component,
    double size = 12,
    bool italic = false,
  }) =>
      paintText(
          canvas,
          drawingText(text,
              size: size,
              weight: FontWeight.w600,
              color: color,
              italic: italic),
          at,
          alignment);

  @override
  bool shouldRepaint(QuestionCircuitPainter old) =>
      old.energized != energized ||
      old.parallel != parallel ||
      old.progress != progress;
}

/// Planta elétrica simplificada de uma sala, com a mesma simbologia da
/// planta do quarto: quadro de distribuição, ponto de luz no teto (circuito
/// 1, comando a), interruptor simples junto à porta e tomadas baixas.
class _RoomPlanPainter extends CustomPainter {
  _RoomPlanPainter({required this.progress, required this.energized})
      : super(repaint: energized ? progress : null);

  final Animation<double> progress;
  final bool energized;

  static const _spacing = 20.0;

  @override
  void paint(Canvas canvas, Size size) {
    paintText(
        canvas,
        drawingText('Planta elétrica · sala',
            size: 10, weight: FontWeight.w600, color: AppColors.muted),
        Offset.zero,
        Alignment.topLeft);

    // Paredes em faixa, como na planta do quarto.
    const wall = 5.0;
    final outer = Rect.fromLTRB(8, 18, size.width - 8, size.height - 4);
    final room = outer.deflate(wall);
    canvas.drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(outer)
          ..addRect(room),
        Paint()..color = PlanColors.wallFill);
    final face = Paint()
      ..color = PlanColors.wall
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas
      ..drawRect(outer, face)
      ..drawRect(room, face);

    // Porta na parede de baixo, abrindo para dentro.
    final leaf = math.min(32.0, room.height * .4);
    final hinge = Offset(room.left + 12, room.bottom);
    canvas
      ..drawRect(
          Rect.fromLTRB(
              hinge.dx, room.bottom - 1, hinge.dx + leaf, outer.bottom + 1),
          Paint()..color = AppColors.surface)
      ..drawLine(
          hinge,
          hinge - Offset(0, leaf),
          Paint()
            ..color = AppColors.muted
            ..strokeWidth = 2)
      ..drawArc(
          Rect.fromCircle(center: hinge, radius: leaf),
          -math.pi / 2,
          math.pi / 2,
          false,
          Paint()
            ..color = AppColors.muted.withValues(alpha: .7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);

    // Quadro de distribuição: retângulo com metade cheia.
    final qd = Rect.fromLTWH(room.left, room.top + 10, 10, 24);
    canvas
      ..drawRect(qd, Paint()..color = AppColors.surface)
      ..drawPath(
          Path()
            ..moveTo(qd.left, qd.top)
            ..lineTo(qd.right, qd.top)
            ..lineTo(qd.left, qd.bottom)
            ..close(),
          Paint()..color = PlanColors.symbol)
      ..drawRect(
          qd,
          Paint()
            ..color = PlanColors.symbol
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.3);
    paintText(canvas, drawingText('QD', size: 10, weight: FontWeight.w700),
        Offset(qd.right + 4, qd.center.dy), Alignment.centerLeft);

    final light = Offset(room.center.dx + 8, room.center.dy - 2);
    const radius = 15.0;
    final switchAt = Offset(hinge.dx + leaf + 14, room.bottom - 6);
    final outlets = [
      (
        base: Offset(room.right - 1, room.top + 18),
        inward: const Offset(-1, 0)
      ),
      (
        base: Offset(room.right - 1, room.bottom - 18),
        inward: const Offset(-1, 0)
      ),
    ];

    // Eletrodutos: do QD ao ponto de luz e dali a cada ponto.
    final feed = Path()
      ..moveTo(qd.right, qd.center.dy + 6)
      ..quadraticBezierTo(light.dx - 30, qd.center.dy + 8, light.dx, light.dy);
    final branches = [
      Path()
        ..moveTo(light.dx, light.dy)
        ..quadraticBezierTo(
            switchAt.dx + 6, light.dy + 6, switchAt.dx, switchAt.dy),
      for (final o in outlets)
        Path()
          ..moveTo(light.dx, light.dy)
          ..quadraticBezierTo(
              o.base.dx - 30, light.dy, o.base.dx - 8, o.base.dy),
    ];
    final conduit = PlanSymbols.conduit();
    canvas.drawPath(feed, conduit);
    for (final b in branches) {
      canvas.drawPath(b, conduit);
    }

    if (energized) {
      final feedMetric = feed.computeMetrics().first;
      final shift = progress.value * _spacing * 2;
      _current(canvas, feedMetric, shift, 0);
      for (final b in branches) {
        _current(canvas, b.computeMetrics().first, shift, feedMetric.length);
      }
    }

    PlanSymbols.ceilingLight(canvas, light, radius,
        line: PlanColors.symbol,
        fill: energized ? PlanColors.lit : AppColors.surface);
    final ink = energized ? AppColors.ink : AppColors.text;
    for (final (text, dx) in [('1', -.42), ('a', .42)]) {
      paintText(
          canvas,
          drawingText(text, size: 9, weight: FontWeight.w700, color: ink),
          light + Offset(radius * dx, radius * .42));
    }

    PlanSymbols.simpleSwitch(canvas, switchAt, 3.8, PlanColors.symbol);
    paintText(canvas, drawingText('a', size: 11, weight: FontWeight.w700),
        switchAt + const Offset(8, -8), Alignment.centerLeft);
    for (final o in outlets) {
      PlanSymbols.outlet(canvas,
          base: o.base,
          inward: o.inward,
          size: 12,
          high: false,
          color: PlanColors.symbol,
          background: AppColors.surface);
    }
  }

  void _current(
      Canvas canvas, PathMetric metric, double shift, double startsAt) {
    CircuitSymbols.current(canvas, metric,
        shift: shift, spacing: _spacing, startsAt: startsAt, radius: 2.3);
  }

  @override
  bool shouldRepaint(_RoomPlanPainter old) =>
      old.energized != energized || old.progress != progress;
}

/// Laço fechado de controle: sensor (medição), CLP (decisão), válvula (ação)
/// e tanque (processo), com a realimentação voltando ao sensor. Um pulso
/// percorre o laço.
class _ProcessLoopPainter extends CustomPainter {
  _ProcessLoopPainter({required this.progress, required this.energized})
      : super(repaint: energized ? progress : null);

  final Animation<double> progress;
  final bool energized;

  static const _blocks = [
    ('Sensor', 'medição'),
    ('CLP', 'decisão'),
    ('Válvula', 'ação'),
    ('Tanque', 'processo'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    paintText(
        canvas,
        drawingText('Laço de controle de processo',
            size: 10, weight: FontWeight.w600, color: AppColors.muted),
        Offset.zero,
        Alignment.topLeft);

    const n = 4;
    const gapMin = 16.0;
    final boxW = math.min(70.0, (size.width - 4 - gapMin * (n - 1)) / n);
    final gap = (size.width - 4 - boxW * n) / (n - 1);
    const boxH = 40.0;
    const cy = 48.0;
    final boxes = [
      for (var i = 0; i < n; i++)
        Rect.fromLTWH(2 + i * (boxW + gap), cy - boxH / 2, boxW, boxH),
    ];
    final loopY = boxes.first.bottom + 26;

    final line = Paint()
      ..color = AppColors.skyOnInk
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    // Caminho do sinal: pelos blocos e de volta do tanque ao sensor.
    final loop = Path()..moveTo(boxes.first.center.dx, boxes.first.center.dy);
    for (final b in boxes.skip(1)) {
      loop.lineTo(b.center.dx, b.center.dy);
    }
    loop
      ..lineTo(boxes.last.center.dx, loopY)
      ..lineTo(boxes.first.center.dx, loopY)
      ..close();
    canvas.drawPath(loop, line);

    for (var i = 0; i < n - 1; i++) {
      CircuitSymbols.arrowHead(
          canvas, Offset(boxes[i + 1].left, cy), const Offset(1, 0),
          color: AppColors.skyOnInk, size: 6);
    }
    CircuitSymbols.arrowHead(
        canvas, boxes.first.bottomCenter, const Offset(0, -1),
        color: AppColors.skyOnInk, size: 6);
    final feedback = drawingText('realimentação',
        size: 9.5, weight: FontWeight.w500, color: AppColors.muted);
    final mid = Offset(size.width / 2, loopY);
    canvas.drawRect(
        Rect.fromCenter(
            center: mid, width: feedback.width + 10, height: feedback.height),
        Paint()..color = AppColors.surface);
    paintText(canvas, feedback, mid);

    if (energized) {
      final metric = loop.computeMetrics().first;
      final position =
          metric.getTangentForOffset(metric.length * progress.value)?.position;
      if (position != null) {
        canvas.drawCircle(position, 4, Paint()..color = CircuitColors.current);
      }
    }

    for (var i = 0; i < n; i++) {
      final box = RRect.fromRectAndRadius(boxes[i], const Radius.circular(7));
      canvas
        ..drawRRect(box, Paint()..color = AppColors.surfaceHigh)
        ..drawRRect(box, line);
      final (name, role) = _blocks[i];
      paintText(canvas, drawingText(name, size: 10.5, weight: FontWeight.w700),
          boxes[i].center - const Offset(0, 7));
      paintText(
          canvas,
          drawingText(role,
              size: 9, weight: FontWeight.w500, color: AppColors.muted),
          boxes[i].center + const Offset(0, 8));
    }
  }

  @override
  bool shouldRepaint(_ProcessLoopPainter old) =>
      old.energized != energized || old.progress != progress;
}
