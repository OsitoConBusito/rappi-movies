import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Estado visible del banner de conectividad.
enum _BannerKind { hidden, offline, restored }

/// Banner de conectividad con micro-interacción: aparece con **borde rojo** al
/// perder internet (persistente; la app sigue sirviendo la caché) y con **borde
/// verde** efímero ("conexión restaurada") al recuperarlo.
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  static const _restoredDuration = Duration(seconds: 3);

  _BannerKind _kind = _BannerKind.hidden;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onStatusChanged(ConnectionStatus? next) {
    if (next == ConnectionStatus.offline) {
      _hideTimer?.cancel();
      setState(() => _kind = _BannerKind.offline);
    } else if (next == ConnectionStatus.online &&
        _kind == _BannerKind.offline) {
      // Solo mostramos "restaurada" si veníamos de estar sin conexión.
      setState(() => _kind = _BannerKind.restored);
      _hideTimer?.cancel();
      _hideTimer = Timer(_restoredDuration, () {
        if (mounted) setState(() => _kind = _BannerKind.hidden);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectionStatusProvider, (previous, next) {
      _onStatusChanged(next.value);
    });

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: _kind == _BannerKind.hidden
          ? const SizedBox.shrink()
          : _ConnectivityBar(kind: _kind, key: ValueKey(_kind)),
    );
  }
}

class _ConnectivityBar extends StatelessWidget {
  const _ConnectivityBar({required this.kind, super.key});

  final _BannerKind kind;

  @override
  Widget build(BuildContext context) {
    final isOffline = kind == _BannerKind.offline;
    final accent = isOffline ? MarqueePalette.error : MarqueePalette.success;
    final colors = context.colors;
    final label = isOffline
        ? context.t.offline.banner
        : context.t.offline.restored;
    final icon = isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      builder: (context, value, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.elevated,
          border: Border(
            bottom: BorderSide(color: accent, width: 2.5 * value),
          ),
        ),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: accent),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                label,
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
