# Setup

This repository ships no Firebase configuration: to build the app you point it
at a Firebase project of your own. The free Spark plan is enough.

Replace `<your-project>` and `<your.package.id>` below with your own values.
The default package id used by this repo is `dev.quietmachineworks.tvtrack`; if you change
it, update `android/app/build.gradle.kts` (`namespace` and `applicationId`)
accordingly.

## 1. Create and link a Firebase project

1. Create a project on [console.firebase.google.com](https://console.firebase.google.com).
2. **Authentication → Sign-in method**: enable **Google**. This step has to be
   done in the console — it provisions the OAuth web client for you.
3. Create the database and deploy the security rules:
   ```sh
   gcloud services enable firestore.googleapis.com --project=<your-project>
   gcloud firestore databases create --location=europe-west1 --project=<your-project>
   firebase deploy --only firestore:rules --project=<your-project>
   ```
4. Generate the local configuration files (all gitignored):
   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<your-project> --platforms=android \
     --android-package-name=<your.package.id> --yes
   ```
5. Register the SHA-1 and SHA-256 fingerprints of your debug keystore under
   *Project settings → Your apps → Android → Add fingerprint*. Google Sign-In
   rejects the app until they are present:
   ```sh
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android \
     | openssl x509 -inform DER -fingerprint -sha1 -noout
   ```
   Then download `google-services.json` again (or re-run `flutterfire configure`)
   so it includes the OAuth clients.

## 2. Run

```sh
flutter pub get
dart run build_runner build
flutter run --dart-define=METADATA_PROXY_URL=https://europe-west1-xxx.cloudfunctions.net/metadata \
            --dart-define=GOOGLE_SERVER_CLIENT_ID=xxxxx.apps.googleusercontent.com
```

`GOOGLE_SERVER_CLIENT_ID` is the OAuth **web** client ID that Firebase created
when you enabled the Google provider — find it under *Google Cloud Console →
Credentials*, or as the `client_type: 3` entry in `google-services.json`.
Google Sign-In on Android needs it; without it the app builds fine and then
fails at sign-in with `serverClientId must be provided on Android`.

`METADATA_PROXY_URL` points at the proxy deployed in step 3.1, which holds the
provider keys. Both are free:

| Key | Where to get it | What breaks without it |
|---|---|---|
| `TVDB_API_KEY` | [thetvdb.com/api-information](https://thetvdb.com/api-information) | Show metadata enrichment (seasons, episodes, artwork) |
| `TMDB_API_KEY` | [themoviedb.org → Settings → API](https://www.themoviedb.org/settings/api) | Discover, global search, streaming providers |

Without the proxy URL the app still runs on whatever is already stored in
Firestore, with the affected features disabled.

### UI preview without Firebase

Renders the screens against sample data, so no Firebase project is needed:

```sh
flutter run -t lib/preview_main.dart
# variants: --dart-define=PREVIEW=detail|movie|search
```

### Seeding a TV Time export (one-shot, outside the app)

1. Sign in once in the app, which creates the Firebase Auth user.
2. Grab the UID from *Firebase console → Authentication → Users*, or:
   ```sh
   firebase auth:export /dev/stdout --format=json --project=<your-project>
   ```
3. Import the export:
   ```sh
   dart run tool/seed_tvtime.dart --uid <UID> \
     --series tvtime-series-<date>.json \
     --movies tvtime-movies-<date>.json
   ```

The script reuses the app's tested parser and writes through the Firestore REST
API with your `gcloud` token, so IAM applies and the security rules are bypassed.
It is idempotent: one document per `tvdbId`, safe to re-run.

## 3. CI: GitHub Actions → Firebase App Distribution

Add the following under *Settings → Secrets and variables → Actions →
Repository secrets* (encode file values with `base64 -i <file>`):

| Secret | Contents |
|---|---|
| `FIREBASE_ANDROID_APP_ID` | Firebase Android app ID (`1:…:android:…`) |
| `GOOGLE_SERVER_CLIENT_ID` | OAuth web client ID (`…apps.googleusercontent.com`) |
| `ANDROID_KEY_ALIAS` | key alias inside the release keystore |
| `METADATA_PROXY_URL` | URL of the deployed proxy (see below) |
| `GOOGLE_SERVICES_JSON` | base64 of `android/app/google-services.json` |
| `FIREBASE_OPTIONS_DART` | base64 of `lib/firebase_options.dart` |
| `ANDROID_KEYSTORE` | base64 of the release keystore |
| `ANDROID_KEYSTORE_PASSWORD` | keystore password |
| `FIREBASE_SERVICE_ACCOUNT` | JSON key of a service account with the *Firebase App Distribution Admin* role |

The TMDB and TheTVDB keys are deliberately absent: they live in the proxy, not
in the APK.

Two things also need to exist on the Firebase side:

- the SHA-1 and SHA-256 of the **release** keystore, registered like the debug
  ones in step 1.5;
- a tester group named **`testers`** in App Distribution — that alias is what
  `.github/workflows/release.yml` publishes to.

### 3.1 Metadata proxy

`functions/` holds a Cloud Function that forwards read-only calls to TMDB and
TheTVDB, appending the provider credentials server-side. Anything shipped in an
APK is extractable, so the keys never leave the server; the function answers
callers presenting a valid Firebase ID token only.

Cloud Functions requires the **Blaze** plan — at this volume the monthly bill
stays within the free grant, but a card must be on file.

```sh
cd functions && npm install && cd ..

firebase functions:secrets:set TMDB_API_KEY
firebase functions:secrets:set TVDB_API_KEY
firebase deploy --only functions
```

The deploy prints the function URL. That URL is the `METADATA_PROXY_URL` secret
above, and the `--dart-define` local builds need:

```sh
flutter run --dart-define=METADATA_PROXY_URL=https://europe-west1-<project>.cloudfunctions.net/metadata
```

Rotating a provider key means re-running `functions:secrets:set` and
redeploying; no app release is involved. `tool/enrich_metadata.dart` still talks
to the providers directly with `TMDB_API_KEY` / `TVDB_API_KEY` from the
environment, since it runs on your machine rather than on a device.

### Creating the release keystore and service account

```sh
keytool -genkeypair -v -keystore release.keystore -alias <your-alias> \
  -keyalg RSA -keysize 2048 -validity 10000

gcloud iam service-accounts create app-distribution \
  --display-name="App Distribution" --project=<your-project>
gcloud projects add-iam-policy-binding <your-project> \
  --member="serviceAccount:app-distribution@<your-project>.iam.gserviceaccount.com" \
  --role="roles/firebaseappdistro.admin" --condition=None
gcloud iam service-accounts keys create service-account.json \
  --iam-account=app-distribution@<your-project>.iam.gserviceaccount.com
```

Store the keystore and its password outside the repository and back them up:
losing the keystore means you can no longer update an installed build. Once both
files are loaded into the repository secrets, delete the local service account
key.

### Cutting a release

Builds are tag-driven, so `main` moves without producing an APK:

```sh
# bump `version:` in pubspec.yaml and add the section to CHANGELOG.md first
git tag -a v1.2.3 -m "TV Track 1.2.3"
git push origin v1.2.3
```

The tag runs codegen → tests → signed APK → distribution to the `testers` group
in [`release.yml`](../.github/workflows/release.yml). Pull requests and pushes to
`main` run [`ci.yml`](../.github/workflows/ci.yml) instead, which analyzes,
checks formatting and runs the tests without building an APK.
