import 'package:flutter/material.dart';

import '../features/start/start_screen.dart';
import 'dependencies.dart';
import 'theme.dart';

class GabariteiApp extends StatelessWidget {
  const GabariteiApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return Dependencies(
      value: dependencies,
      child: MaterialApp(
        title: 'Gabaritei',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const StartScreen(),
      ),
    );
  }
}
