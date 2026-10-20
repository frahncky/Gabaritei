/// Formatação de números e datas no padrão brasileiro, sem depender do
/// pacote `intl`.
library;

/// Número inteiro com ponto de milhar (ex.: 1240 → "1.240").
String formatNumber(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Fração de 0 a 1 como porcentagem inteira (ex.: 0.74 → "74%").
String formatPercent(double fraction) => '${(fraction * 100).round()}%';

/// Data curta "dd/mm".
String formatShortDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}';
}

/// "hoje", "ontem" ou "há N dias", comparando só as datas.
String formatRelativeDay(DateTime date, DateTime now) {
  final days = DateTime.utc(now.year, now.month, now.day)
      .difference(DateTime.utc(date.year, date.month, date.day))
      .inDays;
  if (days <= 0) return 'hoje';
  if (days == 1) return 'ontem';
  return 'há $days dias';
}

/// Nome com o sobrenome abreviado (ex.: "Maria Costa" → "Maria C.").
String shortName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first;
  return '${parts.first} ${parts[1].substring(0, 1)}.';
}

/// Iniciais do primeiro e do último nome (ex.: "Pedro Henrique" → "PH").
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}
