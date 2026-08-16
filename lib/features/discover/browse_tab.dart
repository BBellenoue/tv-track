import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../l10n/app_localizations.dart';
import 'browse_controller.dart';
import 'catalog_poster.dart';
import 'category_screen.dart';

/// Browse mode: one horizontal rail for trending plus one per genre, each
/// opening onto the full category grid.
class BrowseTab extends ConsumerWidget {
  const BrowseTab({super.key, required this.kind});

  final MediaKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genres = ref.watch(catalogGenresProvider(kind));

    return genres.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context).loadFailed,
          style: TextStyle(color: dust),
        ),
      ),
      data: (list) {
        final rails = <({String title, int? genreId})>[
          (title: AppLocalizations.of(context).railTrending, genreId: null),
          for (final g in list.take(10)) (title: g.name, genreId: g.id),
        ];
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: rails.length,
          itemBuilder: (context, i) => _Rail(
            kind: kind,
            title: rails[i].title,
            genreId: rails[i].genreId,
          ),
        );
      },
    );
  }
}

class _Rail extends ConsumerWidget {
  const _Rail({required this.kind, required this.title, this.genreId});

  final MediaKind kind;
  final String title;
  final int? genreId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final row = ref.watch(catalogRowProvider(kind: kind, genreId: genreId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
          child: Row(
            children: [
              Container(width: 14, height: 2, color: tungsten),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono(size: 12, color: linen, letterSpacing: 1.2),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(
                      kind: kind,
                      title: title,
                      genreId: genreId,
                    ),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).seeAll,
                  style: mono(size: 11, color: tungsten),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 208,
          child: row.when(
            loading: () => const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (e, _) => const SizedBox.shrink(),
            data: (items) => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) =>
                  SizedBox(width: 118, child: CatalogPoster(item: items[i])),
            ),
          ),
        ),
      ],
    );
  }
}
