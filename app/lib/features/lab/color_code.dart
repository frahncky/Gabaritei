/// Código de cores de resistores de 4 faixas (sem Flutter, fácil de testar).
library;

import 'dart:math' as math;

/// Cores das faixas e o que cada uma vale em cada posição.
enum BandColor {
  preto('Preto', digit: 0, exponent: 0),
  marrom('Marrom', digit: 1, exponent: 1, tolerance: 1),
  vermelho('Vermelho', digit: 2, exponent: 2, tolerance: 2),
  laranja('Laranja', digit: 3, exponent: 3),
  amarelo('Amarelo', digit: 4, exponent: 4),
  verde('Verde', digit: 5, exponent: 5, tolerance: 0.5),
  azul('Azul', digit: 6, exponent: 6, tolerance: 0.25),
  violeta('Violeta', digit: 7, tolerance: 0.1),
  cinza('Cinza', digit: 8),
  branco('Branco', digit: 9),
  dourado('Dourado', exponent: -1, tolerance: 5),
  prata('Prata', exponent: -2, tolerance: 10);

  const BandColor(this.label, {this.digit, this.exponent, this.tolerance});

  final String label;

  /// Valor como 1ª ou 2ª faixa (dígito).
  final int? digit;

  /// Valor como 3ª faixa: quantos zeros (potência de 10).
  final int? exponent;

  /// Valor como 4ª faixa: tolerância em %.
  final double? tolerance;

  /// O primeiro dígito nunca é zero, então o preto não entra.
  static List<BandColor> get firstDigits =>
      values.where((c) => c.digit != null && c.digit != 0).toList();
  static List<BandColor> get digits =>
      values.where((c) => c.digit != null).toList();
  static List<BandColor> get multipliers =>
      values.where((c) => c.exponent != null).toList();
  static List<BandColor> get tolerances =>
      values.where((c) => c.tolerance != null).toList();
}

class ResistorBands {
  const ResistorBands({
    this.first = BandColor.marrom,
    this.second = BandColor.preto,
    this.multiplier = BandColor.vermelho,
    this.tolerance = BandColor.dourado,
  });

  final BandColor first;
  final BandColor second;
  final BandColor multiplier;
  final BandColor tolerance;

  /// Resistência nominal: dois dígitos × 10^multiplicador.
  double get ohms =>
      (first.digit! * 10 + second.digit!) *
      math.pow(10, multiplier.exponent!).toDouble();

  double get tolerancePercent => tolerance.tolerance!;

  double get minOhms => ohms * (1 - tolerancePercent / 100);
  double get maxOhms => ohms * (1 + tolerancePercent / 100);

  /// Compara só o valor nominal, com folga para arredondamento.
  bool matches(double target) => (ohms - target).abs() <= target * 1e-9;

  ResistorBands copyWith({
    BandColor? first,
    BandColor? second,
    BandColor? multiplier,
    BandColor? tolerance,
  }) =>
      ResistorBands(
        first: first ?? this.first,
        second: second ?? this.second,
        multiplier: multiplier ?? this.multiplier,
        tolerance: tolerance ?? this.tolerance,
      );
}

/// Valores comerciais usados nos desafios.
const resistorTargets = <double>[
  100, 220, 330, 470, 1000, 2200, 4700, 10000, 47000, 100000, 1000000, //
];

/// Resistência com prefixo e vírgula (ex.: 4700 → "4,7 kΩ", 0.47 → "0,47 Ω").
String formatOhms(double ohms) {
  final (value, unit) = ohms >= 1e6
      ? (ohms / 1e6, 'MΩ')
      : ohms >= 1e3
          ? (ohms / 1e3, 'kΩ')
          : (ohms, 'Ω');
  var text = value.toStringAsFixed(2);
  text = text.replaceFirst(RegExp(r'\.?0+$'), '');
  return '${text.replaceAll('.', ',')} $unit';
}
