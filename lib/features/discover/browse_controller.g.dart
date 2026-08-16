// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browse_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(catalogGenres)
final catalogGenresProvider = CatalogGenresFamily._();

final class CatalogGenresProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Genre>>,
          List<Genre>,
          FutureOr<List<Genre>>
        >
    with $FutureModifier<List<Genre>>, $FutureProvider<List<Genre>> {
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

  CatalogGenresProvider call(MediaKind kind) =>
      CatalogGenresProvider._(argument: kind, from: this);

  @override
  String toString() => r'catalogGenresProvider';
}

/// One Browse rail: first page only. A null [genreId] means this week's
/// trending entries.

@ProviderFor(catalogRow)
final catalogRowProvider = CatalogRowFamily._();

/// One Browse rail: first page only. A null [genreId] means this week's
/// trending entries.

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
  /// One Browse rail: first page only. A null [genreId] means this week's
  /// trending entries.
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

String _$catalogRowHash() => r'b8d86848b593d9d00fbf6032b3b319b7aaf68091';

/// One Browse rail: first page only. A null [genreId] means this week's
/// trending entries.

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

  /// One Browse rail: first page only. A null [genreId] means this week's
  /// trending entries.

  CatalogRowProvider call({required MediaKind kind, int? genreId}) =>
      CatalogRowProvider._(
        argument: (kind: kind, genreId: genreId),
        from: this,
      );

  @override
  String toString() => r'catalogRowProvider';
}

/// Paginated, sortable category grid backing the infinite-scrolling screen.

@ProviderFor(CategoryGrid)
final categoryGridProvider = CategoryGridFamily._();

/// Paginated, sortable category grid backing the infinite-scrolling screen.
final class CategoryGridProvider
    extends $AsyncNotifierProvider<CategoryGrid, List<CatalogItem>> {
  /// Paginated, sortable category grid backing the infinite-scrolling screen.
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

String _$categoryGridHash() => r'31ae7221decb5789f8ac0b31f792e3ae52057d73';

/// Paginated, sortable category grid backing the infinite-scrolling screen.

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

  /// Paginated, sortable category grid backing the infinite-scrolling screen.

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

/// Paginated, sortable category grid backing the infinite-scrolling screen.

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
