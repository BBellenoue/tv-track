import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/episode_tag.dart';
import '../../core/widgets/filter_tabs.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilterTabs<ShowFilter>(
                items: [
                  for (final f in ShowFilter.values)
                    (f, f.label, all.where(f.matches).length),
                ],
                selected: filter.value,
                onSelect: (f) => filter.value = f,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(metadataRefreshProvider.notifier)
                    .run(force: true),
                child: filtered.isEmpty
                    ? const _NothingHere()
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 12),
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
    final next = show.nextEpisode;
    final progress =
        show.totalEpisodes == 0 ? 0.0 : show.watchedEpisodes / show.totalEpisodes;

    return Dismissible(
      key: ValueKey('show-${show.tvdbId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: const Color(0xFF3A211C),
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Color(0xFFE07A6B)),
      ),
      onDismissed: (_) => _delete(context, ref),
      child: InkWell(
        onTap: () => context.push('/show/${show.tvdbId}'),
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
                    style: condensed(size: 15.5),
                  ),
                  const SizedBox(height: 4),
                  _SubtitleLine(show: show, next: next),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: charcoalHigh,
                            color: tungsten,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${show.watchedEpisodes}/${show.totalEpisodes}',
                        style: mono(size: 10.5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            if (next == null)
              const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.check_circle, color: tungsten, size: 26),
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
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref) {
    final repo = ref.read(trackingRepositoryProvider);
    if (repo == null) return;
    HapticFeedback.mediumImpact();
    repo.deleteShow(show.tvdbId);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('${show.title} retirée de ta liste'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () => repo.saveShow(show),
        ),
      ));
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

class _SubtitleLine extends StatelessWidget {
  const _SubtitleLine({required this.show, required this.next});

  final Show show;
  final EpisodeRef? next;

  @override
  Widget build(BuildContext context) {
    final bodySmall = Theme.of(context)
        .textTheme
        .bodySmall
        ?.copyWith(color: dust, height: 1.2);

    if (next != null) {
      return Row(children: [
        EpisodeTag(
            'S${_pad(next!.season.number)}E${_pad(next!.episode.number)}'),
        if (next!.episode.name.isNotEmpty) ...[
          const SizedBox(width: 7),
          Expanded(
            child: Text(next!.episode.name,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: bodySmall),
          ),
        ],
      ]);
    }

    final airDate = show.nextAirDate;
    if (airDate != null) {
      return Row(children: [
        EpisodeTag(_date(airDate).toUpperCase(), emphasis: true),
        const SizedBox(width: 7),
        Expanded(
            child: Text('prochain épisode',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: bodySmall)),
      ]);
    }

    return Text(
      show.isEnded ? 'Terminée' : 'À jour',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: bodySmall,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.live_tv_rounded, size: 56, color: dust),
          const SizedBox(height: 12),
          Text('Bibliothèque vide', style: condensed(size: 17)),
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
