import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/poster.dart';
import '../../core/widgets/section_label.dart';
import '../../data/models/movie.dart';
import '../../data/models/show.dart';
import '../discover/preview_sheet.dart';
import 'search_controller.dart';

/// Recherche globale : ta bibliothèque (local, instantané) + Découvrir (TMDB).
class SearchScreen extends HookConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raw = useState('');
    final query = useState('');

    // Debounce ~300 ms avant d'interroger TMDB.
    useEffect(() {
      final t = Timer(const Duration(milliseconds: 300),
          () => query.value = raw.value.trim());
      return t.cancel;
    }, [raw.value]);

    final q = query.value.toLowerCase();
    final shows = (ref.watch(showsProvider).value ?? const <Show>[])
        .where((s) => q.length >= 2 && s.title.toLowerCase().contains(q))
        .take(20)
        .toList();
    final movies = (ref.watch(moviesProvider).value ?? const <Movie>[])
        .where((m) => q.length >= 2 && m.title.toLowerCase().contains(q))
        .take(20)
        .toList();
    final tmdb = ref.watch(tmdbSearchProvider(query.value));
    final trackedTv = ref.watch(trackedShowTmdbIdsProvider);
    final trackedMv = ref.watch(trackedMovieTmdbIdsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          onChanged: (v) => raw.value = v,
          textInputAction: TextInputAction.search,
          style: condensed(size: 18),
          decoration: InputDecoration(
            hintText: 'Rechercher une série, un film…',
            hintStyle: TextStyle(color: dust),
            border: InputBorder.none,
          ),
        ),
      ),
      body: q.length < 2
          ? Center(
              child: Text('Tape au moins 2 lettres.',
                  style: TextStyle(color: dust)))
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (shows.isNotEmpty || movies.isNotEmpty) ...[
                  _label('Ma bibliothèque'),
                  for (final s in shows)
                    _LibraryRow(
                        title: s.title,
                        subtitle: 'Série · ${s.watchedEpisodes}/${s.totalEpisodes}',
                        posterUrl: s.poster,
                        seed: s.tvdbId,
                        onTap: () => context.push('/show/${s.tvdbId}')),
                  for (final m in movies)
                    _LibraryRow(
                        title: m.title,
                        subtitle: 'Film${m.year != null ? ' · ${m.year}' : ''}',
                        posterUrl: m.poster,
                        seed: m.tvdbId,
                        onTap: () => context.push('/movie/${m.tvdbId}')),
                ],
                _label('Découvrir'),
                ...tmdb.when(
                  loading: () => [
                    const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()))
                  ],
                  error: (_, _) => [
                    Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Recherche indisponible.',
                            style: TextStyle(color: dust)))
                  ],
                  data: (items) => items.isEmpty
                      ? [
                          Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text('Aucun résultat.',
                                  style: TextStyle(color: dust)))
                        ]
                      : [
                          for (final item in items)
                            _LibraryRow(
                              title: item.title,
                              subtitle:
                                  '${item.kind.isTv ? 'Série' : 'Film'}${item.year != null ? ' · ${item.year}' : ''}',
                              posterUrl: item.posterUrlSmall,
                              seed: item.tmdbId,
                              tracked: item.kind.isTv
                                  ? trackedTv.contains(item.tmdbId)
                                  : trackedMv.contains(item.tmdbId),
                              onTap: () => showCatalogPreview(context, item),
                            ),
                        ],
                ),
              ],
            ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
        child: SectionLabel(t),
      );
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({
    required this.title,
    required this.subtitle,
    required this.posterUrl,
    required this.seed,
    required this.onTap,
    this.tracked = false,
  });

  final String title;
  final String subtitle;
  final String? posterUrl;
  final int seed;
  final VoidCallback onTap;
  final bool tracked;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(children: [
          Poster(title: title, seed: seed, url: posterUrl, width: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: condensed(size: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: mono(size: 10.5)),
              ],
            ),
          ),
          if (tracked) const Icon(Icons.check, size: 18, color: tungsten),
        ]),
      ),
    );
  }
}
