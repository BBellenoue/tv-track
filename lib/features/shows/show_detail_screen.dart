import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/expandable_text.dart';
import '../../core/widgets/season_progress_bar.dart';
import '../../core/widgets/section_label.dart';
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
          if (show.providers.isNotEmpty || (show.overview?.isNotEmpty ?? false))
            SliverToBoxAdapter(child: _Overview(show: show)),
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

class _Overview extends StatelessWidget {
  const _Overview({required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (show.providers.isNotEmpty) ...[
            const SectionLabel('Où regarder'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in show.providers) _ProviderChip(p),
              ],
            ),
            const SizedBox(height: 18),
          ],
          if (show.overview?.isNotEmpty ?? false) ...[
            const SectionLabel('Synopsis'),
            const SizedBox(height: 8),
            ExpandableText(show.overview!),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ProviderChip extends StatelessWidget {
  const _ProviderChip(this.name);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: charcoal,
        border: Border.all(color: tungsten.withValues(alpha: .4)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(name, style: condensed(size: 13.5, letterSpacing: .3)),
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

class _EpisodeRow extends ConsumerStatefulWidget {
  const _EpisodeRow({required this.show, required this.episode});

  final Show show;
  final Episode episode;

  @override
  ConsumerState<_EpisodeRow> createState() => _EpisodeRowState();
}

class _EpisodeRowState extends ConsumerState<_EpisodeRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final episode = widget.episode;
    final airDate = episode.airDate;
    final unaired = airDate != null && airDate.isAfter(DateTime.now());
    final hasOverview = episode.overview?.isNotEmpty ?? false;

    void toggleWatched() {
      if (unaired) return;
      HapticFeedback.selectionClick();
      ref.read(trackingRepositoryProvider)?.saveShow(
          widget.show.withEpisodeWatched(episode.tvdbId, !episode.watched));
    }

    // Ligne d'au moins 56px de haut ; case à cocher dans une cible de 44px.
    return InkWell(
      onTap: hasOverview ? () => setState(() => _expanded = !_expanded) : null,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Check(
                      watched: episode.watched,
                      enabled: !unaired,
                      onTap: toggleWatched),
                  Text('E${episode.number.toString().padLeft(2, '0')}',
                      style: mono(size: 12.5, color: unaired ? dust : linen)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          episode.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: unaired ? dust : linen, height: 1.25),
                        ),
                        if (unaired)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              'diffusé le ${DateFormat('d MMMM', 'fr_FR').format(airDate.toLocal())}',
                              style: mono(size: 10.5, color: tungsten),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hasOverview)
                    Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                        size: 20, color: dust),
                ],
              ),
            ),
            if (hasOverview && _expanded)
              Padding(
                padding: const EdgeInsets.only(left: 44, top: 2, bottom: 12),
                child: Text(
                  episode.overview!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: linen.withValues(alpha: .78), height: 1.4),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Case à cocher tungstène dans une cible tactile de 44px (case visuelle
/// de 24px centrée). Désactivée pour les épisodes non diffusés.
class _Check extends StatelessWidget {
  const _Check(
      {required this.watched, required this.enabled, required this.onTap});

  final bool watched;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: enabled ? onTap : null,
      radius: 26,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: watched ? tungsten : Colors.transparent,
              border: Border.all(
                  color: enabled ? (watched ? tungsten : dust) : outlineDim,
                  width: 1.6),
              borderRadius: BorderRadius.circular(7),
            ),
            child: watched
                ? const Icon(Icons.check, size: 16, color: Color(0xFF221603))
                : null,
          ),
        ),
      ),
    );
  }
}
