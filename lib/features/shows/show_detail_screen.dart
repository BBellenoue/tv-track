import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../data/models/show.dart';

class ShowDetailScreen extends ConsumerWidget {
  const ShowDetailScreen({super.key, required this.tvdbId});

  final int tvdbId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final show = ref
        .watch(showsProvider)
        .value
        ?.firstWhereOrNull((s) => s.tvdbId == tvdbId);

    if (show == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final nextSeasonNumber = show.nextEpisode?.season.number;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _Header(show: show),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList.list(children: [
              for (final season in show.regularSeasons)
                _SeasonTile(
                  key: PageStorageKey('season-${season.number}'),
                  show: show,
                  season: season,
                  initiallyExpanded: season.number == nextSeasonNumber,
                ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backdrop = show.posterLarge ?? show.poster;
    final progress =
        show.totalEpisodes == 0 ? 0.0 : show.watchedEpisodes / show.totalEpisodes;

    final chips = <String>[
      if (show.network != null) show.network!,
      if (show.airStatus == 'Running')
        'En diffusion'
      else if (show.isEnded)
        'Terminée',
      if (show.nextAirDate != null)
        'Prochain ép. le ${DateFormat('d MMM', 'fr_FR').format(show.nextAirDate!.toLocal())}',
    ];

    return SliverAppBar(
      expandedHeight: backdrop == null ? 180 : 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(
            start: 56, bottom: 14, end: 16),
        title: Text(
          show.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        background: backdrop == null
            ? null
            : Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: backdrop,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.3),
                  ),
                  // Dégradé pour la lisibilité du titre et de la status bar.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black45, Colors.transparent, Color(0xE60D0D17)],
                        stops: [0, .45, 1],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          color: theme.scaffoldBackgroundColor,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        '${show.watchedEpisodes}/${show.totalEpisodes} épisodes',
                        ...chips,
                      ].join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                borderRadius: BorderRadius.circular(3),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SeasonTile extends ConsumerWidget {
  const _SeasonTile({
    super.key,
    required this.show,
    required this.season,
    required this.initiallyExpanded,
  });

  final Show show;
  final Season season;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.read(trackingRepositoryProvider);

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Text('Saison ${season.number}',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${season.watchedCount}/${season.episodes.length} vus',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: IconButton(
        icon: Icon(season.isCompleted ? Icons.remove_done : Icons.done_all),
        tooltip: season.isCompleted
            ? 'Marquer la saison non vue'
            : 'Marquer toute la saison vue',
        onPressed: () {
          HapticFeedback.lightImpact();
          repo?.saveShow(
              show.withSeasonWatched(season.number, !season.isCompleted));
        },
      ),
      children: [
        for (final episode
            in season.episodes.sorted((a, b) => a.number - b.number))
          _EpisodeRow(show: show, episode: episode),
      ],
    );
  }
}

class _EpisodeRow extends ConsumerWidget {
  const _EpisodeRow({required this.show, required this.episode});

  final Show show;
  final Episode episode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final airDate = episode.airDate;
    final unaired = airDate != null && airDate.isAfter(DateTime.now());

    return CheckboxListTile(
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      value: episode.watched,
      onChanged: unaired
          ? null
          : (v) {
              HapticFeedback.selectionClick();
              ref
                  .read(trackingRepositoryProvider)
                  ?.saveShow(show.withEpisodeWatched(episode.tvdbId, v ?? false));
            },
      title: Text(
        'E${episode.number.toString().padLeft(2, '0')}'
        '${episode.name.isEmpty ? '' : '  ${episode.name}'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: unaired
            ? theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)
            : null,
      ),
      subtitle: unaired
          ? Text('Diffusé le ${DateFormat('d MMMM', 'fr_FR').format(airDate.toLocal())}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary))
          : null,
    );
  }
}
