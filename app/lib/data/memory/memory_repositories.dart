/// Implementações em memória dos repositórios.
///
/// Guardam tudo enquanto o app está aberto. Sozinhas não persistem nada;
/// `lib/data/local/` as restaura e salva no aparelho via `onChanged`.
library;

import 'dart:async';

import '../../domain/models/content.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/quiz_result.dart';
import '../../domain/models/student.dart';
import '../../domain/models/teacher.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/rules/question_bank_rules.dart';
import '../../domain/rules/streak_rules.dart';
import '../../domain/rules/xp_rules.dart';
import 'sample_content.dart';

/// Função que devolve a data/hora atual. Permite controlar o "hoje"
/// nos testes.
typedef Clock = DateTime Function();

class MemoryStudentRepository implements StudentRepository {
  MemoryStudentRepository({
    Clock? clock,
    Student? initial,
    Map<String, int>? missionProgress,
    Map<String, double>? quizScores,
    DateTime? missionsDay,
    this.weeklyXp = 515,
    this.onChanged,
  }) : _clock = clock ?? DateTime.now {
    bestQuizScores = Map.of(quizScores ?? const {});
    _student = initial ?? _sampleStudent(_clock());
    _missionsDay = missionsDay ?? _today();
    _missions = [
      for (final m in SampleContent.dailyMissions)
        _withProgress(m, missionProgress?[m.id] ?? m.progress),
    ];
    final restoredMedals = SampleContent.subjectMedalIdsForScores(bestQuizScores)
        .difference(_student.earnedBadgeIds);
    if (restoredMedals.isNotEmpty) {
      _student = _student.copyWith(
          earnedBadgeIds: {..._student.earnedBadgeIds, ...restoredMedals});
      onChanged?.call(this);
    }
  }

  final Clock _clock;
  late Student _student;

  /// Melhor acerto por atividade; salvo separadamente do XP.
  late final Map<String, double> bestQuizScores;
  late List<Mission> _missions;
  late DateTime _missionsDay;

  /// XP ganho na semana corrente (usado pelo ranking semanal).
  int weeklyXp;

  /// Chamado após cada alteração, para quem quiser salvar o estado.
  final void Function(MemoryStudentRepository repo)? onChanged;

  /// Estado atual, exposto para a persistência.
  Student get student => _student;
  DateTime get missionsDay => _missionsDay;
  Map<String, int> get missionProgress =>
      {for (final m in _missions) m.id: m.progress};

  DateTime _today() {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  /// Missões são diárias: num dia novo, voltam ao início.
  void _resetMissionsIfNewDay() {
    final today = _today();
    if (_missionsDay == today) return;
    _missionsDay = today;
    _missions = List.of(SampleContent.dailyMissions);
    onChanged?.call(this);
  }

  static Mission _withProgress(Mission m, int progress) => Mission(
        id: m.id,
        title: m.title,
        rewardXp: m.rewardXp,
        progress: progress,
        goal: m.goal,
        quizId: m.quizId,
        isFlash: m.isFlash,
      );

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
  Future<Student> getCurrentStudent() async {
    // Sequência perdida não deve continuar aparecendo como ativa.
    if (_student.streakDays > 0 &&
        StreakRules.isBroken(
            lastStudyDay: _student.lastStudyDay, today: _clock())) {
      _student = _student.copyWith(streakDays: 0);
      onChanged?.call(this);
    }
    return _student;
  }

  @override
  Future<List<Mission>> getDailyMissions() async {
    _resetMissionsIfNewDay();
    return List.unmodifiable(_missions);
  }

  @override
  Future<List<Medal>> getAllMedals() async => SampleContent.medals;

  @override
  Future<void> resetProgress() async {
    _student = Student(
      id: _student.id,
      name: _student.name,
      className: _student.className,
      courseName: _student.courseName,
      totalXp: 0,
      streakDays: 0,
      lastStudyDay: null,
      league: League.cobre,
      questionsAnswered: 0,
      correctAnswers: 0,
      earnedBadgeIds: const {},
      studyDays: const {},
    );
    _missionsDay = _today();
    _missions = [
      for (final m in SampleContent.dailyMissions) _withProgress(m, 0),
    ];
    weeklyXp = 0;
    bestQuizScores.clear();
    onChanged?.call(this);
  }

  @override
  Future<QuizResult> submitQuiz(Quiz quiz, List<AnswerRecord> answers) async {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    _resetMissionsIfNewDay();
    final before = _student;

    final xp = XpRules.score(answers, completionReward: quiz.rewardXp);
    final correct = answers.where((a) => a.correct).length;
    final streak = StreakRules.nextStreak(
      currentStreak: before.streakDays,
      lastStudyDay: before.lastStudyDay,
      today: today,
    );

    // Recalcula a partir do gabarito; respostas ausentes contam como erro.
    final validAnswers = {
      for (final answer in answers) answer.questionId: answer,
    };
    final moduleCorrect = quiz.questions.where((question) {
      final answer = validAnswers[question.id];
      return answer != null && question.isCorrect(answer.selectedIndex);
    }).length;
    final moduleScore =
        quiz.questions.isEmpty ? 0.0 : moduleCorrect / quiz.questions.length;
    if (moduleScore > (bestQuizScores[quiz.id] ?? 0)) {
      bestQuizScores[quiz.id] = moduleScore;
    }

    // Medalhas novas.
    final earned = Set<String>.of(before.earnedBadgeIds);
    final newMedalIds = <String>[];
    final quizBadge = quiz.badgeId;
    final finalTrail = SampleContent.trails.where((trail) =>
        trail.modules.any((m) => m.isFinalExam && m.quizId == quiz.id)).firstOrNull;
    bool trailPassed(Trail trail) => trail.modules.every(
        (module) => (bestQuizScores[module.quizId] ?? 0) >= 0.7);
    final prerequisite = SampleContent.trails.where(
        (trail) => trail.id == finalTrail?.requiresTrailId).firstOrNull;
    final qualifies = finalTrail == null
        ? moduleScore >= 0.8
        : trailPassed(finalTrail) &&
            (finalTrail.requiresTrailId == null ||
                (prerequisite != null && trailPassed(prerequisite)));
    if (quizBadge != null && qualifies && earned.add(quizBadge)) {
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
    onChanged?.call(this);

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
        if (m.quizId == quizId && !m.isDone) _withProgress(m, m.goal) else m,
    ];
  }
}

class MemoryContentRepository implements ContentRepository {
  MemoryContentRepository({List<Question>? createdQuestions, this.onChanged,
    this.studentRepository})
      : _createdQuestions = List.of(createdQuestions ?? const []);

