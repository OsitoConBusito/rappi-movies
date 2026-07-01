import 'package:app/src/home_placeholder.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Raíz de la app. Aplica los temas claro/oscuro de MARQUEE; el `themeMode`
/// se hará configurable en una iteración posterior (persistido en prefs).
class MarqueeApp extends StatelessWidget {
  const MarqueeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MARQUEE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HomePlaceholder(),
    );
  }
}
