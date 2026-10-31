import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../format.dart';
import 'electrical_symbols.dart';

/// Números da planta elétrica do quarto. As questões de instalações citam
/// estes valores: mudar algum exige revisar o conteúdo junto.
abstract final class BedroomPlanSpec {
  static const widthM = 3.5;
  static const depthM = 3.0;
  static const doorM = 0.8;
  static const lightVa = 160;
  static const lightCircuit = 1;
  static const command = 'a';
  static const outletVa = 100;
  static const outletCount = 3;
  static const outletCircuit = 2;
  static const acWatts = 1500;
  static const acCircuit = 3;

  /// Descrição para leitor de tela, completa o bastante para responder às
  /// questões sem ver o desenho.
  static String get semanticsLabel {
    String m(double value) => '${formatDecimal(value, 2)} m';
    return 'Planta baixa elétrica de um quarto retangular de ${m(widthM)} de '
        'largura por ${m(depthM)} de profundidade. A porta, de ${m(doorM)}, '
        'fica na parede de baixo, perto do canto esquerdo, e a janela fica na '
        'parede de cima. No centro do teto há um ponto de luz de $lightVa VA, '
        'circuito $lightCircuit, comando $command. O interruptor simples '
        '$command, do circuito $lightCircuit, fica ao lado da porta, do lado '
        'de dentro. Há $outletCount tomadas de uso geral baixas, de '
        '$outletVa VA cada, no circuito $outletCircuit: duas na parede de '
        'cima, uma de cada lado da cabeceira da cama, e uma na parede direita. '
        'Há uma tomada de uso específico alta, de ${formatNumber(acWatts)} W, '
        'no circuito $acCircuit, para o ar-condicionado da parede esquerda. A '
        'alimentação vem do quadro de distribuição, fora do quarto: o '
        'eletroduto entra pela parede de baixo e chega ao ponto de luz; dali, '
        'eletrodutos descem para o interruptor e para cada tomada.';
  }
}

enum WallSide { top, right, bottom, left }

/// Posição na face interna de uma parede, em metros a partir do canto
/// superior esquerdo do quarto (x nas paredes de cima e de baixo, y nas
/// laterais).
class WallPoint {
  const WallPoint(this.side, this.along);

  final WallSide side;
  final double along;
}

enum PlanPointKind { simpleSwitch, lowOutlet, highOutlet }

/// Ponto elétrico de parede, com a etiqueta (valor e circuito) e o caminho
/// do eletroduto que desce do ponto de luz até ele.
class PlanPoint {
  const PlanPoint({
    required this.kind,
    required this.wall,
    required this.label,
    required this.circuit,
    required this.tagAnchor,
    required this.tagAlignment,
    this.controls = const [],
  });

  final PlanPointKind kind;
  final WallPoint wall;

  /// Primeira linha da etiqueta: potência ou letra do comando.
  final String label;
  final int circuit;

  /// Âncora da etiqueta, em metros.
  final Offset tagAnchor;

  /// Ponto da etiqueta que fica sobre a âncora (ex.: `topRight` = a etiqueta
  /// cresce para a esquerda e para baixo).
  final Alignment tagAlignment;

  /// Pontos de controle da curva do eletroduto, em metros.
  final List<Offset> controls;

  String get circuitLabel => 'circ. $circuit';
}

/// Geometria da planta para uma largura: escala, paredes, móveis, pontos,
/// etiquetas e eletrodutos. Separada do painter para ser testada.
class BedroomPlanLayout {
  BedroomPlanLayout(this.width);

  /// Acima disso o desenho só cresceria sem ganhar leitura.
  static const maxWidth = 440.0;

  // Margens fixas: título e cota de cima, cota da esquerda e chegada do QD.
  static const _top = 44.0;
  static const _left = 24.0;
  static const _bottom = 24.0;
  static const _wallM = 0.12;

  static const switchRadius = 4.5;
  static const outletSize = 13.0;