  final List<Question> _createdQuestions;
  final MemoryStudentRepository? studentRepository;

  /// Chamado após salvar uma questão, para quem quiser persistir.
  final FutureOr<void> Function(List<Question> createdQuestions)? onChanged;
  Future<void> _pendingSave = Future.value();

  @override
  Future<List<Trail>> getTrails() async {
    final scores = studentRepository?.bestQuizScores ?? const <String, double>{};
    bool passed(TrailModule module) =>
        module.quizId != null && (scores[module.quizId] ?? 0) >= 0.7;
    final completed = {
      for (final trail in SampleContent.trails)
        if (trail.modules.every(passed)) trail.id,
    };
    return [
      for (final trail in SampleContent.trails)
        Trail(
          id: trail.id,
          title: trail.title,
          requiresTrailId: trail.requiresTrailId,
          unlocked: trail.requiresTrailId == null ||
              completed.contains(trail.requiresTrailId),
          modules: [
            for (var i = 0; i < trail.modules.length; i++)
              _withProgress(
                trail.modules[i],
                scores[trail.modules[i].quizId] ?? 0,
                (trail.requiresTrailId == null ||
                    completed.contains(trail.requiresTrailId)) &&
                    trail.modules.take(i).every(passed),
              ),
          ],
        ),
    ];
  }

  static TrailModule _withProgress(
      TrailModule module, double score, bool available) => TrailModule(
    id: module.id,
    order: module.order,
    title: module.title,
    subtitle: module.subtitle,
    lessonText: module.lessonText,
    status: !available ? ModuleStatus.locked
        : score >= 0.7 ? ModuleStatus.done : ModuleStatus.current,
    stars: !available ? 0 : score >= 1 ? 3 : score >= 0.85 ? 2 : score >= 0.7 ? 1 : 0,
    lessonsDone: available && score >= 0.7 ? 1 : 0,
    lessonsTotal: 1,
    quizId: module.quizId,
    isFinalExam: module.isFinalExam,
  );

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
  Future<Question> saveQuestion(Question question) {
    final save = _pendingSave.then((_) async {
      final admitted = QuestionBankRules.admit(question, _createdQuestions);
      if (_createdQuestions.any((item) => item.id == admitted.id)) {
        return admitted;
      }
      final updated = [
        ..._createdQuestions, admitted,
      ];
      await onChanged?.call(List.unmodifiable(updated));
      _createdQuestions
        ..clear()
        ..addAll(updated);
      return admitted;
    });
    _pendingSave = save.then<void>((_) {}, onError: (Object _) {});
    return save;
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
