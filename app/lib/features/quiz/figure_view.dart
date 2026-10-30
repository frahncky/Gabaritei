import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/models/question_figure.dart';

/// Figuras estáticas, responsivas e ligadas aos dados da questão.
class QuestionFigureView extends StatelessWidget {
  const QuestionFigureView({super.key, required this.figure});
  final QuestionFigure figure;

  @override
  Widget build(BuildContext context) {
    final table = figure.kind == FigureKind.truthTable ||
        figure.kind == FigureKind.referenceTable;
    return Card(
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFamilyFallback: ['GabariteiTechnical']),
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(figure.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (table)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                columns: [for (final header in figure.headers)
                  DataColumn(label: Text(header))],
                rows: [for (final row in figure.rows)
                  DataRow(cells: [for (final value in row) DataCell(Text(value))])],
              ),
            )
          else
            Semantics(
              label: figure.description,
              image: true,
              child: AspectRatio(
                aspectRatio: 1.5,
                child: CustomPaint(painter: FigurePainter(figure)),
              ),
            ),
          if (figure.traces.isNotEmpty)
            Wrap(spacing: 14, runSpacing: 6, children: [
              for (var i = 0; i < figure.traces.length; i++)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(
                    color: _colors[i % _colors.length], shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(figure.traces[i].label,
                    style: TextStyle(color: _colors[i % _colors.length])),
                ]),
            ]),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Descrição da figura'),
            children: [Align(alignment: Alignment.centerLeft,
              child: Padding(padding: const EdgeInsets.only(bottom: 12),
                child: Text(figure.description)))],
          ),
        ]),
      ),
      ),
    );
  }
}

const _colors = [AppColors.skyOnInk, AppColors.amber, AppColors.success];

class FigurePainter extends CustomPainter {
  const FigurePainter(this.figure);
  final QuestionFigure figure;

