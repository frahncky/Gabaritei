import '../rules/level_rules.dart';
import '../rules/xp_rules.dart';
import 'content.dart';
import 'gamification.dart';

/// Resultado de um desafio, já registrado no perfil do aluno.
class QuizResult {
  const QuizResult({
    required this.quiz,
    required this.answers,
    required this.xp,
    required this.xpBefore,
    required this.xpAfter,
    required this.streakAfter,
    this.newMedals = const [],
  });

  final Quiz quiz;
  final List<AnswerRecord> answers;
  final XpBreakdown xp;
  final int xpBefore;
  final int xpAfter;
  final int streakAfter;
  final List<Medal> newMedals;

  int get correctCount => answers.where((a) => a.correct).length;

  int get total => answers.length;

  LevelProgress get levelAfter => LevelRules.progressFor(xpAfter);

  bool get leveledUp =>
      LevelRules.progressFor(xpBefore).current.index < levelAfter.current.index;

  bool get reachedNewTier => LevelRules.reachedNewTier(xpBefore, xpAfter);

  /// Questões erradas, para a seção "Para revisar".
  List<Question> get wrongQuestions {
    final wrongIds = answers.where((a) => !a.correct).map((a) => a.questionId);
    return quiz.questions.where((q) => wrongIds.contains(q.id)).toList();
  }
}
