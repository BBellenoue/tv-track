import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/locale.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/section_label.dart';
import '../../data/models/movie.dart';
import '../../data/models/show.dart';
import '../../l10n/app_localizations.dart';
import '../auth/auth_controller.dart';

// Watch time is an estimate: episodes carry no runtime, and most movies only
// have one once TMDB has been queried.
const _avgEpisodeMinutes = 42;
const _avgMovieMinutes = 115;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final shows = ref.watch(showsProvider).value ?? const <Show>[];
    final movies = ref.watch(moviesProvider).value ?? const <Movie>[];

    final watchedEpisodes = shows.fold<int>(0, (n, s) => n + s.watchedEpisodes);
    final watchedMovies = movies.where((m) => m.watched).toList();
    final seriesInProgress = shows
        .where((s) => s.isStarted && !s.isUpToDate)
        .length;
    final seriesMinutes = watchedEpisodes * _avgEpisodeMinutes;
    final movieMinutes = watchedMovies.fold<int>(
      0,
      (n, m) => n + (m.runtime ?? _avgMovieMinutes),
    );
    final totalMinutes = seriesMinutes + movieMinutes;
    final days = totalMinutes / 60 / 24;

    final topShow = shows.isEmpty
        ? null
        : shows.reduce(
            (a, b) => a.watchedEpisodes >= b.watchedEpisodes ? a : b,
          );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile.toUpperCase())),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _AccountHeader(
            name: user?.displayName,
            email: user?.email,
            photo: user?.photoURL,
          ),
          const SizedBox(height: 28),

          // Headline figure: hours until there is enough to talk in days.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              color: charcoal,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tungsten.withValues(alpha: .35)),
            ),
            child: Column(
              children: [
                Text(
                  days >= 1
                      ? days.toStringAsFixed(1)
                      : (totalMinutes / 60).toStringAsFixed(0),
                  style: condensed(
                    size: 52,
                    weight: FontWeight.w700,
                    color: tungsten,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (days >= 1 ? l10n.daysOnScreen : l10n.hoursWatched)
                      .toUpperCase(),
                  style: mono(size: 11, letterSpacing: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              _Stat(value: '$watchedEpisodes', label: l10n.statEpisodesWatched),
              const SizedBox(width: 12),
              _Stat(
                value: '${watchedMovies.length}',
                label: l10n.statMoviesWatched,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Stat(value: '${shows.length}', label: l10n.statShowsTracked),
              const SizedBox(width: 12),
              _Stat(
                value: '$seriesInProgress',
                label: l10n.statShowsInProgress,
              ),
            ],
          ),

          if (topShow != null && topShow.watchedEpisodes > 0) ...[
            const SizedBox(height: 28),
            SectionLabel(l10n.mostWatchedShow),
            const SizedBox(height: 10),
            Text(topShow.title, style: condensed(size: 20)),
            Text(
              l10n.episodeCount(topShow.watchedEpisodes),
              style: mono(size: 11, color: tungsten),
            ),
          ],

          const SizedBox(height: 28),
          SectionLabel(l10n.language),
          const SizedBox(height: 10),
          const _LanguagePicker(),

          const SizedBox(height: 40),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE07A6B),
              side: BorderSide(
                color: const Color(0xFFE07A6B).withValues(alpha: .5),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout),
            label: Text(l10n.signOut, style: condensed(size: 15)),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}

/// Switches the interface language, and with it the language metadata is
/// fetched in — show and episode text follows on the next refresh.
class _LanguagePicker extends ConsumerWidget {
  const _LanguagePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeControllerProvider);

    return Row(
      children: [
        for (final locale in AppLocale.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  ref.read(localeControllerProvider.notifier).select(locale),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: locale == current ? tungsten : charcoal,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: locale == current ? tungsten : outlineDim,
                  ),
                ),
                child: Center(
                  child: Text(
                    locale.label,
                    style: condensed(
                      size: 14,
                      color: locale == current ? const Color(0xFF221603) : dust,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (locale != AppLocale.values.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({this.name, this.email, this.photo});
  final String? name;
  final String? email;
  final String? photo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: charcoalHigh,
          backgroundImage: photo != null ? NetworkImage(photo!) : null,
          child: photo == null ? const Icon(Icons.person, color: dust) : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? AppLocalizations.of(context).you,
                style: condensed(size: 20),
              ),
              if (email != null)
                Text(
                  email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono(size: 11),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: charcoal,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: condensed(size: 30, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label, style: mono(size: 10.5)),
          ],
        ),
      ),
    );
  }
}
