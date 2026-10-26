/// Regras do banco de questões criado pelo professor.
library;

import '../models/content.dart';

class QuestionBankRules {
  QuestionBankRules._();

  /// Devolve [question] pronta para entrar em [bank] sem apagar outra.
  ///
  /// O gerador cria ids determinísticos por `sequence`, e a sequência
  /// recomeça a cada vez que o professor abre o painel. Por isso o id pode
  /// repetir o de uma questão já salva:
  /// - id livre: a questão entra como veio;
  /// - mesmo id e mesmo conteúdo: é a mesma questão (toque duplo em
  ///   "Adicionar"), e o id é mantido para não duplicar;
  /// - mesmo id e conteúdo diferente: recebe o primeiro sufixo livre
  ///   (`-2`, `-3`...).
  static Question admit(Question question, Iterable<Question> bank) {
    final byId = {for (final q in bank) q.id: q};
    final same = byId[question.id];
    if (same == null || sameContent(same, question)) return question;
    var suffix = 2;
    while (byId.containsKey('${question.id}-$suffix')) {
      final candidate = byId['${question.id}-$suffix']!;
      if (sameContent(candidate, question)) {
        return withId(question, candidate.id);
      }
      suffix++;
    }
    return withId(question, '${question.id}-$suffix');
  }

  /// Compara tudo menos o id.
  static bool sameContent(Question a, Question b) =>
      a.topic == b.topic &&
      a.prompt == b.prompt &&
      _sameList(a.options, b.options) &&
      a.correctIndex == b.correctIndex &&
      a.explanation == b.explanation &&
      a.hint == b.hint &&
      a.visual == b.visual;

  static Question withId(Question q, String id) => Question(
        id: id,
        topic: q.topic,
        prompt: q.prompt,
        options: q.options,
        correctIndex: q.correctIndex,
        explanation: q.explanation,
        hint: q.hint,
        visual: q.visual,
      );

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
