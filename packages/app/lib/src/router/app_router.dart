import 'package:app/src/pages/about_page.dart';
import 'package:app/src/widgets/adaptive_nav_shell.dart';
import 'package:feature_catalog/feature_catalog.dart';
import 'package:go_router/go_router.dart';

/// Router de la app. Un `StatefulShellRoute` da la navegación **adaptativa**
/// (bottom nav / rail / sidebar) preservando el estado de cada rama; el detalle
/// se abre como ruta de nivel superior.
final appRouter = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AdaptiveNavShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => CatalogHomePage(
                onOpenMedia: (media) => context.push(
                  '/media/${media.type.name}/${media.id}',
                  extra: media,
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => SearchPage(
                onOpenMedia: (media) => context.push(
                  '/media/${media.type.name}/${media.id}',
                  extra: media,
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/about',
              builder: (context, state) => const AboutPage(),
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
        final extra = state.extra;
        return MediaDetailPage(
          type: isTv ? MediaType.tv : MediaType.movie,
          id: id,
          preview: extra is Media ? extra : null,
          onOpenMedia: (media) => context.push(
            '/media/${media.type.name}/${media.id}',
            extra: media,
          ),
        );
      },
    ),
  ],
);
