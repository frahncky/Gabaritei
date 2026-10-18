import 'package:flutter/foundation.dart';

import '../../domain/models/content.dart';
import '../../domain/rules/xp_rules.dart';

/// Estado de um desafio em andamento.
///
/// Fluxo de cada questão: escolher alternativa → confirmar → ver se
/// acertou (com explicação) → avançar. Não depende de widgets, então
/// pode ser testado isoladamente (ver `test/quiz_controller_test.dart`).
class QuizController extends ChangeNotifier {
  QuizController(this.quiz) : assert(quiz.questions.isNotEmpty);

  final Quiz quiz;

  int _index = 0;
  int? _selected;
  bool _hintUsed = false;
  bool _revealed = false;
  final List<AnswerRecord> _answers = [];

  int get index => _index;
  int get total => quiz.questions.length;
  Question get current => quiz.questions[_index];
  int? get selected => _selected;
  bool get hintUsed => _hintUsed;

  /// Verdadeiro depois de confirmar: mostra se acertou e a explicação.
  bool get revealed => _revealed;

  bool get isLast => _index == total - 1;
  bool get isFinished => _answers.length == total && _revealed && isLast;

  List<AnswerRecord> get answers => List.unmodifiable(_answers);

  bool get canUseHint => current.hint != null && !_hintUsed && !_revealed;

  bool? get lastAnswerCorrect => _answers.isEmpty ? null : _answers.last.correct;

  /// Acertos seguidos até agora.
  int get currentStreak {
    var streak = 0;
    for (final a in _answers.reversed) {
      if (!a.correct) break;
      streak++;
    }
    return streak;
  }

  /// O combo vale a partir de [XpRules.comboThreshold] acertos seguidos.
  bool get comboActive => currentStreak >= XpRules.comboThreshold;

  /// XP acumulado até o momento (sem o bônus de conclusão).
  int get partialXp => XpRules.score(_answers).total;

  void select(int optionIndex) {
    if (_revealed) return;
    if (optionIndex < 0 || optionIndex >= current.options.length) return;
    _selected = optionIndex;
    notifyListeners();
  }

  void useHint() {
    if (!canUseHint) return;
    _hintUsed = true;
    notifyListeners();
  }

  void confirm() {
    final choice = _selected;
    if (_revealed || choice == null) return;
    _answers.add(AnswerRecord(
      questionId: current.id,
      selectedIndex: choice,
      correct: current.isCorrect(choice),
      usedHint: _hintUsed,
    ));
    _revealed = true;
    notifyListeners();
  }

  /// Avança para a próxima questão. Na última, não faz nada (o desafio
  /// terminou e a tela deve enviar o resultado).
  void next() {
    if (!_revealed || isLast) return;
    _index++;
    _selected = null;
    _hintUsed = false;
    _revealed = false;
    notifyListeners();
  }
}
