/// Implementações em memória dos repositórios.
///
/// Guardam tudo enquanto o app está aberto (sem servidor e sem
/// persistência). Servem para desenvolver as telas e para os testes.
library;

import '../../domain/models/content.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/quiz_result.dart';
import '../../domain/models/student.dart';
import '../../domain/models/teacher.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/streak_rules.dart';
import '../../domain/rules/xp_rules.dart';
import 'sample_content.dart';

/// Função que devolve a data/hora atual. Permite controlar o "hoje"
/// nos testes.
typedef Clock = DateTime Function();

class MemoryStudentRepository implements StudentRepository {
  MemoryStudentRepository({Clock? clock, Student? initial})
      : _clock = clock ?? DateTime.now {
    _student = initial ?? _sampleStudent(_clock());
  }

  final Clock _clock;
  late Student _student;
  List<Mission> _missions = List.of(SampleContent.dailyMissions);

  /// XP ganho na semana corrente (usado pelo ranking semanal).
  int weeklyXp = 515;

  static Student _sampleStudent(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    // Últimos 12 dias seguidos até ontem, mais alguns dias soltos antes.
    final days = <DateTime>{
      for (var i = 1; i <= 12; i++) today.subtract(Duration(days: i)),
      today.subtract(const Duration(days: 15)),
      today.subtract(const Duration(days: 17)),
      today.subtract(const Duration(days: 18)),
      today.subtract(const Duration(days: 21)),
      today.subtract(const Duration(days: 24)),
    };
    return Student(
      id: 'aluno-ana',
      name: 'Ana Souza',
      className: 'Eletrotécnica 2º A',
      courseName: 'Técnico em Eletrotécnica',
      totalXp: 1000,
      streakDays: 12,
      lastStudyDay: today.subtract(const Duration(days: 1)),
      league: League.cobre,
      questionsAnswered: 186,
      correctAnswers: 138,
      earnedBadgeIds: {'potencia-total', 'streak-7'},
      studyDays: days,
    );
  }

  @override
  Future<Student> getCurrentStudent() async => _student;

  @override
  Future<List<Mission>> getDailyMissions() async =>
      List.unmodifiable(_missions);

  @override
  Future<List<Medal>> getAllMedals() async => SampleContent.medals;

  @override
  Future<QuizResult> submitQuiz(Quiz quiz, List<AnswerRecord> answers) async {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    final before = _student;

    final xp = XpRules.score(answers, completionReward: quiz.rewardXp);
    final correct = answers.where((a) => a.correct).length;
    final streak = StreakRules.nextStreak(
      currentStreak: before.streakDays,
      lastStudyDay: before.lastStudyDay,
      today: today,
    );

    // Medalhas novas.
    final earned = Set<String>.of(before.earnedBadgeIds);
    final newMedalIds = <String>[];
    final accuracy = answers.isEmpty ? 0.0 : correct / answers.length;
    final quizBadge = quiz.badgeId;
    if (quizBadge != null && accuracy >= 0.8 && earned.add(quizBadge)) {
      newMedalIds.add(quizBadge);
    }
    for (final milestone in StreakRules.milestones) {
      final id = 'streak-$milestone';
      if (streak >= milestone && earned.add(id)) newMedalIds.add(id);
    }

    _student = before.copyWith(
      totalXp: before.totalXp + xp.total,
      streakDays: streak,
      lastStudyDay: today,
      questionsAnswered: before.questionsAnswered + answers.length,
      correctAnswers: before.correctAnswers + correct,
      earnedBadgeIds: earned,
      studyDays: {...before.studyDays, today},
    );
    weeklyXp += xp.total;
    _completeMissionsFor(quiz.id);

    return QuizResult(
      quiz: quiz,
      answers: List.unmodifiable(answers),
      xp: xp,
      xpBefore: before.totalXp,
      xpAfter: _student.totalXp,
      streakAfter: streak,
      newMedals: SampleContent.medals
          .where((m) => newMedalIds.contains(m.id))
          .toList(),
    );
  }

  void _completeMissionsFor(String quizId) {
    _missions = [
      for (final m in _missions)
        if (m.quizId == quizId && !m.isDone)
          Mission(
            id: m.id,
            title: m.title,
            rewardXp: m.rewardXp,
            progress: m.goal,
            goal: m.goal,
            quizId: m.quizId,
            isFlash: m.isFlash,
          )
        else
          m,
    ];
  }
}

class MemoryContentRepository implements ContentRepository {
  final List<Question> _createdQuestions = [];

  @override
  Future<List<Trail>> getTrails() async => SampleContent.trails;

  @override
  Future<Quiz> getQuiz(String quizId) async {
    return SampleContent.quizzes.firstWhere(
      (q) => q.id == quizId,
      orElse: () => throw ArgumentError('Desafio não encontrado: $quizId'),
    );
  }

  @override
  Future<List<Question>> getCreatedQuestions() async =>
      List.unmodifiable(_createdQuestions);

