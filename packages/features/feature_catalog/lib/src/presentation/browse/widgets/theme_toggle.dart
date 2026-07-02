import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Botón que alterna el tema (claro/oscuro) a demanda; la elección persiste.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeControllerProvider) == ThemeMode.dark;

    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: context.colors.textSecondary,
      ),
      tooltip: context.t.theme.toggle,
      onPressed: () =>
          unawaited(ref.read(themeModeControllerProvider.notifier).toggle()),
    );
  }
}
