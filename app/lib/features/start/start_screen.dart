import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../domain/rules/level_rules.dart';
import '../../shared/brand.dart';
import '../../shared/widgets.dart';
import '../student/student_shell.dart';
import '../teacher/teacher_dashboard_screen.dart';

/// Tela de entrada.
///
/// Por enquanto só escolhe o perfil (aluno ou professor), para facilitar
/// o desenvolvimento. Quando houver backend, aqui entra o login.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      // O fundo (o mesmo ground do splash, com a grade) vem da rota.
      child: Scaffold(
        body: DecoratedBox(
          // Brilho azul discreto atrás do símbolo, como no banner: dá
          // profundidade sem tingir a tela toda.
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.45),
              radius: 0.7,
              colors: [
                AppColors.progress.withValues(alpha: 0.12),
                AppColors.progress.withValues(alpha: 0),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                // Em telas baixas (ou deitadas) o conteúdo rola em vez de
                // estourar; nas normais, os espaços flexíveis preenchem.
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(child: _content(context)),
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

  Widget _content(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 2),
          const Center(child: AnimatedGabariteiMark(size: 96, repeat: true)),
          const SizedBox(height: 24),
          const Text(
            'Estude · Jogue · Domine',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.skyOnInk,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Gabaritei',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              fontSize: 44,
              letterSpacing: -1,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Da primeira faísca ao domínio da matéria.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.mutedOnInk),
          ),
          const SizedBox(height: 32),
          const _LevelLadder(),
          const SizedBox(height: 40),
          const Spacer(),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.amber,
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const StudentShell()),
            ),
            icon: const Icon(Icons.school_outlined),
            label: const Text('Entrar como aluno'),
          ),
          const _RoleHint('Estude por trilhas, ganhe XP e suba no ranking.'),
          const SizedBox(height: 16),
          // Secundária: tonal, sem contorno, na mesma altura da principal.
          FilledButton.icon(
            style: AppTheme.tonalButton.copyWith(
              minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
            ),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TeacherDashboardScreen(),
              ),
            ),
            icon: const Icon(Icons.dashboard_outlined),
            label: const Text('Entrar como professor'),
          ),
          const _RoleHint('Acompanhe a turma e crie desafios.'),
          const SizedBox(height: 24),
          Text(
            keepLastWordsTogether(
              'Versão de desenvolvimento: dados de exemplo, sem login.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: AppColors.mutedOnInk),
          ),
        ],
      ),
    );
  }
}

/// O que cada perfil encontra, logo abaixo do botão de entrada.
class _RoleHint extends StatelessWidget {
  const _RoleHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: AppColors.mutedOnInk),
      ),
    );
  }
}

/// Os cinco níveis em sequência, acendendo do mais fraco ao âmbar pleno.
class _LevelLadder extends StatelessWidget {
  const _LevelLadder();

  @override
  Widget build(BuildContext context) {
    const tiers = LevelTier.values;
    return Semantics(
      label: 'Níveis: ${tiers.map((t) => t.label).join(', ')}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var i = 0; i < tiers.length; i++)
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(
                        alpha: 0.25 + 0.75 * i / (tiers.length - 1),
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tiers[i].label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: i == tiers.length - 1
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: i == tiers.length - 1
                          ? AppColors.amberOnInk
                          : AppColors.mutedOnInk,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
