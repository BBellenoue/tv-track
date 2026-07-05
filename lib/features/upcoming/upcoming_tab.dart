import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/episode_tag.dart';
import '../../core/widgets/poster.dart';
import '../../data/models/show.dart';

/// Un épisode à venir, rattaché à sa série.
typedef Upcoming = ({Show show, Season season, Episode episode, DateTime airDate});

/// Épisodes datés dans le futur, toutes séries suivies confondues, triés par
/// date de diffusion croissante.
final upcomingProvider = Provider<List<Upcoming>>((ref) {
  final shows = ref.watch(showsProvider).value ?? const [];
  final now = DateTime.now();
  final items = <Upcoming>[];
  for (final show in shows) {
    for (final season in show.regularSeasons) {
      for (final episode in season.episodes) {
        final date = episode.airDate;
        if (date != null && date.isAfter(now)) {
          items.add((show: show, season: season, episode: episode, airDate: date));
        }
      }
    }
  }
  items.sort((a, b) => a.airDate.compareTo(b.airDate));
  return items;
});

class UpcomingTab extends ConsumerWidget {
  const UpcomingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingProvider);

    if (upcoming.isEmpty) {
      return _empty(context);
    }

    // Regroupe par jour calendaire.
    final byDay = groupBy(upcoming,
        (Upcoming u) => DateTime(u.airDate.year, u.airDate.month, u.airDate.day));
    final days = byDay.keys.sorted((a, b) => a.compareTo(b));

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: days.length,
      itemBuilder: (context, i) {
        final day = days[i];
        final entries = byDay[day]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DayHeader(day: day),
            for (final u in entries) _UpcomingRow(item: u),
          ],
        );
      },
    );
  }

  Widget _empty(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_available_outlined, size: 56, color: dust),
            const SizedBox(height: 12),
            Text('Aucune diffusion annoncée', style: condensed(size: 17)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Les prochains épisodes de tes séries en cours apparaîtront ici.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: dust),
              ),
            ),
          ],
        ),
      );
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = day.difference(today).inDays;

    final String label;
    if (diff == 0) {
      label = "AUJOURD'HUI";
    } else if (diff == 1) {
      label = 'DEMAIN';
    } else if (diff < 7) {
      label = DateFormat('EEEE', 'fr_FR').format(day).toUpperCase();
    } else {
      label = DateFormat('EEEE d MMMM', 'fr_FR').format(day).toUpperCase();
    }

    final relative = diff >= 7 ? '' : DateFormat('d MMM', 'fr_FR').format(day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Row(
        children: [
          Container(width: 14, height: 2, color: tungsten),
          const SizedBox(width: 8),
          Text(label, style: mono(size: 11, color: linen, letterSpacing: 1.4)),
          if (relative.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(relative, style: mono(size: 11, color: dust)),
          ],
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.item});

  final Upcoming item;

  @override
  Widget build(BuildContext context) {
    final ep = item.episode;
    return InkWell(
      onTap: () => context.go('/show/${item.show.tvdbId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          children: [
            Poster(
                title: item.show.title,
                seed: item.show.tvdbId,
                url: item.show.poster,
                width: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.show.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: condensed(size: 15)),
                  const SizedBox(height: 4),
                  Row(children: [
                    EpisodeTag(
                        'S${_pad(item.season.number)}E${_pad(ep.number)}'),
                    if (ep.name.isNotEmpty) ...[
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(ep.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: dust)),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(DateFormat('HH:mm').format(item.airDate.toLocal()),
                style: mono(size: 11, color: tungsten)),
          ],
        ),
      ),
    );
  }
}

String _pad(int n) => n.toString().padLeft(2, '0');
