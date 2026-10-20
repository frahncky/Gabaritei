import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../domain/rules/level_rules.dart';
import '../../shared/brand.dart';
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
      child: Scaffold(
        // Mesmo fundo do splash, para a abertura não "piscar".
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 3),
                    const Center(
                      child: GabariteiMark(size: 96, withBackground: false),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Gabaritei',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        fontSize: 44,
                        letterSpacing: -1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Da primeira faísca ao domínio da matéria.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, color: AppColors.mutedOnInk),
                    ),
                    const SizedBox(height: 32),
                    const _LevelLadder(),
                    const Spacer(flex: 4),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.amber,
                        foregroundColor: AppColors.ink,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                            builder: (_) => const StudentShell()),
                      ),
                      icon: const Icon(Icons.school_outlined),
                      label: const Text('Entrar como aluno'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: AppColors.inkSoft, width: 1.5),
                        minimumSize: const Size.fromHeight(52),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const TeacherDashboardScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.dashboard_outlined),
                      label: const Text('Entrar como professor'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Versão de desenvolvimento: dados de exemplo, sem login.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12, color: AppColors.mutedOnInk),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
