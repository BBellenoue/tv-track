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
///   métas datent de plus de 24 h, **plus** toute fiche incomplète
///   (`isIncomplete` : contenu manquant ou resté en anglais) — au plus une
///   tentative / 24 h ;
/// - **manuel** (pull-to-refresh) : idem, mais on force les fiches incomplètes
///   même si elles ne sont pas encore périmées.
///
/// Chaque série est enrichie via **TheTVDB** (structure, titres/résumés FR,
/// images, dates, statut, chaîne) puis TMDB pour les seules plateformes de
/// streaming (voir [enrichShowFromTvdb]). Les séries introuvables côté TheTVDB
/// sont tamponnées pour ne pas boucler. Lots de 8, incomplètes d'abord.

@ProviderFor(MetadataRefresh)
final metadataRefreshProvider = MetadataRefreshProvider._();

/// Rafraîchissement incrémental des métadonnées depuis l'app.
///
/// Deux déclencheurs :
/// - **automatique** (ouverture de l'app) : séries non terminées dont les
///   métas datent de plus de 24 h, **plus** toute fiche incomplète
///   (`isIncomplete` : contenu manquant ou resté en anglais) — au plus une
///   tentative / 24 h ;
/// - **manuel** (pull-to-refresh) : idem, mais on force les fiches incomplètes
///   même si elles ne sont pas encore périmées.
///
/// Chaque série est enrichie via **TheTVDB** (structure, titres/résumés FR,
/// images, dates, statut, chaîne) puis TMDB pour les seules plateformes de
/// streaming (voir [enrichShowFromTvdb]). Les séries introuvables côté TheTVDB
/// sont tamponnées pour ne pas boucler. Lots de 8, incomplètes d'abord.
final class MetadataRefreshProvider
    extends $NotifierProvider<MetadataRefresh, bool> {
  /// Rafraîchissement incrémental des métadonnées depuis l'app.
  ///
  /// Deux déclencheurs :
  /// - **automatique** (ouverture de l'app) : séries non terminées dont les
  ///   métas datent de plus de 24 h, **plus** toute fiche incomplète
  ///   (`isIncomplete` : contenu manquant ou resté en anglais) — au plus une
  ///   tentative / 24 h ;
  /// - **manuel** (pull-to-refresh) : idem, mais on force les fiches incomplètes
  ///   même si elles ne sont pas encore périmées.
  ///
  /// Chaque série est enrichie via **TheTVDB** (structure, titres/résumés FR,
  /// images, dates, statut, chaîne) puis TMDB pour les seules plateformes de
  /// streaming (voir [enrichShowFromTvdb]). Les séries introuvables côté TheTVDB
  /// sont tamponnées pour ne pas boucler. Lots de 8, incomplètes d'abord.
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

String _$metadataRefreshHash() => r'd90ffc2ba83288aa4af00d198f32f2dc80990d3e';

/// Rafraîchissement incrémental des métadonnées depuis l'app.
///
/// Deux déclencheurs :
/// - **automatique** (ouverture de l'app) : séries non terminées dont les
///   métas datent de plus de 24 h, **plus** toute fiche incomplète
///   (`isIncomplete` : contenu manquant ou resté en anglais) — au plus une
///   tentative / 24 h ;
/// - **manuel** (pull-to-refresh) : idem, mais on force les fiches incomplètes
///   même si elles ne sont pas encore périmées.
///
/// Chaque série est enrichie via **TheTVDB** (structure, titres/résumés FR,
/// images, dates, statut, chaîne) puis TMDB pour les seules plateformes de
/// streaming (voir [enrichShowFromTvdb]). Les séries introuvables côté TheTVDB
/// sont tamponnées pour ne pas boucler. Lots de 8, incomplètes d'abord.

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
