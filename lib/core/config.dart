/// ID client OAuth de type "Web" du projet Firebase (visible dans
/// Google Cloud Console → Identifiants, créé automatiquement quand on active
/// le provider Google dans Firebase Auth).
///
/// Requis sur Android pour Google Sign-In. Fourni au build :
///   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
/// Un ID client OAuth n'est pas un secret : le mettre en defaultValue est
/// acceptable pour une app perso.
const googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  // Client web du projet tv-track-perso (normalement résolu automatiquement
  // via google-services.json ; gardé ici en fallback).
  defaultValue:
      '304761545305-k0bnp3g6d936uumapchmfii110fri6o2.apps.googleusercontent.com',
);

/// Clé API TMDB (v3), utilisée par le deck Découverte pour lister les séries
/// populaires/tendances. Injectée au build :
///   flutter run --dart-define=TMDB_API_KEY=xxxxx
/// En CI, fournie par la variable sécurisée Codemagic du même nom.
/// Clé en lecture seule et à faible sensibilité — l'onglet Découverte se
/// désactive proprement si elle est absente.
const tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');
