import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/season_progress_bar.dart';
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
    final backdrop = show.posterLarge ?? show.poster;

    // Ligne de données façon guide TV : chaîne · statut · prochaine diffusion.
    final facts = <String>[
      '${show.watchedEpisodes}/${show.totalEpisodes}',
      if (show.network != null) show.network!.toUpperCase(),
      if (show.airStatus == 'Running')
        'EN DIFFUSION'
      else if (show.isEnded)
        'TERMINÉE',
      if (show.nextAirDate != null)
        'PROCHAIN ÉP. ${DateFormat('d MMM', 'fr_FR').format(show.nextAirDate!.toLocal()).toUpperCase()}',
    ];

    return SliverAppBar(
      expandedHeight: backdrop == null ? 180 : 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsetsDirectional.only(start: 56, bottom: 14, end: 16),
        title: Text(
          show.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: condensed(size: 17),
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
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          Color(0xE612100D),
                        ],
                        stops: [0, .45, 1],
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: Container(
          color: screenBlack,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facts.join('  ·  '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: mono(size: 10.5, letterSpacing: .4),
              ),
              const SizedBox(height: 9),
              SeasonProgressBar(show: show),
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
    final repo = ref.read(trackingRepositoryProvider);

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Row(
        children: [
          Text('S${season.number.toString().padLeft(2, '0')}',
              style: mono(size: 13, color: linen, weight: FontWeight.w600)),
          const SizedBox(width: 10),
          Text('Saison ${season.number}', style: condensed(size: 15)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text('${season.watchedCount}/${season.episodes.length} vus',
            style: mono(size: 10.5)),
      ),
      trailing: IconButton(
        icon: Icon(season.isCompleted ? Icons.remove_done : Icons.done_all),
        color: season.isCompleted ? tungsten : dust,
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
    final airDate = episode.airDate;
    final unaired = airDate != null && airDate.isAfter(DateTime.now());

    return CheckboxListTile(
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: tungsten,
      checkColor: const Color(0xFF221603),
      value: episode.watched,
      onChanged: unaired
          ? null
          : (v) {
              HapticFeedback.selectionClick();
              ref.read(trackingRepositoryProvider)?.saveShow(
                  show.withEpisodeWatched(episode.tvdbId, v ?? false));
            },
      title: Row(
        children: [
          Text('E${episode.number.toString().padLeft(2, '0')}',
              style: mono(size: 12, color: unaired ? dust : linen)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              episode.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: unaired ? dust : linen, height: 1.2),
            ),
          ),
        ],
      ),
      subtitle: unaired
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'diffusé le ${DateFormat('d MMMM', 'fr_FR').format(airDate.toLocal())}',
                style: mono(size: 10.5, color: tungsten),
              ),
            )
          : null,
    );
  }
}
