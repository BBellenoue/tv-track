// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// File de cartes du deck Découverte : séries populaires / tendances / en
/// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.

@ProviderFor(DiscoverDeck)
final discoverDeckProvider = DiscoverDeckProvider._();

/// File de cartes du deck Découverte : séries populaires / tendances / en
/// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.
final class DiscoverDeckProvider
    extends $AsyncNotifierProvider<DiscoverDeck, List<TmdbTv>> {
  /// File de cartes du deck Découverte : séries populaires / tendances / en
  /// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.
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

String _$discoverDeckHash() => r'0abf05e1b7812703303b3bdfcc07f7c663a0c8b5';

/// File de cartes du deck Découverte : séries populaires / tendances / en
/// diffusion (TMDB, FR), débarrassées de celles déjà suivies ou déjà swipées.

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
