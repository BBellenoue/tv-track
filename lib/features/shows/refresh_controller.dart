import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/locale.dart';
import '../../core/providers.dart';
import '../../data/models/show.dart';
import '../../data/tvdb/enrichment.dart';

part 'refresh_controller.g.dart';

/// Incremental metadata refresh, in batches, running shows that need it most
/// first.
///
/// Fires on app open for running shows whose metadata is over a day old, plus
/// any record with something missing. A pull-to-refresh passes `force`, which
/// also picks up incomplete records that are not stale yet.
@riverpod
class MetadataRefresh extends _$MetadataRefresh {
  static const _batchSize = 8;
  static const _staleAfter = Duration(hours: 24);

  bool _running = false;

  @override
  bool build() => false; // true while a batch is running

  Future<void> run({bool force = false}) async {
    if (_running) return;
    final repo = ref.read(trackingRepositoryProvider);
    final shows = ref.read(showsProvider).value;
    if (repo == null || shows == null) return;

    final tvdb = ref.read(tvdbApiProvider);
    if (tvdb == null) return; // no key: enrichment is disabled

    final wantEnglish = ref.read(localeControllerProvider) == AppLocale.english;
    final cutoff = DateTime.now().subtract(_staleAfter);
    bool isStale(Show s) =>
        s.metaRefreshedAt == null || s.metaRefreshedAt!.isBefore(cutoff);
    bool needsRepair(Show s) => s.needsRepair(wantEnglish: wantEnglish);
    bool eligible(Show s) => needsRepair(s)
        // A manual pull retries broken records immediately; otherwise they get
        // at most one attempt a day.
        ? (force || isStale(s))
        // Routine upkeep for running shows with stale metadata.
        : (!s.isEnded && isStale(s));

    final batch = shows
        .where(eligible)
        .sorted((a, b) {
          // Broken records first — that is the problem worth fixing.
          final ra = needsRepair(a) ? 0 : 1;
          final rb = needsRepair(b) ? 0 : 1;
          if (ra != rb) return ra - rb;
          return (b.lastWatchedAt ?? DateTime(1970)).compareTo(
            a.lastWatchedAt ?? DateTime(1970),
          );
        })
        .take(_batchSize)
        .toList();
    if (batch.isEmpty) return;

    _running = true;
    state = true;
    final tmdb = ref.read(tmdbApiProvider);
    try {
      for (final show in batch) {
        try {
          final merged = await enrichShowFromTvdb(show, tvdb, tmdb: tmdb);
          await repo.saveShow(merged);
        } catch (_) {
          // Move on; the next refresh will retry this one.
        }
        // Stay polite towards the API between shows.
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } finally {
      _running = false;
      state = false;
    }
  }
}
