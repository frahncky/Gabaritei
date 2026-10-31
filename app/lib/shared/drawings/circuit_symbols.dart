import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Cores dos esquemas elétricos, as mesmas no laboratório e nas questões.
///
/// Só a energia ganha cor quente: condutores e componentes ficam em tons
/// neutros e a corrente (e a lâmpada acesa) em âmbar.
abstract final class CircuitColors {
  /// Condutor sem destaque.
  static const wire = AppColors.muted;

  /// Contorno dos componentes e textos principais.
  static const component = AppColors.text;

  /// Cargas andando no sentido convencional da corrente.
  static const current = AppColors.amberText;

  /// Valores secundários (tensão num resistor, corrente num ramo).
  static const value = AppColors.skyOnInk;
}

/// Símbolos de circuito da IEC 60617 (a norma ensinada nos cursos técnicos):
/// resistor em retângulo, fonte CC com placa longa (+) e curta (−), lâmpada
/// com X e nó com ponto cheio.
abstract final class CircuitSymbols {
  /// Traço de condutor.
  static Paint wire({Color color = CircuitColors.wire, double width = 2.4}) =>
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

  /// Resistor: retângulo vazado sobre o fio. O fundo cobre o condutor e as
  /// cargas que passam por baixo.
  static void resistor(
    Canvas canvas,
    Offset center, {
    required bool horizontal,
    required Color background,
    double length = 46,
    double thickness = 16,
    Color color = CircuitColors.component,
    double strokeWidth = 2,
  }) {
    final body = horizontal
        ? Rect.fromCenter(center: center, width: length, height: thickness)
        : Rect.fromCenter(center: center, width: thickness, height: length);
    canvas
      ..drawRect(body, Paint()..color = background)
      ..drawRect(
        body,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
  }

  /// Fonte de tensão contínua num fio vertical: placa longa e fina em cima
  /// (+) e curta e grossa embaixo (−), separadas por [gap]. O fio deve parar
  /// a `gap / 2 + 4` do centro.
  static void cell(
    Canvas canvas,
    Offset center, {
    double gap = 14,
    double width = 26,
    Color color = CircuitColors.component,
  }) {
    canvas
      ..drawLine(
        center + Offset(-width / 2, -gap / 2),
        center + Offset(width / 2, -gap / 2),
        Paint()
          ..color = color
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      )
      ..drawLine(
        center + Offset(-width * .27, gap / 2),
        center + Offset(width * .27, gap / 2),
        Paint()
          ..color = color
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
  }

  /// Lâmpada: círculo com X. O filamento esquenta de [CircuitColors.wire]
  /// até [CircuitColors.current] conforme [glow] (0 a 1).
  static void lamp(
    Canvas canvas,
    Offset center,
    double radius, {
    required Color background,
    double glow = 0,
  }) {
    canvas
      ..drawCircle(center, radius, Paint()..color = background)
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = CircuitColors.component
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2,
      );
    final cross = Paint()
      ..color = Color.lerp(
          CircuitColors.wire, CircuitColors.current, glow.clamp(0.0, 1.0))!
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final d = radius * math.sqrt1_2;
    canvas
      ..drawLine(center + Offset(-d, -d), center + Offset(d, d), cross)
      ..drawLine(center + Offset(-d, d), center + Offset(d, -d), cross);
  }

  /// Nó (ligação entre três ou mais condutores).
  static void node(Canvas canvas, Offset at,
          {double radius = 4, Color color = CircuitColors.component}) =>
      canvas.drawCircle(at, radius, Paint()..color = color);

  /// Ponta de seta cheia em [tip], apontando na direção [direction].
  static void arrowHead(Canvas canvas, Offset tip, Offset direction,
      {double size = 7, Color color = CircuitColors.value}) {
    final d = direction / direction.distance;
    final n = Offset(-d.dy, d.dx);
    final back = tip - d * size;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo((back + n * size * .55).dx, (back + n * size * .55).dy)
        ..lineTo((back - n * size * .55).dx, (back - n * size * .55).dy)
        ..close(),
      Paint()..color = color,
    );
  }

