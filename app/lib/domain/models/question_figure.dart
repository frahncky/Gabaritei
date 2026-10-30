/// Figuras didáticas com dados explícitos; o desenho não consulta o gabarito.
library;

enum FigureKind {
  seriesCircuit, parallelCircuit, mixedCircuit, waveform, phasor,
  truthTable, ladder, chart, blocks, bars, force, gears, lever,
  cylinder, robotArm, dimension, resistorBands, topology, flow,
  referenceTable,
}

enum CircuitSymbol { resistor, capacitor, inductor, diode }

class CircuitElement {
  const CircuitElement(this.label, {this.symbol = CircuitSymbol.resistor});
  final String label;
  final CircuitSymbol symbol;

  Map<String, dynamic> toJson() => {'label': label, 'symbol': symbol.name};
  factory CircuitElement.fromJson(Map<String, dynamic> json) => CircuitElement(
    json['label'] as String,
    symbol: CircuitSymbol.values.byName(json['symbol'] as String),
  );
}

class FigurePoint {
  const FigurePoint(this.x, this.y);
  final double x;
  final double y;
  List<double> toJson() => [x, y];
}

class FigureTrace {
  const FigureTrace(this.label, this.points);
  final String label;
  final List<FigurePoint> points;
  Map<String, dynamic> toJson() => {
    'label': label, 'points': [for (final p in points) p.toJson()],
  };
  factory FigureTrace.fromJson(Map<String, dynamic> json) => FigureTrace(
    json['label'] as String,
    [for (final p in json['points'] as List)
      FigurePoint((p[0] as num).toDouble(), (p[1] as num).toDouble())],
  );
}

class QuestionFigure {
  const QuestionFigure({
    required this.kind,
    required this.title,
    required this.description,
    this.sourceLabel = '',
    this.elements = const [],
    this.labels = const [],
    this.values = const [],
    this.headers = const [],
    this.rows = const [],
    this.traces = const [],
    this.xLabel = '',
    this.yLabel = '',
    this.xMin = 0,
    this.xMax = 1,
    this.yMin = 0,
    this.yMax = 1,
    this.feedback = false,
  });

  final FigureKind kind;
  final String title;
  final String description;
  final String sourceLabel;
  final List<CircuitElement> elements;
  final List<String> labels;
  final List<double> values;
  final List<String> headers;
  final List<List<String>> rows;
  final List<FigureTrace> traces;
  final String xLabel;
  final String yLabel;
  final double xMin, xMax, yMin, yMax;
  final bool feedback;

  Map<String, dynamic> toJson() => {
    'kind': kind.name, 'title': title, 'description': description,
    'sourceLabel': sourceLabel,
    'elements': [for (final e in elements) e.toJson()],
    'labels': labels, 'values': values, 'headers': headers, 'rows': rows,
    'traces': [for (final t in traces) t.toJson()],
    'xLabel': xLabel, 'yLabel': yLabel,
    'xMin': xMin, 'xMax': xMax, 'yMin': yMin, 'yMax': yMax,
    'feedback': feedback,
  };

  factory QuestionFigure.fromJson(Map<String, dynamic> json) => QuestionFigure(
    kind: FigureKind.values.byName(json['kind'] as String),
    title: json['title'] as String,
    description: json['description'] as String,
    sourceLabel: json['sourceLabel'] as String? ?? '',
    elements: [for (final e in json['elements'] as List? ?? [])
      CircuitElement.fromJson(Map<String, dynamic>.from(e as Map))],
    labels: (json['labels'] as List? ?? []).cast<String>(),
    values: [for (final v in json['values'] as List? ?? []) (v as num).toDouble()],
    headers: (json['headers'] as List? ?? []).cast<String>(),
    rows: [for (final row in json['rows'] as List? ?? []) (row as List).cast<String>()],
    traces: [for (final t in json['traces'] as List? ?? [])
      FigureTrace.fromJson(Map<String, dynamic>.from(t as Map))],
    xLabel: json['xLabel'] as String? ?? '',
    yLabel: json['yLabel'] as String? ?? '',
    xMin: (json['xMin'] as num? ?? 0).toDouble(),
    xMax: (json['xMax'] as num? ?? 1).toDouble(),
    yMin: (json['yMin'] as num? ?? 0).toDouble(),
    yMax: (json['yMax'] as num? ?? 1).toDouble(),
    feedback: json['feedback'] as bool? ?? false,
  );
}
