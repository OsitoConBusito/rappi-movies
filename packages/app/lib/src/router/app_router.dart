import 'package:app/src/widgets/offline_banner.dart';
import 'package:feature_catalog/feature_catalog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n/i18n.dart';

/// Router de la app. Un `StatefulShellRoute` provee el bottom nav (Inicio /
/// Buscar) preservando el estado de cada rama; el detalle se abre como ruta de
/// nivel superior (cubre el bottom nav).
final appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => CatalogHomePage(
                onOpenMedia: (media) =>
                    context.push('/media/${media.type.name}/${media.id}'),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => SearchPage(
                onOpenMedia: (media) =>
                    context.push('/media/${media.type.name}/${media.id}'),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/media/:type/:id',
      builder: (context, state) {
        final isTv = state.pathParameters['type'] == MediaType.tv.name;
        final id = int.parse(state.pathParameters['id']!);
        return MediaDetailPage(
          type: isTv ? MediaType.tv : MediaType.movie,
          id: id,
        );
      },
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      // SafeArea en el shell: mantiene el banner (y el contenido) por debajo de
      // la status bar. El SafeArea interno de las páginas queda como no-op.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t.nav.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search_rounded),
            label: t.nav.search,
          ),
        ],
      ),
    );
  }
}
