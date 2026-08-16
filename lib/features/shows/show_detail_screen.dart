import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/credits_block.dart';
import '../../core/widgets/expandable_text.dart';
import '../../core/widgets/season_progress_bar.dart';
import '../../core/widgets/section_label.dart';
import '../../core/locale.dart';
import '../../data/models/show.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../l10n/app_localizations.dart';
import 'live_repair.dart';

class ShowDetailScreen extends ConsumerStatefulWidget {
  const ShowDetailScreen({super.key, required this.tvdbId});

  final int tvdbId;

  @override
  ConsumerState<ShowDetailScreen> createState() => _ShowDetailScreenState();
}

class _ShowDetailScreenState extends ConsumerState<ShowDetailScreen> {
  // Marks the next episode to watch, so the screen can scroll to it on open.
  final _nextEpisodeKey = GlobalKey();
  bool _scrolled = false;
  bool _repairTried = false;

  @override
  Widget build(BuildContext context) {
    final show = ref
        .watch(showsProvider)
        .value
        ?.firstWhereOrNull((s) => s.tvdbId == widget.tvdbId);

    if (show == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final wantEnglish =
        ref.watch(localeControllerProvider) == AppLocale.english;
    if (!_repairTried && show.needsRepair(wantEnglish: wantEnglish)) {
      _repairTried = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(liveRepairProvider.notifier).repairShow(show);
      });
    }
    final repairing = ref
        .watch(liveRepairProvider)
        .contains('show-${widget.tvdbId}');

    final next = show.nextEpisode;
    final nextSeasonNumber = next?.season.number;
    final nextEpisodeTvdb = next?.episode.tvdbId;

    // Bring the next episode into view once, so a well-advanced season does
    // not open scrolled to the top of a long list.

