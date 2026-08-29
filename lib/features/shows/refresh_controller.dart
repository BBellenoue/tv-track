import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/locale.dart';
import '../../core/providers.dart';
import '../../data/models/show.dart';
import '../../data/tvdb/enrichment.dart';

part 'refresh_controller.g.dart';

/// Picks what to refresh next.
///
/// A record TheTVDB has nothing more to give stays broken forever, so filling
/// the batch with broken records first would refresh the same handful every
/// day and never reach the rest of the library. Only [repairSlots] of the
/// batch go to repairs; the remaining seats go to whatever was refreshed
/// longest ago, which rotates through every show.
List<Show> selectRefreshBatch(
  List<Show> shows, {
  required bool wantEnglish,
  required DateTime now,
  bool force = false,
  int size = MetadataRefresh.batchSize,
  int repairSlots = MetadataRefresh.repairSlots,
}) {
  final cutoff = now.subtract(MetadataRefresh.staleAfter);
  bool isStale(Show s) =>
      s.metaRefreshedAt == null || s.metaRefreshedAt!.isBefore(cutoff);
  bool needsRepair(Show s) => s.needsRepair(wantEnglish: wantEnglish);
  // Broken records and running shows are worth revisiting; an ended show with
  // everything filled in is not. A manual pull goes ahead whatever the age,
  // otherwise a record gets at most one attempt a day.
  bool eligible(Show s) =>
      (needsRepair(s) || !s.isEnded) && (force || isStale(s));

  final eligibleShows = shows.where(eligible).toList();
  final oldestFirst = eligibleShows.sorted(
    (a, b) => (a.metaRefreshedAt ?? DateTime(1970)).compareTo(
      b.metaRefreshedAt ?? DateTime(1970),
    ),
  );

  final batch = [
    ...oldestFirst.where(needsRepair).take(repairSlots),
    ...oldestFirst.whereNot(needsRepair),
  ].take(size).toList();
  // Nothing else is waiting: the broken ones may as well have the free seats.
  if (batch.length < size) {
    batch.addAll(
      oldestFirst.whereNot(batch.contains).take(size - batch.length),
    );
  }
  return batch;
}

/// Incremental metadata refresh, one batch at a time.
///
/// Fires on app open for running shows whose metadata is over a day old, plus
/// any record with something missing. A pull-to-refresh passes `force`, which
/// takes the age condition out of the way.
@riverpod
class MetadataRefresh extends _$MetadataRefresh {
  static const batchSize = 8;
  static const repairSlots = 3;
  static const staleAfter = Duration(hours: 24);

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

    final batch = selectRefreshBatch(
      shows,
      wantEnglish: ref.read(localeControllerProvider) == AppLocale.english,
      now: DateTime.now(),
      force: force,
    );
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