  @override
  Future<void> saveQuestion(Question question) async {
    _createdQuestions.removeWhere((item) => item.id == question.id);
    _createdQuestions.add(question);
  }
}

class MemoryRankingRepository implements RankingRepository {
  MemoryRankingRepository(this._students);

  final MemoryStudentRepository _students;

  static const _peers = <(String, String, int)>[
    ('aluno-maria', 'Maria Costa', 745),
    ('aluno-joao', 'João Pedro', 610),
    ('aluno-lucas', 'Lucas Ribeiro', 580),
    ('aluno-beatriz', 'Beatriz Farias', 540),
    ('aluno-gabriel', 'Gabriel Teixeira', 470),
    ('aluno-rafael', 'Rafael Moura', 430),
    ('aluno-camila', 'Camila Lima', 395),
  ];

  @override
  Future<List<RankingEntry>> getClassRanking(RankingPeriod period) async {
    final me = await _students.getCurrentStudent();
    // Multiplicadores fictícios só para os períodos parecerem diferentes.
    final factor = switch (period) {
      RankingPeriod.week => 1,
      RankingPeriod.month => 4,
      RankingPeriod.all => 12,
    };
    final rows = <(String, String, int)>[
      for (final p in _peers) (p.$1, p.$2, p.$3 * factor),
      (me.id, me.name, _students.weeklyXp * factor),
    ]..sort((a, b) => b.$3.compareTo(a.$3));

    return [
      for (var i = 0; i < rows.length; i++)
        RankingEntry(
          position: i + 1,
          studentId: rows[i].$1,
          name: rows[i].$2,
          xp: rows[i].$3,
          isCurrentStudent: rows[i].$1 == me.id,
        ),
    ];
  }
}

class MemoryTeacherRepository implements TeacherRepository {
  MemoryTeacherRepository({Clock? clock}) : _clock = clock ?? DateTime.now;

  final Clock _clock;
  final List<ActiveChallenge> _published = [];
  final List<String> remindersSent = [];

  @override
  Future<List<({String id, String name})>> getClasses() async => const [
        (id: 'eletro-2a', name: 'Eletrotécnica 2º A'),
        (id: 'eletro-2b', name: 'Eletrotécnica 2º B'),
        (id: 'eletronica-1a', name: 'Eletrônica 1º A'),
      ];

  @override
  Future<ClassOverview> getClassOverview(String classId) async {
    final now = _clock();
    final classes = await getClasses();
    final name = classes
        .firstWhere((c) => c.id == classId, orElse: () => classes.first)
        .name;
    return ClassOverview(
      classId: classId,
      className: name,
      studentCount: 32,
      activeThisWeek: 27,
      averageAccuracy: 0.71,
      challengesCompleted: 184,
      averageStreak: 6,
      topics: const [
        TopicPerformance(topic: 'Lei de Ohm', accuracy: 0.81),
        TopicPerformance(topic: 'Potência elétrica', accuracy: 0.74),
        TopicPerformance(topic: 'Código de cores', accuracy: 0.62),
        TopicPerformance(topic: 'Associação em série', accuracy: 0.66),
        TopicPerformance(topic: 'Associação em paralelo', accuracy: 0.48),
      ],
      alerts: [
        StudentAlert(
          studentId: 'aluno-pedro',
          name: 'Pedro Henrique',
          lastAccess: now.subtract(const Duration(days: 6)),
          accuracy: 0.58,
          reason: 'Sem acesso há quase uma semana',
        ),
        StudentAlert(
          studentId: 'aluno-larissa',
          name: 'Larissa Nunes',
          lastAccess: now.subtract(const Duration(days: 1)),
          accuracy: 0.41,
          reason: 'Acerto baixo em associação em paralelo',
        ),
        StudentAlert(
          studentId: 'aluno-mateus',
          name: 'Mateus Oliveira',
          lastAccess: now.subtract(const Duration(days: 4)),
          accuracy: 0.66,
          reason: 'Perdeu uma sequência de 15 dias',
        ),
        StudentAlert(
          studentId: 'aluno-julia',
          name: 'Júlia Vieira',
          lastAccess: now,
          accuracy: 0.49,
          reason: 'Usou dica em 80% das questões',
        ),
      ],
      activeChallenges: [
        ActiveChallenge(
          id: 'ch-cores',
          title: 'Código de cores de resistores',
          deadline: now.add(const Duration(days: 2)),
          completedBy: 22,
          classSize: 32,
        ),
        ActiveChallenge(
          id: 'ch-potencia',
          title: 'Potência em circuitos residenciais',
          deadline: now.add(const Duration(days: 6)),
          completedBy: 9,
          classSize: 32,
        ),
        ..._published,
      ],
    );
  }

  @override
  Future<void> publishChallenge(String classId, NewChallengeDraft draft) async {
    _published.add(ActiveChallenge(
      id: 'ch-${_published.length + 1}',
      title: draft.title,
      deadline: draft.deadline,
      completedBy: 0,
      classSize: 32,
    ));
  }

  @override
  Future<void> sendReminder(String studentId) async {
    remindersSent.add(studentId);
  }
}
