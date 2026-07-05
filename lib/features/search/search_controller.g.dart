// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Recherche TMDB (séries + films, FR) pour une requête. Retourne les séries
/// puis les films, triés par popularité au sein de chaque type.

@ProviderFor(tmdbSearch)
final tmdbSearchProvider = TmdbSearchFamily._();

/// Recherche TMDB (séries + films, FR) pour une requête. Retourne les séries
/// puis les films, triés par popularité au sein de chaque type.

final class TmdbSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CatalogItem>>,
          List<CatalogItem>,
          FutureOr<List<CatalogItem>>
        >
    with
        $FutureModifier<List<CatalogItem>>,
        $FutureProvider<List<CatalogItem>> {
  /// Recherche TMDB (séries + films, FR) pour une requête. Retourne les séries
  /// puis les films, triés par popularité au sein de chaque type.
  TmdbSearchProvider._({
    required TmdbSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tmdbSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tmdbSearchHash();

  @override
  String toString() {
    return r'tmdbSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CatalogItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CatalogItem>> create(Ref ref) {
    final argument = this.argument as String;
    return tmdbSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TmdbSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tmdbSearchHash() => r'277bc9a8b58ddca454f2b7456dcc608c91a11f94';

/// Recherche TMDB (séries + films, FR) pour une requête. Retourne les séries
/// puis les films, triés par popularité au sein de chaque type.

final class TmdbSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CatalogItem>>, String> {
  TmdbSearchFamily._()
    : super(
        retry: null,
        name: r'tmdbSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Recherche TMDB (séries + films, FR) pour une requête. Retourne les séries
  /// puis les films, triés par popularité au sein de chaque type.

  TmdbSearchProvider call(String query) =>
      TmdbSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'tmdbSearchProvider';
}
