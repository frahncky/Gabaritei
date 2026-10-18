import 'package:flutter/material.dart';

import '../../app/dependencies.dart';
import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../shared/widgets.dart';
import 'quiz_controller.dart';
import 'result_screen.dart';

/// Abre um desafio. O `Future` termina quando o aluno conclui ou sai.
Future<void> openQuiz(BuildContext context, String quizId) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => QuizScreen(quizId: quizId)),
  );
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.quizId});

  final String quizId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Future<Quiz>? _quiz;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quiz ??= Dependencies.of(context).content.getQuiz(widget.quizId);
  }

  Future<void> _finish(QuizController controller) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final result = await Dependencies.of(context)
        .students
        .submitQuiz(controller.quiz, controller.answers);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Material garante fundo enquanto o desafio carrega.
    return Material(
      color: AppColors.ground,
      child: AsyncView<Quiz>(
        future: _quiz!,
        builder: (context, quiz) => _QuizBody(
          quiz: quiz,
          submitting: _submitting,
          onFinish: _finish,
        ),
      ),
    );
  }
}

class _QuizBody extends StatefulWidget {
  const _QuizBody({
    required this.quiz,
    required this.submitting,
    required this.onFinish,
  });

  final Quiz quiz;
  final bool submitting;
  final Future<void> Function(QuizController controller) onFinish;

  @override
  State<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends State<_QuizBody> {
  late final QuizController _controller = QuizController(widget.quiz);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final c = _controller;
        final question = c.current;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Sair do desafio',
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(widget.quiz.title, style: const TextStyle(fontSize: 16)),
            actions: [
              if (c.comboActive)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Chip(
                    avatar: const Icon(Icons.bolt, size: 16, color: AppColors.amberOnInk),
                    label: const Text('Combo x2'),
                    labelStyle: const TextStyle(
                      color: AppColors.amberOnInk,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.ink,
                    side: BorderSide.none,
                  ),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              _ProgressDots(controller: c),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.topic.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.prompt,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (c.hintUsed && question.hint != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.amberSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline,
                                  size: 18, color: AppColors.amberText),
                              const SizedBox(width: 8),
                              Expanded(child: Text(question.hint!)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < question.options.length; i++) ...[
                _OptionTile(
                  letter: String.fromCharCode(65 + i),
                  text: question.options[i],
                  state: _optionState(c, i),
                  onTap: () => c.select(i),
                ),
                const SizedBox(height: 10),
              ],
              if (c.revealed) _Feedback(controller: c),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  if (!c.revealed) ...[
                    OutlinedButton.icon(
                      onPressed: c.canUseHint ? c.useHint : null,
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: const Text('Dica −10 XP'),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(child: _primaryButton(c)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _primaryButton(QuizController c) {
    if (!c.revealed) {
      return FilledButton(
        onPressed: c.selected == null ? null : c.confirm,
        child: const Text('Confirmar'),
      );
    }
    if (!c.isLast) {
      return FilledButton(onPressed: c.next, child: const Text('Próxima'));
    }
    return FilledButton(
      onPressed: widget.submitting ? null : () => widget.onFinish(c),
      child: Text(widget.submitting ? 'Enviando…' : 'Ver resultado'),
    );
  }

  _OptionState _optionState(QuizController c, int i) {
    if (!c.revealed) {
      return c.selected == i ? _OptionState.selected : _OptionState.idle;
    }
    if (i == c.current.correctIndex) return _OptionState.correct;
    if (i == c.selected) return _OptionState.wrong;
    return _OptionState.idle;
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final answers = controller.answers;
    return Semantics(
      label: 'Questão ${controller.index + 1} de ${controller.total}',
      child: Row(
        children: [
          for (var i = 0; i < controller.total; i++) ...[
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: i < answers.length
                      ? (answers[i].correct ? AppColors.success : AppColors.error)
                      : i == controller.index
                          ? AppColors.blue
                          : AppColors.line,
                ),
              ),
            ),
            if (i < controller.total - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

enum _OptionState { idle, selected, correct, wrong }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.letter,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (border, fill, badge, badgeText) = switch (state) {
      _OptionState.idle => (AppColors.line, AppColors.surface, AppColors.ground, AppColors.ink),
      _OptionState.selected => (AppColors.blue, AppColors.blueSoft, AppColors.blue, Colors.white),
      _OptionState.correct => (AppColors.success, const Color(0xFFDCFCE7), AppColors.success, Colors.white),
      _OptionState.wrong => (AppColors.error, AppColors.errorSoft, AppColors.error, Colors.white),
    };
    return Semantics(
      button: true,
      selected: state == _OptionState.selected,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: border,
            width: state == _OptionState.idle ? 1 : 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badge,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(color: badgeText, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  if (state == _OptionState.correct)
                    const Icon(Icons.check_circle, color: AppColors.success),
                  if (state == _OptionState.wrong)
                    const Icon(Icons.cancel, color: AppColors.error),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.controller});

  final QuizController controller;

  @override
  Widget build(BuildContext context) {
    final correct = controller.lastAnswerCorrect ?? false;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFDCFCE7) : AppColors.errorSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? 'Mandou bem!' : 'Quase lá.',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: correct ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(controller.current.explanation),
        ],
      ),
    );
  }
}
