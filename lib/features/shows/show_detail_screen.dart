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
          _EpisodeTile(show: show, season: season, episode: episode),
      ],
    );
  }
}

/// Tuile d'épisode : vignette 16:9, code + titre, date/résumé, case à cocher.
/// Cocher un épisode alors que des précédents sont non vus propose de tout
/// marquer avant (multi-saison).
class _EpisodeTile extends ConsumerStatefulWidget {
  const _EpisodeTile(
      {required this.show, required this.season, required this.episode});

  final Show show;
  final Season season;
  final Episode episode;

  @override
  ConsumerState<_EpisodeTile> createState() => _EpisodeTileState();
}

class _EpisodeTileState extends ConsumerState<_EpisodeTile> {
  bool _expanded = false;

  void _toggle() {
    final ep = widget.episode;
    final repo = ref.read(trackingRepositoryProvider);
    if (repo == null) return;
    HapticFeedback.selectionClick();
    repo.saveShow(widget.show.withEpisodeWatched(ep.tvdbId, !ep.watched));

    // En cochant : proposer de rattraper les épisodes précédents non vus.
    if (!ep.watched) {
      final before =
          widget.show.unwatchedBefore(widget.season.number, ep.number);
      if (before > 0) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(
                '$before épisode${before > 1 ? 's' : ''} non vu${before > 1 ? 's' : ''} avant celui-ci'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Tout marquer',
              onPressed: () {
                HapticFeedback.mediumImpact();
                repo.saveShow(widget.show
                    .markWatchedUpTo(widget.season.number, ep.number));
              },
            ),
          ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = widget.episode;
    final airDate = ep.airDate;
    final unaired = airDate != null && airDate.isAfter(DateTime.now());
    final hasOverview = ep.overview?.isNotEmpty ?? false;

    final secondary = unaired
        ? 'diffusé le ${DateFormat('d MMMM', 'fr_FR').format(airDate.toLocal())}'
        : ep.overview;

    return InkWell(
      onTap: hasOverview && !unaired
          ? () => setState(() => _expanded = !_expanded)
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Still(episode: ep, dimmed: unaired),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('E${ep.number.toString().padLeft(2, '0')}',
                            style: mono(
                                size: 11, color: unaired ? dust : tungsten)),
                        const SizedBox(height: 3),
                        Text(
                          ep.name.isEmpty ? 'Épisode ${ep.number}' : ep.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: condensed(
                              size: 15, color: unaired ? dust : linen),
                        ),
                        if (secondary != null && secondary.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            secondary,
                            maxLines: _expanded ? null : 2,
                            overflow: _expanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: unaired
                                ? mono(size: 10.5, color: tungsten)
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: dust, height: 1.35),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _Check(
                    watched: ep.watched, enabled: !unaired, onTap: _toggle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Vignette 16:9 d'un épisode (112×63) avec repli teinté si absente.
class _Still extends StatelessWidget {
  const _Still({required this.episode, required this.dimmed});

  final Episode episode;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    const w = 112.0, h = 63.0;
    final child = episode.still != null
        ? CachedNetworkImage(
            imageUrl: episode.still!,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ColoredBox(color: charcoal),
            errorWidget: (_, _, _) => _fallback(),
          )
        : _fallback();
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: w,
        height: h,
        child: dimmed
            ? Opacity(opacity: 0.5, child: child)
            : child,
      ),
    );
  }

  Widget _fallback() => DecoratedBox(
        decoration: const BoxDecoration(color: charcoalHigh),
        child: Center(
          child: Icon(Icons.movie_outlined,
              color: dust.withValues(alpha: .5), size: 22),
        ),
      );
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
