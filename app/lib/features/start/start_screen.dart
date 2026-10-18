import 'package:flutter/material.dart';

import '../../app/theme.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.bolt, size: 44, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gabaritou',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Da primeira faísca ao domínio da matéria.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                  const SizedBox(height: 36),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (_) => const StudentShell()),
                    ),
                    icon: const Icon(Icons.school_outlined),
                    label: const Text('Entrar como aluno'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TeacherDashboardScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.dashboard_outlined),
                    label: const Text('Entrar como professor'),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Versão de desenvolvimento: dados de exemplo, sem login.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
