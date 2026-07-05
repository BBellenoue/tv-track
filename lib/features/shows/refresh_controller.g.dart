// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Rafraîchissement incrémental des métadonnées TVmaze depuis l'app
/// (pull-to-refresh) : uniquement les séries non terminées dont les métas
/// datent de plus de 24 h, les plus récemment regardées d'abord, par lots
/// de 8 pour respecter le rate limit TVmaze (~20 req/10 s).

@ProviderFor(MetadataRefresh)
final metadataRefreshProvider = MetadataRefreshProvider._();

/// Rafraîchissement incrémental des métadonnées TVmaze depuis l'app
/// (pull-to-refresh) : uniquement les séries non terminées dont les métas
/// datent de plus de 24 h, les plus récemment regardées d'abord, par lots
/// de 8 pour respecter le rate limit TVmaze (~20 req/10 s).
final class MetadataRefreshProvider
    extends $NotifierProvider<MetadataRefresh, bool> {
  /// Rafraîchissement incrémental des métadonnées TVmaze depuis l'app
  /// (pull-to-refresh) : uniquement les séries non terminées dont les métas
  /// datent de plus de 24 h, les plus récemment regardées d'abord, par lots
  /// de 8 pour respecter le rate limit TVmaze (~20 req/10 s).
  MetadataRefreshProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metadataRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metadataRefreshHash();

  @$internal
  @override
  MetadataRefresh create() => MetadataRefresh();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$metadataRefreshHash() => r'8f1ac1f300151920027569350b1a0db52bdeb757';

/// Rafraîchissement incrémental des métadonnées TVmaze depuis l'app
/// (pull-to-refresh) : uniquement les séries non terminées dont les métas
/// datent de plus de 24 h, les plus récemment regardées d'abord, par lots
/// de 8 pour respecter le rate limit TVmaze (~20 req/10 s).

abstract class _$MetadataRefresh extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
