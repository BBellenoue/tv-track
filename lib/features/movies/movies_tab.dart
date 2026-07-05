import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/poster.dart';
import '../../data/models/movie.dart';

class MoviesTab extends HookConsumerWidget {
  const MoviesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(moviesProvider);
    final showWatched = useState(false);

    return movies.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur : $e')),
      data: (all) {
        if (all.isEmpty) {
          return const Center(child: Text('Bibliothèque vide.'));
        }

        final toWatch = all.where((m) => !m.watched).length;
        final filtered =
            all.where((m) => m.watched == showWatched.value).sorted((a, b) {
          if (showWatched.value) {
            final da = a.watchedAt ?? DateTime(1970);
            final db = b.watchedAt ?? DateTime(1970);
            return db.compareTo(da);
          }
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(value: false, label: Text('À voir · $toWatch')),
                  ButtonSegment(
                      value: true, label: Text('Vus · ${all.length - toWatch}')),
                ],
                selected: {showWatched.value},
                onSelectionChanged: (s) => showWatched.value = s.first,
                showSelectedIcon: false,
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(child: Text('Rien ici pour le moment.'))
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => _MovieTile(
                        key: ValueKey(filtered[i].tvdbId),
                        movie: filtered[i],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MovieTile extends ConsumerWidget {
  const _MovieTile({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        children: [
          Poster(
              title: movie.title,
              seed: movie.tvdbId,
              url: movie.poster,
              width: 52),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (movie.year != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${movie.year}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton.filledTonal(
            isSelected: movie.watched,
            icon: const Icon(Icons.visibility_outlined, size: 22),
            selectedIcon: const Icon(Icons.check, size: 22),
            tooltip: movie.watched ? 'Marquer non vu' : 'Marquer vu',
            onPressed: () => _toggle(context, ref),
          ),
        ],
      ),
    );
  }

  void _toggle(BuildContext context, WidgetRef ref) {
    final repo = ref.read(trackingRepositoryProvider);
    if (repo == null) return;
    final watched = !movie.watched;

    HapticFeedback.lightImpact();
    repo.saveMovie(movie.copyWith(
      watched: watched,
      watchedAt: watched ? DateTime.now() : null,
    ));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content:
            Text('${movie.title} — ${watched ? 'vu' : 'remis dans "À voir"'}'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () => repo.saveMovie(movie),
        ),
      ));
  }
}
