import 'package:flutter/material.dart';

import '../features/start/start_screen.dart';
import 'dependencies.dart';
import 'theme.dart';

class GabaritouApp extends StatelessWidget {
  const GabaritouApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return Dependencies(
      value: dependencies,
      child: MaterialApp(
        title: 'Gabaritou',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const StartScreen(),
      ),
    );
  }
}
