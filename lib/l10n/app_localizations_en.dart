// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get undo => 'Undo';

  @override
  String get delete => 'Delete';

  @override
  String get titleGenres => 'Genres';

  @override
  String get directedBy => 'Directed by';

  @override
  String get createdBy => 'Created by';

  @override
  String get starring => 'Starring';

  @override
  String get synopsis => 'Synopsis';

  @override
  String get loadFailed => 'Couldn\'t load.';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get updatingInfo => 'Updating…';

  @override
  String get removeFromList => 'Remove from my list';

  @override
  String get libraryEmpty => 'Your library is empty';

  @override
  String get nothingHere => 'Nothing here yet.';

  @override
  String get tabUpcoming => 'Upcoming';

  @override
  String get tabShows => 'Shows';

  @override
  String get tabMovies => 'Movies';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get search => 'Search';

  @override
  String get profile => 'Profile';

  @override
  String get signInTagline => 'Where you left off, episode by episode.';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInFailed =>
      'Sign-in failed. Try again. If it keeps happening, check your connection.';

  @override
  String get filterWatching => 'Watching';

  @override
  String get filterUpToDate => 'Up to date';

  @override
  String get filterToWatch => 'To watch';

  @override
  String get filterWatched => 'Watched';

  @override
  String get statusEnded => 'Ended';

  @override
  String get statusAiring => 'Airing';

  @override
  String get statusToWatch => 'To watch';

  @override
  String get nextEpisodeLabel => 'next episode';

  @override
  String markEpisodeWatched(String code) {
    return 'Mark $code as watched';
  }

  @override
  String episodeMarkedWatched(String title, String code) {
    return '$title: $code watched';
  }

  @override
  String showRemoved(String title) {
    return '$title removed from your list';
  }

  @override
  String movieRemoved(String title) {
    return '$title removed from your list';
  }

  @override
  String get markWatched => 'Mark as watched';

  @override
  String get markUnwatched => 'Mark as unwatched';

  @override
  String get watched => 'Watched';

  @override
  String movieMarkedWatched(String title) {
    return '$title: watched';
  }

  @override
  String movieMarkedToWatch(String title) {
    return '$title: back in \"To watch\"';
  }

  @override
  String get noOverview => 'No overview available.';

  @override
  String get deleteMovieTitle => 'Delete this movie?';

  @override
  String deleteMovieBody(String title) {
    return '“$title” will be removed from your list.';
  }

  @override
  String get noUpcoming => 'Nothing scheduled';

  @override
  String get noUpcomingBody =>
      'The next episodes of the shows you follow will show up here.';

  @override
  String get tonight => 'Tonight';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get today => 'Today';

  @override
  String nextAiring(String when) {
    return 'Next airing · $when';
  }

  @override
  String get searchHint => 'Search for a show or a movie…';

  @override
  String get searchMinChars => 'Type at least 2 letters.';

  @override
  String get myLibrary => 'My library';

  @override
  String get searchUnavailable => 'Search unavailable.';

  @override
  String get noResults => 'No results.';

  @override
  String get kindShow => 'Show';

  @override
  String get kindMovie => 'Movie';

  @override
  String showProgress(int watched, int total) {
    return 'Show · $watched/$total';
  }

  @override
  String get daysOnScreen => 'Days on screen';

  @override
  String get hoursWatched => 'Hours watched';

  @override
  String get statEpisodesWatched => 'episodes watched';

  @override
  String get statMoviesWatched => 'movies watched';

  @override
  String get statShowsTracked => 'shows tracked';

  @override
  String get statShowsInProgress => 'shows in progress';

  @override
  String get mostWatchedShow => 'Your most watched show';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count episodes',
      one: '1 episode',
    );
    return '$_temp0';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get you => 'You';

  @override
  String get language => 'Language';

  @override
  String get discoverUnavailable => 'Discover unavailable';

  @override
  String get discoverNoKey => 'No TMDB API key configured.';

  @override
  String get swipeMode => 'Swipe';

  @override
  String get browseMode => 'Browse';

  @override
  String get deckEmpty => 'Nothing left to discover right now.';

  @override
  String get stampSkip => 'NOT FOR ME';

  @override
  String get stampWant => 'WANT';

  @override
  String get railTrending => 'Trending';

  @override
  String get seeAll => 'See all ›';

  @override
  String get sortPopular => 'Popular';

  @override
  String get sortRecent => 'Recent';

  @override
  String get sortTopRated => 'Top rated';

  @override
  String get alreadyInList => 'Already in your list';

  @override
  String get openRecord => 'Open the record';

  @override
  String get addToList => 'Add to my list';

  @override
  String addedToList(String title) {
    return '$title added to your list';
  }

  @override
  String addFailed(String title) {
    return 'Couldn\'t add $title';
  }

  @override
  String get deleteShowTitle => 'Delete this show?';

  @override
  String deleteShowBody(String title) {
    return '“$title” will be removed from your list.';
  }

  @override
  String nextEpisodeOn(String date) {
    return 'NEXT EP. $date';
  }

  @override
  String get whereToWatch => 'Where to watch';

  @override
  String seasonNumber(int number) {
    return 'Season $number';
  }

  @override
  String seasonWatchedCount(int watched, int total) {
    return '$watched/$total watched';
  }

  @override
  String get markSeasonWatched => 'Mark the whole season as watched';

  @override
  String get markSeasonUnwatched => 'Mark the season as unwatched';

  @override
  String episodeNumber(int number) {
    return 'Episode $number';
  }

  @override
  String airsOn(String date) {
    return 'airs $date';
  }

  @override
  String unwatchedBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unwatched episodes before this one',
      one: '1 unwatched episode before this one',
    );
    return '$_temp0';
  }

  @override
  String get markAllPrevious => 'Mark all';

  @override
  String get more => 'more';

  @override
  String get less => 'less';
}
