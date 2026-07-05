// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

@ProviderFor(tvmazeApi)
final tvmazeApiProvider = TvmazeApiProvider._();

final class TvmazeApiProvider
    extends $FunctionalProvider<TvmazeApi, TvmazeApi, TvmazeApi>
    with $Provider<TvmazeApi> {
  TvmazeApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tvmazeApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tvmazeApiHash();

  @$internal
  @override
  $ProviderElement<TvmazeApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TvmazeApi create(Ref ref) {
    return tvmazeApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TvmazeApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TvmazeApi>(value),
    );
  }
}

String _$tvmazeApiHash() => r'0d803ce39312d4d471352ee9c2e500c169049749';

/// Client TMDB si une clé est configurée (sinon null → Découverte désactivée).

@ProviderFor(tmdbApi)
final tmdbApiProvider = TmdbApiProvider._();

/// Client TMDB si une clé est configurée (sinon null → Découverte désactivée).

final class TmdbApiProvider
    extends $FunctionalProvider<TmdbApi?, TmdbApi?, TmdbApi?>
    with $Provider<TmdbApi?> {
  /// Client TMDB si une clé est configurée (sinon null → Découverte désactivée).
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

String _$tmdbApiHash() => r'e3b74015eaa88123c58f676ec0b36f6ae8259379';

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

/// IDs TMDB des séries suivies (pour dédoublonner / griser dans Découverte).

@ProviderFor(trackedShowTmdbIds)
final trackedShowTmdbIdsProvider = TrackedShowTmdbIdsProvider._();

/// IDs TMDB des séries suivies (pour dédoublonner / griser dans Découverte).

final class TrackedShowTmdbIdsProvider
    extends $FunctionalProvider<Set<int>, Set<int>, Set<int>>
    with $Provider<Set<int>> {
  /// IDs TMDB des séries suivies (pour dédoublonner / griser dans Découverte).
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

/// IDs TMDB des films de la liste (suivis ou vus).

@ProviderFor(trackedMovieTmdbIds)
final trackedMovieTmdbIdsProvider = TrackedMovieTmdbIdsProvider._();

/// IDs TMDB des films de la liste (suivis ou vus).

final class TrackedMovieTmdbIdsProvider
    extends $FunctionalProvider<Set<int>, Set<int>, Set<int>>
    with $Provider<Set<int>> {
  /// IDs TMDB des films de la liste (suivis ou vus).
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
