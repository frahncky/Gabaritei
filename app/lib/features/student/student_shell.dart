import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../ranking/ranking_screen.dart';
import '../trails/trails_screen.dart';

/// Estrutura do app do aluno: quatro abas com barra inferior.
///
/// Quando um desafio termina, as telas chamam [onDataChanged], que
/// recria a aba atual para recarregar XP, missões e ranking.
class StudentShell extends StatefulWidget {
  const StudentShell({super.key});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _tab = 0;
  final List<int> _revisions = List<int>.filled(4, 0);

  void _goTo(int tab) => setState(() => _tab = tab);

  /// Recria somente a aba cuja atividade alterou os dados. As demais mantêm
  /// rolagem e estado local quando o aluno alterna pela navegação inferior.
  void _refresh() => setState(() => _revisions[_tab]++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            KeyedSubtree(
              key: ValueKey('home-${_revisions[0]}'),
              child: HomeScreen(
                onDataChanged: _refresh,
                onOpenTrails: () => _goTo(1),
              ),
            ),
            KeyedSubtree(
              key: ValueKey('trails-${_revisions[1]}'),
              child: TrailsScreen(onDataChanged: _refresh),
            ),
            KeyedSubtree(
              key: ValueKey('ranking-${_revisions[2]}'),
              child: const RankingScreen(),
            ),
            KeyedSubtree(
              key: ValueKey('profile-${_revisions[3]}'),
              child: const ProfileScreen(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Trilhas',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Ranking',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
