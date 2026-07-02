import 'package:app/src/app.dart';
import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Español por defecto (ignora el locale del sistema) y tema guardado; se
  // restauran antes de renderizar para evitar un parpadeo en el primer frame.
  await restoreSavedLocale();
  await restoreSavedThemeMode();
  runApp(
    TranslationProvider(
      child: const ProviderScope(child: MarqueeApp()),
    ),
  );
}
