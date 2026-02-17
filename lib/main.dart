import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/app_shell/presentation/pages/app_shell_page.dart';

void main() {
  configureDependencies();
  runApp(const TorcavApp());
}

class TorcavApp extends StatelessWidget {
  const TorcavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Torcav Wi-Fi Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AppShellPage(),
    );
  }
}
