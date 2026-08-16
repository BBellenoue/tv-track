// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// TMDB search across both media kinds: shows first, then movies, each in the
/// order TMDB returns them. Entries without a poster are dropped, since the
/// result rows are poster-led.

@ProviderFor(tmdbSearch)
final tmdbSearchProvider = TmdbSearchFamily._();

/// TMDB search across both media kinds: shows first, then movies, each in the
/// order TMDB returns them. Entries without a poster are dropped, since the
/// result rows are poster-led.

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
  /// TMDB search across both media kinds: shows first, then movies, each in the
  /// order TMDB returns them. Entries without a poster are dropped, since the
  /// result rows are poster-led.
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

/// TMDB search across both media kinds: shows first, then movies, each in the
/// order TMDB returns them. Entries without a poster are dropped, since the
/// result rows are poster-led.

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

  /// TMDB search across both media kinds: shows first, then movies, each in the
  /// order TMDB returns them. Entries without a poster are dropped, since the
  /// result rows are poster-led.

  TmdbSearchProvider call(String query) =>
      TmdbSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'tmdbSearchProvider';
}
