// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden at startup with the instance loaded in `main`, so preferences can
/// be read synchronously from providers.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Overridden at startup with the instance loaded in `main`, so preferences can
/// be read synchronously from providers.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Overridden at startup with the instance loaded in `main`, so preferences can
  /// be read synchronously from providers.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'70ef90bd70df9f89260fca9b542d9f8d25d8e3cb';

/// Overridden at startup with the store opened in `main`, for the same reason
/// as the preferences above.

@ProviderFor(metadataCacheStore)
final metadataCacheStoreProvider = MetadataCacheStoreProvider._();

/// Overridden at startup with the store opened in `main`, for the same reason
/// as the preferences above.

final class MetadataCacheStoreProvider
    extends $FunctionalProvider<CacheStore, CacheStore, CacheStore>
    with $Provider<CacheStore> {
  /// Overridden at startup with the store opened in `main`, for the same reason
  /// as the preferences above.
  MetadataCacheStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metadataCacheStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metadataCacheStoreHash();

  @$internal
  @override
  $ProviderElement<CacheStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CacheStore create(Ref ref) {
    return metadataCacheStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CacheStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CacheStore>(value),
    );
  }
}

String _$metadataCacheStoreHash() =>
    r'4b6d88c6fa77863d85c54d15227c6282187e2ea9';

@ProviderFor(firebaseAuth)
final firebaseAuthProvider = FirebaseAuthProvider._();

final class FirebaseAuthProvider
    extends $FunctionalProvider<FirebaseAuth, FirebaseAuth, FirebaseAuth>
    with $Provider<FirebaseAuth> {
  FirebaseAuthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseAuthProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseAuthHash();

  @$internal
  @override
  $ProviderElement<FirebaseAuth> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FirebaseAuth create(Ref ref) {
    return firebaseAuth(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseAuth value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseAuth>(value),
    );
  }
}

String _$firebaseAuthHash() => r'8c3e9d11b27110ca96130356b5ef4d5d34a5ffc2';

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

final class AuthStateProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'4f403845df0a7b94f769c9a7d5f9b2e890f4960f';

@ProviderFor(trackingRepository)
final trackingRepositoryProvider = TrackingRepositoryProvider._();

final class TrackingRepositoryProvider
    extends
        $FunctionalProvider<
          TrackingRepository?,
          TrackingRepository?,
          TrackingRepository?
        >
    with $Provider<TrackingRepository?> {
  TrackingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingRepositoryHash();

  @$internal
  @override
  $ProviderElement<TrackingRepository?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TrackingRepository? create(Ref ref) {
    return trackingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingRepository? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingRepository?>(value),
    );
  }
}

String _$trackingRepositoryHash() =>
    r'6832c68ff352eb8ea6c05fb287c136807bf816f2';

@ProviderFor(shows)
final showsProvider = ShowsProvider._();

final class ShowsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Show>>,
          List<Show>,
          Stream<List<Show>>
        >
    with $FutureModifier<List<Show>>, $StreamProvider<List<Show>> {
  ShowsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showsHash();

  @$internal
  @override
  $StreamProviderElement<List<Show>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Show>> create(Ref ref) {
    return shows(ref);
  }
}

String _$showsHash() => r'143903d1ad6f94c0aaaa410cad7dccca802e857d';

@ProviderFor(movies)
final moviesProvider = MoviesProvider._();

final class MoviesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Movie>>,
          List<Movie>,
          Stream<List<Movie>>
        >
    with $FutureModifier<List<Movie>>, $StreamProvider<List<Movie>> {
  MoviesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moviesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moviesHash();

  @$internal
  @override
  $StreamProviderElement<List<Movie>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Movie>> create(Ref ref) {
    return movies(ref);
  }
}

String _$moviesHash() => r'e6ead94bc7fb43e0f148b5d2a13b41237512ba5e';

/// Null when no proxy is configured, which disables show enrichment.
/// keepAlive so the auth token survives for the whole session.

@ProviderFor(tvdbApi)
final tvdbApiProvider = TvdbApiProvider._();

/// Null when no proxy is configured, which disables show enrichment.
/// keepAlive so the auth token survives for the whole session.

final class TvdbApiProvider
    extends $FunctionalProvider<TvdbApi?, TvdbApi?, TvdbApi?>
    with $Provider<TvdbApi?> {
  /// Null when no proxy is configured, which disables show enrichment.
  /// keepAlive so the auth token survives for the whole session.
  TvdbApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tvdbApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tvdbApiHash();

  @$internal
  @override
  $ProviderElement<TvdbApi?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TvdbApi? create(Ref ref) {
    return tvdbApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TvdbApi? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TvdbApi?>(value),
    );
  }
}

String _$tvdbApiHash() => r'2e5fe086de61557bfe6d25175e0f81ffcd24dd2e';

/// Null when no proxy is configured, which disables Discover and search.