  // Arquitetura e móveis, em metros (origem no canto superior esquerdo).
  static const windowFrom = 0.35, windowTo = 1.45;
  static const doorHinge = 0.15;
  static const bed = Rect.fromLTWH(2.12, 0, 0.8, 1.88);
  static const pillow = Rect.fromLTWH(2.19, 0.07, 0.66, 0.3);
  static const nightstands = [
    Rect.fromLTWH(1.7, 0, 0.38, 0.38),
    Rect.fromLTWH(2.96, 0, 0.38, 0.38),
  ];
  static const airConditioner = Rect.fromLTWH(0, 0.95, 0.2, 0.9);
  static const lightM = Offset(1.75, 1.5);
  static const feedM = 1.75;

  static const switchPoint = PlanPoint(
    kind: PlanPointKind.simpleSwitch,
    wall: WallPoint(WallSide.bottom, 1.15),
    label: BedroomPlanSpec.command,
    circuit: BedroomPlanSpec.lightCircuit,
    tagAnchor: Offset(1.27, 2.95),
    tagAlignment: Alignment.bottomLeft,
    controls: [Offset(1.15, 2.05)],
  );

  /// Interruptor, tomadas de uso geral (duas na cabeceira da cama e uma na
  /// parede direita) e a tomada do ar-condicionado.
  static final points = [
    switchPoint,
    const PlanPoint(
      kind: PlanPointKind.lowOutlet,
      wall: WallPoint(WallSide.top, 1.89),
      label: '${BedroomPlanSpec.outletVa} VA',
      circuit: BedroomPlanSpec.outletCircuit,
      tagAnchor: Offset(1.62, 0.06),
      tagAlignment: Alignment.topRight,
    ),
    const PlanPoint(
      kind: PlanPointKind.lowOutlet,
      wall: WallPoint(WallSide.top, 3.15),
      label: '${BedroomPlanSpec.outletVa} VA',
      circuit: BedroomPlanSpec.outletCircuit,
      tagAnchor: Offset(3.47, 0.46),
      tagAlignment: Alignment.topRight,
      controls: [Offset(2.45, 1.1), Offset(2.75, 0.2)],
    ),
    const PlanPoint(
      kind: PlanPointKind.lowOutlet,
      wall: WallPoint(WallSide.right, 2.42),
      label: '${BedroomPlanSpec.outletVa} VA',
      circuit: BedroomPlanSpec.outletCircuit,
      tagAnchor: Offset(3.44, 2.58),
      tagAlignment: Alignment.topRight,
      controls: [Offset(2.15, 2.55)],
    ),
    PlanPoint(
      kind: PlanPointKind.highOutlet,
      wall: const WallPoint(WallSide.left, 0.75),
      label: '${formatNumber(BedroomPlanSpec.acWatts)} W',
      circuit: BedroomPlanSpec.acCircuit,
      tagAnchor: const Offset(0.2, 0.64),
      tagAlignment: Alignment.bottomLeft,
      controls: const [Offset(0.75, 1.05)],
    ),
  ];

  final double width;

  /// Pixels por metro.
  late final double scale =
      (width - _left - 1) / (BedroomPlanSpec.widthM + 2 * _wallM);
  late final double wall = _wallM * scale;

  /// Face interna das paredes.
  late final Rect room = Rect.fromLTWH(_left + wall, _top + wall,
      BedroomPlanSpec.widthM * scale, BedroomPlanSpec.depthM * scale);
  late final Rect outer = room.inflate(wall);
  late final double height = outer.bottom + _bottom;

  /// Raio do ponto de luz: no mínimo o bastante para "160 VA" caber em cima.
  late final double lightRadius = (0.25 * scale).clamp(20.0, 22.0);

  Offset at(Offset meters) => room.topLeft + meters * scale;

  Rect rect(Rect meters) =>
      Rect.fromPoints(at(meters.topLeft), at(meters.bottomRight));

  Offset get light => at(lightM);

  Offset onWall(WallPoint p) => switch (p.side) {
        WallSide.top => Offset(room.left + p.along * scale, room.top),
        WallSide.bottom => Offset(room.left + p.along * scale, room.bottom),
        WallSide.left => Offset(room.left, room.top + p.along * scale),
        WallSide.right => Offset(room.right, room.top + p.along * scale),
      };

