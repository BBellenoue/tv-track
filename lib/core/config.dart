/// Build-time configuration.
///
/// Every value below is supplied with `--dart-define` so that nothing tied to a
/// specific Firebase project lives in the repository. Each feature degrades
/// gracefully when its value is missing. Provider API keys are deliberately
/// absent: they stay server-side, behind the proxy in `functions/`.
library;

/// OAuth "Web" client ID of the Firebase project, required by Google Sign-In on
/// Android:
///
///   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=xxx.apps.googleusercontent.com
///
/// Left empty, the plugin falls back to the `default_web_client_id` string
/// resource generated from `google-services.json`, which requires a
/// `client_type: 3` entry in that file, and survives release builds only
/// because `android/app/src/main/res/raw/keep.xml` holds it against the
/// resource shrinker.
///
/// Both conditions fail silently at build time and surface as a sign-in error
/// on the device, so passing the value explicitly keeps the configuration
/// visible and reviewable.
///
/// This is not a secret: it ships inside the APK either way.
const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

/// Base URL of the metadata proxy deployed from `functions/`, which holds the
/// TMDB and TheTVDB keys so the APK never carries them:
///
///   flutter run --dart-define=METADATA_PROXY_URL=https://europe-west1-xxx.cloudfunctions.net/metadata
///
/// It answers signed-in callers only, and exposes one path per provider
/// (`/tmdb/…`, `/tvdb/…`) mirroring the upstream routes. Left empty, Discover,
/// search and show enrichment disable themselves.
const metadataProxyUrl = String.fromEnvironment('METADATA_PROXY_URL');

/// Streaming market used to resolve "where to watch" providers and regional
/// release dates, as an ISO 3166-1 country code. Separate from the interface
/// language: where you live is not what language you read in.
const watchRegion = String.fromEnvironment('WATCH_REGION', defaultValue: 'FR');
