// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_repair.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Réparation « live » d'une fiche isolée, déclenchée à l'ouverture de son écran
/// de détail quand le contenu est incomplet (voir [Show.isIncomplete] /
/// [Movie.isIncomplete]) : synopsis, affiche, image de fond, épisodes ou durée
/// manquants, ou affichage resté en anglais.
///
/// Complète le rafraîchissement par lots ([MetadataRefresh], à l'ouverture de
/// l'app / pull-to-refresh) : ici on cible une seule fiche, immédiatement,
/// sans attendre le prochain balayage.
///
/// Garde-fous :
/// - **anti-boucle** : chaque fiche n'est tentée qu'une fois par session, même
///   si elle reste incomplète (TMDB/TVmaze peut ne rien avoir) — évite de
///   marteler l'API à chaque rebuild ou réouverture ;
/// - **dédup in-flight** : une réparation déjà en cours n'est pas relancée.
///
/// L'état exposé est l'ensemble des clés en cours (`show-<id>` / `movie-<id>`),
/// pour qu'un écran affiche un indicateur « Mise à jour… ».

@ProviderFor(LiveRepair)
final liveRepairProvider = LiveRepairProvider._();

/// Réparation « live » d'une fiche isolée, déclenchée à l'ouverture de son écran
/// de détail quand le contenu est incomplet (voir [Show.isIncomplete] /
/// [Movie.isIncomplete]) : synopsis, affiche, image de fond, épisodes ou durée
/// manquants, ou affichage resté en anglais.
///
/// Complète le rafraîchissement par lots ([MetadataRefresh], à l'ouverture de
/// l'app / pull-to-refresh) : ici on cible une seule fiche, immédiatement,
/// sans attendre le prochain balayage.
///
/// Garde-fous :
/// - **anti-boucle** : chaque fiche n'est tentée qu'une fois par session, même
///   si elle reste incomplète (TMDB/TVmaze peut ne rien avoir) — évite de
///   marteler l'API à chaque rebuild ou réouverture ;
/// - **dédup in-flight** : une réparation déjà en cours n'est pas relancée.
///
/// L'état exposé est l'ensemble des clés en cours (`show-<id>` / `movie-<id>`),
/// pour qu'un écran affiche un indicateur « Mise à jour… ».
final class LiveRepairProvider
    extends $NotifierProvider<LiveRepair, Set<String>> {
  /// Réparation « live » d'une fiche isolée, déclenchée à l'ouverture de son écran
  /// de détail quand le contenu est incomplet (voir [Show.isIncomplete] /
  /// [Movie.isIncomplete]) : synopsis, affiche, image de fond, épisodes ou durée
  /// manquants, ou affichage resté en anglais.
  ///
  /// Complète le rafraîchissement par lots ([MetadataRefresh], à l'ouverture de
  /// l'app / pull-to-refresh) : ici on cible une seule fiche, immédiatement,
  /// sans attendre le prochain balayage.
  ///
  /// Garde-fous :
  /// - **anti-boucle** : chaque fiche n'est tentée qu'une fois par session, même
  ///   si elle reste incomplète (TMDB/TVmaze peut ne rien avoir) — évite de
  ///   marteler l'API à chaque rebuild ou réouverture ;
  /// - **dédup in-flight** : une réparation déjà en cours n'est pas relancée.
  ///
  /// L'état exposé est l'ensemble des clés en cours (`show-<id>` / `movie-<id>`),
  /// pour qu'un écran affiche un indicateur « Mise à jour… ».
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

String _$liveRepairHash() => r'f4ddeb5de8d5c5bcd96d5ad0a8462f9bc8180e34';

/// Réparation « live » d'une fiche isolée, déclenchée à l'ouverture de son écran
/// de détail quand le contenu est incomplet (voir [Show.isIncomplete] /
/// [Movie.isIncomplete]) : synopsis, affiche, image de fond, épisodes ou durée
/// manquants, ou affichage resté en anglais.
///
/// Complète le rafraîchissement par lots ([MetadataRefresh], à l'ouverture de
/// l'app / pull-to-refresh) : ici on cible une seule fiche, immédiatement,
/// sans attendre le prochain balayage.
///
/// Garde-fous :
/// - **anti-boucle** : chaque fiche n'est tentée qu'une fois par session, même
///   si elle reste incomplète (TMDB/TVmaze peut ne rien avoir) — évite de
///   marteler l'API à chaque rebuild ou réouverture ;
/// - **dédup in-flight** : une réparation déjà en cours n'est pas relancée.
///
/// L'état exposé est l'ensemble des clés en cours (`show-<id>` / `movie-<id>`),
/// pour qu'un écran affiche un indicateur « Mise à jour… ».

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
