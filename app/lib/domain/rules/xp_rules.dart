/// Regras de pontuação (XP) dos desafios.
library;

/// Registro de uma resposta dada pelo aluno.
class AnswerRecord {
  const AnswerRecord({
    required this.questionId,
    required this.selectedIndex,
    required this.correct,
    this.usedHint = false,
  });

  final String questionId;
  final int selectedIndex;
  final bool correct;
  final bool usedHint;
}

/// Detalhamento do XP ganho num desafio.
class XpBreakdown {
  const XpBreakdown({
    required this.baseXp,
    required this.comboXp,
    required this.completionXp,
    required this.hintPenalty,
  });

  final int baseXp;
  final int comboXp;
  final int completionXp;
  final int hintPenalty;

  int get total {
    final value = baseXp + comboXp + completionXp - hintPenalty;
    return value < 0 ? 0 : value;
  }
}

class XpRules {
  XpRules._();

  /// XP por questão correta.
  static const int xpPerCorrect = 10;

  /// XP descontado por dica usada.
  static const int hintCost = 10;

  /// A partir de quantos acertos seguidos o combo começa a valer.
  static const int comboThreshold = 3;

  /// Multiplicador aplicado às questões em combo (2 = dobra o XP).
  static const int comboMultiplier = 2;

  /// Calcula o XP de um desafio.
  ///
  /// [completionReward] é o bônus por concluir o desafio (definido pelo
  /// professor ou pela missão). Ele só é concedido se o aluno acertou
  /// ao menos metade das questões.
  static XpBreakdown score(
    List<AnswerRecord> answers, {
    int completionReward = 0,
  }) {
    var base = 0;
    var combo = 0;
    var penalty = 0;
    var streak = 0;
    var correctCount = 0;

    for (final answer in answers) {
      if (answer.usedHint) penalty += hintCost;
      if (answer.correct) {
        correctCount++;
        streak++;
        base += xpPerCorrect;
        if (streak >= comboThreshold) {
          combo += xpPerCorrect * (comboMultiplier - 1);
        }
      } else {
        streak = 0;
      }
    }

    final passed = answers.isNotEmpty && correctCount * 2 >= answers.length;
    return XpBreakdown(
      baseXp: base,
      comboXp: combo,
      completionXp: passed ? completionReward : 0,
      hintPenalty: penalty,
    );
  }

  /// Maior sequência de acertos seguidos nas respostas.
  static int bestStreak(List<AnswerRecord> answers) {
    var best = 0;
    var current = 0;
    for (final answer in answers) {
      current = answer.correct ? current + 1 : 0;
      if (current > best) best = current;
    }
    return best;
  }
}
