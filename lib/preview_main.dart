// Visual preview harness: renders the screens against sample data, with no
// Firebase project and no sign-in, so the UI can be checked on an emulator.
//
//   flutter run -t lib/preview_main.dart --dart-define=PREVIEW=detail
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/providers.dart';
import 'core/theme.dart';
import 'data/models/movie.dart';
import 'data/models/show.dart';
import 'features/home/home_screen.dart';
import 'features/movies/movie_detail_screen.dart';
import 'features/search/search_screen.dart';
import 'features/shows/show_detail_screen.dart';
import 'l10n/app_localizations.dart';

const _tmdbImg = 'https://image.tmdb.org/t/p/w500';
const _screen = String.fromEnvironment('PREVIEW', defaultValue: 'home');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        trackingRepositoryProvider.overrideWithValue(null),
        showsProvider.overrideWith((ref) => Stream.value(_sampleShows)),
        moviesProvider.overrideWith((ref) => Stream.value(_sampleMovies)),
        discoverSeenKeysProvider.overrideWith(
          (ref) => Stream.value(<String>{}),
        ),
      ],
      child: MaterialApp(
        title: 'TV Track preview',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: switch (_screen) {
          'detail' => const ShowDetailScreen(tvdbId: 94997),
          'movie' => const MovieDetailScreen(tvdbId: 1),
          'search' => const SearchScreen(),
          _ => const HomeScreen(),
        },
      ),
    ),
  );
}

// Real episode stills, so the episode rows render as they would in production.
const _stills = [
  'https://static.tvmaze.com/uploads/images/medium_landscape/523/1308302.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/524/1310398.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/525/1314706.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/526/1315941.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/527/1318505.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/528/1320543.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/529/1323520.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/530/1325316.jpg',
];

Season _season(
  int n,
  int count,
  int watched, {
  int? futureEpAt,
  bool stills = false,
}) => Season(
  number: n,
  episodes: [
    for (var i = 1; i <= count; i++)
      Episode(
        tvdbId: n * 1000 + i,
        number: i,
        name: 'Episode $i',
        watched: i <= watched,
        watchedAt: i <= watched ? DateTime(2026, 6, i.clamp(1, 28)) : null,
        overview: i <= watched + 1
            ? 'Tensions rise another notch, and an unexpected alliance '
                  'reshuffles the board before the final confrontation.'
            : null,
        still: stills && i <= _stills.length ? _stills[i - 1] : null,
        airDate: futureEpAt == i ? DateTime(2026, 7, 10 + n, 21, 0) : null,
      ),
  ],
);

final _sampleShows = <Show>[
  Show(
    tvdbId: 94997,
    tmdbId: 94997,
    title: 'House of the Dragon',
    poster: '$_tmdbImg/lP73xk4HGJ9CPxDWouzKzK6j82o.jpg',
    posterLarge: '$_tmdbImg/lP73xk4HGJ9CPxDWouzKzK6j82o.jpg',
    airStatus: 'Running',
    network: 'HBO',
    providers: const ['Max'],
    overview:
        'Nearly 200 years before the events of Game of Thrones, House '
        'Targaryen is at the height of its power, dragons and all. The fight '
        'over who succeeds Viserys I threatens to tear the dynasty apart and '
        'drag Westeros into war.',
    seasons: [
      _season(1, 10, 10),
      _season(2, 8, 3, futureEpAt: 4, stills: true),
    ],
  ),
  Show(
    tvdbId: 124364,
    tmdbId: 124364,
    title: 'FROM',
    poster: '$_tmdbImg/ubZpbtVOZJulIiqYWOPUl5DvaBY.jpg',
    airStatus: 'Running',
    network: 'MGM+',
    providers: const ['Paramount+'],
    seasons: [_season(1, 10, 10), _season(2, 10, 6, futureEpAt: 7)],
  ),
  Show(
    tvdbId: 1399,
    tmdbId: 1399,
    title: 'Game of Thrones',
    poster: '$_tmdbImg/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
    airStatus: 'Ended',
    network: 'HBO',
    seasons: [_season(1, 10, 10), _season(2, 10, 10)],
  ),
  Show(
    tvdbId: 66732,
    tmdbId: 66732,
    title: 'Stranger Things',
    poster: '$_tmdbImg/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',
    airStatus: 'Ended',
    network: 'Netflix',
    providers: const ['Netflix'],
    seasons: [_season(1, 8, 0)], // never started, to cover that filter
  ),
];

const _dunePoster = '$_tmdbImg/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg';
const _duneBackdrop = '$_tmdbImg/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg';

final _sampleMovies = <Movie>[
  const Movie(
    tvdbId: 1,
    title: 'Dune: Part Two',
    year: 2024,
    runtime: 167,
    poster: _dunePoster,
    backdrop: _duneBackdrop,
    overview:
        'Paul Atreides unites with Chani and the Fremen to wage war against '
        'those who destroyed his family. Haunted by visions of a terrible '
        'future, he must choose between the love of his life and the fate of '
        'the known universe.',
  ),
  const Movie(tvdbId: 2, title: 'The Wild Robot', year: 2024, watched: true),
  const Movie(tvdbId: 3, title: 'Oppenheimer', year: 2023),
];
