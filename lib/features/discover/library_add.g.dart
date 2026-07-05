// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_add.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ajout d'un élément de catalogue (série ou film) à la liste de l'utilisateur.
/// Réutilisé par le deck, les rails, la grille et la recherche.

@ProviderFor(LibraryAdd)
final libraryAddProvider = LibraryAddProvider._();

/// Ajout d'un élément de catalogue (série ou film) à la liste de l'utilisateur.
/// Réutilisé par le deck, les rails, la grille et la recherche.
final class LibraryAddProvider extends $NotifierProvider<LibraryAdd, void> {
  /// Ajout d'un élément de catalogue (série ou film) à la liste de l'utilisateur.
  /// Réutilisé par le deck, les rails, la grille et la recherche.
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

String _$libraryAddHash() => r'db9bdf7a76dd51ad37814cc6362e3a72330a7fe9';

/// Ajout d'un élément de catalogue (série ou film) à la liste de l'utilisateur.
/// Réutilisé par le deck, les rails, la grille et la recherche.

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
