/// Persistência no aparelho com `shared_preferences`.
///
/// Restaura os repositórios em memória com o que foi salvo e grava de
/// novo a cada alteração. Quando houver servidor, esta camada pode virar
/// um cache offline.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/content.dart';
import '../../domain/models/question_figure.dart';
import '../../domain/models/student.dart';
import '../memory/memory_repositories.dart';

class LocalStore {
  LocalStore(this._prefs);

  static const _studentKey = 'gabaritei.student.v1';
  static const _questionsKey = 'gabaritei.questions.v1';

  final SharedPreferences _prefs;

  static Future<LocalStore> open() async =>
      LocalStore(await SharedPreferences.getInstance());

  MemoryStudentRepository studentRepository({Clock? clock}) {
    final saved = _readJson(_studentKey);
    return MemoryStudentRepository(
      clock: clock,
      quizScores: (saved?['quizScores'] as Map?)?.map(
        (key, value) => MapEntry(key as String, (value as num).toDouble())),
      initial: saved == null ? null : _studentFromJson(saved['student']),
      missionProgress:
          saved == null ? null : (saved['missions'] as Map).cast<String, int>(),
      missionsDay: saved == null ? null : DateTime.parse(saved['missionsDay']),
      weeklyXp: (saved?['weeklyXp'] as int?) ?? 515,
      onChanged: (repo) => _prefs.setString(
        _studentKey,
        jsonEncode({
          'student': _studentToJson(repo.student),
          'missions': repo.missionProgress,
          'missionsDay': repo.missionsDay.toIso8601String(),
          'weeklyXp': repo.weeklyXp,
          'quizScores': repo.bestQuizScores,
        }),
      ),
    );
  }

  MemoryContentRepository contentRepository({MemoryStudentRepository? students}) {
    final raw = _prefs.getString(_questionsKey);
    final saved = raw == null ? const <dynamic>[] : jsonDecode(raw) as List;
    return MemoryContentRepository(
      studentRepository: students,
      createdQuestions: [for (final q in saved) _questionFromJson(q)],
      onChanged: (questions) async {
        final saved = await _prefs.setString(
          _questionsKey,
          jsonEncode([for (final q in questions) _questionToJson(q)]),
        );
        if (!saved) throw StateError('Falha ao persistir questões.');
      },
    );
  }

  /// Apaga o progresso salvo (volta aos dados de exemplo).
  Future<void> clear() async {
    await _prefs.remove(_studentKey);
    await _prefs.remove(_questionsKey);
  }

  Map<String, dynamic>? _readJson(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return null; // Dado corrompido: recomeça com os dados de exemplo.
    }
  }

  static Map<String, dynamic> _studentToJson(Student s) => {
        'id': s.id,
        'name': s.name,
        'className': s.className,
        'courseName': s.courseName,
        'totalXp': s.totalXp,
        'streakDays': s.streakDays,
        'lastStudyDay': s.lastStudyDay?.toIso8601String(),
        'league': s.league.name,
        'questionsAnswered': s.questionsAnswered,
        'correctAnswers': s.correctAnswers,
        'earnedBadgeIds': s.earnedBadgeIds.toList(),
        'studyDays': [for (final d in s.studyDays) d.toIso8601String()],
      };

  static Student _studentFromJson(Map<String, dynamic> j) => Student(
        id: j['id'],
        name: j['name'],
        className: j['className'],
        courseName: j['courseName'],
        totalXp: j['totalXp'],
        streakDays: j['streakDays'],
        lastStudyDay: j['lastStudyDay'] == null
            ? null
            : DateTime.parse(j['lastStudyDay']),
        league: League.values.byName(j['league']),
        questionsAnswered: j['questionsAnswered'],
        correctAnswers: j['correctAnswers'],
        earnedBadgeIds: (j['earnedBadgeIds'] as List).cast<String>().toSet(),
        studyDays: {
          for (final d in (j['studyDays'] as List).cast<String>())
            DateTime.parse(d),
        },
      );

  static Map<String, dynamic> _questionToJson(Question q) => {
        'id': q.id,
        'topic': q.topic,
        'prompt': q.prompt,
        'options': q.options,
        'correctIndex': q.correctIndex,
        'explanation': q.explanation,
        'hint': q.hint,
        'visual': q.visual?.name,
        'figure': q.figure?.toJson(),
      };

  static Question _questionFromJson(Map<String, dynamic> j) => Question(
        id: j['id'],
        topic: j['topic'],
        prompt: j['prompt'],
        options: (j['options'] as List).cast<String>(),
        correctIndex: j['correctIndex'],
        explanation: j['explanation'],
        hint: j['hint'],
        figure: j['figure'] == null ? null : QuestionFigure.fromJson(
            Map<String, dynamic>.from(j['figure'] as Map)),
        visual: j['visual'] == null
            ? null
            : QuestionVisual.values.byName(j['visual']),
      );
}
