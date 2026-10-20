/// Elementos de gamificação: missões, medalhas e ranking.
library;

class Mission {
  const Mission({
    required this.id,
    required this.title,
    required this.rewardXp,
    required this.progress,
    required this.goal,
    this.quizId,
    this.isFlash = false,
  });

  final String id;
  final String title;
  final int rewardXp;
  final int progress;
  final int goal;

  /// Desafio a abrir quando o aluno toca na missão.
  final String? quizId;

  /// Desafio relâmpago (destacado na tela inicial).
  final bool isFlash;

  bool get isDone => progress >= goal;

  double get fraction =>
      goal == 0 ? 0 : (progress / goal).clamp(0, 1).toDouble();
}

/// Medalha (conquista). Chamada de `Medal` para não colidir com o
/// widget `Badge` do Flutter.
class Medal {
  const Medal({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  final String id;
  final String name;
  final String description;

  /// Ícone que representa a conquista, independente do desenho da medalha.
  final MedalIcon icon;
}

enum MedalIcon {
  ohm,
  bolt,
  streak,
  resistor,
  parallel,
  electrician,
  kirchhoff,
}

enum RankingPeriod {
  week('Semana'),
  month('Mês'),
  all('Geral');

  const RankingPeriod(this.label);

  final String label;
}

class RankingEntry {
  const RankingEntry({
    required this.position,
    required this.studentId,
    required this.name,
    required this.xp,
    this.isCurrentStudent = false,
  });

  final int position;
  final String studentId;
  final String name;
  final int xp;
  final bool isCurrentStudent;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }
}
