// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Incremental metadata refresh, one batch at a time.
///
/// Fires on app open for running shows whose metadata is over a day old, plus
/// any record with something missing. A pull-to-refresh passes `force`, which
/// takes the age condition out of the way.

@ProviderFor(MetadataRefresh)
final metadataRefreshProvider = MetadataRefreshProvider._();

/// Incremental metadata refresh, one batch at a time.
///
/// Fires on app open for running shows whose metadata is over a day old, plus
/// any record with something missing. A pull-to-refresh passes `force`, which
/// takes the age condition out of the way.
final class MetadataRefreshProvider
    extends $NotifierProvider<MetadataRefresh, bool> {
  /// Incremental metadata refresh, one batch at a time.
  ///
  /// Fires on app open for running shows whose metadata is over a day old, plus
  /// any record with something missing. A pull-to-refresh passes `force`, which
  /// takes the age condition out of the way.
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

String _$metadataRefreshHash() => r'200f5f528fcc633ede2eb5551f5f9a48ac21a8e8';

/// Incremental metadata refresh, one batch at a time.
///
/// Fires on app open for running shows whose metadata is over a day old, plus
/// any record with something missing. A pull-to-refresh passes `force`, which
/// takes the age condition out of the way.

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
