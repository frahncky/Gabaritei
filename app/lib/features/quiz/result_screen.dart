import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../domain/models/content.dart';
import '../../domain/models/gamification.dart';
import '../../domain/models/quiz_result.dart';
import '../../domain/rules/level_rules.dart';
import '../../shared/effects/confetti.dart';
import '../../shared/effects/reveal.dart';
import '../../shared/effects/shine.dart';
import '../../shared/format.dart';
import '../../shared/level_card.dart';
import '../../shared/medal_badge.dart';
import '../../shared/motion.dart';

/// Resultado do desafio.
///
/// Comemora na medida do desempenho: gabarito, nível novo e medalha nova
/// ganham um pico curto de festa (faíscas, confete, vibração); nota baixa
/// entra sóbria, só com o XP contando. Tudo segue o [_Script] num único
/// [AnimationController] que para no fim; um toque na tela pula para o
/// estado final, e "Continuar" responde desde o primeiro quadro.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.result});

  final QuizResult result;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

/// Faixas de desempenho, da maior festa para a mais sóbria.
enum _Tier { perfect, great, good, review }

enum _Buzz { light, medium, heavy }

/// Barra do LevelCard: parada no XP antigo, subindo ou no estado final.
enum _LevelPhase { waiting, running, done }

/// Um pico da comemoração: quando (ms) e com que vibração.
typedef _Peak = ({int at, _Buzz buzz});

/// Roteiro da comemoração, em milissegundos desde a abertura da tela.
class _Script {
  factory _Script(QuizResult result) {
    final ratio = result.total == 0 ? 0.0 : result.correctCount / result.total;
    final tier = ratio >= 1
        ? _Tier.perfect
        : ratio >= 0.7
            ? _Tier.great
            : ratio >= 0.4
                ? _Tier.good
                : _Tier.review;
    final cheers = tier == _Tier.perfect || tier == _Tier.great;

    int? levelUpAt;
    var levelMountAt = levelIn.$1;
    if (result.leveledUp) {
      // Quanto a barra do LevelCard leva, depois de montada, para cruzar o
      // nível novo (inverso de easeOutCubic).
      final gained = result.xpAfter - result.xpBefore;
      final reach = gained <= 0
          ? 1.0
          : ((result.levelAfter.current.minXp - result.xpBefore) / gained)
              .clamp(0.0, 1.0)
              .toDouble();
      final t = 1 - math.pow(1 - reach, 1 / 3);
      final toCross = (t * levelCardRun).round();
      // O selo quer cair depois do cartão aparecer e longe do pico do anel;
      // a barra é montada mais tarde para cruzar exatamente nesse momento.
      // Se nem montando na entrada do cartão ela cruza a tempo, o selo
      // espera a barra (nunca chega antes dela).
      final earliest = cheers ? ringClose + 200 : levelIn.$2;
      final target = math.min(math.max(levelIn.$1 + toCross, earliest), 1400);
      levelMountAt = math.max(levelIn.$1, target - toCross);
      levelUpAt = levelMountAt + toCross;
    }

    final medals = result.newMedals.length;
    final medalAt =
        medals == 0 ? null : math.max(medalIn.$2 + 50, (levelUpAt ?? 0) + 300);

    final peaks = <_Peak>[
      if (tier == _Tier.perfect) (at: ringClose, buzz: _Buzz.medium),
      if (tier == _Tier.great) (at: ringClose, buzz: _Buzz.light),
      if (levelUpAt != null) (at: levelUpAt, buzz: _Buzz.heavy),
      if (medalAt != null)
        (
          at: medalAt + 120,
          buzz: levelUpAt == null ? _Buzz.heavy : _Buzz.medium,
        ),
    ]..sort((a, b) => a.at.compareTo(b.at));

    // Confete só nos picos: o anel ao gabaritar; os canhões das laterais no
    // nível novo ou, sem ele, na medalha nova.
    final cannonAt = levelUpAt ?? (medalAt == null ? null : medalAt + 80);
    final confetti = ConfettiPlan([
      if (tier == _Tier.perfect) ...[
        const ConfettiShot.sparks(
          anchor: Alignment.topCenter,
          offset: ringCenter,
          startRadius: 66,
          count: 14,
          delay: Duration(milliseconds: ringClose),
        ),
        const ConfettiShot.burst(
          anchor: Alignment.topCenter,
          offset: ringCenter,
          startRadius: 58,
          count: 40,
          delay: Duration(milliseconds: ringClose + 20),
        ),
      ],
      if (cannonAt != null)
        for (final side in const [-1.0, 1.0])
          ConfettiShot.cannon(
            anchor: side < 0 ? Alignment.bottomLeft : Alignment.bottomRight,
            offset: const Offset(0, -72),
            direction: -math.pi / 2 - side * 0.5,
            count: 18,
            delay: Duration(milliseconds: cannonAt),
          ),
    ]);

    var total = 1500;
    if (levelUpAt != null) total = math.max(total, levelUpAt + 720);
    if (medalAt != null) {
      total = math.max(total, medalAt + (medals - 1) * medalGap + 760);
    }
    total = math.max(total, confetti.duration.inMilliseconds);

    return _Script._(
      tier: tier,
      levelMountAt: levelMountAt,
      levelUpAt: levelUpAt,
      medalAt: medalAt,
      confetti: confetti,
      peaks: peaks,
      total: total,
    );
  }

