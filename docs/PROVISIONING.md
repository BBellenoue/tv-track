# Journal de provisioning — tv-track-perso

Journal exhaustif de la mise en place de l'infra (2026-07-03), pour
reproductibilité. Projet Firebase : `tv-track-perso` (n° `304761545305`),
app Android `com.bruno.tv_track` (`1:304761545305:android:76c0a85e1885a5ca870748`).

> Aucune valeur listée ici n'est un secret : les app IDs, project IDs et
> client IDs OAuth sont des identifiants publics (présents dans l'APK).
> Les secrets (keystore, mots de passe, service account, token API Codemagic)
> vivent dans `~/keystores/` et les variables sécurisées Codemagic.

## 1. Créations manuelles (console)

- Projet Firebase `tv-track-perso` créé dans la [console](https://console.firebase.google.com).
- **Authentication → Sign-in method → Google : activé** (seule étape
  impossible par API : la console provisionne elle-même le client OAuth web).

## 2. Authentifications locales (interactives)

```sh
firebase login --reauth
gcloud auth login
```

## 3. Enregistrement des apps + fichiers de config

```sh
dart pub global activate flutterfire_cli

# Enregistre les apps Android & iOS dans le projet et génère
# lib/firebase_options.dart + android/app/google-services.json
# (+ branche le plugin gradle com.google.gms.google-services).
flutterfire configure --project=tv-track-perso \
  --platforms=android,ios \
  --android-package-name=com.bruno.tv_track \
  --ios-bundle-id=com.bruno.tvTrack --yes
# ⚠️ échec partiel iOS : gem Ruby `xcodeproj` absente → relancé Android seul :
flutterfire configure --project=tv-track-perso --platforms=android \
  --android-package-name=com.bruno.tv_track --yes
```

## 4. Firestore

```sh
gcloud services enable firestore.googleapis.com --project=tv-track-perso
gcloud firestore databases create --location=europe-west1 --project=tv-track-perso
firebase deploy --only firestore:rules --project=tv-track-perso   # firestore.rules
```

## 5. Empreintes de signature (Google Sign-In)

Enregistrées via l'API Firebase Management (la CLI ne le permet pas).
`$APP` = `1:304761545305:android:76c0a85e1885a5ca870748`.

```sh
# Extraction (keytool -list -v bug en locale FR → passage par openssl) :
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android \
  | openssl x509 -inform DER -fingerprint -sha1 -noout

curl -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "x-goog-user-project: tv-track-perso" -H "Content-Type: application/json" \
  -d '{"shaHash": "<SHA>", "certType": "SHA_1"}' \
  "https://firebase.googleapis.com/v1beta1/projects/tv-track-perso/androidApps/$APP/sha"
```

Enregistrés : SHA-1 + SHA-256 du keystore **debug** de la machine de dev,
SHA-1 + SHA-256 du keystore **release** (voir §6).

Après activation du provider Google + ajout des SHA, régénération de
`google-services.json` pour y inclure les clients OAuth :

```sh
firebase apps:sdkconfig ANDROID $APP --project=tv-track-perso \
  | sed -n '/{/,$p' > android/app/google-services.json
```

## 6. Keystore release

```sh
keytool -genkeypair -v -keystore ~/keystores/tv_track.keystore -alias tvtrack \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass "<généré : openssl rand -base64 18>" -keypass "<idem>" \
  -dname "CN=Bruno Bellenoue, O=TV Track, C=FR"
```

Stocké **hors repo** : `~/keystores/tv_track.keystore` + mot de passe dans
`~/keystores/tv_track.keystore.password` (chmod 600). Sauvegarde ces deux
fichiers (gestionnaire de mots de passe) : keystore perdu = impossible de
mettre à jour l'app installée.

## 7. Codemagic (via API REST)

App Codemagic `tv-track` créée manuellement (connexion du repo GitHub).
Variables créées par API (`POST https://api.codemagic.io/apps/<appId>/variables`,
header `x-auth-token`), groupe `firebase` :

| Variable | Contenu | Secure |
|---|---|---|
| `FIREBASE_ANDROID_APP_ID` | app ID Android | non |
| `GOOGLE_SERVICES_JSON` | `base64 -i android/app/google-services.json` | oui |
| `FIREBASE_OPTIONS_DART` | `base64 -i lib/firebase_options.dart` | oui |
| `ANDROID_KEYSTORE` | `base64 -i ~/keystores/tv_track.keystore` | oui |
| `ANDROID_KEYSTORE_PASSWORD` | mot de passe du keystore | oui |
| `FIREBASE_SERVICE_ACCOUNT` | clé JSON du service account (§8) | oui |

## 8. Service account App Distribution (fait à la main — élévation IAM)

```sh
gcloud iam service-accounts create codemagic-distribution \
  --display-name="Codemagic App Distribution" --project=tv-track-perso

gcloud projects add-iam-policy-binding tv-track-perso \
  --member="serviceAccount:codemagic-distribution@tv-track-perso.iam.gserviceaccount.com" \
  --role="roles/firebaseappdistro.admin" --condition=None

gcloud iam service-accounts keys create ~/keystores/codemagic-service-account.json \
  --iam-account=codemagic-distribution@tv-track-perso.iam.gserviceaccount.com
```

Puis la clé est chargée dans la variable Codemagic `FIREBASE_SERVICE_ACCOUNT`
(groupe `firebase`, secure) et le fichier local peut être supprimé.

## 9. App Distribution : groupe de testeurs

Console Firebase → [App Distribution](https://console.firebase.google.com/project/tv-track-perso/appdistribution)
→ « Commencer » → onglet *Testeurs et groupes* → créer le groupe **`perso`**
(alias exact référencé par `codemagic.yaml`) et y ajouter son adresse.

## Récapitulatif des surfaces sensibles

| Élément | Où | Commité ? |
|---|---|---|
| `firebase_options.dart`, `google-services.json` | local + var Codemagic | ❌ (gitignorés) |
| Keystore release + mot de passe | `~/keystores/` + vars Codemagic | ❌ |
| Service account JSON | vars Codemagic uniquement | ❌ |
| Token API Codemagic | nulle part (usage ponctuel) | ❌ |
| Export TV Time (données perso) | local uniquement | ❌ |
| `firestore.rules`, `codemagic.yaml`, code | repo public | ✅ |
