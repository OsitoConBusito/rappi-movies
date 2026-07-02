import 'package:design_system/src/theme/app_theme.dart';
import 'package:design_system/src/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

/// Una opción de [SegmentedPills]: su valor, etiqueta y un icono opcional.
class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Control segmentado con una "píldora" dorada que se **desliza** hacia la
/// opción activa. Los segmentos tienen el mismo ancho y admiten icono; con
/// [width] se pueden alinear varios controles al mismo ancho total.
class SegmentedPills<T> extends StatelessWidget {
  const SegmentedPills({
    required this.options,
    required this.selected,
    required this.onSelected,
    this.textStyle,
    this.iconSize = 18,
    this.width,
    super.key,
  });

  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final TextStyle? textStyle;
  final double iconSize;

  /// Ancho total fijo del control. Útil para alinear varios controles al mismo
  /// ancho; si es null, el control se ajusta a su contenido.
  final double? width;

  static const Duration slideDuration = Duration(milliseconds: 260);

  /// Posición horizontal (−1 izquierda … 1 derecha) de la píldora para el
  /// segmento [index].
  double _alignmentXFor(int index) {
    if (options.length <= 1) return 0;
    return index / (options.length - 1) * 2 - 1;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedIndex = options.indexWhere(
      (option) => option.value == selected,
    );

    final control = Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              duration: slideDuration,
              curve: Curves.easeOutBack,
              tween: Tween<double>(
                end: _alignmentXFor(selectedIndex < 0 ? 0 : selectedIndex),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              builder: (context, x, child) => FractionallySizedBox(
                widthFactor: 1 / options.length,
                heightFactor: 1,
                alignment: Alignment(x, 0),
                child: child,
              ),
            ),
          ),
          Row(
            children: [
              for (final option in options)
                Expanded(
                  child: _Segment<T>(
                    option: option,
                    active: option.value == selected,
                    textStyle: textStyle,
                    iconSize: iconSize,
                    onTap: () => onSelected(option.value),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: control);
    }
    return IntrinsicWidth(child: control);
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.option,
    required this.active,
    required this.textStyle,
    required this.iconSize,
    required this.onTap,
  });

  final SegmentOption<T> option;
  final bool active;
  final TextStyle? textStyle;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onAccent = Theme.of(context).colorScheme.onPrimary;
    final baseStyle = textStyle ?? Theme.of(context).textTheme.labelLarge;
    final targetColor = active ? onAccent : colors.textSecondary;

    return Semantics(
      button: true,
      selected: active,
      label: option.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: TweenAnimationBuilder<Color?>(
          duration: SegmentedPills.slideDuration,
          curve: Curves.easeOut,
          tween: ColorTween(end: targetColor),
          builder: (context, color, _) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: iconSize, color: color),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: baseStyle?.copyWith(color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
