# Setup

Le repo est public et ne contient **aucune** config Firebase : pour builder,
il faut brancher ton propre projet Firebase (gratuit, plan Spark suffisant).
L'historique complet des commandes utilisées pour provisionner l'instance
d'origine est dans [PROVISIONING.md](PROVISIONING.md).

## 1. Créer et lier ton projet Firebase

1. Créer un projet sur [console.firebase.google.com](https://console.firebase.google.com).
2. **Authentication → Sign-in method** : activer **Google**.
3. Créer la base et déployer les règles :
   ```sh
   gcloud services enable firestore.googleapis.com --project=<ton-projet>
   gcloud firestore databases create --location=europe-west1 --project=<ton-projet>
   firebase deploy --only firestore:rules --project=<ton-projet>
   ```
4. Générer la config locale (fichiers gitignorés) :
   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<ton-projet> --platforms=android \
     --android-package-name=<ton.package.id> --yes
   ```
5. Déclarer le SHA-1 (+ SHA-256) de ton keystore debug dans
   *Paramètres du projet → Tes apps → Android → Ajouter une empreinte* :
   ```sh
   keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android \
     | openssl x509 -inform DER -fingerprint -sha1 -noout
   ```
   puis re-télécharger `google-services.json` (ou relancer `flutterfire configure`).

## 2. Lancer

```sh
flutter pub get
dart run build_runner build
flutter run
```

### Seed de l'export TV Time (one-shot, hors app)

1. Se connecter une première fois dans l'app (crée l'utilisateur Firebase Auth).
2. Récupérer l'UID : [console → Authentication → Users](https://console.firebase.google.com/project/tv-track-perso/authentication/users),
   ou `firebase auth:export /dev/stdout --format=json --project=<projet>`.
3. ```sh
   dart run tool/seed_tvtime.dart --uid <UID> \
     --series tvtime-series-2026-07-03.json \
     --movies tvtime-movies-2026-07-03.json
   ```

Le script réutilise le parser testé de l'app et écrit via l'API REST Firestore
avec ton token gcloud (accès IAM : les security rules ne s'appliquent pas).
Idempotent : un doc par `tvdbId`, relançable sans doublons.

## 3. CI Codemagic → Firebase App Distribution

Connecter le repo dans Codemagic ; `codemagic.yaml` est détecté. Créer un
groupe de variables **`firebase`** (les valeurs base64 : `base64 -i <fichier>`) :

| Variable | Contenu | Secure |
|---|---|---|
| `FIREBASE_ANDROID_APP_ID` | app ID Android (`1:…:android:…`) | non |
| `GOOGLE_SERVICES_JSON` | base64 de `android/app/google-services.json` | oui |
| `FIREBASE_OPTIONS_DART` | base64 de `lib/firebase_options.dart` | oui |
| `ANDROID_KEYSTORE` | base64 du keystore release | oui |
| `ANDROID_KEYSTORE_PASSWORD` | mot de passe du keystore (alias `tvtrack`) | oui |
| `FIREBASE_SERVICE_ACCOUNT` | clé JSON d'un service account avec le rôle *Firebase App Distribution Admin* | oui |
| `TMDB_API_KEY` | clé API TMDB v3 (Découverte, recherche, posters). Injectée au build via `--dart-define`. | oui |

> **Clé TMDB** : gratuite, créée sur [themoviedb.org → Paramètres → API](https://www.themoviedb.org/settings/api).
> Requise pour Découverte, la recherche et l'enrichissement des métadonnées.
> En local : `flutter run --dart-define=TMDB_API_KEY=xxxxx`.

Le SHA-1/SHA-256 du keystore **release** doit aussi être déclaré dans Firebase,
et un groupe de testeurs **`perso`** doit exister dans App Distribution
(c'est l'alias référencé dans `codemagic.yaml`).

Chaque push sur `main` : codegen → tests → APK signé → distribution au groupe
`perso` (mail avec lien d'installation).