@ProviderFor(tmdbApi)
final tmdbApiProvider = TmdbApiProvider._();

/// Null when no proxy is configured, which disables Discover and search.

final class TmdbApiProvider
    extends $FunctionalProvider<TmdbApi?, TmdbApi?, TmdbApi?>
    with $Provider<TmdbApi?> {
  /// Null when no proxy is configured, which disables Discover and search.
  TmdbApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tmdbApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tmdbApiHash();

  @$internal
  @override
  $ProviderElement<TmdbApi?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TmdbApi? create(Ref ref) {
    return tmdbApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TmdbApi? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TmdbApi?>(value),
    );
  }
}

String _$tmdbApiHash() => r'fa492c513ce7ade4e20f91f74e5e4b0358223a50';

/// Genres and credits for one title. Fetched when a detail screen opens
/// rather than stored, so no record has to be migrated to gain them.

@ProviderFor(titleExtras)
final titleExtrasProvider = TitleExtrasFamily._();

/// Genres and credits for one title. Fetched when a detail screen opens
/// rather than stored, so no record has to be migrated to gain them.

final class TitleExtrasProvider
    extends
        $FunctionalProvider<
          AsyncValue<TmdbExtras?>,
          TmdbExtras?,
          FutureOr<TmdbExtras?>
        >
    with $FutureModifier<TmdbExtras?>, $FutureProvider<TmdbExtras?> {
  /// Genres and credits for one title. Fetched when a detail screen opens
  /// rather than stored, so no record has to be migrated to gain them.
  TitleExtrasProvider._({
    required TitleExtrasFamily super.from,
    required (MediaKind, int) super.argument,
  }) : super(
         retry: null,
         name: r'titleExtrasProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$titleExtrasHash();

  @override
  String toString() {
    return r'titleExtrasProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<TmdbExtras?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TmdbExtras?> create(Ref ref) {
    final argument = this.argument as (MediaKind, int);
    return titleExtras(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TitleExtrasProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$titleExtrasHash() => r'49dd4d52692f791b968bc76255b11540ccf0b454';

/// Genres and credits for one title. Fetched when a detail screen opens
/// rather than stored, so no record has to be migrated to gain them.

final class TitleExtrasFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<TmdbExtras?>, (MediaKind, int)> {
  TitleExtrasFamily._()
    : super(
        retry: null,
        name: r'titleExtrasProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Genres and credits for one title. Fetched when a detail screen opens
  /// rather than stored, so no record has to be migrated to gain them.

  TitleExtrasProvider call(MediaKind kind, int tmdbId) =>
      TitleExtrasProvider._(argument: (kind, tmdbId), from: this);

  @override
  String toString() => r'titleExtrasProvider';
}

@ProviderFor(discoverSeenKeys)
final discoverSeenKeysProvider = DiscoverSeenKeysProvider._();

final class DiscoverSeenKeysProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String>>,
          Set<String>,
          Stream<Set<String>>
        >
    with $FutureModifier<Set<String>>, $StreamProvider<Set<String>> {
  DiscoverSeenKeysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverSeenKeysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverSeenKeysHash();

  @$internal
  @override
  $StreamProviderElement<Set<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Set<String>> create(Ref ref) {
    return discoverSeenKeys(ref);
  }
}

String _$discoverSeenKeysHash() => r'b79470ef6f7bf8236c4925f3168e5811a1950e4a';

/// TMDB ids of tracked shows, used to grey out entries already in the library.

@ProviderFor(trackedShowTmdbIds)
final trackedShowTmdbIdsProvider = TrackedShowTmdbIdsProvider._();

/// TMDB ids of tracked shows, used to grey out entries already in the library.

final class TrackedShowTmdbIdsProvider
    extends $FunctionalProvider<Set<int>, Set<int>, Set<int>>
    with $Provider<Set<int>> {
  /// TMDB ids of tracked shows, used to grey out entries already in the library.
  TrackedShowTmdbIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackedShowTmdbIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackedShowTmdbIdsHash();

  @$internal
  @override
  $ProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<int> create(Ref ref) {
    return trackedShowTmdbIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$trackedShowTmdbIdsHash() =>
    r'69a12f276928e2c31f3730eed12192353cc69621';

@ProviderFor(trackedMovieTmdbIds)
final trackedMovieTmdbIdsProvider = TrackedMovieTmdbIdsProvider._();

final class TrackedMovieTmdbIdsProvider
    extends $FunctionalProvider<Set<int>, Set<int>, Set<int>>
    with $Provider<Set<int>> {
  TrackedMovieTmdbIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackedMovieTmdbIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackedMovieTmdbIdsHash();

  @$internal
  @override
  $ProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<int> create(Ref ref) {
    return trackedMovieTmdbIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$trackedMovieTmdbIdsHash() =>
    r'77cd99727062c31c674efbbd3dff258d6c50402d';
