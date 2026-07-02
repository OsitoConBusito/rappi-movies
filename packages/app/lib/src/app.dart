import 'package:app/src/router/app_router.dart';
import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Raíz de la app. Aplica los temas claro/oscuro de MARQUEE, el modo de tema a
/// demanda y el locale activo (slang vía [TranslationProvider]).
class MarqueeApp extends ConsumerWidget {
  const MarqueeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeData = TranslationProvider.of(context);
    final themeMode = ref.watch(themeModeControllerProvider);

    return MaterialApp.router(
      title: 'MARQUEE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: localeData.flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: appRouter,
    );
  }
}
