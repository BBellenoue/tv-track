import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @titleGenres.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get titleGenres;

  /// No description provided for @directedBy.
  ///
  /// In en, this message translates to:
  /// **'Directed by'**
  String get directedBy;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get createdBy;

  /// No description provided for @starring.
  ///
  /// In en, this message translates to:
  /// **'Starring'**
  String get starring;

  /// No description provided for @synopsis.
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get synopsis;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load.'**
  String get loadFailed;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @updatingInfo.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get updatingInfo;

  /// No description provided for @removeFromList.
  ///
  /// In en, this message translates to:
  /// **'Remove from my list'**
  String get removeFromList;

  /// No description provided for @libraryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your library is empty'**
  String get libraryEmpty;

  /// No description provided for @nothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get nothingHere;

  /// No description provided for @tabUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get tabUpcoming;

  /// No description provided for @tabShows.
  ///
  /// In en, this message translates to:
  /// **'Shows'**
  String get tabShows;

  /// No description provided for @tabMovies.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get tabMovies;

  /// No description provided for @tabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get tabDiscover;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signInTagline.
  ///
  /// In en, this message translates to:
  /// **'Where you left off, episode by episode.'**
  String get signInTagline;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Try again — if it keeps happening, check your connection.'**
  String get signInFailed;

  /// No description provided for @filterWatching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get filterWatching;

  /// No description provided for @filterUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get filterUpToDate;

  /// No description provided for @filterToWatch.
  ///
  /// In en, this message translates to:
  /// **'To watch'**
  String get filterToWatch;

  /// No description provided for @filterWatched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get filterWatched;

  /// No description provided for @statusEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get statusEnded;

  /// No description provided for @statusAiring.
  ///
  /// In en, this message translates to:
  /// **'Airing'**
  String get statusAiring;

  /// No description provided for @statusToWatch.
  ///
  /// In en, this message translates to:
  /// **'To watch'**
  String get statusToWatch;

  /// No description provided for @nextEpisodeLabel.
  ///
  /// In en, this message translates to:
  /// **'next episode'**
  String get nextEpisodeLabel;

  /// No description provided for @markEpisodeWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark {code} as watched'**
  String markEpisodeWatched(String code);

  /// No description provided for @episodeMarkedWatched.
  ///
  /// In en, this message translates to:
  /// **'{title} — {code} watched'**
  String episodeMarkedWatched(String title, String code);

  /// No description provided for @showRemoved.
  ///
  /// In en, this message translates to:
  /// **'{title} removed from your list'**
  String showRemoved(String title);

  /// No description provided for @movieRemoved.
  ///
  /// In en, this message translates to:
  /// **'{title} removed from your list'**
  String movieRemoved(String title);

  /// No description provided for @markWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark as watched'**
  String get markWatched;

  /// No description provided for @markUnwatched.
  ///
  /// In en, this message translates to:
  /// **'Mark as unwatched'**
  String get markUnwatched;

  /// No description provided for @watched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watched;

  /// No description provided for @movieMarkedWatched.
  ///
  /// In en, this message translates to:
  /// **'{title} — watched'**
  String movieMarkedWatched(String title);

  /// No description provided for @movieMarkedToWatch.
  ///
  /// In en, this message translates to:
  /// **'{title} — back in \"To watch\"'**
  String movieMarkedToWatch(String title);

  /// No description provided for @noOverview.
  ///
  /// In en, this message translates to:
  /// **'No overview available.'**
  String get noOverview;

  /// No description provided for @deleteMovieTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this movie?'**
  String get deleteMovieTitle;

  /// No description provided for @deleteMovieBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed from your list.'**
  String deleteMovieBody(String title);

  /// No description provided for @noUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get noUpcoming;

  /// No description provided for @noUpcomingBody.
  ///
  /// In en, this message translates to:
  /// **'The next episodes of the shows you follow will show up here.'**
  String get noUpcomingBody;

  /// No description provided for @tonight.
  ///
  /// In en, this message translates to:
  /// **'Tonight'**
  String get tonight;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @nextAiring.
  ///
  /// In en, this message translates to:
  /// **'Next airing · {when}'**
  String nextAiring(String when);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for a show or a movie…'**
  String get searchHint;

  /// No description provided for @searchMinChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 letters.'**
  String get searchMinChars;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'My library'**
  String get myLibrary;

  /// No description provided for @searchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Search unavailable.'**
  String get searchUnavailable;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @kindShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get kindShow;

  /// No description provided for @kindMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get kindMovie;

  /// No description provided for @showProgress.
  ///
  /// In en, this message translates to:
  /// **'Show · {watched}/{total}'**
  String showProgress(int watched, int total);

  /// No description provided for @daysOnScreen.
  ///
  /// In en, this message translates to:
  /// **'Days on screen'**
  String get daysOnScreen;

  /// No description provided for @hoursWatched.
  ///
  /// In en, this message translates to:
  /// **'Hours watched'**
  String get hoursWatched;

  /// No description provided for @statEpisodesWatched.
  ///
  /// In en, this message translates to:
  /// **'episodes watched'**
  String get statEpisodesWatched;

  /// No description provided for @statMoviesWatched.
  ///
  /// In en, this message translates to:
  /// **'movies watched'**
  String get statMoviesWatched;

  /// No description provided for @statShowsTracked.
  ///
  /// In en, this message translates to:
  /// **'shows tracked'**
  String get statShowsTracked;

  /// No description provided for @statShowsInProgress.
  ///
  /// In en, this message translates to:
  /// **'shows in progress'**
  String get statShowsInProgress;

  /// No description provided for @mostWatchedShow.
  ///
  /// In en, this message translates to:
  /// **'Your most watched show'**
  String get mostWatchedShow;

  /// No description provided for @episodeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 episode} other{{count} episodes}}'**
  String episodeCount(int count);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @discoverUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Discover unavailable'**
  String get discoverUnavailable;

  /// No description provided for @discoverNoKey.
  ///
  /// In en, this message translates to:
  /// **'No TMDB API key configured.'**
  String get discoverNoKey;

  /// No description provided for @swipeMode.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get swipeMode;

  /// No description provided for @browseMode.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browseMode;

  /// No description provided for @deckEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to discover right now.'**
  String get deckEmpty;

  /// No description provided for @stampSkip.
  ///
  /// In en, this message translates to:
  /// **'NOT FOR ME'**
  String get stampSkip;

  /// No description provided for @stampWant.
  ///
  /// In en, this message translates to:
  /// **'WANT'**
  String get stampWant;

  /// No description provided for @railTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get railTrending;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all ›'**
  String get seeAll;

  /// No description provided for @sortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get sortPopular;

  /// No description provided for @sortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get sortRecent;

  /// No description provided for @sortTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top rated'**
  String get sortTopRated;

  /// No description provided for @alreadyInList.
  ///
  /// In en, this message translates to:
  /// **'Already in your list'**
  String get alreadyInList;

  /// No description provided for @addToList.
  ///
  /// In en, this message translates to:
  /// **'Add to my list'**
  String get addToList;

  /// No description provided for @addedToList.
  ///
  /// In en, this message translates to:
  /// **'{title} added to your list'**
  String addedToList(String title);

  /// No description provided for @addFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add {title}'**
  String addFailed(String title);

  /// No description provided for @deleteShowTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this show?'**
  String get deleteShowTitle;

  /// No description provided for @deleteShowBody.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be removed from your list.'**
  String deleteShowBody(String title);

  /// No description provided for @nextEpisodeOn.
  ///
  /// In en, this message translates to:
  /// **'NEXT EP. {date}'**
  String nextEpisodeOn(String date);

  /// No description provided for @whereToWatch.
  ///
  /// In en, this message translates to:
  /// **'Where to watch'**
  String get whereToWatch;

  /// No description provided for @seasonNumber.
  ///
  /// In en, this message translates to:
  /// **'Season {number}'**
  String seasonNumber(int number);

  /// No description provided for @seasonWatchedCount.
  ///
  /// In en, this message translates to:
  /// **'{watched}/{total} watched'**
  String seasonWatchedCount(int watched, int total);

  /// No description provided for @markSeasonWatched.
  ///
  /// In en, this message translates to:
  /// **'Mark the whole season as watched'**
  String get markSeasonWatched;

  /// No description provided for @markSeasonUnwatched.
  ///
  /// In en, this message translates to:
  /// **'Mark the season as unwatched'**
  String get markSeasonUnwatched;

  /// No description provided for @episodeNumber.
  ///
  /// In en, this message translates to:
  /// **'Episode {number}'**
  String episodeNumber(int number);

  /// No description provided for @airsOn.
  ///
  /// In en, this message translates to:
  /// **'airs {date}'**
  String airsOn(String date);

  /// No description provided for @unwatchedBefore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 unwatched episode before this one} other{{count} unwatched episodes before this one}}'**
  String unwatchedBefore(int count);

  /// No description provided for @markAllPrevious.
  ///
  /// In en, this message translates to:
  /// **'Mark all'**
  String get markAllPrevious;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'more'**
  String get more;

  /// No description provided for @less.
  ///
  /// In en, this message translates to:
  /// **'less'**
  String get less;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
