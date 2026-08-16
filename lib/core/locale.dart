import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'providers.dart';

part 'locale.g.dart';

/// A language the app can run in.
///
/// The choice drives both the interface strings and the language metadata is
/// fetched in, so switching it changes show and episode text on the next
/// refresh.
enum AppLocale {
  english(Locale('en'), 'English', tmdb: 'en-US', tvdb: 'eng'),
  french(Locale('fr'), 'Français', tmdb: 'fr-FR', tvdb: 'fra');

  const AppLocale(
    this.locale,
    this.label, {
    required this.tmdb,
    required this.tvdb,
  });

  final Locale locale;

  /// Endonym, so the option stays recognisable whatever the current language.
  final String label;

  /// TMDB `language` query parameter.
  final String tmdb;

  /// TheTVDB translation path segment (ISO 639-2/T).
  final String tvdb;

  static AppLocale? byCode(String? code) =>
      values.where((l) => l.locale.languageCode == code).firstOrNull;
}

const _prefsKey = 'app_locale';

/// Selected language, persisted across launches.
///
/// Falls back to the device language when nothing was chosen yet, then to
/// English for unsupported locales.
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  AppLocale build() {
    final stored = ref.watch(sharedPreferencesProvider).getString(_prefsKey);
    return AppLocale.byCode(stored) ??
        AppLocale.byCode(PlatformDispatcher.instance.locale.languageCode) ??
        AppLocale.english;
  }

  Future<void> select(AppLocale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_prefsKey, locale.locale.languageCode);
  }
}
