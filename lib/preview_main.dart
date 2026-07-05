// Harness de preview visuel (hors Firebase / auth) : rend les écrans avec des
// données d'exemple pour valider l'UI sur émulateur.
//   flutter run -t lib/preview_main.dart --dart-define=TMDB_API_KEY=xxx
//   flutter run -t lib/preview_main.dart --dart-define=PREVIEW=detail ...
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/providers.dart';
import 'core/theme.dart';
import 'data/models/movie.dart';
import 'data/models/show.dart';
import 'features/home/home_screen.dart';
import 'features/movies/movie_detail_screen.dart';
import 'features/search/search_screen.dart';
import 'features/shows/show_detail_screen.dart';

const _tmdbImg = 'https://image.tmdb.org/t/p/w500';
const _screen = String.fromEnvironment('PREVIEW', defaultValue: 'home');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  runApp(ProviderScope(
    overrides: [
      authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
      trackingRepositoryProvider.overrideWithValue(null),
      showsProvider.overrideWith((ref) => Stream.value(_sampleShows)),
      moviesProvider.overrideWith((ref) => Stream.value(_sampleMovies)),
      discoverSeenKeysProvider.overrideWith((ref) => Stream.value(<String>{})),
    ],
    child: MaterialApp(
      title: 'TV Track — preview',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
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
  ));
}

// Vignettes réelles TVmaze (House of the Dragon S2) pour la preview.
const _hotdStills = [
  'https://static.tvmaze.com/uploads/images/medium_landscape/523/1308302.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/524/1310398.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/525/1314706.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/526/1315941.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/527/1318505.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/528/1320543.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/529/1323520.jpg',
  'https://static.tvmaze.com/uploads/images/medium_landscape/530/1325316.jpg',
];

Season _season(int n, int count, int watched,
        {int? futureEpAt, bool stills = false}) =>
    Season(
      number: n,
      episodes: [
        for (var i = 1; i <= count; i++)
          Episode(
            tvdbId: n * 1000 + i,
            number: i,
            name: 'Épisode $i',
            watched: i <= watched,
            watchedAt: i <= watched ? DateTime(2026, 6, i.clamp(1, 28)) : null,
            overview: i <= watched + 1
                ? 'Les tensions montent d\'un cran ; une alliance inattendue '
                    'redistribue les cartes avant l\'affrontement final.'
                : null,
            still: stills && i <= _hotdStills.length ? _hotdStills[i - 1] : null,
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
        'Près de 200 ans avant les évènements de Game of Thrones, la maison '
        'Targaryen est au sommet de sa puissance, forte de ses dragons. La '
        'lutte pour la succession de Viserys Ier menace de déchirer la '
        'dynastie et de plonger Westeros dans la guerre.',
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
    seasons: [
      _season(1, 10, 10),
      _season(2, 10, 6, futureEpAt: 7),
    ],
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
    seasons: [_season(1, 8, 0)], // pas commencée
  ),
];

const _dunePoster = '$_tmdbImg/1pdfLvkbY9ohJlCjQH2CZjjYVvJ.jpg';
const _duneBackdrop = '$_tmdbImg/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg';

final _sampleMovies = <Movie>[
  const Movie(
    tvdbId: 1,
    title: 'Dune : Deuxième partie',
    year: 2024,
    runtime: 167,
    poster: _dunePoster,
    backdrop: _duneBackdrop,
    overview:
        'Paul Atreides s\'unit à Chani et aux Fremen pour mener la révolte '
        'contre ceux qui ont anéanti sa famille. Hanté par des visions '
        'inquiétantes, il doit choisir entre l\'amour de sa vie et le sort '
        'de l\'univers connu.',
  ),
  const Movie(tvdbId: 2, title: 'The Wild Robot', year: 2024, watched: true),
  const Movie(tvdbId: 3, title: 'Oppenheimer', year: 2023),
];
