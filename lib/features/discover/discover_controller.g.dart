// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// File de cartes du deck Découverte pour un type (séries OU films) : populaires
/// / tendances / à venir (TMDB, FR), sans celles déjà suivies ou déjà swipées.
///
/// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
/// un curseur local dans l'UI (évite tout clignotement au départ d'une carte).

@ProviderFor(DiscoverDeck)
final discoverDeckProvider = DiscoverDeckFamily._();

/// File de cartes du deck Découverte pour un type (séries OU films) : populaires
/// / tendances / à venir (TMDB, FR), sans celles déjà suivies ou déjà swipées.
///
/// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
/// un curseur local dans l'UI (évite tout clignotement au départ d'une carte).
final class DiscoverDeckProvider
    extends $AsyncNotifierProvider<DiscoverDeck, List<CatalogItem>> {
  /// File de cartes du deck Découverte pour un type (séries OU films) : populaires
  /// / tendances / à venir (TMDB, FR), sans celles déjà suivies ou déjà swipées.
  ///
  /// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
  /// un curseur local dans l'UI (évite tout clignotement au départ d'une carte).
  DiscoverDeckProvider._({
    required DiscoverDeckFamily super.from,
    required MediaKind super.argument,
  }) : super(
         retry: null,
         name: r'discoverDeckProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$discoverDeckHash();

  @override
  String toString() {
    return r'discoverDeckProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DiscoverDeck create() => DiscoverDeck();

  @override
  bool operator ==(Object other) {
    return other is DiscoverDeckProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$discoverDeckHash() => r'f20d61089c4c436d512a60d435087ddb5b35768c';

/// File de cartes du deck Découverte pour un type (séries OU films) : populaires
/// / tendances / à venir (TMDB, FR), sans celles déjà suivies ou déjà swipées.
///
/// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
/// un curseur local dans l'UI (évite tout clignotement au départ d'une carte).

final class DiscoverDeckFamily extends $Family
    with
        $ClassFamilyOverride<
          DiscoverDeck,
          AsyncValue<List<CatalogItem>>,
          List<CatalogItem>,
          FutureOr<List<CatalogItem>>,
          MediaKind
        > {
  DiscoverDeckFamily._()
    : super(
        retry: null,
        name: r'discoverDeckProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// File de cartes du deck Découverte pour un type (séries OU films) : populaires
  /// / tendances / à venir (TMDB, FR), sans celles déjà suivies ou déjà swipées.
  ///
  /// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
  /// un curseur local dans l'UI (évite tout clignotement au départ d'une carte).

  DiscoverDeckProvider call(MediaKind kind) =>
      DiscoverDeckProvider._(argument: kind, from: this);

  @override
  String toString() => r'discoverDeckProvider';
}

/// File de cartes du deck Découverte pour un type (séries OU films) : populaires
/// / tendances / à venir (TMDB, FR), sans celles déjà suivies ou déjà swipées.
///
/// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
/// un curseur local dans l'UI (évite tout clignotement au départ d'une carte).

abstract class _$DiscoverDeck extends $AsyncNotifier<List<CatalogItem>> {
  late final _$args = ref.$arg as MediaKind;
  MediaKind get kind => _$args;

  FutureOr<List<CatalogItem>> build(MediaKind kind);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<CatalogItem>>, List<CatalogItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<CatalogItem>>, List<CatalogItem>>,
              AsyncValue<List<CatalogItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
