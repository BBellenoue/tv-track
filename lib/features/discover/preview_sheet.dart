import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme.dart';
import '../../core/widgets/section_label.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../l10n/app_localizations.dart';
import 'library_add.dart';

/// Opens the preview sheet for a catalog entry, with the action to add it to
/// the library.
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
    final l10n = AppLocalizations.of(context);
    final libraryId = ref.watch(libraryAddProvider.notifier).libraryId(item);
    final backdrop = item.backdropUrl ?? item.posterUrl;

    final meta = [
      if (item.year != null) '${item.year}',
      if (item.voteAverage != null && item.voteAverage! > 0)
        '★ ${item.voteAverage!.toStringAsFixed(1)}',
      (item.kind.isTv ? l10n.kindShow : l10n.kindMovie).toUpperCase(),
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
                  imageUrl: backdrop,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: condensed(size: 24, weight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(meta, style: mono(size: 11, color: tungsten)),
                const SizedBox(height: 20),
                if (item.overview != null) ...[
                  SectionLabel(l10n.synopsis),
                  const SizedBox(height: 8),
                  Text(
                    item.overview!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: linen.withValues(alpha: .85),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                SizedBox(
                  width: double.infinity,
                  child: libraryId != null
                      ? OutlinedButton.icon(
                          onPressed: () => _open(context, libraryId),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.check, color: tungsten),
                          label: Text(
                            l10n.openRecord,
                            style: condensed(size: 15, color: linen),
                          ),
                        )
                      : FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: tungsten,
                            foregroundColor: const Color(0xFF221603),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.add),
                          label: Text(
                            l10n.addToList,
                            style: condensed(
                              size: 15,
                              color: const Color(0xFF221603),
                              weight: FontWeight.w600,
                            ),
                          ),
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

  void _open(BuildContext context, int libraryId) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push('/${item.kind.isTv ? 'show' : 'movie'}/$libraryId');
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    final ok = await ref.read(libraryAddProvider.notifier).add(item);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok ? l10n.addedToList(item.title) : l10n.addFailed(item.title),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
