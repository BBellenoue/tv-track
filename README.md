# TV Track

App Flutter de suivi de séries et films — remplaçant perso de TV Time (RIP).

- **Données** : Firestore (`users/{uid}/shows/{tvdbId}`, `users/{uid}/movies/{tvdbId}`), auth Google, chaque utilisateur ne voit que ses données ([firestore.rules](firestore.rules)).
- **Métadonnées** : TVmaze (structure, dates/heures de diffusion, vignettes d'épisodes) + TMDB (résumés et titres **en français**, posters, plateformes de streaming FR, catalogue de découverte). Gratuit.
- **Import initial** : seed one-shot de l'export TV Time via `tool/seed_tvtime.dart` ; enrichissement via `tool/enrich_metadata.dart`.
- **CI** : Codemagic (`codemagic.yaml`) → APK signé → Firebase App Distribution à chaque merge sur `main`.

Le repo est public : **aucune config Firebase, keystore, clé TMDB ni donnée perso
n'est commité** — tout est gitignoré et injecté en CI par variables sécurisées.
Setup avec ton propre projet Firebase : [docs/SETUP.md](docs/SETUP.md) ·
journal du provisioning d'origine : [docs/PROVISIONING.md](docs/PROVISIONING.md).

## Fonctionnalités

- **À venir** — agenda des prochaines diffusions de tes séries (hero + par jour)
- **Séries / Films** — listes filtrées, progression, fiches détaillées (synopsis,
  saisons, tuiles d'épisodes avec vignettes, plateformes où regarder), rattrapage
  « tout marquer avant », swipe pour retirer
- **Découverte** — deux modes, séries **ou** films :
  - *Swipe* : deck à la Tinder (like → watchlist)
  - *Parcourir* : rails par genre + grille catégorie triable (façon Netflix)
- **Recherche globale** (loupe AppBar) : bibliothèque locale + catalogue TMDB
- **Profil** : compte Google, déconnexion, stats de visionnage

## Stack

`hooks_riverpod` + `riverpod_generator` (state), `freezed` + `json_serializable`
(modèles), `go_router` (navigation), `dio` (TMDB/TVmaze),
`firebase_auth` + `google_sign_in` + `cloud_firestore`,
`cached_network_image`, `google_fonts`, `flutter_launcher_icons`.

## Dev

```sh
flutter pub get
dart run build_runner watch   # codegen freezed/riverpod/json en continu
flutter test                  # tests sur fixtures (test/fixtures/)
# La clé TMDB (Découverte/recherche/enrichissement) est injectée au build :
flutter run --dart-define=TMDB_API_KEY=xxxxx   # config Firebase requise, voir docs/SETUP.md
```

Aperçu visuel sur émulateur sans Firebase (données d'exemple) :
`flutter run -t lib/preview_main.dart --dart-define=TMDB_API_KEY=xxx`
(modes : `--dart-define=PREVIEW=detail|movie|search`).

## Structure

```
lib/
├── core/            # providers riverpod, router, thème, config, widgets partagés
├── data/
│   ├── models/      # Show/Season/Episode, Movie (freezed)
│   ├── tvtime/      # parsing de l'export TV Time
│   ├── tvmaze/      # client TVmaze + fusion des métadonnées
│   ├── tmdb/        # client TMDB + modèle CatalogItem unifié
│   └── repositories/# Firestore
└── features/
    ├── auth/        # Google Sign-In
    ├── home/        # NavigationBar (À venir / Séries / Films / Découverte)
    ├── upcoming/    # agenda des diffusions
    ├── shows/       # liste + détail série + refresh métadonnées
    ├── movies/      # liste + détail film
    ├── discover/    # deck swipe, Parcourir (rails/grille), aperçu+ajout
    ├── search/      # recherche globale
    └── profile/     # compte + stats
tool/                # seed_tvtime.dart, enrich_metadata.dart (hors app)
```

## Licence

[MIT](LICENSE)
