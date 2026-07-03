import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
      appBar: AppBar(title: Text(show.title)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${show.watchedEpisodes}/${show.totalEpisodes} épisodes vus',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: show.totalEpisodes == 0
                      ? 0
                      : show.watchedEpisodes / show.totalEpisodes,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          for (final season in show.regularSeasons)
            _SeasonTile(
              show: show,
              season: season,
              initiallyExpanded: season.number == nextSeasonNumber,
            ),
        ],
      ),
    );
  }
}

class _SeasonTile extends ConsumerWidget {
  const _SeasonTile({
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
      key: PageStorageKey('season-${season.number}'),
      initiallyExpanded: initiallyExpanded,
      title: Text('Saison ${season.number}'),
      subtitle: Text('${season.watchedCount}/${season.episodes.length} vus'),
      trailing: IconButton(
        icon: Icon(season.isCompleted
            ? Icons.remove_done
            : Icons.done_all),
        tooltip: season.isCompleted
            ? 'Marquer la saison non vue'
            : 'Marquer toute la saison vue',
        onPressed: () => repo?.saveShow(
          show.withSeasonWatched(season.number, !season.isCompleted),
        ),
      ),
      children: [
        for (final episode
            in season.episodes.sorted((a, b) => a.number - b.number))
          CheckboxListTile(
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            value: episode.watched,
            onChanged: (v) => repo?.saveShow(
              show.withEpisodeWatched(episode.tvdbId, v ?? false),
            ),
            title: Text(
              'E${episode.number.toString().padLeft(2, '0')}'
              '${episode.name.isEmpty ? '' : '  ${episode.name}'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
