import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/locale.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/credits_block.dart';
import '../../core/widgets/section_label.dart';
import '../../data/models/movie.dart';
import '../../data/tmdb/catalog_item.dart';
import '../../l10n/app_localizations.dart';
import '../shows/live_repair.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  const MovieDetailScreen({super.key, required this.tvdbId});

  final int tvdbId;

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  bool _repairTried = false;

  @override
  Widget build(BuildContext context) {
    final movie = ref
        .watch(moviesProvider)
        .value
        ?.firstWhereOrNull((m) => m.tvdbId == widget.tvdbId);

    if (movie == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final wantEnglish =
        ref.watch(localeControllerProvider) == AppLocale.english;
    if (!_repairTried && movie.needsRepair(wantEnglish: wantEnglish)) {
      _repairTried = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(liveRepairProvider.notifier).repairMovie(movie);
      });
    }
    final repairing = ref
        .watch(liveRepairProvider)
        .contains('movie-${widget.tvdbId}');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _Header(
            movie: movie,
            // Deleting is only offered before a movie is watched: past that,
            // it would destroy watch history.
            onDelete: movie.watched ? null : () => _confirmDelete(movie),
          ),
          if (repairing) const SliverToBoxAdapter(child: _RepairBanner()),
          SliverToBoxAdapter(child: _Body(movie: movie)),
        ],
      ),
      floatingActionButton: _WatchedButton(movie: movie),
    );
  }

  Future<void> _confirmDelete(Movie movie) async {
    final repo = ref.read(trackingRepositoryProvider);
    if (repo == null) return;

    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: charcoal,
        title: Text(l10n.deleteMovieTitle, style: condensed(size: 18)),
        content: Text(
          l10n.deleteMovieBody(movie.title),
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
    // Leave the screen first: the Firestore stream is about to drop the movie,
    // and this screen would have nothing left to render.
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    await repo.deleteMovie(movie.tvdbId);
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.movieRemoved(movie.title))),
    );
  }
}

class _RepairBanner extends StatelessWidget {
  const _RepairBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
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

class _Header extends StatelessWidget {
  const _Header({required this.movie, this.onDelete});

  final Movie movie;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final backdrop = movie.backdrop ?? movie.poster;
    return SliverAppBar(
      expandedHeight: backdrop == null ? 120 : 240,
      pinned: true,
      actions: [
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppLocalizations.of(context).removeFromList,
            onPressed: onDelete,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // Wider end inset when the delete action shows, so the collapsed
        // title does not slide under the icon.
        titlePadding: EdgeInsetsDirectional.only(
          start: 56,
          bottom: 14,
          end: onDelete != null ? 56 : 16,
        ),
        title: Text(
          movie.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: condensed(size: 17),
        ),
        background: backdrop == null
            ? null
            : Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: backdrop, fit: BoxFit.cover),
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
                        stops: [0, .5, 1],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final facts = [
      if (movie.year != null) '${movie.year}',
      if (movie.runtime != null && movie.runtime! > 0)
        '${movie.runtime! ~/ 60}h${(movie.runtime! % 60).toString().padLeft(2, '0')}',
      (movie.watched ? l10n.watched : l10n.statusToWatch).toUpperCase(),
    ].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(facts, style: mono(size: 11, letterSpacing: .4)),
          const SizedBox(height: 20),
          if (movie.overview?.isNotEmpty ?? false) ...[
            SectionLabel(l10n.synopsis),
            const SizedBox(height: 8),
            Text(
              movie.overview!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: linen.withValues(alpha: .85),
                height: 1.5,
              ),
            ),
          ] else
            Text(
              l10n.noOverview,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: dust),
            ),
          if (movie.tmdbId != null)
            CreditsBlock(kind: MediaKind.movie, tmdbId: movie.tmdbId!),
        ],
      ),
    );
  }
}

class _WatchedButton extends ConsumerWidget {
  const _WatchedButton({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watched = movie.watched;
    return FloatingActionButton.extended(
      backgroundColor: watched ? charcoalHigh : tungsten,
      foregroundColor: watched ? linen : const Color(0xFF221603),
      icon: Icon(watched ? Icons.check_circle : Icons.check_circle_outline),
      label: Text(
        watched
            ? AppLocalizations.of(context).watched
            : AppLocalizations.of(context).markWatched,
        style: condensed(
          size: 15,
          color: watched ? linen : const Color(0xFF221603),
        ),
      ),
      onPressed: () {
        HapticFeedback.lightImpact();
        final now = !watched;
        ref
            .read(trackingRepositoryProvider)
            ?.saveMovie(
              movie.copyWith(
                watched: now,
                watchedAt: now ? DateTime.now() : null,
              ),
            );
      },
    );
  }
}
