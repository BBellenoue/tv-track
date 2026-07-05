import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers.dart';
import '../../data/tvmaze/enrichment.dart';
import '../../data/tvmaze/tvmaze_api.dart';

part 'refresh_controller.g.dart';

/// Rafraîchissement incrémental des métadonnées TVmaze depuis l'app
/// (pull-to-refresh) : uniquement les séries non terminées dont les métas
/// datent de plus de 24 h, les plus récemment regardées d'abord, par lots
/// de 8 pour respecter le rate limit TVmaze (~20 req/10 s).
@riverpod
class MetadataRefresh extends _$MetadataRefresh {
  static const _batchSize = 8;
  static const _staleAfter = Duration(hours: 24);

  bool _running = false;

  @override
  bool build() => false; // true = rafraîchissement en cours

  Future<void> run() async {
    if (_running) return;
    final repo = ref.read(trackingRepositoryProvider);
    final shows = ref.read(showsProvider).value;
    if (repo == null || shows == null) return;

    final cutoff = DateTime.now().subtract(_staleAfter);
    final stale = shows
        .where((s) =>
            !s.isEnded &&
            (s.metaRefreshedAt == null || s.metaRefreshedAt!.isBefore(cutoff)))
        .sorted((a, b) => (b.lastWatchedAt ?? DateTime(1970))
            .compareTo(a.lastWatchedAt ?? DateTime(1970)))
        .take(_batchSize)
        .toList();
    if (stale.isEmpty) return;

    _running = true;
    state = true;
    final api = TvmazeApi();
    try {
      for (final show in stale) {
        try {
          final meta = await api.lookupByTvdb(show.tvdbId);
          await Future.delayed(const Duration(milliseconds: 600));
          if (meta == null) {
            // Inconnue de TVmaze : on tamponne pour ne pas réessayer à chaque pull.
            await repo.saveShow(show.copyWith(metaRefreshedAt: DateTime.now()));
            continue;
          }
          final episodes = await api.episodes(meta.id);
          await Future.delayed(const Duration(milliseconds: 600));
          await repo.saveShow(
              mergeTvmaze(show, meta, episodes, now: DateTime.now()));
        } catch (_) {
          // Réseau/API en erreur : on passe à la suivante, retentée au
          // prochain rafraîchissement.
        }
      }
    } finally {
      _running = false;
      state = false;
    }
  }
}
