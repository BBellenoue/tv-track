import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/widgets/poster.dart';
import '../../data/models/show.dart';
import 'refresh_controller.dart';

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
          return const _EmptyState();
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SegmentedButton<ShowFilter>(
                segments: [
                  for (final f in ShowFilter.values)
                    ButtonSegment(
                      value: f,
                      label:
                          Text('${f.label} · ${all.where(f.matches).length}'),
                    ),
                ],
                selected: {filter.value},
                onSelectionChanged: (s) => filter.value = s.first,
                showSelectedIcon: false,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(metadataRefreshProvider.notifier).run(),
                child: filtered.isEmpty
                    ? const _NothingHere()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 4, bottom: 12),
                        itemCount: filtered.length,
                        itemBuilder: (context, i) => _ShowTile(
                          key: ValueKey(filtered[i].tvdbId),
                          show: filtered[i],
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShowTile extends ConsumerWidget {
  const _ShowTile({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final next = show.nextEpisode;
    final progress =
        show.totalEpisodes == 0 ? 0.0 : show.watchedEpisodes / show.totalEpisodes;

    final String subtitle;
    if (next != null) {
      final name = next.episode.name;
      subtitle = 'S${_pad(next.season.number)}E${_pad(next.episode.number)}'
          '${name.isEmpty ? '' : ' · $name'}';
    } else {
      final airDate = show.nextAirDate;
      subtitle = airDate != null
          ? 'Prochain épisode le ${_date(airDate)}'
          : show.isEnded
              ? 'Terminée · ${show.watchedEpisodes} épisodes vus'
              : 'À jour · en attente de nouveaux épisodes';
    }

    return InkWell(
      onTap: () => context.go('/show/${show.tvdbId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          children: [
            Poster(
                title: show.title,
                seed: show.tvdbId,
                url: show.poster,
                width: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${show.watchedEpisodes}/${show.totalEpisodes}',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (next == null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.check_circle,
                    color: theme.colorScheme.primary, size: 26),
              )
            else
              IconButton.filledTonal(
                icon: const Icon(Icons.check, size: 22),
                tooltip:
                    'Marquer S${next.season.number}E${next.episode.number} vu',
                onPressed: () => _checkNext(context, ref),
              ),
          ],
        ),
      ),
    );
  }

  void _checkNext(BuildContext context, WidgetRef ref) {
    final next = show.nextEpisode;
    final repo = ref.read(trackingRepositoryProvider);
    if (next == null || repo == null) return;

    HapticFeedback.lightImpact();
    repo.saveShow(show.withEpisodeWatched(next.episode.tvdbId, true));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
            '${show.title} — S${_pad(next.season.number)}E${_pad(next.episode.number)} vu'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () => repo.saveShow(show),
        ),
      ));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.live_tv_rounded,
              size: 56, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('Bibliothèque vide', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _NothingHere extends StatelessWidget {
  const _NothingHere();

  @override
  Widget build(BuildContext context) {
    // ListView pour rester "pullable" avec le RefreshIndicator.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(child: Text('Rien ici pour le moment.')),
      ],
    );
  }
}

String _pad(int n) => n.toString().padLeft(2, '0');

String _date(DateTime d) => DateFormat('d MMM', 'fr_FR').format(d.toLocal());
