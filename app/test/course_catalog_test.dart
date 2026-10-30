import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/memory/curriculum_content.dart';
import 'package:gabaritei/data/memory/memory_repositories.dart';
import 'package:gabaritei/data/memory/sample_content.dart';
import 'package:gabaritei/domain/models/content.dart';
import 'package:gabaritei/domain/rules/xp_rules.dart';
import 'package:gabaritei/domain/services/course_catalog.dart';
import 'package:gabaritei/domain/services/question_generator.dart';

void main() {
  test('quatro cursos possuem identidade, descrição e objetivos próprios', () {
    expect(CourseCatalog.courses.length, 4);
    expect(CourseCatalog.courses.map((c) => c.id).toSet().length, 4);
    for (final course in CourseCatalog.courses) {
      expect(course.description, isNotEmpty);
      expect(course.objective, isNotEmpty);
      expect(course.disciplines, isNotEmpty);
    }
  });

  test('cada disciplina da matriz está ligada a uma trilha executável', () {
    expect(CourseCatalog.trailIds.keys.toSet(), QuestionGenerator.topics.toSet());
    expect(CourseCatalog.trailIds.values.toSet().length, 26);
    for (final course in CourseCatalog.courses) {
      final trails = CourseCatalog.trailsFor(course.type, SampleContent.trails);
      expect(trails.length, course.disciplines.length);
      expect(trails.map((t) => t.id).toList(),
          course.disciplines.map((d) => CourseCatalog.trailIds[d]).toList());
      for (final trail in trails) {
        for (final module in trail.modules.where((m) => !m.isFinalExam)) {
          expect(module.lessonText, isNotEmpty, reason: module.id);
          expect(SampleContent.quizzes.any((q) => q.id == module.quizId), isTrue);
        }
      }
    }
  });

  test('novas unidades seguem a ementa e contêm questões próprias', () {
    expect(ExtendedContent.disciplines.length, 21);
    final ids = <String>{};
    for (final discipline in ExtendedContent.disciplines) {
      expect(discipline.lessons.map((l) => l.title).toList(),
          QuestionGenerator.unitsFor(discipline.title).map((u) => u.label).toList());
      for (final lesson in discipline.lessons) {
        expect(lesson.summary, isNotEmpty);
        expect(lesson.questions.length, 2);
        for (final question in lesson.questions) {
          expect(ids.add(question.id), isTrue);
          expect(question.prompt, isNot(contains('Qual alternativa descreve')));
          expect(question.explanation, isNotEmpty);
          expect(question.options.toSet().length, 4);
        }
      }
    }
    expect(ids.length, 126);
  });

  test('mesma disciplina compartilha progresso entre cursos', () async {
    final student = MemoryStudentRepository();
    final content = MemoryContentRepository(studentRepository: student);
    final before = await content.getTrails();
    final electronic = CourseCatalog.trailsFor(TechnicalCourse.electronics, before).first;
    final quiz = await content.getQuiz(electronic.modules.first.quizId!);
    await student.submitQuiz(quiz, [
      for (final q in quiz.questions)
        AnswerRecord(questionId: q.id, selectedIndex: q.correctIndex, correct: true),
    ]);
    final after = await content.getTrails();
    for (final course in CourseCatalog.courses) {
      final same = CourseCatalog.trailsFor(course.type, after)
          .firstWhere((t) => t.id == electronic.id);
      expect(same.modules.first.status, ModuleStatus.done);
      expect(same.modules[1].status, ModuleStatus.current);
    }
  });
}
