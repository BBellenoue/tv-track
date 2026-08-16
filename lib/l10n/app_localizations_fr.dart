// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get cancel => 'Annuler';

  @override
  String get undo => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get titleGenres => 'Genres';

  @override
  String get directedBy => 'Réalisation';

  @override
  String get createdBy => 'Création';

  @override
  String get starring => 'Avec';

  @override
  String get synopsis => 'Synopsis';

  @override
  String get loadFailed => 'Chargement impossible.';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get updatingInfo => 'Mise à jour des infos…';

  @override
  String get removeFromList => 'Retirer de ma liste';

  @override
  String get libraryEmpty => 'Bibliothèque vide';

  @override
  String get nothingHere => 'Rien ici pour le moment.';

  @override
  String get tabUpcoming => 'À venir';

  @override
  String get tabShows => 'Séries';

  @override
  String get tabMovies => 'Films';

  @override
  String get tabDiscover => 'Découverte';

  @override
  String get search => 'Rechercher';

  @override
  String get profile => 'Profil';

  @override
  String get signInTagline => 'Où tu t\'es arrêté, épisode par épisode.';

  @override
  String get signInWithGoogle => 'Continuer avec Google';

  @override
  String get signInFailed =>
      'Connexion impossible. Réessaie — si ça persiste, vérifie ta connexion.';

  @override
  String get filterWatching => 'En cours';

  @override
  String get filterUpToDate => 'À jour';

  @override
  String get filterToWatch => 'À voir';

  @override
  String get filterWatched => 'Vus';

  @override
  String get statusEnded => 'Terminée';

  @override
  String get statusAiring => 'En diffusion';

  @override
  String get statusToWatch => 'À voir';

  @override
  String get nextEpisodeLabel => 'prochain épisode';

  @override
  String markEpisodeWatched(String code) {
    return 'Marquer $code vu';
  }

  @override
  String episodeMarkedWatched(String title, String code) {
    return '$title — $code vu';
  }

  @override
  String showRemoved(String title) {
    return '$title retirée de ta liste';
  }

  @override
  String movieRemoved(String title) {
    return '$title retiré de ta liste';
  }

  @override
  String get markWatched => 'Marquer vu';

  @override
  String get markUnwatched => 'Marquer non vu';

  @override
  String get watched => 'Vu';

  @override
  String movieMarkedWatched(String title) {
    return '$title — vu';
  }

  @override
  String movieMarkedToWatch(String title) {
    return '$title — remis dans « À voir »';
  }

  @override
  String get noOverview => 'Pas de résumé disponible.';

  @override
  String get deleteMovieTitle => 'Supprimer le film ?';

  @override
  String deleteMovieBody(String title) {
    return '« $title » sera retiré de ta liste.';
  }

  @override
  String get noUpcoming => 'Aucune diffusion annoncée';

  @override
  String get noUpcomingBody =>
      'Les prochains épisodes de tes séries en cours apparaîtront ici.';

  @override
  String get tonight => 'Ce soir';

  @override
  String get tomorrow => 'Demain';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String nextAiring(String when) {
    return 'Prochaine diffusion · $when';
  }

  @override
  String get searchHint => 'Rechercher une série, un film…';

  @override
  String get searchMinChars => 'Tape au moins 2 lettres.';

  @override
  String get myLibrary => 'Ma bibliothèque';

  @override
  String get searchUnavailable => 'Recherche indisponible.';

  @override
  String get noResults => 'Aucun résultat.';

  @override
  String get kindShow => 'Série';

  @override
  String get kindMovie => 'Film';

  @override
  String showProgress(int watched, int total) {
    return 'Série · $watched/$total';
  }

  @override
  String get daysOnScreen => 'Jours devant l\'écran';

  @override
  String get hoursWatched => 'Heures de visionnage';

  @override
  String get statEpisodesWatched => 'épisodes vus';

  @override
  String get statMoviesWatched => 'films vus';

  @override
  String get statShowsTracked => 'séries suivies';

  @override
  String get statShowsInProgress => 'séries en cours';

  @override
  String get mostWatchedShow => 'Ta série la plus regardée';

  @override
  String episodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes',
      one: '1 épisode',
    );
    return '$_temp0';
  }

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get you => 'Toi';

  @override
  String get language => 'Langue';

  @override
  String get discoverUnavailable => 'Découverte indisponible';

  @override
  String get discoverNoKey => 'Aucune clé TMDB configurée.';

  @override
  String get swipeMode => 'Swipe';

  @override
  String get browseMode => 'Parcourir';

  @override
  String get deckEmpty => 'Plus rien à découvrir pour l\'instant.';

  @override
  String get stampSkip => 'PAS POUR MOI';

  @override
  String get stampWant => 'ENVIE';

  @override
  String get railTrending => 'Tendances';

  @override
  String get seeAll => 'Tout voir ›';

  @override
  String get sortPopular => 'Populaires';

  @override
  String get sortRecent => 'Récentes';

  @override
  String get sortTopRated => 'Mieux notées';

  @override
  String get alreadyInList => 'Déjà dans ta liste';

  @override
  String get addToList => 'Ajouter à ma liste';

  @override
  String addedToList(String title) {
    return '$title ajouté à ta liste';
  }

  @override
  String addFailed(String title) {
    return 'Impossible d\'ajouter $title';
  }

  @override
  String get deleteShowTitle => 'Supprimer la série ?';

  @override
  String deleteShowBody(String title) {
    return '« $title » sera retirée de ta liste.';
  }

  @override
  String nextEpisodeOn(String date) {
    return 'PROCHAIN ÉP. $date';
  }

  @override
  String get whereToWatch => 'Où regarder';

  @override
  String seasonNumber(int number) {
    return 'Saison $number';
  }

  @override
  String seasonWatchedCount(int watched, int total) {
    return '$watched/$total vus';
  }

  @override
  String get markSeasonWatched => 'Marquer toute la saison vue';

  @override
  String get markSeasonUnwatched => 'Marquer la saison non vue';

  @override
  String episodeNumber(int number) {
    return 'Épisode $number';
  }

  @override
  String airsOn(String date) {
    return 'diffusé le $date';
  }

  @override
  String unwatchedBefore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épisodes non vus avant celui-ci',
      one: '1 épisode non vu avant celui-ci',
    );
    return '$_temp0';
  }

  @override
  String get markAllPrevious => 'Tout marquer';

  @override
  String get more => 'plus';

  @override
  String get less => 'moins';
}
