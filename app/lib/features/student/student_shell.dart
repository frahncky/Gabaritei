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
  int _version = 0;

  void _goTo(int tab) => setState(() => _tab = tab);

  void _refresh() => setState(() => _version++);

  @override
  Widget build(BuildContext context) {
    final Widget page = switch (_tab) {
      0 => HomeScreen(onDataChanged: _refresh, onOpenTrails: () => _goTo(1)),
      1 => TrailsScreen(onDataChanged: _refresh),
      2 => const RankingScreen(),
      _ => const ProfileScreen(),
    };

    return Scaffold(
      body: SafeArea(
        child: KeyedSubtree(key: ValueKey('$_tab-$_version'), child: page),
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
