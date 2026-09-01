# Changelog

Notable changes to TV Track. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project follows
[semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.3] - 2026-09-01

### Fixed

- A show imported from the TV Time export kept the export's title for good, so
  searching the name the rest of the app displays never reached it. Show titles
  now follow TheTVDB in the language the app runs in, as overviews and episode
  titles already did.
- The preview sheet of a title already in the library was a dead end: it said
  so on a disabled button and offered no way through. It opens the record now.
- Search through the library ignores case and accents, so "nouvelle ecole"
  finds "Nouvelle École".

## [1.0.2] - 2026-08-29

### Fixed

- Adding a title from Discover or Search failed now and then and went through
  on a second try. Reads through the metadata proxy retry a timeout, a dropped
  connection or an upstream 5xx, and an add no longer depends on the
  enrichment call succeeding.

## [1.0.1] - 2026-08-29

### Added

- Pull to refresh on a show and on the Shows list, which re-fetches metadata
  there and then instead of waiting for the daily pass

### Fixed

- A show could sit forever with a season listed as bare "Episode 1", "Episode
  2": the daily refresh filled its batch with records that stay incomplete
  whatever happens, so the rest of the library was never revisited
- Episode titles and overviews for a season that has no translation yet, which
  TheTVDB serves empty rather than falling back on its own. They now come back
  in English instead of not at all.

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

[Unreleased]: https://github.com/BBellenoue/tv-track/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/BBellenoue/tv-track/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/BBellenoue/tv-track/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/BBellenoue/tv-track/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/BBellenoue/tv-track/releases/tag/v1.0.0
