import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme.dart';
import '../../data/tmdb/catalog_item.dart';
import 'library_add.dart';
import 'preview_sheet.dart';

/// Vignette d'un élément de catalogue : poster 2:3 (remplit la largeur du
/// parent) + titre. Ouvre l'aperçu au tap. Grisée avec une pastille « suivie »
/// si l'élément est déjà dans la liste.
class CatalogPoster extends ConsumerWidget {
  const CatalogPoster({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracked = ref.watch(libraryAddProvider.notifier).isTracked(item);
    final hue = (item.tmdbId % 360).toDouble();

    return GestureDetector(
      onTap: () => showCatalogPreview(context, item),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Opacity(
                    opacity: tracked ? 0.38 : 1,
                    child: item.posterUrlSmall != null
                        ? CachedNetworkImage(
                            imageUrl: item.posterUrlSmall!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) =>
                                const ColoredBox(color: charcoal),
                            errorWidget: (_, _, _) => _fallback(hue),
                          )
                        : _fallback(hue),
                  ),
                  if (tracked)
                    const Positioned(
                      top: 6,
                      right: 6,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xE612100D),
                        child: Icon(Icons.check, size: 15, color: tungsten),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: condensed(
                size: 12.5, color: tracked ? dust : linen, letterSpacing: .2),
          ),
        ],
      ),
    );
  }

  final CatalogItem item;

  Widget _fallback(double hue) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              HSLColor.fromAHSL(1, hue, .28, .26).toColor(),
              HSLColor.fromAHSL(1, (hue + 40) % 360, .28, .15).toColor(),
            ],
          ),
        ),
        child: Center(
          child: Text(item.title.isEmpty ? '?' : item.title.characters.first,
              style: condensed(size: 28, color: Colors.white70)),
        ),
      );
}
