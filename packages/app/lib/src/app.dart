import 'package:design_system/design_system.dart';
import 'package:feature_catalog/feature_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n/i18n.dart';

/// Raíz de la app. Aplica los temas claro/oscuro de MARQUEE y el locale activo
/// (gestionado por slang vía [TranslationProvider]).
class MarqueeApp extends StatelessWidget {
  const MarqueeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeData = TranslationProvider.of(context);

    return MaterialApp(
      title: 'MARQUEE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      locale: localeData.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const CatalogHomePage(),
    );
  }
}
