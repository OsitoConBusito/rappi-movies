import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:i18n/i18n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Pantalla "Acerca de": autor de la app y su aplicación publicada, gigbook.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _developer = 'Juan Cano';
  static const _webUrl = 'https://gigbook.app';
  static const _appStoreUrl =
      'https://apps.apple.com/co/app/gigbook/id6774455071';
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=app.gigbook.gigbook_app';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              'MARQUEE',
              style: textTheme.displayMedium?.copyWith(color: colors.accent),
            ),
            const SizedBox(height: AppSpacing.xxl),
            _Label(text: t.about.madeBy),
            const SizedBox(height: AppSpacing.sm),
            Text(_developer, style: textTheme.headlineMedium),
            Text(
              t.about.role,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            _Label(text: t.about.otherApp),
            const SizedBox(height: AppSpacing.sm),
            Text('gigbook', style: textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _LinkTile(icon: Icons.language, label: t.about.web, url: _webUrl),
            const SizedBox(height: AppSpacing.sm),
            _LinkTile(
              icon: Icons.apple,
              label: t.about.appStore,
              url: _appStoreUrl,
            ),
            const SizedBox(height: AppSpacing.sm),
            _LinkTile(
              icon: Icons.shop_2_outlined,
              label: t.about.playStore,
              url: _playStoreUrl,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: context.colors.textMuted,
        letterSpacing: 1,
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.icon, required this.label, required this.url});

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => unawaited(
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: colors.accent, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
