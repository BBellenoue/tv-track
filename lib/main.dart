import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/locale.dart';
import 'core/providers.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Needed by DateFormat for the weekday and month names on the Upcoming tab.
  await initializeDateFormatting();
  final prefs = await SharedPreferences.getInstance();
  // Cache directory rather than documents: the OS may reclaim it, and nothing
  // in there is worth keeping.
  final cacheDir = await getTemporaryDirectory();
  final metadataCache = FileCacheStore('${cacheDir.path}/metadata_cache');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        metadataCacheStoreProvider.overrideWithValue(metadataCache),
      ],
      child: const TvTrackApp(),
    ),
  );
}

class TvTrackApp extends ConsumerWidget {
  const TvTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'TV Track',
      theme: buildTheme(),
      locale: ref.watch(localeControllerProvider).locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}
