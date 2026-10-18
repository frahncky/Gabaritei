import 'package:flutter/widgets.dart';

import '../data/memory/memory_repositories.dart';
import '../domain/repositories/repositories.dart';

/// Reúne os repositórios usados pelo app.
///
/// Para trocar o backend, crie aqui uma fábrica que devolva as novas
/// implementações (por exemplo `AppDependencies.supabase(...)`) e use-a
/// em `main.dart`. As telas não precisam mudar.
class AppDependencies {
  AppDependencies({
    required this.students,
    required this.content,
    required this.ranking,
    required this.teacher,
  });

  /// Versão sem servidor, com dados de exemplo em memória.
  factory AppDependencies.inMemory() {
    final students = MemoryStudentRepository();
    return AppDependencies(
      students: students,
      content: MemoryContentRepository(),
      ranking: MemoryRankingRepository(students),
      teacher: MemoryTeacherRepository(),
    );
  }

  final StudentRepository students;
  final ContentRepository content;
  final RankingRepository ranking;
  final TeacherRepository teacher;
}

/// Disponibiliza [AppDependencies] para toda a árvore de widgets.
///
/// Uso numa tela: `final deps = Dependencies.of(context);`
class Dependencies extends InheritedWidget {
  const Dependencies({super.key, required this.value, required super.child});

  final AppDependencies value;

  static AppDependencies of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<Dependencies>();
    assert(widget != null, 'Dependencies não encontrado na árvore.');
    return widget!.value;
  }

  @override
  bool updateShouldNotify(Dependencies oldWidget) => value != oldWidget.value;
}
