import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/src/components/shimmer_box.dart';
import 'package:design_system/src/theme/app_theme.dart';
import 'package:design_system/src/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

/// Card de poster (relación 2:3) con placeholder shimmer y micro-interacción de
/// press (escala). Si se pasa [heroTag], habilita la transición de elemento
/// compartido hacia la pantalla de detalle.
class PosterCard extends StatefulWidget {
  const PosterCard({
    required this.imageUrl,
    this.title,
    this.heroTag,
    this.onTap,
    super.key,
  });

  final String? imageUrl;
  final String? title;
  final Object? heroTag;
  final VoidCallback? onTap;

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _pressed = false;

  void _setPressed({required bool value}) {
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.md);

    Widget image = AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: radius,
        child: _PosterImage(imageUrl: widget.imageUrl),
      ),
    );

    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(value: true),
      onTapUp: (_) => _setPressed(value: false),
      onTapCancel: () => _setPressed(value: false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            image,
            if (widget.title != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PosterImage extends StatelessWidget {
  const _PosterImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = context.colors.elevated;
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return ColoredBox(
        color: fallback,
        child: const Center(child: Icon(Icons.movie_outlined)),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, _) => const ShimmerBox(),
      errorWidget: (context, _, _) => ColoredBox(
        color: fallback,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      ),
    );
  }
}
