import 'package:flutter_test/flutter_test.dart';
import 'package:gabaritei/data/local/local_store.dart';
import 'package:gabaritei/data/memory/memory_repositories.dart';
import 'package:gabaritei/domain/services/question_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('reabrir gerador com a mesma sequência não sobrescreve a questão anterior', () async {
    SharedPreferences.setMockInitialValues({});
    final first = QuestionGenerator.generate(topic: 'Eletricidade básica', sequence: 1);
    final repo = (await LocalStore.open()).contentRepository();
    await repo.saveQuestion(first);
    final second = QuestionGenerator.generate(topic: 'Eletricidade básica', sequence: 1);
    expect(second.id, isNot(first.id));
    expect(second.prompt, first.prompt);
    final reopened = (await LocalStore.open()).contentRepository();
    await reopened.saveQuestion(second);
    final saved = await (await LocalStore.open()).contentRepository().getCreatedQuestions();
    expect(saved.map((q) => q.id), [first.id, second.id]);
    expect(saved.last.figure!.toJson(), second.figure!.toJson());
  });

  test('falha de persistência é propagada e permite tentar novamente', () async {
    var failing = true;
    final repo = MemoryContentRepository(onChanged: (_) async {
      if (failing) throw StateError('disco indisponível');
    });
    final q = QuestionGenerator.generate(topic: 'Circuitos CC', sequence: 1);
    await expectLater(repo.saveQuestion(q), throwsStateError);
    expect(await repo.getCreatedQuestions(), isEmpty);
    failing = false;
    await repo.saveQuestion(q);
    expect((await repo.getCreatedQuestions()).single.id, q.id);
  });

  test('salvamentos concorrentes preservam ambas as questões', () async {
    final repo = MemoryContentRepository(onChanged: (_) async {
      await Future<void>.delayed(Duration.zero);
    });
    final first = QuestionGenerator.generate(topic: 'Circuitos CC', sequence: 1);
    final second = QuestionGenerator.generate(topic: 'Circuitos CC', sequence: 2);
    await Future.wait([repo.saveQuestion(first), repo.saveQuestion(second)]);
    expect((await repo.getCreatedQuestions()).map((q) => q.id), [first.id, second.id]);
  });
}
