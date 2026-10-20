/// Cálculos do Laboratório de eletricidade (sem Flutter, fáceis de testar).
library;

enum LabMode {
  ohm(
    tab: 'Ohm',
    title: 'Lei de Ohm',
    formula: 'I = V ÷ R',
    idea: 'A corrente cresce com a tensão e cai com a resistência',
    tip:
        'Dobre a tensão e a corrente dobra; dobre a resistência e ela cai pela metade',
  ),
  serie(
    tab: 'Série',
    title: 'Resistores em série',
    formula: 'Req = R₁ + R₂',
    idea: 'A mesma corrente atravessa os dois resistores',
    tip: 'A tensão da fonte se divide: o resistor maior fica com a maior parte',
  ),
  paralelo(
    tab: 'Paralelo',
    title: 'Resistores em paralelo',
    formula: '1/Req = 1/R₁ + 1/R₂',
    idea: 'A corrente se divide entre os caminhos',
    tip: 'O caminho de menor resistência leva mais corrente',
  ),
  potencia(
    tab: 'Potência',
    title: 'Potência elétrica',
    formula: 'P = V × I = V² ÷ R',
    idea: 'Mais potência, mais luz e mais calor',
    tip: 'Acima da potência nominal, a lâmpada queima',
  );

  const LabMode({
    required this.tab,
    required this.title,
    required this.formula,
    required this.idea,
    required this.tip,
  });

  final String tab;
  final String title;
  final String formula;
  final String idea;
  final String tip;

  /// Na aba de potência o que importa são os watts; nas outras, os ampères.
  bool get watchesPower => this == potencia;

  /// Limite de segurança: fusível (A) ou potência nominal da lâmpada (W).
  double get limit => watchesPower ? LabLimits.lampWatts : LabLimits.fuseAmps;
}

class LabLimits {
  LabLimits._();

  static const fuseAmps = 3.0;
  static const lampWatts = 15.0;
  static const maxVolts = 24.0;
  static const minOhms = 5.0;
  static const maxOhms = 100.0;
}

class CircuitInput {
  const CircuitInput({this.volts = 12, this.r1 = 20, this.r2 = 40});

  final double volts;
  final double r1;
  final double r2;

  CircuitInput copyWith({double? volts, double? r1, double? r2}) =>
      CircuitInput(
        volts: volts ?? this.volts,
        r1: r1 ?? this.r1,
        r2: r2 ?? this.r2,
      );
}

enum LabStatus { off, safe, near, over }

class CircuitReading {
  const CircuitReading._({
    required this.mode,
    required this.total,
    required this.i1,
    required this.i2,
    required this.v1,
    required this.v2,
    required this.req,
    required this.power,
  });

  factory CircuitReading.solve(LabMode mode, CircuitInput input) {
    final v = input.volts;
    switch (mode) {
      case LabMode.ohm:
      case LabMode.potencia:
        final i = v / input.r1;
        return CircuitReading._(
          mode: mode,
          total: i,
          i1: i,
          i2: 0,
          v1: v,
          v2: 0,
          req: input.r1,
          power: v * i,
        );
      case LabMode.serie:
        final req = input.r1 + input.r2;
        final i = v / req;
        return CircuitReading._(
          mode: mode,
          total: i,
          i1: i,
          i2: i,
          v1: i * input.r1,
          v2: i * input.r2,
          req: req,
          power: v * i,
        );
      case LabMode.paralelo:
        final i1 = v / input.r1;
        final i2 = v / input.r2;
        return CircuitReading._(
          mode: mode,
          total: i1 + i2,
          i1: i1,
          i2: i2,
          v1: v,
          v2: v,
          req: input.r1 * input.r2 / (input.r1 + input.r2),
          power: v * (i1 + i2),
        );
    }
  }

  final LabMode mode;

  /// Corrente que sai da fonte (A).
  final double total;

  /// Corrente em R₁ e R₂ (A).
  final double i1;
  final double i2;

  /// Tensão sobre R₁ e R₂ (V).
  final double v1;
  final double v2;

  /// Resistência equivalente (Ω).
  final double req;

  /// Potência total (W).
  final double power;

  /// Grandeza vigiada: watts na aba de potência, ampères nas outras.
  double get watched => mode.watchesPower ? power : total;

  LabStatus get status {
    if (watched < 0.001) return LabStatus.off;
    final ratio = watched / mode.limit;
    if (ratio > 1) return LabStatus.over;
    if (ratio > 0.8) return LabStatus.near;
    return LabStatus.safe;
  }
}
