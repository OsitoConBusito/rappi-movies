import 'package:app/src/widgets/offline_banner.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:i18n/i18n.dart';

/// Un destino del nav.
class NavDestinationData {
  const NavDestinationData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Shell de navegación **adaptativo**: bottom nav (móvil), icon rail (tablet) o
/// sidebar (desktop), según el ancho. El offline banner va sobre el contenido.
class AdaptiveNavShell extends StatelessWidget {
  const AdaptiveNavShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _go(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final destinations = [
      NavDestinationData(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: t.nav.home,
      ),
      NavDestinationData(
        icon: Icons.search_outlined,
        selectedIcon: Icons.search_rounded,
        label: t.nav.search,
      ),
      NavDestinationData(
        icon: Icons.info_outline_rounded,
        selectedIcon: Icons.info_rounded,
        label: t.nav.about,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final device = AppBreakpoints.of(constraints.maxWidth);
        final content = Column(
          children: [
            const OfflineBanner(),
            Expanded(child: navigationShell),
          ],
        );

        if (device == DeviceClass.mobile) {
          return Scaffold(
            body: SafeArea(bottom: false, child: content),
            bottomNavigationBar: AnimatedBottomNav(
              destinations: destinations,
              selectedIndex: navigationShell.currentIndex,
              onSelected: _go,
            ),
          );
        }

        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                _SideNav(
                  destinations: destinations,
                  selectedIndex: navigationShell.currentIndex,
                  onSelected: _go,
                  extended: device == DeviceClass.desktop,
                ),
                Expanded(child: content),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Bottom nav con micro-interacción: una **píldora acento** que se desliza al
/// tab seleccionado (spring), con el ícono escalando sobre ella.
class AnimatedBottomNav extends StatelessWidget {
  const AnimatedBottomNav({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<NavDestinationData> destinations;
  final int selectedIndex;
  final void Function(int index) onSelected;

  static const double _pillWidth = 56;
  static const double _pillHeight = 34;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.hover)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / destinations.length;
              final pillLeft =
                  tabWidth * selectedIndex + (tabWidth - _pillWidth) / 2;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 340),
                    curve: Curves.easeOutBack,
                    top: 8,
                    left: pillLeft,
                    child: Container(
                      width: _pillWidth,
                      height: _pillHeight,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        Expanded(
                          child: _NavTab(
                            data: destinations[i],
                            selected: i == selectedIndex,
                            onTap: () => onSelected(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final NavDestinationData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onAccent = Theme.of(context).colorScheme.onPrimary;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: Center(
              child: AnimatedScale(
                scale: selected ? 1.1 : 1,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
                child: Icon(
                  selected ? data.selectedIcon : data.icon,
                  size: 22,
                  color: selected ? onAccent : colors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: selected ? colors.accent : colors.textMuted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(data.label),
          ),
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    required this.extended,
  });

  final List<NavDestinationData> destinations;
  final int selectedIndex;
  final void Function(int index) onSelected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(right: BorderSide(color: colors.hover)),
      ),
      child: NavigationRail(
        extended: extended,
        minWidth: AppBreakpoints.railWidth,
        minExtendedWidth: AppBreakpoints.sidebarWidth,
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        onDestinationSelected: onSelected,
        indicatorColor: colors.accent,
        labelType: extended ? null : NavigationRailLabelType.none,
        selectedIconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        unselectedIconTheme: IconThemeData(color: colors.textSecondary),
        selectedLabelTextStyle: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: colors.textSecondary),
        leading: _Brand(extended: extended),
        destinations: [
          for (final d in destinations)
            NavigationRailDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: Text(d.label),
            ),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: extended
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond_outlined, color: colors.accent, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Text('MARQUEE', style: Theme.of(context).textTheme.titleMedium),
              ],
            )
          : Icon(Icons.diamond_outlined, color: colors.accent, size: 22),
    );
  }
}