  Paint get ink => Paint()..color = AppColors.skyOnInk..strokeWidth = 2
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    switch (figure.kind) {
      case FigureKind.seriesCircuit:
      case FigureKind.parallelCircuit:
      case FigureKind.mixedCircuit:
        _circuit(canvas, size);
      case FigureKind.waveform:
      case FigureKind.chart:
        _chart(canvas, size);
      case FigureKind.phasor:
        _phasor(canvas, size);
      case FigureKind.ladder:
        _ladder(canvas, size);
      case FigureKind.bars:
        _bars(canvas, size);
      case FigureKind.gears:
      case FigureKind.lever:
      case FigureKind.force:
      case FigureKind.cylinder:
      case FigureKind.robotArm:
      case FigureKind.dimension:
        _mechanical(canvas, size);
      case FigureKind.resistorBands:
        _bands(canvas, size);
      case FigureKind.topology:
        _topology(canvas, size);
      case FigureKind.blocks:
      case FigureKind.flow:
        _blocks(canvas, size);
      case FigureKind.truthTable:
      case FigureKind.referenceTable:
        break; // Tabelas são widgets nativos, com células acessíveis.
    }
  }

  void _text(Canvas c, String text, Offset center, {double width = 100,
      Color color = AppColors.text, double fontSize = 11}) {
    final p = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: color,
          fontSize: fontSize, fontFamily: 'GabariteiTechnical', fontWeight: FontWeight.w500)),
      textDirection: TextDirection.ltr, textAlign: TextAlign.center,
    )..layout(maxWidth: width);
    p.paint(c, center - Offset(p.width / 2, p.height / 2));
  }

  void _arrow(Canvas c, Offset from, Offset to, {Color color = AppColors.amber}) {
    final p = Paint()..color = color..strokeWidth = 2;
    c.drawLine(from, to, p);
    final angle = math.atan2(to.dy - from.dy, to.dx - from.dx);
    for (final side in [-1, 1]) {
      c.drawLine(to, to - Offset(math.cos(angle + side * .45),
          math.sin(angle + side * .45)) * 8, p);
    }
  }

  void _box(Canvas c, String label, Offset center, {double width = 76,
      double height = 42}) {
    final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width, height: height),
        const Radius.circular(6));
    c.drawRRect(rect, Paint()..color = AppColors.blueSoft);
    c.drawRRect(rect, ink);
    _text(c, label, center, width: width - 8);
  }

  void _element(Canvas c, Offset center, CircuitElement e,
      {bool vertical = false, bool compact = false}) {
    c.save();
    c.translate(center.dx, center.dy);
    if (vertical) c.rotate(math.pi / 2);
    c.drawRect(const Rect.fromLTWH(-25, -14, 50, 28),
        Paint()..color = AppColors.surface);
    final p = ink;
    switch (e.symbol) {
      case CircuitSymbol.resistor:
        c.drawLine(const Offset(-25, 0), const Offset(-19, 0), p);
        c.drawRect(const Rect.fromLTWH(-19, -9, 38, 18), p);
        c.drawLine(const Offset(19, 0), const Offset(25, 0), p);
      case CircuitSymbol.capacitor:
        c.drawLine(const Offset(-25, 0), const Offset(-5, 0), p);
        c.drawLine(const Offset(-5, -12), const Offset(-5, 12), p);
        c.drawLine(const Offset(5, -12), const Offset(5, 12), p);
        c.drawLine(const Offset(5, 0), const Offset(25, 0), p);
      case CircuitSymbol.inductor:
        final path = Path()..moveTo(-25, 0)..lineTo(-20, 0);
        for (var x = -20.0; x < 20; x += 10) {
          path.cubicTo(x, -15, x + 10, -15, x + 10, 0);
        }
        path.lineTo(25, 0);
        c.drawPath(path, p);
      case CircuitSymbol.diode:
        c.drawLine(const Offset(-25, 0), const Offset(-12, 0), p);
        c.drawPath(Path()..moveTo(-12, -12)..lineTo(10, 0)
          ..lineTo(-12, 12)..close(), p);
        c.drawLine(const Offset(10, -12), const Offset(10, 12), p);
        c.drawLine(const Offset(10, 0), const Offset(25, 0), p);
    }
    c.restore();
    _text(c, e.label, center + (vertical ? Offset(compact ? -36 : -44, 0) : const Offset(0, -25)),
        width: vertical ? (compact ? 50 : 65) : 90, fontSize: compact ? 10 : 11);
  }

  void _circuit(Canvas c, Size s) {
    final top = s.height * .26, bottom = s.height * .84;
    const left = 30.0;
    final mid = (top + bottom) / 2;
    c.drawLine(Offset(left, top), Offset(left, mid - 17), ink);
    c.drawLine(Offset(left, mid + 17), Offset(left, bottom), ink);
    c.drawCircle(Offset(left, mid), 17, ink);
    if (figure.alternatingSource) {
      final path = Path();
      for (var i=0; i<=24; i++) {
        final x = left - 11 + 22*i/24;
        final y = mid - 6*math.sin(2*math.pi*i/24);
        if (i==0) { path.moveTo(x,y); } else { path.lineTo(x,y); }
      }
      c.drawPath(path, ink);
    } else {
      _text(c, '+', Offset(left, mid - 6), width: 24);
      _text(c, '−', Offset(left, mid + 7), width: 24);
    }
    _text(c, figure.sourceLabel, Offset(46, top - 29), width: 88);
    final elements = figure.elements;
    if (figure.kind == FigureKind.seriesCircuit) {
      final right = s.width - 20;
      c.drawLine(Offset(left, top), Offset(right, top), ink);
      c.drawLine(Offset(right, top), Offset(right, bottom), ink);
      c.drawLine(Offset(right, bottom), Offset(left, bottom), ink);
      for (var i = 0; i < elements.length; i++) {
        final x = 96 + (right - 112) * (i + .5) / elements.length;
        _element(c, Offset(x, top), elements[i]);
      }
    } else {
      final mixed = figure.kind == FigureKind.mixedCircuit;
      final branchElements = mixed ? elements.skip(1).toList() : elements;
      final start = mixed ? s.width * .63
          : s.width * (branchElements.length > 2 ? .40 : .46);
      final end = s.width - 26;
      c.drawLine(Offset(left, top), Offset(end, top), ink);
      c.drawLine(Offset(left, bottom), Offset(end, bottom), ink);
      if (mixed) _element(c, Offset(s.width * .35, top), elements.first);
      for (var i = 0; i < branchElements.length; i++) {
        final x = branchElements.length == 1 ? end
            : start + (end - start) * i / (branchElements.length - 1);
        c.drawLine(Offset(x, top), Offset(x, bottom), ink);
        _element(c, Offset(x, mid), branchElements[i],
            vertical: true, compact: branchElements.length > 2);
        c.drawCircle(Offset(x, top), 3, Paint()..color = AppColors.skyOnInk);
        c.drawCircle(Offset(x, bottom), 3, Paint()..color = AppColors.skyOnInk);
      }
    }
    _text(c, 'Esquema de conexões', Offset(s.width / 2, s.height - 8),
        color: AppColors.muted, fontSize: 10);
  }

  void _chart(Canvas c, Size s) {
    final rect = Rect.fromLTRB(48, 25, s.width - 16, s.height - 43);
    Offset point(FigurePoint p) => Offset(
      rect.left + (p.x - figure.xMin) / (figure.xMax - figure.xMin) * rect.width,
      rect.bottom - (p.y - figure.yMin) / (figure.yMax - figure.yMin) * rect.height);
    final grid = Paint()..color = AppColors.line..strokeWidth = 1;
    String number(double n) => n.abs() < .001 ? '0'
      : (n - n.round()).abs() < .001 ? '${n.round()}' : n.toStringAsFixed(1).replaceAll('.', ',');
    for (var i = 0; i <= 4; i++) {
      final x = rect.left + rect.width * i / 4;
      c.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), grid);
      _text(c, number(figure.xMin + (figure.xMax - figure.xMin) * i / 4),
        Offset(x, rect.bottom + 12), width: 45, fontSize: 10);
    }
    for (final value in verticalTicks(figure)) {
      final y = rect.bottom - (value-figure.yMin)/(figure.yMax-figure.yMin)*rect.height;
      c.drawLine(Offset(rect.left,y), Offset(rect.right,y), grid);
      _text(c, number(value), Offset(22,y), width: 42, fontSize: 10);
    }
    c.drawRect(rect, ink);
    c.save(); c.clipRect(rect.inflate(1));
    for (var i = 0; i < figure.traces.length; i++) {
      final path = Path();
      final points = figure.traces[i].points;
      for (var j = 0; j < points.length; j++) {
        final p = point(points[j]);
        if (j == 0) { path.moveTo(p.dx, p.dy); }
        else { path.lineTo(p.dx, p.dy); }
      }
      c.drawPath(path, Paint()..color = _colors[i % _colors.length]
        ..strokeWidth = 2.3..style = PaintingStyle.stroke);
    }
    c.restore();
    _text(c, figure.yLabel, Offset(s.width / 2, 9), width: s.width - 20);
    _text(c, figure.xLabel, Offset(s.width / 2, s.height - 7), width: s.width - 20);
  }

  static List<double> verticalTicks(QuestionFigure figure) =>
    figure.yLabel.toLowerCase().contains('lógic')
        ? <double>[0,1]
        : figure.yLabel.toLowerCase().contains('amplitude normalizada')
          ? <double>[-1,0,1]
          : [for (var i=0; i<=4; i++) figure.yMin + (figure.yMax-figure.yMin)*i/4];

  void _phasor(Canvas c, Size s) {
    final r = figure.values[0], x = figure.values[1];
    final origin = Offset(38, x >= 0 ? s.height - 38 : 36);
    final scale = math.min((s.width - 100) / r.abs(), (s.height - 90) / x.abs());
    final elbow = origin + Offset(r * scale, 0);
    final tip = elbow + Offset(0, -x * scale);
    _arrow(c, origin, elbow, color: AppColors.skyOnInk);
    _arrow(c, elbow, tip, color: AppColors.success);
    _arrow(c, origin, tip);
    _text(c, figure.labels[0], (origin + elbow) / 2 + const Offset(0, 17), width: 130);
    _text(c, figure.labels[1], (elbow + tip) / 2 + const Offset(30, 0), width: 58);
    _text(c, figure.labels[2], (origin + tip) / 2 + const Offset(-16, -14), width: 110);
  }

  void _ladder(Canvas c, Size s) {
    final left = 16.0, right = s.width - 20;
    c.drawLine(Offset(left, 24), Offset(left, s.height - 22), ink);
    c.drawLine(Offset(right, 24), Offset(right, s.height - 22), ink);
    final join = s.width - 72;
    final count = figure.rows.length;
    for (var row = 0; row < count; row++) {
      final y = s.height * (row + 1) / (count + 1);
      c.drawLine(Offset(left, y), Offset(join, y), ink);
      final contacts = figure.rows[row];
      for (var i = 0; i < contacts.length; i++) {
        final x = left + (join - left) * (i + 1) / (contacts.length + 1);
        c.drawRect(Rect.fromCenter(center: Offset(x, y), width: 26, height: 25),
            Paint()..color = AppColors.surface);
        c.drawLine(Offset(x - 8, y - 11), Offset(x - 8, y + 11), ink);
        c.drawLine(Offset(x + 8, y - 11), Offset(x + 8, y + 11), ink);
        if (contacts[i].startsWith('!')) {
          c.drawLine(Offset(x - 11, y + 9), Offset(x + 11, y - 9), ink);
        }
        _text(c, contacts[i].replaceAll('!', ''), Offset(x, y - 24), width: 55);
      }
    }
    final firstY = s.height / (count + 1), lastY = s.height * count / (count + 1);
    c.drawLine(Offset(join, firstY), Offset(join, lastY), ink);
    final y = s.height / 2;
    c.drawLine(Offset(join, y), Offset(right, y), ink);
    final coil = Offset(right - 24, y);
    c.drawRect(Rect.fromCenter(center: coil, width: 28, height: 30),
        Paint()..color = AppColors.surface);
    _text(c, '( )', coil, fontSize: 22, width: 32);
    _text(c, figure.labels.first, coil + const Offset(0, -27), width: 55);
  }

  void _blocks(Canvas c, Size s) {
    final n = figure.labels.length;
    final width = math.min(82.0, (s.width - 14 * (n - 1)) / n);
    final y = s.height * .48;
    final centers = [for (var i = 0; i < n; i++)
      Offset(width / 2 + i * (s.width - width) / math.max(1, n - 1), y)];
    for (var i = 0; i < n; i++) {
      _box(c, figure.labels[i], centers[i], width: width, height: 54);
      if (i > 0) {
        _arrow(c, centers[i - 1] + Offset(width / 2, 0),
            centers[i] - Offset(width / 2, 0));
      }
    }
    if (figure.feedback && n > 1) {
      final backY = s.height * .84;
      final path = Path()..moveTo(centers.last.dx, y + 28)
        ..lineTo(centers.last.dx, backY)..lineTo(centers.first.dx, backY)
        ..lineTo(centers.first.dx, y + 28);
      c.drawPath(path, ink);
      _arrow(c, Offset(centers.first.dx, backY), centers.first + const Offset(0, 28));
      _text(c, 'Realimentação', Offset(s.width / 2, backY + 13), width: 150);
    }
  }

  void _bars(Canvas c, Size s) {
    final max = figure.values.reduce(math.max);
    final baseline = s.height - 47;
    for (var i = 0; i < figure.values.length; i++) {
      final x = s.width * (i + .5) / figure.values.length;
      final height = (baseline - 30) * figure.values[i] / max;
      c.drawRect(Rect.fromLTWH(x - 23, baseline - height, 46, height),
          Paint()..color = _colors[i % _colors.length]);
      final value = figure.values[i];
      final number = value == value.roundToDouble() ? '${value.toInt()}'
          : value.toStringAsFixed(1).replaceAll('.', ',');
      _text(c, '$number ${figure.yLabel}',
          Offset(x, baseline - height - 12), width: 100);
      _text(c, figure.labels[i], Offset(x, baseline + 22), width: s.width / figure.values.length - 8);
    }
    c.drawLine(Offset(12, baseline), Offset(s.width - 12, baseline), ink);
  }

  void _mechanical(Canvas c, Size s) {
    final w = s.width, h = s.height;
    switch (figure.kind) {
      case FigureKind.gears:
        final z1 = figure.values[0], z2 = figure.values[1];
        final scale = math.min((w - 45) / (2 * (z1 + z2)), (h - 100) / (2 * math.max(z1, z2)));
        final r1 = z1 * scale, r2 = z2 * scale;
        final a = Offset((w - 2 * (r1 + r2)) / 2 + r1, h / 2);
        final b = a + Offset(r1 + r2, 0);
        for (final item in [(a, r1, z1.toInt()), (b, r2, z2.toInt())]) {
          final path = Path();
          for (var i = 0; i <= item.$3 * 4; i++) {
            final angle = 2 * math.pi * i / (item.$3 * 4);
            final radius = item.$2 - (i % 4 < 2 ? 2 : 0);
            final p = item.$1 + Offset(math.cos(angle), math.sin(angle)) * radius;
            if (i == 0) { path.moveTo(p.dx, p.dy); } else { path.lineTo(p.dx, p.dy); }
          }
          c.drawPath(path..close(), ink);
          c.drawCircle(item.$1, 4, ink);
        }
        _text(c, figure.labels[0], Offset(w / 2, 14), width: w - 12);
        _text(c, figure.labels[1], Offset(w / 2, h - 14), width: w - 12);
      case FigureKind.lever:
        final a = Offset(35, h * .55), b = Offset(w - 35, h * .55);
        c.drawLine(a, b, ink);
        c.drawPath(Path()..moveTo(a.dx, a.dy)..lineTo(a.dx - 13, a.dy + 22)
          ..lineTo(a.dx + 13, a.dy + 22)..close(), ink);
        _arrow(c, b - const Offset(0, 65), b);
        _text(c, figure.labels[0], b - const Offset(25, 79), width: 100);
        _text(c, figure.labels[1], Offset(w / 2, a.dy + 40), width: 160);
      case FigureKind.force:
        c.drawRect(Rect.fromLTWH(65, h / 2 - 24, w - 130, 48), ink);
        _arrow(c, Offset(66, h / 2), Offset(10, h / 2));
        _arrow(c, Offset(w - 66, h / 2), Offset(w - 10, h / 2));
        _text(c, figure.labels[0], Offset(w / 2, h / 2 - 48), width: 180);
        _text(c, figure.labels[1], Offset(w / 2, h / 2 + 47), width: 180);
      case FigureKind.cylinder:
        c.drawRect(Rect.fromLTWH(45, h * .32, w * .6, h * .36), ink);
        final piston = w * .59;
        c.drawLine(Offset(piston, h * .32), Offset(piston, h * .68), ink);
        c.drawLine(Offset(piston, h * .5), Offset(w - 20, h * .5), ink);
        _arrow(c, Offset(55, h * .5), Offset(105, h * .5));
        _text(c, figure.labels[0], Offset(w * .4, h * .19), width: 200);
        _text(c, figure.labels[1], Offset(w * .4, h * .82), width: 200);
        _text(c, 'F = ?', Offset(w - 40, h * .38), width: 70);
      case FigureKind.robotArm:
        final points = [Offset(35, h - 35), Offset(w * .46, 50), Offset(w - 30, h * .55)];
        for (var i = 1; i < points.length; i++) {
          c.drawLine(points[i-1], points[i], ink..strokeWidth = 7);
        }
        for (var i = 0; i < points.length; i++) {
          c.drawCircle(points[i], 11, Paint()..color = AppColors.amber);
          _text(c, figure.labels[i], points[i] + const Offset(0, -25), width: 90);
        }
      case FigureKind.dimension:
        c.drawRect(Rect.fromLTWH(35, h * .3, w - 70, h * .26), ink);
        _arrow(c, Offset(36, h * .7), Offset(w - 36, h * .7));
        _arrow(c, Offset(w - 36, h * .7), Offset(36, h * .7));
        _text(c, figure.labels[0], Offset(w / 2, h * .17), width: w - 10);
        _text(c, figure.labels[1], Offset(w / 2, h * .83), width: w - 10);
      default: break;
    }
  }

  void _bands(Canvas c, Size s) {
    final body = RRect.fromRectAndRadius(Rect.fromLTWH(35, s.height * .37,
        s.width - 70, 48), const Radius.circular(18));
    c.drawLine(Offset(8, body.outerRect.center.dy), Offset(s.width - 8, body.outerRect.center.dy), ink);
    c.drawRRect(body, Paint()..color = const Color(0xFFD6B47B));
    const colors = {'marrom': Color(0xFF80502B), 'preto': Color(0xFF111827),
      'vermelho': Color(0xFFDC2626), 'dourado': Color(0xFFEAB308),
      'amarelo': Color(0xFFFACC15), 'violeta': Color(0xFF7C3AED),
      'laranja': Color(0xFFF97316), 'verde': Color(0xFF16A34A)};
    for (var i = 0; i < figure.labels.length; i++) {
      final x = 60 + (s.width - 120) * i / math.max(1, figure.labels.length - 1);
      c.drawRect(Rect.fromLTWH(x - 6, body.top, 12, 48),
        Paint()..color = colors[figure.labels[i]] ?? AppColors.muted);
      _text(c, figure.labels[i], Offset(x, body.bottom + 20), width: 70, fontSize: 10);
    }
  }

  void _topology(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final positions = [Offset(s.width / 2, 25), Offset(46, s.height - 28),
      Offset(s.width - 46, s.height - 28)];
    for (var i = 1; i < figure.labels.length; i++) {
      final point = positions[i - 1];
      c.drawLine(center, point, ink);
      _box(c, figure.labels[i], point, width: 86, height: 36);
    }
    _box(c, figure.labels.first, center, width: 82, height: 40);
  }

  @override
  bool shouldRepaint(FigurePainter oldDelegate) => oldDelegate.figure != figure;
}
