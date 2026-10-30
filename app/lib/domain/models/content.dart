/// Conteúdo pedagógico: trilhas, módulos, questões e desafios.
library;

class Question {
  const Question({
    required this.id,
    required this.topic,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.hint,
    this.visual,
  });

  final String id;

  /// Tópico usado nos relatórios do professor (ex.: "Lei de Ohm").
  final String topic;
  final String prompt;
  final List<String> options;
  final int correctIndex;

  /// Mostrada no resultado quando o aluno erra.
  final String explanation;
  final String? hint;

  /// Recurso visual opcional exibido antes das alternativas.
  final QuestionVisual? visual;

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}

/// Diagramas nativos que uma questão pode apresentar. Novos tipos podem ser
/// acrescentados sem misturar widgets à camada de conteúdo.
enum QuestionVisual {
  circuitSeries,
  circuitParallel,
  resistorBands,
  electricalPlan,
  processControl,
}

/// Um desafio (quiz) com várias questões.
class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.topic,
    required this.questions,
    required this.rewardXp,
    this.timeLimitSeconds,
    this.badgeId,
  });

  final String id;
  final String title;
  final String topic;
  final List<Question> questions;

  /// Bônus por concluir o desafio (com pelo menos 50% de acerto).
  final int rewardXp;

  /// Tempo total do desafio relâmpago; `null` = sem limite.
  final int? timeLimitSeconds;

  /// Medalha que pode ser concedida neste desafio.
  final String? badgeId;
}

enum ModuleStatus { done, current, locked }

class TrailModule {
  const TrailModule({
    required this.id,
    required this.order,
    required this.title,
    required this.subtitle,
    required this.status,
    this.stars = 0,
    this.lessonsDone = 0,
    this.lessonsTotal = 0,
    this.quizId,
    this.isFinalExam = false,
    this.lessonText,
  });

  final String id;
  final int order;
  final String title;
  final String subtitle;
  final ModuleStatus status;

  /// 0 a 3 estrelas conforme o acerto no módulo.
  final int stars;
  final int lessonsDone;
  final int lessonsTotal;
  final String? quizId;
  final bool isFinalExam;

  /// Resumo introdutório apresentado antes da atividade.
  final String? lessonText;

  double get lessonFraction =>
      lessonsTotal == 0 ? 0 : lessonsDone / lessonsTotal;
}

class Trail {
  const Trail({
    required this.id,
    required this.title,
    required this.modules,
    this.unlocked = true,
    this.requiresTrailId,
  });

  final String id;
  final String title;
  final List<TrailModule> modules;
  final bool unlocked;

  /// Trilha que precisa ser concluída antes desta.
  final String? requiresTrailId;

  int get modulesDone => modules
      .where((m) => m.status == ModuleStatus.done && !m.isFinalExam)
      .length;

  int get modulesTotal => modules.where((m) => !m.isFinalExam).length;

  double get fraction => modulesTotal == 0 ? 0 : modulesDone / modulesTotal;
}
