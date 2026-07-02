import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Selector manual de idioma (español/inglés). La elección persiste y refresca
/// tanto la UI como el idioma de los datos de TMDB.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider);
    final t = context.t;

    return PopupMenuButton<AppLocale>(
      icon: Icon(Icons.language_rounded, color: context.colors.textSecondary),
      tooltip: t.language.label,
      onSelected: (locale) => unawaited(
        ref.read(localeControllerProvider.notifier).setLocale(locale),
      ),
      itemBuilder: (context) => [
        _item(locale: AppLocale.es, label: t.language.es, current: current),
        _item(locale: AppLocale.en, label: t.language.en, current: current),
      ],
    );
  }

  PopupMenuItem<AppLocale> _item({
    required AppLocale locale,
    required String label,
    required AppLocale current,
  }) {
    return PopupMenuItem<AppLocale>(
      value: locale,
      child: Row(
        children: [
          Icon(
            locale == current ? Icons.check_rounded : null,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      ),
    );
  }
}
