/// Contratos de acesso a dados.
///
/// As telas dependem só destas interfaces, nunca de uma implementação.
/// Hoje elas são atendidas por repositórios em memória
/// (`lib/data/memory/`). Quando o backend for escolhido (Supabase,
/// Firebase, API do IFMA...), basta criar novas classes que implementem
/// estas interfaces e trocá-las em `lib/app/dependencies.dart`.
library;

import '../models/content.dart';
import '../models/gamification.dart';
import '../models/quiz_result.dart';
import '../models/student.dart';
import '../models/teacher.dart';
import '../rules/xp_rules.dart';

abstract interface class StudentRepository {
  /// Aluno conectado no aparelho.
  Future<Student> getCurrentStudent();

  /// Missões do dia do aluno conectado.
  Future<List<Mission>> getDailyMissions();

  /// Registra um desafio concluído: soma XP, atualiza a sequência,
  /// as estatísticas e as medalhas. Devolve o resultado consolidado.
  Future<QuizResult> submitQuiz(Quiz quiz, List<AnswerRecord> answers);

  /// Catálogo de medalhas (conquistadas e por conquistar).
  Future<List<Medal>> getAllMedals();
}

abstract interface class ContentRepository {
  Future<List<Trail>> getTrails();

  Future<Quiz> getQuiz(String quizId);

  Future<List<Question>> getCreatedQuestions();

  Future<void> saveQuestion(Question question);
}

abstract interface class RankingRepository {
  Future<List<RankingEntry>> getClassRanking(RankingPeriod period);
}

abstract interface class TeacherRepository {
  Future<List<({String id, String name})>> getClasses();

  Future<ClassOverview> getClassOverview(String classId);

  Future<void> publishChallenge(String classId, NewChallengeDraft draft);

  Future<void> sendReminder(String studentId);
}
