import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n/strings.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localePrefKey = 'app_locale';

/// Restaura el idioma guardado (o **español por defecto**, ignorando el locale
/// del dispositivo) y lo aplica a slang. Debe llamarse en `main` antes de
/// `runApp`.
Future<AppLocale> restoreSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_localePrefKey);
  final locale = saved == null
      ? AppLocale.es
      : AppLocaleUtils.instance.parse(saved);
  await LocaleSettings.setLocale(locale);
  return locale;
}

/// Estado del idioma activo. El usuario lo cambia con [setLocale] y la elección
/// persiste; la lectura inicial la hace [restoreSavedLocale] en el arranque.
class LocaleController extends Notifier<AppLocale> {
  @override
  AppLocale build() => LocaleSettings.currentLocale;

  Future<void> setLocale(AppLocale locale) async {
    if (locale == state) return;
    await LocaleSettings.setLocale(locale);
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefKey, locale.languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, AppLocale>(
  LocaleController.new,
);
