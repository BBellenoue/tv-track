import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../data/tmdb/tmdb_api.dart';
import 'browse_controller.dart';
import 'catalog_poster.dart';

/// Grille plein écran d'une catégorie (un genre, ou tendances), triable et à
/// défilement infini.
class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({
    super.key,
    required this.kind,
    required this.title,
    this.genreId,
  });

  final MediaKind kind;
  final String title;
  final int? genreId;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  CatalogSort _sort = CatalogSort.popular;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >
          _scroll.position.maxScrollExtent - 600) {
        ref
            .read(_gridProvider.notifier)
            .loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  CategoryGridProvider get _gridProvider => categoryGridProvider(
        kind: widget.kind,
        sort: _sort,
        genreId: widget.genreId,
      );

  @override
  Widget build(BuildContext context) {
    final grid = ref.watch(_gridProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title.toUpperCase())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Row(
              children: [
                for (final s in CatalogSort.values) ...[
                  _SortChip(
                    label: s.label,
                    selected: s == _sort,
                    onTap: () => setState(() => _sort = s),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: grid.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Chargement impossible.',
                      style: TextStyle(color: dust))),
              data: (items) => GridView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.52, // poster 2:3 + titre
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) => CatalogPoster(item: items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? tungsten : charcoal,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? tungsten : outlineDim, width: 1),
        ),
        child: Text(label,
            style: condensed(
                size: 13,
                color: selected ? const Color(0xFF221603) : dust,
                weight: FontWeight.w600)),
      ),
    );
  }
}
