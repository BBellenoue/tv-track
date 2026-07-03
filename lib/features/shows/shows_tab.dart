import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/show.dart';

enum ShowFilter {
  watching('En cours'),
  upToDate('À jour'),
  notStarted('À voir');

  const ShowFilter(this.label);
  final String label;

  bool matches(Show show) => switch (this) {
        watching => show.isStarted && !show.isUpToDate,
        upToDate => show.isStarted && show.isUpToDate,
        notStarted => !show.isStarted,
      };
}

class ShowsTab extends HookConsumerWidget {
  const ShowsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shows = ref.watch(showsProvider);
    final filter = useState(ShowFilter.watching);

    return shows.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
      data: (all) {
        if (all.isEmpty) {
          return const Center(child: Text('Bibliothèque vide.'));
        }

        final filtered = all.where(filter.value.matches).sorted((a, b) {
          if (filter.value == ShowFilter.watching) {
            final da = a.lastWatchedAt ?? DateTime(1970);
            final db = b.lastWatchedAt ?? DateTime(1970);
            return db.compareTo(da);
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SegmentedButton<ShowFilter>(
                segments: [
                  for (final f in ShowFilter.values)
                    ButtonSegment(
                      value: f,
                      label: Text(
                          '${f.label} (${all.where(f.matches).length})'),
                    ),
                ],
                selected: {filter.value},
                onSelectionChanged: (s) => filter.value = s.first,
                showSelectedIcon: false,
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Rien ici pour le moment.'))
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) =>
                          _ShowTile(show: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _ShowTile extends ConsumerWidget {
  const _ShowTile({required this.show});

  final Show show;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = show.nextEpisode;
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            Colors.primaries[show.tvdbId % Colors.primaries.length].shade700,
        foregroundColor: Colors.white,
        child: Text(show.title.characters.first.toUpperCase()),
      ),
      title: Text(show.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: next == null
          ? Text('${show.watchedEpisodes} épisodes vus · à jour')
          : Text(
              'S${next.season.number.toString().padLeft(2, '0')}'
              'E${next.episode.number.toString().padLeft(2, '0')}'
              '${next.episode.name.isEmpty ? '' : ' · ${next.episode.name}'}'
              '  —  ${show.watchedEpisodes}/${show.totalEpisodes}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: next == null
          ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
          : IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Marquer S${next.season.number}E${next.episode.number} vu',
              onPressed: () {
                final repo = ref.read(trackingRepositoryProvider);
                repo?.saveShow(
                    show.withEpisodeWatched(next.episode.tvdbId, true));
              },
            ),
      onTap: () => context.go('/show/${show.tvdbId}'),
    );
  }
}
