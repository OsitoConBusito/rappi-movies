import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Banner no intrusivo que aparece cuando no hay conexión real. La app sigue
/// mostrando el contenido cacheado (offline-first), así que el banner solo
/// informa, no bloquea.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline =
        ref.watch(connectionStatusProvider).value == ConnectionStatus.offline;
    final colors = context.colors;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: !isOffline
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              color: colors.elevated,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(
                    child: Text(
                      context.t.offline.banner,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