    if (!_scrolled && nextEpisodeTvdb != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _nextEpisodeKey.currentContext;
        if (!_scrolled && ctx != null && mounted) {
          _scrolled = true;
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.28,
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _Header(
            show: show,
            // Deleting is only offered before a show is started: past that,
            // it would destroy watch history.
            onDelete: show.isStarted ? null : () => _confirmDelete(show),
          ),
          if (repairing) const SliverToBoxAdapter(child: _RepairBanner()),
          if (show.providers.isNotEmpty || (show.overview?.isNotEmpty ?? false))
            SliverToBoxAdapter(child: _Overview(show: show)),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 24),
            sliver: SliverList.list(
              children: [
                for (final season in show.regularSeasons)
                  _SeasonTile(
                    key: PageStorageKey('season-${season.number}'),
                    show: show,
                    season: season,
                    initiallyExpanded: season.number == nextSeasonNumber,
                    highlightEpisodeTvdb: nextEpisodeTvdb,
                    highlightKey: _nextEpisodeKey,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(Show show) async {
    final repo = ref.read(trackingRepositoryProvider);
    if (repo == null) return;

    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: charcoal,
        title: Text(l10n.deleteShowTitle, style: condensed(size: 18)),
        content: Text(
          l10n.deleteShowBody(show.title),
          style: Theme.of(
            ctx,
          ).textTheme.bodyMedium?.copyWith(color: dust, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: condensed(size: 15, color: dust)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.delete,
              style: condensed(size: 15, color: tungsten),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    HapticFeedback.mediumImpact();
    // Leave the screen first: the Firestore stream is about to drop the show,
    // and this screen would have nothing left to render.
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    await repo.deleteShow(show.tvdbId);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.showRemoved(show.title))),
    );
  }
}

/// Height of the opaque info bar pinned under the artwork.
const _infoBarHeight = 58.0;

class _Header extends StatelessWidget {
  const _Header({required this.show, this.onDelete});

  final Show show;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final backdrop = show.posterLarge ?? show.poster;

    // TV-guide style data line: progress · network · status · next airing.
    final facts = <String>[
      '${show.watchedEpisodes}/${show.totalEpisodes}',
      if (show.network != null) show.network!.toUpperCase(),
      if (show.airStatus == 'Running')
        l10n.statusAiring.toUpperCase()
      else if (show.isEnded)
        l10n.statusEnded.toUpperCase(),
      if (show.nextAirDate != null)
        l10n.nextEpisodeOn(
          DateFormat(
            'd MMM',
            locale,
          ).format(show.nextAirDate!.toLocal()).toUpperCase(),
        ),
    ];

    return SliverAppBar(
      expandedHeight: backdrop == null ? 180 : 300,
      pinned: true,
      actions: [
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.removeFromList,
            onPressed: onDelete,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // Wider end inset when the delete action shows, so the collapsed
        // title does not slide under the icon. The flexible space reaches
        // behind the opaque info bar, so the title has to clear its height or
        // it is painted underneath it.
        titlePadding: EdgeInsetsDirectional.only(
          start: 56,
          bottom: _infoBarHeight + 14,
          end: onDelete != null ? 56 : 16,
        ),
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
                  // Keeps the title and status bar legible over the artwork.
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
        preferredSize: const Size.fromHeight(_infoBarHeight),
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

class _RepairBanner extends StatelessWidget {
  const _RepairBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(strokeWidth: 1.6, color: dust),
          ),
          const SizedBox(width: 10),
          Text(
            AppLocalizations.of(context).updatingInfo,
            style: mono(size: 11, color: dust),
          ),
        ],
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
            SectionLabel(AppLocalizations.of(context).whereToWatch),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final p in show.providers) _ProviderChip(p)],
            ),
            const SizedBox(height: 18),
          ],
          if (show.overview?.isNotEmpty ?? false) ...[
            SectionLabel(AppLocalizations.of(context).synopsis),
            const SizedBox(height: 8),
            ExpandableText(show.overview!),
            const SizedBox(height: 8),
          ],
          if (show.tmdbId != null)
            CreditsBlock(kind: MediaKind.tv, tmdbId: show.tmdbId!),
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
    this.highlightEpisodeTvdb,
    this.highlightKey,
  });

  final Show show;
  final Season season;
  final bool initiallyExpanded;
  final int? highlightEpisodeTvdb;
  final Key? highlightKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(trackingRepositoryProvider);

    return ExpansionTile(
      initiallyExpanded: initiallyExpanded,
      title: Row(
        children: [
          Text(
            'S${season.number.toString().padLeft(2, '0')}',
            style: mono(size: 13, color: linen, weight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Text(l10n.seasonNumber(season.number), style: condensed(size: 15)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          l10n.seasonWatchedCount(season.watchedCount, season.episodes.length),
          style: mono(size: 10.5),
        ),
      ),
      trailing: IconButton(
        icon: Icon(season.isCompleted ? Icons.remove_done : Icons.done_all),
        color: season.isCompleted ? tungsten : dust,
        tooltip: season.isCompleted
            ? l10n.markSeasonUnwatched
            : l10n.markSeasonWatched,
        onPressed: () {
          HapticFeedback.lightImpact();
          repo?.saveShow(
            show.withSeasonWatched(season.number, !season.isCompleted),
          );
        },
      ),
      children: [
        for (final episode in season.episodes.sorted(
          (a, b) => a.number - b.number,
        ))
          _EpisodeTile(
            key: episode.tvdbId == highlightEpisodeTvdb ? highlightKey : null,
            show: show,
            season: season,
            episode: episode,
          ),
      ],
    );
  }
}

/// Episode row. Ticking one while earlier episodes are still unwatched offers
/// to mark everything before it, across seasons.
class _EpisodeTile extends ConsumerStatefulWidget {
  const _EpisodeTile({
    super.key,
    required this.show,
    required this.season,
    required this.episode,
  });

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

    if (!ep.watched) {
      final before = widget.show.unwatchedBefore(
        widget.season.number,
        ep.number,
      );
      if (before > 0) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).unwatchedBefore(before),
              ),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: AppLocalizations.of(context).markAllPrevious,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  repo.saveShow(
                    widget.show.markWatchedUpTo(
                      widget.season.number,
                      ep.number,
                    ),
                  );
                },
              ),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ep = widget.episode;
    final airDate = ep.airDate;
    final unaired = airDate != null && airDate.isAfter(DateTime.now());
    final hasOverview = ep.overview?.isNotEmpty ?? false;

    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final secondary = unaired
        ? l10n.airsOn(DateFormat('d MMMM', locale).format(airDate.toLocal()))
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
                        Row(
                          children: [
                            Text(
                              'E${ep.number.toString().padLeft(2, '0')}',
                              style: mono(
                                size: 11,
                                color: unaired ? dust : tungsten,
                              ),
                            ),
                            // Aired episodes show their date here; upcoming
                            // ones show it on the secondary line instead.
                            if (airDate != null && !unaired) ...[
                              const SizedBox(width: 8),
                              Text(
                                DateFormat(
                                  'd MMM y',
                                  locale,
                                ).format(airDate.toLocal()),
                                style: mono(size: 11, color: dust),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          ep.name.isEmpty
                              ? l10n.episodeNumber(ep.number)
                              : ep.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: condensed(
                            size: 15,
                            color: unaired ? dust : linen,
                          ),
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
                                : Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: dust, height: 1.35),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _Check(watched: ep.watched, enabled: !unaired, onTap: _toggle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
        child: dimmed ? Opacity(opacity: 0.5, child: child) : child,
      ),
    );
  }

  Widget _fallback() => DecoratedBox(
    decoration: const BoxDecoration(color: charcoalHigh),
    child: Center(
      child: Icon(
        Icons.movie_outlined,
        color: dust.withValues(alpha: .5),
        size: 22,
      ),
    ),
  );
}

/// A 24px checkbox centred in a 44px touch target, disabled for episodes that
/// have not aired yet.
class _Check extends StatelessWidget {
  const _Check({
    required this.watched,
    required this.enabled,
    required this.onTap,
  });

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
                width: 1.6,
              ),
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