  const _Script._({
    required this.tier,
    required this.levelMountAt,
    required this.levelUpAt,
    required this.medalAt,
    required this.confetti,
    required this.peaks,
    required this.total,
  });

  // Entrada em cascata: anel → título → XP → nível/medalha → estatísticas.
  static const ringIn = (0, 350);
  static const ringFill = (100, 850);

  /// O arco já parece fechado aqui (easeOutCubic a 88% do trecho).
  static const ringClose = 760;
  static const title = (220, 520);
  static const xpIn = (340, 640);
  static const xpCount = (400, 1100);
  static const xpPop = (1060, 1420);
  static const levelIn = (480, 780);
  static const medalIn = (600, 900);
  static const medalGap = 120;
  static const statsIn = (720, 1020);
  static const reviewIn = (820, 1120);

  /// Duração da barra do [LevelCard], que corre sozinha a partir de
  /// [levelMountAt].
  static final levelCardRun = LevelCard.animationDuration.inMilliseconds;

  /// Centro do anel na área da tela: respiro do topo (28) + meio anel (64).
  static const ringCenter = Offset(0, 28 + _ScoreRing.size / 2);

  final _Tier tier;

  /// Quando o LevelCard é remontado e a barra começa a subir: na entrada do
  /// cartão ou depois, para a barra cruzar o nível novo em [levelUpAt].
  final int levelMountAt;

  /// Quando a barra cruza o nível novo: selo, vibração forte e canhões.
  final int? levelUpAt;
  final int? medalAt;
  final ConfettiPlan confetti;
  final List<_Peak> peaks;
  final int total;

