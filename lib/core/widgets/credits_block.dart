import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/tmdb/catalog_item.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';
import 'section_label.dart';

/// Genres, authorship and cast under the synopsis of a detail screen.
///
/// Renders nothing at all until the credits arrive, so the screen never shows
/// a spinner for something it can do without.
class CreditsBlock extends ConsumerWidget {
  const CreditsBlock({super.key, required this.kind, required this.tmdbId});

  final MediaKind kind;
  final int tmdbId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extras = ref.watch(titleExtrasProvider(kind, tmdbId)).value;
    if (extras == null || extras.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (extras.genres.isNotEmpty)
          _Entry(label: l10n.titleGenres, value: extras.genres.join('  ·  ')),
        if (extras.authors.isNotEmpty)
          _Entry(
            label: kind.isTv ? l10n.createdBy : l10n.directedBy,
            value: extras.authors.join(', '),
          ),
        if (extras.cast.isNotEmpty)
          _Entry(label: l10n.starring, value: extras.cast.join(', ')),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: linen.withValues(alpha: .85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