  static Offset inward(WallSide side) => switch (side) {
        WallSide.top => const Offset(0, 1),
        WallSide.bottom => const Offset(0, -1),
        WallSide.left => const Offset(1, 0),
        WallSide.right => const Offset(-1, 0),
      };

  /// Centro do símbolo, onde termina o eletroduto (o símbolo cobre a ponta).
  Offset symbolCenter(PlanPoint p) =>
      onWall(p.wall) +
      inward(p.wall.side) *
          (p.kind == PlanPointKind.simpleSwitch
              ? switchRadius + 1.5
              : outletSize * .35);

  /// Vão da janela e da porta, atravessando a parede.
  Rect get windowGap => Rect.fromLTRB(room.left + windowFrom * scale, outer.top,
      room.left + windowTo * scale, room.top);
  Rect get doorGap => Rect.fromLTRB(room.left + doorHinge * scale, room.bottom,
      room.left + (doorHinge + BedroomPlanSpec.doorM) * scale, outer.bottom);

  /// Área varrida pela folha da porta.
  Rect get doorSwing => Rect.fromLTRB(doorGap.left,
      room.bottom - BedroomPlanSpec.doorM * scale, doorGap.right, room.bottom);

  /// Eletroduto que vem do QD, de fora do quarto até o ponto de luz.
  Offset get feedStart => Offset(room.left + feedM * scale, outer.bottom + 20);
  Path get feed => Path()
    ..moveTo(feedStart.dx, feedStart.dy)
    ..lineTo(light.dx, light.dy);

  /// Eletroduto do ponto de luz até [p], passando pelos pontos de controle.
  Path conduitTo(PlanPoint p) {
    final end = symbolCenter(p);
    final c = [for (final m in p.controls) at(m)];
    final path = Path()..moveTo(light.dx, light.dy);
    switch (c.length) {
      case 0:
        path.lineTo(end.dx, end.dy);
      case 1:
        path.quadraticBezierTo(c[0].dx, c[0].dy, end.dx, end.dy);
      default:
        path.cubicTo(c[0].dx, c[0].dy, c[1].dx, c[1].dy, end.dx, end.dy);
    }
    return path;
  }

  Rect tagRect(PlanPoint p, Size size) {
    final anchor = at(p.tagAnchor);
    return Rect.fromLTWH(
      anchor.dx - (p.tagAlignment.x + 1) / 2 * size.width,
      anchor.dy - (p.tagAlignment.y + 1) / 2 * size.height,
      size.width,
      size.height,
    );
  }
}

/// Planta do quarto com a legenda embaixo. Animada, a corrente sai do QD pelos
/// eletrodutos e a lâmpada acende; parada, a lâmpada fica apagada.
class BedroomPlan extends StatelessWidget {
  const BedroomPlan({
    super.key,
    required this.progress,
    required this.energized,
  });

  /// Ciclo de 0 a 1 que anda a corrente (o controlador do cartão).
  final Animation<double> progress;
  final bool energized;

  @override
  Widget build(BuildContext context) {
    // A descrição completa fica no Semantics do cartão.
    return ExcludeSemantics(
      child: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: BedroomPlanLayout.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) => SizedBox(
                  height: BedroomPlanLayout(constraints.maxWidth).height,
                  child: CustomPaint(
                    painter: BedroomPlanPainter(
                      progress: progress,
                      energized: energized,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _Legend(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  static const _style = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 11.5,
    height: 1.3,
    color: AppColors.muted,
  );

  @override
  Widget build(BuildContext context) {
    // Flexible: com fonte ampliada, o texto quebra em vez de vazar.
    Widget item(PlanSymbol symbol, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlanSymbolIcon(symbol, size: 16),
            const SizedBox(width: 6),
            Flexible(child: Text(text, style: _style)),
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlanSymbolIcon(PlanSymbol.ceilingLight, size: 16),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Ponto de luz no teto: potência (VA) em cima; circuito e '
                'comando embaixo',
                style: _style,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            item(PlanSymbol.simpleSwitch, 'Interruptor simples'),
            item(PlanSymbol.lowOutlet, 'TUG baixa (uso geral)'),
            item(PlanSymbol.highOutlet, 'TUE alta (uso específico)'),
            item(PlanSymbol.conduit, 'Eletroduto'),
          ],
        ),
      ],
    );
  }
}

/// Desenha a planta. Recebe o progresso pelo `repaint:` e guarda geometria e
/// textos entre quadros, já que só a posição da corrente muda.
class BedroomPlanPainter extends CustomPainter {
  BedroomPlanPainter({required this.progress, required this.energized})
      : super(repaint: energized ? progress : null);

