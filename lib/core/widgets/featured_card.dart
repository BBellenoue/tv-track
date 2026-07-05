import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Grande carte "hero" avec visuel large en fond : le point focal d'un écran
/// (prochaine diffusion, série à reprendre). Réserve sa hauteur dans tous les
/// cas ; retombe sur un dégradé teinté si aucun visuel n'est disponible.
class FeaturedCard extends StatelessWidget {
  const FeaturedCard({
    super.key,
    required this.title,
    required this.overline,
    required this.line,
    required this.seed,
    this.backdropUrl,
    this.onTap,
    this.action,
    this.height = 232,
  });

  final String title;
  final String overline;
  final String line;
  final int seed;
  final String? backdropUrl;
  final VoidCallback? onTap;
  final Widget? action;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hue = (seed % 360).toDouble();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (backdropUrl != null)
                CachedNetworkImage(
                  imageUrl: backdropUrl!,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0, -0.25),
                  placeholder: (_, _) => const ColoredBox(color: charcoal),
                  errorWidget: (_, _, _) => _fallback(hue),
                )
              else
                _fallback(hue),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE612100D)],
                    stops: [0.25, 1],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(overline.toUpperCase(),
                              style: mono(
                                  size: 11,
                                  color: tungsten,
                                  letterSpacing: 1.6)),
                          const SizedBox(height: 6),
                          Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: condensed(
                                  size: 27, weight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(line,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: linen)),
                        ],
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(width: 12),
                      action!,
                    ],
                  ],
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: onTap),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback(double hue) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HSLColor.fromAHSL(1, hue, .30, .28).toColor(),
              HSLColor.fromAHSL(1, (hue + 40) % 360, .30, .14).toColor(),
            ],
          ),
        ),
      );
}
