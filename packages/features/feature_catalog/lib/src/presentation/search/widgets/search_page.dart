import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_catalog/src/domain/entities/media.dart';
import 'package:feature_catalog/src/presentation/browse/failure_l10n.dart';
import 'package:feature_catalog/src/presentation/browse/widgets/media_poster_tile.dart';
import 'package:feature_catalog/src/presentation/search/providers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

/// Pantalla de búsqueda (HU-3): campo con debounce, filtro por tipo y grid de
/// resultados combinados. Estados inicial, vacío, error/offline.
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({this.onOpenMedia, super.key});

  final void Function(Media media)? onOpenMedia;

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    ref.read(searchResultsProvider.notifier).search(query);
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final results = ref.watch(searchResultsProvider);
    final filter = ref.watch(selectedSearchFilterProvider);
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: t.search.hint,
                  filled: true,
                  fillColor: colors.surface,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _clear,
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            _FilterChips(selected: filter),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildBody(results, filter, t)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    AsyncValue<List<Media>> results,
    SearchFilter filter,
    Translations t,
  ) {
    final query = _controller.text.trim();

    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _Message(
        icon: Icons.wifi_off_rounded,
        text: error is NetworkFailure
            ? t.search.offline
            : (error is Failure ? error.localized(t) : t.errors.unknown),
      ),
      data: (medias) {
        if (query.isEmpty) {
          return _Message(icon: Icons.search_rounded, text: t.search.initial);
        }
        final filtered = _applyFilter(medias, filter);
        if (filtered.isEmpty) {
          return _Message(
            icon: Icons.search_off_rounded,
            text: t.search.noResults(query: query),
          );
        }
        return _ResultsGrid(medias: filtered, onOpen: widget.onOpenMedia);
      },
    );
  }

  List<Media> _applyFilter(List<Media> medias, SearchFilter filter) =>
      switch (filter) {
        SearchFilter.all => medias,
        SearchFilter.movies =>
          medias.where((media) => media.type == MediaType.movie).toList(),
        SearchFilter.series =>
          medias.where((media) => media.type == MediaType.tv).toList(),
      };
}

class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.selected});

  final SearchFilter selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final items = <(SearchFilter, String)>[
      (SearchFilter.all, t.search.filters.all),
      (SearchFilter.movies, t.search.filters.movies),
      (SearchFilter.series, t.search.filters.series),
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final (filter, label) = items[index];
          return _Chip(
            label: label,
            active: filter == selected,
            onTap: () =>
                ref.read(selectedSearchFilterProvider.notifier).select(filter),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? colors.accent : colors.surface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: active
                ? Theme.of(context).colorScheme.onPrimary
                : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.medias, required this.onOpen});

  final List<Media> medias;
  final void Function(Media media)? onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppBreakpoints.gridColumns(constraints.maxWidth),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 0.5,
          ),
          itemCount: medias.length,
          itemBuilder: (context, index) {
            final media = medias[index];
            return MediaPosterTile(
              media: media,
              showTypeBadge: true,
              onTap: () => onOpen?.call(media),
            );
          },
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: colors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
