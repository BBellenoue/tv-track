# TV Track

App Flutter de suivi de séries et films — remplaçant perso de TV Time (RIP).

- **Données** : Firestore (`users/{uid}/shows/{tvdbId}`, `users/{uid}/movies/{tvdbId}`), auth Google, chaque utilisateur ne voit que ses données ([firestore.rules](firestore.rules)).
- **Import** : seed one-shot de l'export TV Time via `tool/seed_tvtime.dart` (pas de fonctionnalité d'import dans l'app).
- **CI** : Codemagic (`codemagic.yaml`) → APK signé → Firebase App Distribution à chaque merge sur `main`.

Le repo est public : **aucune config Firebase, keystore ni donnée perso n'est
commité** — tout est gitignoré et injecté en CI par variables sécurisées.
Setup avec ton propre projet Firebase : [docs/SETUP.md](docs/SETUP.md) ·
journal du provisioning d'origine : [docs/PROVISIONING.md](docs/PROVISIONING.md).

## Stack

`hooks_riverpod` + `riverpod_generator` (state), `freezed` + `json_serializable`
(modèles), `go_router` (navigation), `firebase_auth` + `google_sign_in` + `cloud_firestore`.

## Dev

```sh
flutter pub get
dart run build_runner watch   # codegen freezed/riverpod/json en continu
flutter test                  # tests sur fixtures (test/fixtures/)
flutter run                   # nécessite la config Firebase, voir docs/SETUP.md
```

## Structure

```
lib/
├── core/        # providers riverpod, router, config
├── data/
│   ├── models/  # Show/Season/Episode, Movie (freezed)
│   ├── tvtime/  # parsing de l'export TV Time
│   └── repositories/  # Firestore
└── features/
    ├── auth/    # Google Sign-In
    ├── home/    # NavigationBar Séries/Films
    ├── shows/   # liste filtrée + détail saisons/épisodes
    ├── movies/  # à voir / vus
    └── import/  # import de l'export
```

## Roadmap (v2)

- Métadonnées TMDB : posters, épisodes des séries en cours de diffusion, recherche/ajout
- Onglet "À venir" (prochaines diffusions)
- Stats

## Licence

[MIT](LICENSE)
