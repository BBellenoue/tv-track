// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browse_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Liste des genres d'un type, en français (mise en cache).

@ProviderFor(catalogGenres)
final catalogGenresProvider = CatalogGenresFamily._();

/// Liste des genres d'un type, en français (mise en cache).

final class CatalogGenresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Genre>>,
          List<Genre>,
          FutureOr<List<Genre>>
        >
    with $FutureModifier<List<Genre>>, $FutureProvider<List<Genre>> {
  /// Liste des genres d'un type, en français (mise en cache).
  CatalogGenresProvider._({
    required CatalogGenresFamily super.from,
    required MediaKind super.argument,
  }) : super(
         retry: null,
         name: r'catalogGenresProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$catalogGenresHash();

  @override
  String toString() {
    return r'catalogGenresProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Genre>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Genre>> create(Ref ref) {
    final argument = this.argument as MediaKind;
    return catalogGenres(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogGenresProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$catalogGenresHash() => r'a94dd5b44e359b741ffddd9f2d9bd250c45fd722';

/// Liste des genres d'un type, en français (mise en cache).

final class CatalogGenresFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Genre>>, MediaKind> {
  CatalogGenresFamily._()
    : super(
        retry: null,
        name: r'catalogGenresProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Liste des genres d'un type, en français (mise en cache).

  CatalogGenresProvider call(MediaKind kind) =>
      CatalogGenresProvider._(argument: kind, from: this);

  @override
  String toString() => r'catalogGenresProvider';
}

/// Une "ligne" du mode Parcourir (rail) : première page seulement.
/// genreId null = tendances de la semaine.

@ProviderFor(catalogRow)
final catalogRowProvider = CatalogRowFamily._();

/// Une "ligne" du mode Parcourir (rail) : première page seulement.
/// genreId null = tendances de la semaine.

final class CatalogRowProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CatalogItem>>,
          List<CatalogItem>,
          FutureOr<List<CatalogItem>>
        >
    with
        $FutureModifier<List<CatalogItem>>,
        $FutureProvider<List<CatalogItem>> {
  /// Une "ligne" du mode Parcourir (rail) : première page seulement.
  /// genreId null = tendances de la semaine.
  CatalogRowProvider._({
    required CatalogRowFamily super.from,
    required ({MediaKind kind, int? genreId}) super.argument,
  }) : super(
         retry: null,
         name: r'catalogRowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$catalogRowHash();

  @override
  String toString() {
    return r'catalogRowProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<CatalogItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CatalogItem>> create(Ref ref) {
    final argument = this.argument as ({MediaKind kind, int? genreId});
    return catalogRow(ref, kind: argument.kind, genreId: argument.genreId);
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogRowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$catalogRowHash() => r'1910241640569d630fe965725735a626bc252dcd';

/// Une "ligne" du mode Parcourir (rail) : première page seulement.
/// genreId null = tendances de la semaine.

final class CatalogRowFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CatalogItem>>,
          ({MediaKind kind, int? genreId})
        > {
  CatalogRowFamily._()
    : super(
        retry: null,
        name: r'catalogRowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Une "ligne" du mode Parcourir (rail) : première page seulement.
  /// genreId null = tendances de la semaine.

  CatalogRowProvider call({required MediaKind kind, int? genreId}) =>
      CatalogRowProvider._(
        argument: (kind: kind, genreId: genreId),
        from: this,
      );

  @override
  String toString() => r'catalogRowProvider';
}

/// Grille catégorie paginée (défilement infini), triable.

@ProviderFor(CategoryGrid)
final categoryGridProvider = CategoryGridFamily._();

/// Grille catégorie paginée (défilement infini), triable.
final class CategoryGridProvider
    extends $AsyncNotifierProvider<CategoryGrid, List<CatalogItem>> {
  /// Grille catégorie paginée (défilement infini), triable.
  CategoryGridProvider._({
    required CategoryGridFamily super.from,
    required ({MediaKind kind, CatalogSort sort, int? genreId}) super.argument,
  }) : super(
         retry: null,
         name: r'categoryGridProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryGridHash();

  @override
  String toString() {
    return r'categoryGridProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CategoryGrid create() => CategoryGrid();

  @override
  bool operator ==(Object other) {
    return other is CategoryGridProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryGridHash() => r'27fae66e0798a8e7b176dc77ff1d895098e37d25';

/// Grille catégorie paginée (défilement infini), triable.

final class CategoryGridFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryGrid,
          AsyncValue<List<CatalogItem>>,
          List<CatalogItem>,
          FutureOr<List<CatalogItem>>,
          ({MediaKind kind, CatalogSort sort, int? genreId})
        > {
  CategoryGridFamily._()
    : super(
        retry: null,
        name: r'categoryGridProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Grille catégorie paginée (défilement infini), triable.

  CategoryGridProvider call({
    required MediaKind kind,
    required CatalogSort sort,
    int? genreId,
  }) => CategoryGridProvider._(
    argument: (kind: kind, sort: sort, genreId: genreId),
    from: this,
  );

  @override
  String toString() => r'categoryGridProvider';
}

/// Grille catégorie paginée (défilement infini), triable.

abstract class _$CategoryGrid extends $AsyncNotifier<List<CatalogItem>> {
  late final _$args =
      ref.$arg as ({MediaKind kind, CatalogSort sort, int? genreId});
  MediaKind get kind => _$args.kind;
  CatalogSort get sort => _$args.sort;
  int? get genreId => _$args.genreId;

  FutureOr<List<CatalogItem>> build({
    required MediaKind kind,
    required CatalogSort sort,
    int? genreId,
  });
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
    return element.handleCreate(
      ref,
      () =>
          build(kind: _$args.kind, sort: _$args.sort, genreId: _$args.genreId),
    );
  }
}
