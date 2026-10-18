/// Regras da sequência de dias estudando.
library;

class StreakRules {
  StreakRules._();

  /// Medalhas de constância (em dias seguidos).
  static const List<int> milestones = [7, 30, 100];

  /// Calcula a nova sequência após uma atividade em [today].
  ///
  /// - Mesma data da última atividade: a sequência não muda.
  /// - Dia seguinte à última atividade: soma 1.
  /// - Qualquer outro caso (pulou um dia ou nunca estudou): recomeça em 1.
  static int nextStreak({
    required int currentStreak,
    required DateTime? lastStudyDay,
    required DateTime today,
  }) {
    if (lastStudyDay == null) return 1;
    final last = _dateOnly(lastStudyDay);
    final now = _dateOnly(today);
    final diff = now.difference(last).inDays;
    if (diff == 0) return currentStreak < 1 ? 1 : currentStreak;
    if (diff == 1) return currentStreak + 1;
    return 1;
  }

  /// Verdadeiro se a sequência já está perdida em [today]
  /// (o aluno não estudou ontem nem hoje).
  static bool isBroken({
    required DateTime? lastStudyDay,
    required DateTime today,
  }) {
    if (lastStudyDay == null) return true;
    return _dateOnly(today).difference(_dateOnly(lastStudyDay)).inDays > 1;
  }

  static DateTime _dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);
}
