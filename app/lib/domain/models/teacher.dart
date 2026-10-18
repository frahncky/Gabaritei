/// Dados do painel do professor.
library;

class TopicPerformance {
  const TopicPerformance({required this.topic, required this.accuracy});

  final String topic;

  /// Taxa de acerto da turma no tópico, de 0 a 1.
  final double accuracy;

  /// Abaixo de 60% o painel sugere retomar o tópico em aula.
  bool get needsReview => accuracy < 0.6;
}

class StudentAlert {
  const StudentAlert({
    required this.studentId,
    required this.name,
    required this.lastAccess,
    required this.accuracy,
    required this.reason,
  });

  final String studentId;
  final String name;
  final DateTime lastAccess;
  final double accuracy;
  final String reason;
}

class ActiveChallenge {
  const ActiveChallenge({
    required this.id,
    required this.title,
    required this.deadline,
    required this.completedBy,
    required this.classSize,
  });

  final String id;
  final String title;
  final DateTime deadline;
  final int completedBy;
  final int classSize;

  double get fraction => classSize == 0 ? 0 : completedBy / classSize;
}

class ClassOverview {
  const ClassOverview({
    required this.classId,
    required this.className,
    required this.studentCount,
    required this.activeThisWeek,
    required this.averageAccuracy,
    required this.challengesCompleted,
    required this.averageStreak,
    required this.topics,
    required this.alerts,
    required this.activeChallenges,
  });

  final String classId;
  final String className;
  final int studentCount;
  final int activeThisWeek;
  final double averageAccuracy;
  final int challengesCompleted;
  final double averageStreak;
  final List<TopicPerformance> topics;
  final List<StudentAlert> alerts;
  final List<ActiveChallenge> activeChallenges;
}

/// Dados para o professor criar um desafio rápido.
class NewChallengeDraft {
  const NewChallengeDraft({
    required this.title,
    required this.moduleId,
    required this.questionCount,
    required this.rewardXp,
    required this.deadline,
    this.badgeId,
  });

  final String title;
  final String moduleId;
  final int questionCount;
  final int rewardXp;
  final DateTime deadline;
  final String? badgeId;
}