  final Animation<double> progress;
  final bool energized;

  /// Distância entre as cargas que andam pelo eletroduto.
  static const _spacing = 26.0;

  BedroomPlanLayout? _layout;
  late List<({Path path, PathMetric metric, double startsAt})> _conduits;
  final _texts = <String, TextPainter>{};

  BedroomPlanLayout _layoutFor(Size size) {
    final cached = _layout;
    if (cached != null && cached.width == size.width) return cached;
    final l = BedroomPlanLayout(size.width);
    final feed = l.feed;
    final feedLength = feed.computeMetrics().first.length;
    _conduits = [
      for (final path in [feed, ...BedroomPlanLayout.points.map(l.conduitTo)])
        (
          path: path,
          metric: path.computeMetrics().first,
          // Os ramais continuam a contagem do alimentador, para a corrente
          // parecer um fluxo só, do QD até cada ponto.
          startsAt: identical(path, feed) ? 0.0 : feedLength,
        ),
    ];
    return _layout = l;
  }

  TextPainter _text(
    String text, {
    double size = 10.5,
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.text,
    double spacing = 0,
  }) =>
      _texts.putIfAbsent(
        '$text|$size|${weight.value}|${color.toARGB32()}|$spacing',
        () => TextPainter(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontFamilyFallback: AppFonts.fallback,
              fontSize: size,
              fontWeight: weight,
              color: color,
              letterSpacing: spacing,
              height: 1.15,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
      );

  @override
  void paint(Canvas canvas, Size size) {
    final l = _layoutFor(size);
    _text('Planta elétrica · quarto', size: 10, color: AppColors.muted)
        .paint(canvas, Offset.zero);
    _furniture(canvas, l);
    _walls(canvas, l);
    _dimensions(canvas, l);

    final light = l.light;
    final radius = l.lightRadius;
    if (energized) {
      final glow = Rect.fromCircle(center: light, radius: radius * 2.8);
      canvas.drawCircle(
        light,
        glow.width / 2,
        Paint()
          ..shader = RadialGradient(colors: [
            PlanColors.lit.withValues(alpha: .3),
            PlanColors.lit.withValues(alpha: 0),
          ]).createShader(glow),
      );
    }

    final conduit = PlanSymbols.conduit();
    for (final c in _conduits) {
      canvas.drawPath(c.path, conduit);
    }
    _feedArrival(canvas, l);
    if (energized) _current(canvas);

    PlanSymbols.ceilingLight(
      canvas,
      light,
      radius,
      line: PlanColors.symbol,
      fill: energized ? PlanColors.lit : AppColors.surface,
    );
    // Com a unidade escrita, o aluno não depende da legenda para ler "VA".
    final ink = energized ? AppColors.ink : AppColors.text;
    _centered(
        canvas,
        _text('${BedroomPlanSpec.lightVa} VA',
            size: 9.5, weight: FontWeight.w700, color: ink),
        light + Offset(0, -radius * .4));
    _centered(
        canvas,
        _text('${BedroomPlanSpec.lightCircuit}',
            size: 10, weight: FontWeight.w700, color: ink),
        light + Offset(-radius * .42, radius * .45));
    _centered(
        canvas,
        _text(BedroomPlanSpec.command,
            size: 10, weight: FontWeight.w700, color: ink),
        light + Offset(radius * .42, radius * .4));

    for (final p in BedroomPlanLayout.points) {
      _point(canvas, l, p);
    }
  }

  void _furniture(Canvas canvas, BedroomPlanLayout l) {
    final line = Paint()
      ..color = AppColors.muted.withValues(alpha: .4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final bed = l.rect(BedroomPlanLayout.bed);
    canvas.drawRRect(
        RRect.fromRectAndRadius(bed, const Radius.circular(3)), line);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            l.rect(BedroomPlanLayout.pillow), const Radius.circular(4)),
        line);
    // Dobra do lençol.
    final fold = bed.top + bed.height * .3;
    canvas.drawLine(Offset(bed.left, fold), Offset(bed.right, fold), line);
    for (final stand in BedroomPlanLayout.nightstands) {
      canvas.drawRect(l.rect(stand), line);
    }

    // Evaporadora do ar-condicionado, presa no alto da parede.
    final ac = l.rect(BedroomPlanLayout.airConditioner);
    canvas.drawRRect(RRect.fromRectAndRadius(ac, const Radius.circular(2)),
        line..color = AppColors.muted.withValues(alpha: .55));
    final label = _text('ar-cond.',
        size: 10, weight: FontWeight.w500, color: AppColors.muted);
    canvas
      ..save()
      ..translate(ac.center.dx, ac.center.dy)
      ..rotate(-math.pi / 2);
    label.paint(canvas, Offset(-label.width / 2, -label.height / 2));
    canvas.restore();
  }

