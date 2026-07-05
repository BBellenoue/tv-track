// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// File de cartes du deck Découverte : séries populaires / tendances / en
/// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.
///
/// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
/// un curseur local dans l'UI. Ici on ne fait qu'alimenter la file (pagination)
/// et persister l'historique de swipe. Cela évite tout clignotement au moment
/// où une carte quitte l'écran.

@ProviderFor(DiscoverDeck)
final discoverDeckProvider = DiscoverDeckProvider._();

/// File de cartes du deck Découverte : séries populaires / tendances / en
/// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.
///
/// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
/// un curseur local dans l'UI. Ici on ne fait qu'alimenter la file (pagination)
/// et persister l'historique de swipe. Cela évite tout clignotement au moment
/// où une carte quitte l'écran.
final class DiscoverDeckProvider
    extends $AsyncNotifierProvider<DiscoverDeck, List<TmdbTv>> {
  /// File de cartes du deck Découverte : séries populaires / tendances / en
  /// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.
  ///
  /// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
  /// un curseur local dans l'UI. Ici on ne fait qu'alimenter la file (pagination)
  /// et persister l'historique de swipe. Cela évite tout clignotement au moment
  /// où une carte quitte l'écran.
  DiscoverDeckProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'discoverDeckProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$discoverDeckHash();

  @$internal
  @override
  DiscoverDeck create() => DiscoverDeck();
}

String _$discoverDeckHash() => r'97ecae0d0729434c9d72d7e46a2218b1cdbb8f87';

/// File de cartes du deck Découverte : séries populaires / tendances / en
/// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.
///
/// La file ne se reconstruit PAS à chaque swipe : l'avancement est piloté par
/// un curseur local dans l'UI. Ici on ne fait qu'alimenter la file (pagination)
/// et persister l'historique de swipe. Cela évite tout clignotement au moment
/// où une carte quitte l'écran.

abstract class _$DiscoverDeck extends $AsyncNotifier<List<TmdbTv>> {
  FutureOr<List<TmdbTv>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TmdbTv>>, List<TmdbTv>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TmdbTv>>, List<TmdbTv>>,
              AsyncValue<List<TmdbTv>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
