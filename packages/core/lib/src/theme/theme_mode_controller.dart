import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themePrefKey = 'theme_mode';

ThemeMode _initialThemeMode = ThemeMode.dark;

/// Restaura el modo de tema guardado (oscuro por defecto). Debe llamarse en
/// `main` antes de `runApp`, para que el controlador nazca con el valor bueno.
Future<void> restoreSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_themePrefKey);
  _initialThemeMode = ThemeMode.values.firstWhere(
    (mode) => mode.name == saved,
    orElse: () => ThemeMode.dark,
  );
}

/// Controla el modo de tema (claro/oscuro) a demanda; la elección persiste.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => _initialThemeMode;

  /// Alterna entre claro y oscuro.
  Future<void> toggle() =>
      _set(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  Future<void> _set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, mode.name);
  }
}

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);
