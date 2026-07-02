import 'package:app/src/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Espera la carga del locale del dispositivo (incluye el diferido) antes de
  // renderizar, para evitar un parpadeo de idioma en el primer frame.
  await LocaleSettings.useDeviceLocale();
  runApp(
    TranslationProvider(
      child: const ProviderScope(child: MarqueeApp()),
    ),
  );
}
