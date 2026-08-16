import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/episode_tag.dart';
import '../../core/widgets/featured_card.dart';
import '../../core/widgets/poster.dart';
import '../../data/models/show.dart';
import '../../l10n/app_localizations.dart';

/// An upcoming episode, carrying the show and season it belongs to.
typedef Upcoming = ({
  Show show,
  Season season,
  Episode episode,
  DateTime airDate,
});

/// Every future-dated episode across tracked shows, soonest first.
final upcomingProvider = Provider<List<Upcoming>>((ref) {
  final shows = ref.watch(showsProvider).value ?? const [];
  final now = DateTime.now();
  final items = <Upcoming>[];
  for (final show in shows) {
    for (final season in show.regularSeasons) {
      for (final episode in season.episodes) {
        final date = episode.airDate;
        if (date != null && date.isAfter(now)) {
          items.add((
            show: show,
            season: season,
            episode: episode,
            airDate: date,
          ));
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

    // The soonest airing gets the hero card; the rest fills the agenda.
    final hero = upcoming.first;
    final rest = upcoming.skip(1).toList();
    final byDay = groupBy(
      rest,
      (Upcoming u) => DateTime(u.airDate.year, u.airDate.month, u.airDate.day),
    );
    final days = byDay.keys.sorted((a, b) => a.compareTo(b));

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        _Hero(item: hero),
        for (final day in days) ...[
          _DayHeader(day: day),
          for (final u in byDay[day]!) _UpcomingRow(item: u),
        ],
      ],
    );
  }

  Widget _empty(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.event_available_outlined, size: 56, color: dust),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).noUpcoming,
          style: condensed(size: 17),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            AppLocalizations.of(context).noUpcomingBody,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: dust),
          ),
        ),
      ],
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.item});

  final Upcoming item;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(
      item.airDate.year,
      item.airDate.month,
      item.airDate.day,
    );
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final diff = day.difference(today).inDays;
    final when = diff == 0
        ? l10n.tonight
        : diff == 1
        ? l10n.tomorrow
        : DateFormat('EEEE d MMMM', locale).format(day);

    final ep = item.episode;
    final line = [
      'S${_pad(item.season.number)}E${_pad(ep.number)}',
      if (ep.name.isNotEmpty) ep.name,
      DateFormat('HH:mm').format(item.airDate.toLocal()),
    ].join('  ·  ');

    return FeaturedCard(
      overline: l10n.nextAiring(when),
      title: item.show.title,
      line: line,
      seed: item.show.tvdbId,
      backdropUrl: item.show.posterLarge ?? item.show.poster,
      height: 244,
      onTap: () => context.push('/show/${item.show.tvdbId}'),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final diff = day.difference(today).inDays;

    final String label;
    if (diff == 0) {
      label = l10n.today.toUpperCase();
    } else if (diff == 1) {
      label = l10n.tomorrow.toUpperCase();
    } else if (diff < 7) {
      label = DateFormat('EEEE', locale).format(day).toUpperCase();
    } else {
      label = DateFormat('EEEE d MMMM', locale).format(day).toUpperCase();
    }

    // Past the one-week mark the weekday alone stops being useful.
    final relative = diff >= 7 ? '' : DateFormat('d MMM', locale).format(day);

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
      onTap: () => context.push('/show/${item.show.tvdbId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          children: [
            Poster(
              title: item.show.title,
              seed: item.show.tvdbId,
              url: item.show.poster,
              width: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.show.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: condensed(size: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      EpisodeTag(
                        'S${_pad(item.season.number)}E${_pad(ep.number)}',
                      ),
                      if (ep.name.isNotEmpty) ...[
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            ep.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: dust),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('HH:mm').format(item.airDate.toLocal()),
              style: mono(size: 11, color: tungsten),
            ),
          ],
        ),
      ),
    );
  }
}

String _pad(int n) => n.toString().padLeft(2, '0');
