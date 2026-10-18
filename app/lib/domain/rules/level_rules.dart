/// Regras de níveis do Gabaritou.
///
/// Cinco grandes níveis (Faísca → Aprendiz → Afiado → Craque → Domínio).
/// Os quatro primeiros têm três subníveis (I, II, III); Domínio é único.
/// Total: 13 degraus. Os valores de XP são um ponto de partida para
/// calibrar no piloto: os degraus de Faísca são rápidos e o custo cresce
/// aos poucos.
library;

enum LevelTier {
  faisca('Faísca'),
  aprendiz('Aprendiz'),
  afiado('Afiado'),
  craque('Craque'),
  dominio('Domínio');

  const LevelTier(this.label);

  final String label;
}

/// Um degrau da escada de níveis.
class LevelStep {
  const LevelStep({
    required this.index,
    required this.tier,
    required this.sublevel,
    required this.minXp,
  });

  /// Posição na escada (0 a 12).
  final int index;
  final LevelTier tier;

  /// 1, 2 ou 3 para os níveis com subníveis; 0 para Domínio.
  final int sublevel;

  /// XP total necessário para alcançar este degrau.
  final int minXp;

  /// Nome exibido, ex.: "Afiado II" ou "Domínio".
  String get name {
    if (sublevel == 0) return tier.label;
    const romans = ['I', 'II', 'III'];
    return '${tier.label} ${romans[sublevel - 1]}';
  }

  /// Verdadeiro quando este degrau inicia um grande nível (marco).
  bool get isMilestone => sublevel <= 1;

  @override
  String toString() => 'LevelStep($name, $minXp XP)';
}

/// Progresso do aluno dentro da escada de níveis.
class LevelProgress {
  const LevelProgress({
    required this.totalXp,
    required this.current,
    required this.next,
  });

  final int totalXp;
  final LevelStep current;

  /// Próximo degrau, ou `null` se o aluno já está em Domínio.
  final LevelStep? next;

  bool get isMax => next == null;

  /// XP acumulado desde o início do degrau atual.
  int get xpIntoStep => totalXp - current.minXp;

  /// XP que o degrau atual exige para chegar ao próximo.
  int get stepSize => isMax ? 0 : next!.minXp - current.minXp;

  /// XP que falta para o próximo degrau.
  int get xpToNext => isMax ? 0 : next!.minXp - totalXp;

  /// Fração (0 a 1) concluída do degrau atual.
  double get fraction => isMax ? 1 : xpIntoStep / stepSize;
}

class LevelRules {
  LevelRules._();

  /// Custo, em XP, de cada degrau para o seguinte (12 transições).
  static const List<int> _stepCosts = [
    50, 70, 80, // Faísca I → II → III → Aprendiz I
    120, 140, 160, // Aprendiz
    200, 230, 250, // Afiado
    300, 350, 450, // Craque → Domínio
  ];

  static final List<LevelStep> steps = _buildSteps();

  static List<LevelStep> _buildSteps() {
    final result = <LevelStep>[];
    var xp = 0;
    var index = 0;
    for (final tier in LevelTier.values) {
      final sublevels = tier == LevelTier.dominio ? [0] : [1, 2, 3];
      for (final sub in sublevels) {
        result.add(LevelStep(
          index: index,
          tier: tier,
          sublevel: sub,
          minXp: xp,
        ));
        if (index < _stepCosts.length) xp += _stepCosts[index];
        index++;
      }
    }
    return List.unmodifiable(result);
  }

  /// Calcula em que degrau está quem acumulou [totalXp].
  static LevelProgress progressFor(int totalXp) {
    final xp = totalXp < 0 ? 0 : totalXp;
    var currentIndex = 0;
    for (var i = 0; i < steps.length; i++) {
      if (xp >= steps[i].minXp) currentIndex = i;
    }
    final next =
        currentIndex + 1 < steps.length ? steps[currentIndex + 1] : null;
    return LevelProgress(totalXp: xp, current: steps[currentIndex], next: next);
  }

  /// Verdadeiro se ganhar XP de [before] para [after] fez o aluno
  /// alcançar um novo grande nível (ex.: de Aprendiz para Afiado).
  static bool reachedNewTier(int before, int after) {
    return progressFor(after).current.tier.index >
        progressFor(before).current.tier.index;
  }
}
