// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_add.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Adds a catalog entry to the user's library. Shared by the swipe deck, the
/// browse rails, the category grid and search.

@ProviderFor(LibraryAdd)
final libraryAddProvider = LibraryAddProvider._();

/// Adds a catalog entry to the user's library. Shared by the swipe deck, the
/// browse rails, the category grid and search.
final class LibraryAddProvider extends $NotifierProvider<LibraryAdd, void> {
  /// Adds a catalog entry to the user's library. Shared by the swipe deck, the
  /// browse rails, the category grid and search.
  LibraryAddProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'libraryAddProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$libraryAddHash();

  @$internal
  @override
  LibraryAdd create() => LibraryAdd();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$libraryAddHash() => r'fe47b727ee0df6a34258afbb4f9528f0497911ad';

/// Adds a catalog entry to the user's library. Shared by the swipe deck, the
/// browse rails, the category grid and search.

abstract class _$LibraryAdd extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
