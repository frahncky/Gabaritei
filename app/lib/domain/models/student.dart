import '../rules/level_rules.dart';

/// Liga semanal do ranking (os 3 primeiros sobem no domingo).
enum League {
  cobre('Cobre'),
  prata('Prata'),
  ouro('Ouro');

  const League(this.label);

  final String label;
}

class Student {
  const Student({
    required this.id,
    required this.name,
    required this.className,
    required this.courseName,
    required this.totalXp,
    required this.streakDays,
    required this.lastStudyDay,
    required this.league,
    required this.questionsAnswered,
    required this.correctAnswers,
    required this.earnedBadgeIds,
    required this.studyDays,
  });

  final String id;
  final String name;

  /// Ex.: "Eletrotécnica 2º A".
  final String className;

  /// Ex.: "Técnico em Eletrotécnica".
  final String courseName;

  final int totalXp;
  final int streakDays;
  final DateTime? lastStudyDay;
  final League league;
  final int questionsAnswered;
  final int correctAnswers;
  final Set<String> earnedBadgeIds;

  /// Dias em que o aluno estudou (para o calendário do perfil).
  final Set<DateTime> studyDays;

  LevelProgress get level => LevelRules.progressFor(totalXp);

  String get firstName => name.split(' ').first;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  /// Taxa de acerto de 0 a 1.
  double get accuracy =>
      questionsAnswered == 0 ? 0 : correctAnswers / questionsAnswered;

  Student copyWith({
    int? totalXp,
    int? streakDays,
    DateTime? lastStudyDay,
    League? league,
    int? questionsAnswered,
    int? correctAnswers,
    Set<String>? earnedBadgeIds,
    Set<DateTime>? studyDays,
  }) {
    return Student(
      id: id,
      name: name,
      className: className,
      courseName: courseName,
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastStudyDay: lastStudyDay ?? this.lastStudyDay,
      league: league ?? this.league,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      studyDays: studyDays ?? this.studyDays,
    );
  }
}
