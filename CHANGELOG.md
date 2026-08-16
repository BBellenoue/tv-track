# Changelog

Notable changes to TV Track. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project follows
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-08-16

First public release.

### Added

- Upcoming schedule across every followed title, with a hero card for the
  closest airing and the rest grouped by day
- Shows and movies lists with per-season progress, detail pages carrying the
  synopsis, the genres, the director or the creators, the main cast, episode
  rows with stills and streaming availability, bulk catch-up and swipe to
  remove
- Discover, as a swipe deck drawn from what you have actually watched, and a
  Browse view with genre rails and a sortable infinite grid
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

### Security

- The TMDB and TheTVDB keys never ship inside the app. Metadata travels through
  a server-side proxy that holds the credentials and serves signed-in callers
  only.

[Unreleased]: https://github.com/BBellenoue/tv-track/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/BBellenoue/tv-track/releases/tag/v1.0.0