  bool get cheers => tier == _Tier.perfect || tier == _Tier.great;
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final _Script _script = _Script(widget.result);
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _script.total),
  )..addListener(_onTick);

  var _started = false;
  var _skipped = false;
  var _nextPeak = 0;

  /// O LevelCard anima sozinho ao ser montado; ele é remontado em
  /// [_Script.levelMountAt], para a barra subir à vista do aluno e cruzar o
  /// nível novo junto com o selo.
  var _levelPhase = _LevelPhase.waiting;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      // Sem movimento: estado final direto e, havendo pico, uma vibração só.
      _skipped = true;
      _levelPhase = _LevelPhase.done;
      final peaks = _script.peaks;
      if (peaks.isNotEmpty) {
        _buzz(peaks
            .map((p) => p.buzz)
            .reduce((a, b) => a.index >= b.index ? a : b));
      }
      _clock.value = 1;
    } else {
      _clock.forward();
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _onTick() {
    if (_skipped) return;
    final ms = _clock.value * _script.total;
    final peaks = _script.peaks;
    while (_nextPeak < peaks.length && ms >= peaks[_nextPeak].at) {
      _buzz(peaks[_nextPeak++].buzz);
    }
    if (_levelPhase == _LevelPhase.waiting && ms >= _script.levelMountAt) {
      setState(() => _levelPhase = _LevelPhase.running);
    }
  }

  /// Um toque na tela pula a comemoração para o estado final.
  void _skip() {
    if (_skipped || !_clock.isAnimating) return;
    _skipped = true;
    setState(() => _levelPhase = _LevelPhase.done);
    _clock.value = 1;
  }

  static void _buzz(_Buzz buzz) => switch (buzz) {
        _Buzz.light => HapticFeedback.lightImpact(),
        _Buzz.medium => HapticFeedback.mediumImpact(),
        _Buzz.heavy => HapticFeedback.heavyImpact(),
      };

  /// Trecho [from]–[to] (ms) do roteiro, de 0 a 1, com [curve].
  Animation<double> _span(int from, int to, [Curve curve = AppMotion.enter]) {
    final total = _script.total;
    return _clock.drive(CurveTween(
      curve: Interval(
        math.min(from, total) / total,
        math.min(to, total) / total,
        curve: curve,
      ),
    ));
  }

  Animation<double> _enter((int, int) span) => _span(span.$1, span.$2);

  /// Sobe até 1 e volta a 0 no trecho: brilho que não fica na tela.
  Animation<double> _pulse(int from, int to) =>
      _span(from, to, Curves.linear).drive(TweenSequence([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 25,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 75,
        ),
      ]));

  /// Escala 1 → [peak] → 1, com um leve rebote na volta.
  Animation<double> _pop(int from, int to, {double peak = 1.15}) =>
      _span(from, to, Curves.linear).drive(TweenSequence([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: peak)
              .chain(CurveTween(curve: Curves.easeOutCubic)),
          weight: 35,
        ),
        TweenSequenceItem(
          tween: Tween(begin: peak, end: 1.0)
              .chain(CurveTween(curve: AppMotion.reward)),
          weight: 65,
        ),
      ]));

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final script = _script;
    final wrong = result.wrongQuestions;
    final ratio = result.total == 0 ? 0.0 : result.correctCount / result.total;
    final levelUpAt = script.levelUpAt;
    final medalAt = script.medalAt;
    const close = _Script.ringClose;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        // Sem fundo próprio: ground e grade vêm da rota.
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _skip,
                      behavior: HitTestBehavior.translucent,
                      excludeFromSemantics: true,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
                        children: [
                          Center(
                            child: _ScoreRing(
                              correct: result.correctCount,
                              total: result.total,
                              enter: _enter(_Script.ringIn),
                              fill: _enter(_Script.ringFill),
                              // Âmbar é conquista: só quando foi bem. Nota
                              // baixa mostra o placar em azul suave.
                              color: script.cheers
                                  ? AppColors.amber
                                  : AppColors.progress,
                              glow: script.cheers
                                  ? _pulse(close, close + 600)
                                  : null,
                              flash: script.tier == _Tier.perfect
                                  ? _pulse(close, close + 360)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Reveal(
                            animation: _enter(_Script.title),
                            child: Column(
                              children: [
                                Text(
                                  _headline(script.tier),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.text,
                                    fontSize: 34,
                                    fontFamily: AppFonts.display,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  '${result.correctCount} de ${result.total} '
                                  'acertos',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.mutedOnInk,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Reveal(
                            animation: _enter(_Script.xpIn),
                            child: Column(
                              children: [
                                _XpGain(
                                  total: result.xp.total,
                                  count: _enter(_Script.xpCount),
                                  // Pop e estrelinhas só quando foi bem.
                                  pop: script.cheers
                                      ? _pop(_Script.xpPop.$1, _Script.xpPop.$2)
                                      : null,
                                  twinkle: script.cheers && result.xp.total > 0
                                      ? _span(
                                          _Script.xpPop.$1,
                                          _Script.xpPop.$2 + 120,
                                          Curves.linear,
                                        )
                                      : null,
                                ),
                                Text(
                                  _breakdownText(result),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.mutedOnInk,
                                      fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Reveal(
                            animation: _enter(_Script.levelIn),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (levelUpAt != null) ...[
                                  FadeTransition(
                                    opacity: _span(levelUpAt, levelUpAt + 150),
                                    child: ScaleTransition(
                                      alignment: Alignment.centerLeft,
                                      scale: _span(levelUpAt, levelUpAt + 420,
                                              AppMotion.reward)
                                          .drive(Tween(begin: 0.5, end: 1.0)),
                                      child: _Kicker(
                                        result.reachedNewTier
                                            ? 'Novo nível!'
                                            : 'Subiu de nível',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                RepaintBoundary(
                                  child: _maybeSweep(
                                    at: levelUpAt,
                                    radius: LevelCard.radius,
                                    child: LevelCard(
                                      key: ValueKey(_levelPhase),
                                      // Antes de a barra subir, o cartão
                                      // mostra o XP antigo, para não
                                      // adiantar o nível novo.
                                      level: _levelPhase == _LevelPhase.waiting
                                          ? LevelRules.progressFor(
                                              result.xpBefore)
                                          : result.levelAfter,
                                      animateFromXp:
                                          _levelPhase == _LevelPhase.running
                                              ? result.xpBefore
                                              : null,
                                      color: AppColors.inkRaised,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          for (final (i, medal) in result.newMedals.indexed)
                            ..._medalCard(i, medal, medalAt!),
                          const SizedBox(height: 12),
                          Reveal(
                            animation: _enter(_Script.statsIn),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    icon: Icons.local_fire_department,
                                    iconColor: AppColors.amberText,
                                    label: 'Sequência',
                                    value: '${result.streakAfter} '
                                        '${result.streakAfter == 1 ? 'dia' : 'dias'}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MiniStat(
                                    icon: Icons.track_changes,
                                    label: 'Acerto',
                                    value: formatPercent(ratio),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (wrong.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Reveal(
                              animation: _enter(_Script.reviewIn),
                              child: _ReviewCard(questions: wrong),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    // Ação é azul: o âmbar da tela fica só com a conquista
                    // (anel, XP, nível, medalha).
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Continuar'),
                    ),
                  ),
                ],
              ),
              // Por cima de tudo, sem pegar toques; fora com menos movimento.
              if (!AppMotion.reduced(context) && !script.confetti.isEmpty)
                Positioned.fill(
                  child: ConfettiField(
                    plan: script.confetti,
                    clock: _clock,
                    span: _clock.duration!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Faixa de luz no cartão no momento [at]; sem momento, só o cartão.
  Widget _maybeSweep({
    required int? at,
    required double radius,
    required Widget child,
  }) {
    if (at == null) return child;
    return LightSweep(
      progress: _span(at + 60, at + 700, Curves.easeInOutCubic),
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }

  /// Cartão de medalha nova: entra na cascata e, no seu momento, a medalha
  /// surge girando com um halo e uma faixa de luz atravessa o cartão.
  List<Widget> _medalCard(int index, Medal medal, int medalAt) {
    final enter = _Script.medalIn.$1 + index * _Script.medalGap;
    final at = medalAt + index * 150;
    return [
      const SizedBox(height: 12),
      Reveal(
        animation: _span(enter, enter + 300),
        child: RepaintBoundary(
          child: _maybeSweep(
            at: at + 160,
            radius: AppRadii.large,
            child: _DarkCard(
              leading: _MedalReveal(
                medal: medal,
                pop: _span(at, at + 450, AppMotion.reward),
                glow: _pulse(at, at + 700),
              ),
              kicker: 'Nova medalha',
              title: medal.name,
              subtitle: medal.description,
            ),
          ),
        ),
      ),
    ];
  }

  static String _headline(_Tier tier) => switch (tier) {
        _Tier.perfect => 'Gabaritou!',
        _Tier.great => 'Mandou bem!',
        _Tier.good => 'Bom treino!',
        _Tier.review => 'Bora revisar?',
      };

  static String _breakdownText(QuizResult result) {
    final xp = result.xp;
    final parts = <String>['${xp.baseXp} XP de acertos'];
    if (xp.comboXp > 0) parts.add('${xp.comboXp} de combo');
    if (xp.completionXp > 0) parts.add('${xp.completionXp} de conclusão');
    if (xp.hintPenalty > 0) parts.add('−${xp.hintPenalty} de dicas');
    return parts.join(' · ');
  }
}

/// Anel com a fração de acertos: entra, se preenche contando os acertos e,
/// ao fechar bem, acende um halo rápido (com um clarão no gabarito).
class _ScoreRing extends StatelessWidget {
  const _ScoreRing({
    required this.correct,
    required this.total,
    required this.enter,
    required this.fill,
    required this.color,
    this.glow,
    this.flash,
  });

  static const size = 128.0;

  final int correct;
  final int total;
  final Animation<double> enter;
  final Animation<double> fill;

  /// Cor do arco de acertos.
  final Color color;
  final Animation<double>? glow;
  final Animation<double>? flash;

  @override
  Widget build(BuildContext context) {
    final target = total == 0 ? 0.0 : correct / total;
    return Semantics(
      label: '$correct de $total acertos',
      excludeSemantics: true,
      child: RepaintBoundary(
        child: FadeTransition(
          opacity: enter,
          child: ScaleTransition(
            scale: enter.drive(Tween(begin: 0.85, end: 1.0)),
            child: CustomPaint(
              size: const Size.square(size),
              painter: _RingPainter(
                fill: fill,
                target: target,
                color: color,
                glow: glow,
                flash: flash,
              ),
              child: SizedBox.square(
                dimension: size,
                child: Center(
                  child: AnimatedBuilder(
                    animation: fill,
                    builder: (context, _) => Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${(fill.value * correct).round()}',
                            style: const TextStyle(
                                fontSize: 36, color: AppColors.text),
                          ),
                          TextSpan(
                            text: '/$total',
                            style: const TextStyle(
                                fontSize: 18, color: AppColors.mutedOnInk),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fill,
    required this.target,
    required this.color,
    this.glow,
    this.flash,
  }) : super(repaint: Listenable.merge([fill, glow, flash]));

  final Animation<double> fill;
  final double target;
  final Color color;
  final Animation<double>? glow;
  final Animation<double>? flash;

  static const _stroke = 12.0;

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rect = (Offset.zero & size).deflate(_stroke / 2);

    // Halo em volta do anel; passa das bordas e some sozinho.
    final glowValue = glow?.value ?? 0;
    if (glowValue > 0) {
      final radius = size.width / 2 + 24;
      _paint
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            AppColors.amber.withValues(alpha: 0),
            AppColors.amber.withValues(alpha: 0.4 * glowValue),
            AppColors.amber.withValues(alpha: 0),
          ],
          stops: const [0.45, 0.73, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, _paint);
      _paint.shader = null;
    }

    _paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.butt
      ..color = AppColors.track;
    canvas.drawArc(rect, 0, math.pi * 2, false, _paint);

    final sweep = math.pi * 2 * fill.value * target;
    if (sweep <= 0) return;
    _paint
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, _paint);

    // Clarão claro por cima do arco quando ele fecha no gabarito.
    final flashValue = flash?.value ?? 0;
    if (flashValue > 0) {
      _paint.color = AppColors.text.withValues(alpha: 0.7 * flashValue);
      canvas.drawArc(rect, -math.pi / 2, sweep, false, _paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.target != target ||
      oldDelegate.color != color ||
      oldDelegate.glow != glow ||
      oldDelegate.flash != flash;
}

/// "+N XP" contando; quando foi bem, dá um pulo e solta estrelinhas.
class _XpGain extends StatelessWidget {
  const _XpGain({
    required this.total,
    required this.count,
    this.pop,
    this.twinkle,
  });

  final int total;
  final Animation<double> count;
  final Animation<double>? pop;
  final Animation<double>? twinkle;

  @override
  Widget build(BuildContext context) {
    Widget text = AnimatedBuilder(
      animation: count,
      builder: (context, _) => Text(
        '+${formatNumber((count.value * total).round())} XP',
        textAlign: TextAlign.center,
        semanticsLabel: 'Mais $total XP',
        style: const TextStyle(
          color: AppColors.amberOnInk,
          fontSize: 44,
          fontFamily: AppFonts.display,
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
    final pop = this.pop;
    if (pop != null) text = ScaleTransition(scale: pop, child: text);
    final twinkle = this.twinkle;
    if (twinkle != null) {
      text = Twinkle(progress: twinkle, child: text);
    }
    return RepaintBoundary(child: Center(child: text));
  }
}

/// Medalha que surge girando, com um halo âmbar que acende e apaga.
class _MedalReveal extends StatelessWidget {
  const _MedalReveal({
    required this.medal,
    required this.pop,
    required this.glow,
  });

  static const size = 56.0;

  final Medal medal;
  final Animation<double> pop;
  final Animation<double> glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: GlowSpot(
        intensity: glow,
        radius: size * 0.85,
        child: ScaleTransition(
          scale: pop,
          child: RotationTransition(
            turns: pop.drive(Tween(begin: -0.1, end: 0.0)),
            child: MedalBadge(medal: medal, size: size),
          ),
        ),
      ),
    );
  }
}

/// Selo "Novo nível!" acima do LevelCard: tonal, para a barra de XP logo
/// abaixo seguir como o âmbar cheio do bloco.
class _Kicker extends StatelessWidget {
  const _Kicker(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
        decoration: const BoxDecoration(
          color: AppColors.amberSoft,
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.small)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_upward_rounded,
                size: 16, color: AppColors.amberText),
            const SizedBox(width: 4),
            Text(
              text,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.amberText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  const _DarkCard({
    required this.leading,
    required this.kicker,
    required this.title,
    required this.subtitle,
  });

  final Widget leading;
  final String kicker;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.card,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.large)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kicker,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.amberText,
                      fontWeight: FontWeight.w600,
                    )),
                Text(title,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                    )),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.mutedOnInk, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = AppColors.skyOnInk,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Âmbar só para a sequência; o resto é informação, em azul claro.
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.large)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.mutedOnInk, fontSize: 12)),
                Text(value,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Questões erradas com a explicação, para revisar depois.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.questions});

  final List<Question> questions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Para revisar',
                style: Theme.of(context).textTheme.titleMedium),
            for (final q in questions) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cancel, color: AppColors.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.topic,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(q.explanation,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
