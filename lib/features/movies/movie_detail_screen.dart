import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/section_label.dart';
import '../../data/models/movie.dart';
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

    // Contenu incomplet : rafraîchissement live de cette seule fiche (une fois
    // par ouverture ; l'anti-boucle de LiveRepair fait le reste).
    if (!_repairTried && movie.isIncomplete) {
      _repairTried = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(liveRepairProvider.notifier).repairMovie(movie);
      });
    }
    final repairing =
        ref.watch(liveRepairProvider).contains('movie-${widget.tvdbId}');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _Header(movie: movie),
          if (repairing) const SliverToBoxAdapter(child: _RepairBanner()),
          SliverToBoxAdapter(child: _Body(movie: movie)),
        ],
      ),
      floatingActionButton: _WatchedButton(movie: movie),
    );
  }
}

/// Bandeau discret signalant un rafraîchissement live en cours de la fiche.
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
          Text('Mise à jour des infos…', style: mono(size: 11, color: dust)),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final backdrop = movie.backdrop ?? movie.poster;
    return SliverAppBar(
      expandedHeight: backdrop == null ? 120 : 240,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding:
            const EdgeInsetsDirectional.only(start: 56, bottom: 14, end: 16),
        title: Text(movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: condensed(size: 17)),
        background: backdrop == null
            ? null
            : Stack(fit: StackFit.expand, children: [
                CachedNetworkImage(imageUrl: backdrop, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black45,
                        Colors.transparent,
                        Color(0xE612100D)
                      ],
                      stops: [0, .5, 1],
                    ),
                  ),
                ),
              ]),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final facts = [
      if (movie.year != null) '${movie.year}',
      if (movie.runtime != null && movie.runtime! > 0)
        '${movie.runtime! ~/ 60}h${(movie.runtime! % 60).toString().padLeft(2, '0')}',
      movie.watched ? 'VU' : 'À VOIR',
    ].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(facts, style: mono(size: 11, letterSpacing: .4)),
          const SizedBox(height: 20),
          if (movie.overview?.isNotEmpty ?? false) ...[
            const SectionLabel('Synopsis'),
            const SizedBox(height: 8),
            Text(
              movie.overview!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: linen.withValues(alpha: .85), height: 1.5),
            ),
          ] else
            Text('Pas de résumé disponible.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: dust)),
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
      label: Text(watched ? 'Vu' : 'Marquer vu',
          style: condensed(
              size: 15, color: watched ? linen : const Color(0xFF221603))),
      onPressed: () {
        HapticFeedback.lightImpact();
        final now = !watched;
        ref.read(trackingRepositoryProvider)?.saveMovie(movie.copyWith(
              watched: now,
              watchedAt: now ? DateTime.now() : null,
            ));
      },
    );
  }
}
