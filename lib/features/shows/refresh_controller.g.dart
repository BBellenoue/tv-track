// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Rafraîchissement incrémental des métadonnées depuis l'app.
///
/// Deux déclencheurs :
/// - **automatique** (ouverture de l'app) : séries non terminées dont les
///   métas datent de plus de 24 h, **plus** toute série dont l'affichage est
///   resté en anglais (`needsFrenchRepair`) — au plus une tentative / 24 h ;
/// - **manuel** (pull-to-refresh) : idem, mais on force les réparations FR
///   même si elles ne sont pas encore périmées.
///
/// Chaque série est enrichie via TVmaze (structure, dates, vignettes) **puis**
/// TMDB en français (synopsis, poster, plateformes, titres/résumés d'épisodes),
/// pour ne jamais rebasculer l'affichage en anglais. Les séries en échec de
/// réparation (TMDB muet) sont tamponnées pour ne pas boucler à chaque
/// ouverture. Lots de 8, réparations d'abord, pour respecter le rate limit
/// TVmaze (~20 req/10 s).

@ProviderFor(MetadataRefresh)
final metadataRefreshProvider = MetadataRefreshProvider._();

/// Rafraîchissement incrémental des métadonnées depuis l'app.
///
/// Deux déclencheurs :
/// - **automatique** (ouverture de l'app) : séries non terminées dont les
///   métas datent de plus de 24 h, **plus** toute série dont l'affichage est
///   resté en anglais (`needsFrenchRepair`) — au plus une tentative / 24 h ;
/// - **manuel** (pull-to-refresh) : idem, mais on force les réparations FR
///   même si elles ne sont pas encore périmées.
///
/// Chaque série est enrichie via TVmaze (structure, dates, vignettes) **puis**
/// TMDB en français (synopsis, poster, plateformes, titres/résumés d'épisodes),
/// pour ne jamais rebasculer l'affichage en anglais. Les séries en échec de
/// réparation (TMDB muet) sont tamponnées pour ne pas boucler à chaque
/// ouverture. Lots de 8, réparations d'abord, pour respecter le rate limit
/// TVmaze (~20 req/10 s).
final class MetadataRefreshProvider
    extends $NotifierProvider<MetadataRefresh, bool> {
  /// Rafraîchissement incrémental des métadonnées depuis l'app.
  ///
  /// Deux déclencheurs :
  /// - **automatique** (ouverture de l'app) : séries non terminées dont les
  ///   métas datent de plus de 24 h, **plus** toute série dont l'affichage est
  ///   resté en anglais (`needsFrenchRepair`) — au plus une tentative / 24 h ;
  /// - **manuel** (pull-to-refresh) : idem, mais on force les réparations FR
  ///   même si elles ne sont pas encore périmées.
  ///
  /// Chaque série est enrichie via TVmaze (structure, dates, vignettes) **puis**
  /// TMDB en français (synopsis, poster, plateformes, titres/résumés d'épisodes),
  /// pour ne jamais rebasculer l'affichage en anglais. Les séries en échec de
  /// réparation (TMDB muet) sont tamponnées pour ne pas boucler à chaque
  /// ouverture. Lots de 8, réparations d'abord, pour respecter le rate limit
  /// TVmaze (~20 req/10 s).
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

String _$metadataRefreshHash() => r'd6f9d68f9fdd47e334a2e554ef542219c63fbe69';

/// Rafraîchissement incrémental des métadonnées depuis l'app.
///
/// Deux déclencheurs :
/// - **automatique** (ouverture de l'app) : séries non terminées dont les
///   métas datent de plus de 24 h, **plus** toute série dont l'affichage est
///   resté en anglais (`needsFrenchRepair`) — au plus une tentative / 24 h ;
/// - **manuel** (pull-to-refresh) : idem, mais on force les réparations FR
///   même si elles ne sont pas encore périmées.
///
/// Chaque série est enrichie via TVmaze (structure, dates, vignettes) **puis**
/// TMDB en français (synopsis, poster, plateformes, titres/résumés d'épisodes),
/// pour ne jamais rebasculer l'affichage en anglais. Les séries en échec de
/// réparation (TMDB muet) sont tamponnées pour ne pas boucler à chaque
/// ouverture. Lots de 8, réparations d'abord, pour respecter le rate limit
/// TVmaze (~20 req/10 s).

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
