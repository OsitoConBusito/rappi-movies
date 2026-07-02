import 'package:app/src/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Español por defecto (ignora el locale del sistema). Restaura el idioma
  // guardado antes de renderizar, evitando un parpadeo en el primer frame.
  await restoreSavedLocale();
  runApp(
    TranslationProvider(
      child: const ProviderScope(child: MarqueeApp()),
    ),
  );
}
