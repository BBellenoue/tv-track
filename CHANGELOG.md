# Changelog

Notable changes to TV Track. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project follows
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] — 2026-08-09

### Added

- Discover now suggests titles drawn from what you have actually watched, so
  the deck reflects your library instead of repeating the same popular list on
  every launch
- Show and movie pages list the genres, the director or the creators, and the
  main cast

### Changed

- The pass stamp read "LATER" although the choice was final. It reads "NOT FOR
  ME", which is what it does
- Refreshing metadata is faster and pulls less data, since unchanged
  information is no longer downloaded again

### Fixed

- Discover offering titles already in your library, and bringing back cards you
  had already swiped away
- The title missing from a show page whenever it was not part of the artwork

## [1.1.0] — 2026-08-08

### Security

- The TMDB and TheTVDB keys no longer ship inside the app. Metadata now travels
  through a server-side proxy that holds the credentials and serves signed-in
  callers only.

## [1.0.0] — 2026-08-08

First public release. Development before this point is not covered here.

### Added

- Upcoming schedule across every followed title, with a hero card for the
  closest airing and the rest grouped by day
- Shows and movies lists with per-season progress, detail pages carrying the
  synopsis, episode rows with stills and streaming availability, bulk catch-up
  and swipe to remove
- Discover, as a swipe deck that adds liked titles to the library and a Browse
  view with genre rails and a sortable infinite grid
- Search across the library and the TMDB catalog in a single list
- Profile with account, language switch and watch-time stats
- English and French, switchable in-app, driving both the interface and the
  language metadata is fetched in
- TheTVDB v4 as the primary metadata source, TMDB for the discover catalog,
  search, streaming providers, movie details and season fallback
- Google sign-in with per-user Firestore storage
- TV Time export import, in-app and through `tool/seed_tvtime.dart`
- CI pipeline building a signed APK and shipping it to Firebase App
  Distribution

### Fixed

- Google Sign-In failing on release builds only: the OAuth web client ID is now
  passed explicitly through `--dart-define`, and the resource it resolves
  reflectively is kept from the release shrinker
- Titles already in the library appearing in the Browse rails and grid, where
  they were only dimmed instead of hidden

[Unreleased]: https://github.com/BBellenoue/tv-track/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/BBellenoue/tv-track/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/BBellenoue/tv-track/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/BBellenoue/tv-track/releases/tag/v1.0.0
