# Contributing

Thanks for taking the time. Bug reports, translations and pull requests are all
welcome.

## Getting set up

The repository ships no Firebase configuration, so building the app means
pointing it at a project of your own — the walkthrough is in
[docs/SETUP.md](docs/SETUP.md). To work on the UI alone you can skip Firebase
entirely and use the preview entrypoint:

```sh
flutter pub get
dart run build_runner build
flutter run -t lib/preview_main.dart --dart-define=TMDB_API_KEY=xxxxx
```

## Before opening a pull request

```sh
dart run build_runner build   # regenerate if you touched a model, provider or route
dart format lib test tool     # must leave nothing to change
flutter analyze               # must report no issues
flutter test                  # must pass
```

The same four steps run in CI on every pull request.

A fresh clone does not analyze until `lib/firebase_options.dart` exists —
`lib/main.dart` imports it and it is generated per project, so run
`flutterfire configure` as described in [docs/SETUP.md](docs/SETUP.md). CI
stands in for it with a stub.

A few things that are easy to miss:

- **Generated files are committed.** `*.g.dart` and `*.freezed.dart` live in the
  repository, so a change to a `freezed` model or a `riverpod` provider means
  running `build_runner` and committing what it produces.
- **Both locales move together.** A new string goes into `lib/l10n/app_en.arb`
  *and* `lib/l10n/app_fr.arb`; `flutter gen-l10n` runs as part of the build.
- **Never commit configuration or credentials.** `firebase_options.dart`,
  `google-services.json`, `GoogleService-Info.plist`, keystores and service
  account keys are all gitignored and must stay that way. API keys are passed
  with `--dart-define`, never hardcoded.
- **No personal data.** TV Time exports are imported at runtime through the file
  picker; they do not belong in the repository.

## Commits

One logical change per commit. Subject in the imperative, no trailing period,
no prefix or ticket number:

```
Hide titles already in the library from Browse
```

Use the body to explain *why* — the constraint, the failure it avoids, what you
verified. The code says what changed; the message is where the reasoning is
kept, so it does not need to be repeated in comments.

## Reporting a bug

Open an [issue](https://github.com/BBellenoue/tv-track/issues) with the template.
Include the platform, the commit or version you built from, and the steps that
reproduce it. If it involves a specific title, the show or movie name helps a
lot — most metadata bugs come down to one entry on the provider side.

For anything security-related, follow [SECURITY.md](SECURITY.md) instead of
opening a public issue.

## Licence

Contributions are accepted under the [MIT licence](LICENSE) that covers the
project.
