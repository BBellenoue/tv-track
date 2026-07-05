import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/section_label.dart';
import '../../data/tmdb/catalog_item.dart';
import 'library_add.dart';

/// Ouvre la fiche d'aperçu d'un élément de catalogue (poster, synopsis FR,
/// note) avec un bouton « Ajouter à ma liste ».
Future<void> showCatalogPreview(BuildContext context, CatalogItem item) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF171410),
    showDragHandle: true,
    builder: (_) => _PreviewSheet(item: item),
  );
}

class _PreviewSheet extends ConsumerWidget {
  const _PreviewSheet({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracked = ref.watch(libraryAddProvider.notifier).isTracked(item);
    final backdrop = item.backdropUrl ?? item.posterUrl;

    final meta = [
      if (item.year != null) '${item.year}',
      if (item.voteAverage != null && item.voteAverage! > 0)
        '★ ${item.voteAverage!.toStringAsFixed(1)}',
      item.kind.isTv ? 'SÉRIE' : 'FILM',
    ].join('  ·  ');

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: EdgeInsets.zero,
        children: [
          if (backdrop != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                    imageUrl: backdrop, fit: BoxFit.cover),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: condensed(size: 24, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(meta, style: mono(size: 11, color: tungsten)),
                const SizedBox(height: 20),
                if (item.overview != null) ...[
                  const SectionLabel('Synopsis'),
                  const SizedBox(height: 8),
                  Text(item.overview!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: linen.withValues(alpha: .85), height: 1.5)),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  child: tracked
                      ? OutlinedButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.check, color: tungsten),
                          label: Text('Déjà dans ta liste',
                              style: condensed(size: 15, color: dust)),
                        )
                      : FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: tungsten,
                            foregroundColor: const Color(0xFF221603),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text('Ajouter à ma liste',
                              style: condensed(
                                  size: 15,
                                  color: const Color(0xFF221603),
                                  weight: FontWeight.w600)),
                          onPressed: () => _add(context, ref),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    final ok = await ref.read(libraryAddProvider.notifier).add(item);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(ok
            ? '${item.title} ajouté${item.kind.isTv ? 'e' : ''} à ta liste'
            : 'Impossible d\'ajouter ${item.title}'),
        duration: const Duration(seconds: 3),
      ));
  }
}