  /// Desenha as cargas da corrente ao longo de [metric] (ver [CurrentDots]).
  static void current(
    Canvas canvas,
    PathMetric metric, {
    required double shift,
    double spacing = 18,
    double startsAt = 0,
    double radius = 2.6,
    Color color = CircuitColors.current,
  }) {
    final dot = Paint()..color = color;
    for (final d in CurrentDots.offsets(metric.length,
        shift: shift, spacing: spacing, startsAt: startsAt)) {
      final position = metric.getTangentForOffset(d)?.position;
      if (position != null) canvas.drawCircle(position, radius, dot);
    }
  }
}

/// Posição das cargas num trecho de condutor.
abstract final class CurrentDots {
  /// Distâncias, desde o início do trecho, das cargas igualmente espaçadas
  /// que andaram [shift] desde o começo do circuito. [startsAt] é onde o
  /// trecho começa nessa contagem, para que ramos ligados em sequência pareçam
  /// um fluxo só. Andar um múltiplo de [spacing] devolve as mesmas posições:
  /// um ciclo de animação que avança `n * spacing` fecha sem salto.
  static Iterable<double> offsets(
    double length, {
    required double shift,
    required double spacing,
    double startsAt = 0,
  }) sync* {
    for (var d = (shift - startsAt) % spacing; d < length; d += spacing) {
      yield d;
    }
  }
}

/// Texto desenhado num `CustomPainter`, na fonte do app e com a reserva de
/// glifos (Ω, →, ₁).
///
/// Os painters animados pedem os mesmos textos a cada quadro, e medir um
/// [TextPainter] custa caro: o resultado fica guardado em [DrawingTextCache].
/// Não chame `layout` nem `dispose` no objeto devolvido, ele é compartilhado.
TextPainter drawingText(
  String text, {
  double size = 12,
  FontWeight weight = FontWeight.w600,
  Color color = AppColors.text,
  bool italic = false,
}) =>
    DrawingTextCache.lookup(
      '$text|$size|${weight.value}|${color.toARGB32()}|$italic',
      () => TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontFamilyFallback: AppFonts.fallback,
            fontSize: size,
            fontWeight: weight,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color,
            height: 1.15,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(),
    );

/// Textos já medidos por [drawingText], do uso mais antigo ao mais recente.
///
/// Limitado a [capacity] porque leituras que mudam (ex.: "1,2 A") criam
/// textos novos o tempo todo. Esvazia quando as fontes do sistema mudam,
/// porque as medidas guardadas deixam de valer. Os descartados não recebem
/// `dispose`: um painter ainda pode estar com a referência no meio do quadro.
abstract final class DrawingTextCache {
  static const capacity = 256;

  static final _entries = <String, TextPainter>{};
  static bool _listening = false;

  /// Quantos textos estão guardados.
  static int get length => _entries.length;

  static TextPainter lookup(String key, TextPainter Function() create) {
    if (!_listening) {
      _listening = true;
      PaintingBinding.instance.systemFonts.addListener(clear);
    }
    // Tirar e pôr de volta deixa o mapa na ordem de uso.
    final hit = _entries.remove(key);
    if (hit != null) return _entries[key] = hit;
    if (_entries.length >= capacity) _entries.remove(_entries.keys.first);
    return _entries[key] = create();
  }

  static void clear() => _entries.clear();
}

/// Pinta [text] com o ponto [alignment] dele sobre [at] (ex.:
/// `Alignment.centerLeft` = o texto começa em [at], centrado na vertical).
void paintText(Canvas canvas, TextPainter text, Offset at,
    [Alignment alignment = Alignment.center]) {
  text.paint(
    canvas,
    at -
        Offset((alignment.x + 1) / 2 * text.width,
            (alignment.y + 1) / 2 * text.height),
  );
}