  void _walls(Canvas canvas, BedroomPlanLayout l) {
    final band = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(l.outer)
      ..addRect(l.room);
    canvas.drawPath(band, Paint()..color = PlanColors.wallFill);
    final face = Paint()
      ..color = PlanColors.wall
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas
      ..drawRect(l.outer, face)
      ..drawRect(l.room, face);

    // Vãos: apaga a parede e marca os batentes.
    final window = l.windowGap;
    final door = l.doorGap;
    for (final gap in [window, door]) {
      canvas
        ..drawRect(
            Rect.fromLTRB(gap.left, gap.top - 1, gap.right, gap.bottom + 1),
            Paint()..color = AppColors.surface)
        ..drawLine(gap.topLeft, gap.bottomLeft, face)
        ..drawLine(gap.topRight, gap.bottomRight, face);
    }

    // Janela: as duas faces e o vidro no meio.
    final pane = Paint()
      ..color = PlanColors.wall
      ..strokeWidth = 1;
    canvas
      ..drawLine(window.topLeft, window.topRight, pane)
      ..drawLine(window.bottomLeft, window.bottomRight, pane)
      ..drawLine(
          window.centerLeft, window.centerRight, pane..strokeWidth = 1.8);

    // Porta aberta a 90°, com a dobradiça no canto e o arco de abertura.
    final hinge = Offset(door.left, l.room.bottom);
    final leaf = BedroomPlanSpec.doorM * l.scale;
    canvas
      ..drawLine(
          hinge,
          hinge - Offset(0, leaf),
          Paint()
            ..color = AppColors.muted
            ..strokeWidth = 2
            ..strokeCap = StrokeCap.round)
      ..drawArc(
          Rect.fromCircle(center: hinge, radius: leaf),
          -math.pi / 2,
          math.pi / 2,
          false,
          Paint()
            ..color = AppColors.muted.withValues(alpha: .7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
  }

  /// Cotas internas: a linha de chamada vai até a face interna da parede.
  void _dimensions(Canvas canvas, BedroomPlanLayout l) {
    final line = Paint()
      ..color = AppColors.muted
      ..strokeWidth = .9;
    final tick = Paint()
      ..color = AppColors.muted
      ..strokeWidth = 1.4;
    final room = l.room;

    final y = l.outer.top - 8;
    canvas.drawLine(Offset(room.left, y), Offset(room.right, y), line);
    for (final x in [room.left, room.right]) {
      canvas
        ..drawLine(Offset(x, y - 4), Offset(x, room.top), line)
        ..drawLine(Offset(x - 3, y + 3), Offset(x + 3, y - 3), tick);
    }
    final width = _text('${formatDecimal(BedroomPlanSpec.widthM, 2)} m');
    width.paint(
        canvas, Offset(room.center.dx - width.width / 2, y - 1 - width.height));

    final x = l.outer.left - 8;
    canvas.drawLine(Offset(x, room.top), Offset(x, room.bottom), line);
    for (final yy in [room.top, room.bottom]) {
      canvas
        ..drawLine(Offset(x - 4, yy), Offset(room.left, yy), line)
        ..drawLine(Offset(x - 3, yy + 3), Offset(x + 3, yy - 3), tick);
    }
    final depth = _text('${formatDecimal(BedroomPlanSpec.depthM, 2)} m');
    canvas
      ..save()
      ..translate(x - 1 - depth.height / 2, room.center.dy)
      ..rotate(-math.pi / 2);
    depth.paint(canvas, Offset(-depth.width / 2, -depth.height / 2));
    canvas.restore();
  }

  /// Seta e texto do eletroduto que chega do quadro de distribuição. A seta é
  /// aberta para não ser confundida com o triângulo cheio da tomada alta.
  void _feedArrival(Canvas canvas, BedroomPlanLayout l) {
    final x = l.feedStart.dx;
    final y = l.outer.bottom + 4;
    canvas.drawPath(
      Path()
        ..moveTo(x - 4.5, y + 6)
        ..lineTo(x, y)
        ..lineTo(x + 4.5, y + 6),
      Paint()
        ..color = PlanColors.symbol
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    // Sem a lista de circuitos aqui: contá-los nas etiquetas é a questão.
    _text('do QD', weight: FontWeight.w700)
        .paint(canvas, Offset(x + 8, l.outer.bottom + 5));
  }

  void _current(Canvas canvas) {
    final dot = Paint()..color = PlanColors.current;
    // Dois espaçamentos por ciclo: o laço fecha sem salto.
    final shift = progress.value * _spacing * 2;
    for (final c in _conduits) {
      for (var d = (shift - c.startsAt) % _spacing;
          d < c.metric.length;
          d += _spacing) {
        final position = c.metric.getTangentForOffset(d)?.position;
        if (position != null) canvas.drawCircle(position, 2.4, dot);
      }
    }
  }

  void _point(Canvas canvas, BedroomPlanLayout l, PlanPoint p) {
    final inward = BedroomPlanLayout.inward(p.wall.side);
    switch (p.kind) {
      case PlanPointKind.simpleSwitch:
        PlanSymbols.simpleSwitch(canvas, l.symbolCenter(p),
            BedroomPlanLayout.switchRadius, PlanColors.symbol);
      case PlanPointKind.lowOutlet || PlanPointKind.highOutlet:
        PlanSymbols.outlet(
          canvas,
          base: l.onWall(p.wall) + inward,
          inward: inward,
          size: BedroomPlanLayout.outletSize,
          high: p.kind == PlanPointKind.highOutlet,
          color: PlanColors.symbol,
          background: AppColors.surface,
        );
    }

    final value = _text(p.label,
        size: p.kind == PlanPointKind.simpleSwitch ? 12 : 10.5,
        weight: FontWeight.w700);
    final circuit = _text(p.circuitLabel, size: 10, color: AppColors.skyOnInk);
    final box = l.tagRect(
        p,
        Size(math.max(value.width, circuit.width),
            value.height + circuit.height));
    double left(TextPainter t) => switch (p.tagAlignment.x) {
          < 0 => box.left,
          > 0 => box.right - t.width,
          _ => box.center.dx - t.width / 2,
        };
    value.paint(canvas, Offset(left(value), box.top));
    circuit.paint(canvas, Offset(left(circuit), box.top + value.height));
  }

  static void _centered(Canvas canvas, TextPainter text, Offset center) =>
      text.paint(canvas, center - Offset(text.width / 2, text.height / 2));

  @override
  bool shouldRepaint(BedroomPlanPainter old) =>
      old.energized != energized || old.progress != progress;
}
