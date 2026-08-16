// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_repair.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repairs a single record on demand, when its detail screen opens and finds
/// something missing. Complements the batch [MetadataRefresh] by fixing the
/// one record the user is looking at right now.
///
/// Each record is attempted at most once per session even if it stays
/// incomplete (a provider may simply have nothing), which keeps a rebuild or
/// a reopen from hammering the API.
///
/// The exposed state is the set of in-flight keys (`show-<id>` / `movie-<id>`),
/// so a screen can show a progress indicator.

@ProviderFor(LiveRepair)
final liveRepairProvider = LiveRepairProvider._();

/// Repairs a single record on demand, when its detail screen opens and finds
/// something missing. Complements the batch [MetadataRefresh] by fixing the
/// one record the user is looking at right now.
///
/// Each record is attempted at most once per session even if it stays
/// incomplete (a provider may simply have nothing), which keeps a rebuild or
/// a reopen from hammering the API.
///
/// The exposed state is the set of in-flight keys (`show-<id>` / `movie-<id>`),
/// so a screen can show a progress indicator.
final class LiveRepairProvider
    extends $NotifierProvider<LiveRepair, Set<String>> {
  /// Repairs a single record on demand, when its detail screen opens and finds
  /// something missing. Complements the batch [MetadataRefresh] by fixing the
  /// one record the user is looking at right now.
  ///
  /// Each record is attempted at most once per session even if it stays
  /// incomplete (a provider may simply have nothing), which keeps a rebuild or
  /// a reopen from hammering the API.
  ///
  /// The exposed state is the set of in-flight keys (`show-<id>` / `movie-<id>`),
  /// so a screen can show a progress indicator.
  LiveRepairProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveRepairProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveRepairHash();

  @$internal
  @override
  LiveRepair create() => LiveRepair();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$liveRepairHash() => r'bdef98d274722e486f73ec751a0328fade02ccc8';

/// Repairs a single record on demand, when its detail screen opens and finds
/// something missing. Complements the batch [MetadataRefresh] by fixing the
/// one record the user is looking at right now.
///
/// Each record is attempted at most once per session even if it stays
/// incomplete (a provider may simply have nothing), which keeps a rebuild or
/// a reopen from hammering the API.
///
/// The exposed state is the set of in-flight keys (`show-<id>` / `movie-<id>`),
/// so a screen can show a progress indicator.

abstract class _$LiveRepair extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
