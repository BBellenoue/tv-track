import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
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
        final filtered = all
            .where((m) => m.watched == showWatched.value)
            .sorted((a, b) {
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                      value: false, label: Text('À voir ($toWatch)')),
                  ButtonSegment(
                      value: true,
                      label: Text('Vus (${all.length - toWatch})')),
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
                      itemCount: filtered.length,
                      itemBuilder: (context, i) =>
                          _MovieTile(movie: filtered[i]),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _MovieTile extends ConsumerWidget {
  const _MovieTile({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            Colors.primaries[movie.tvdbId % Colors.primaries.length].shade700,
        foregroundColor: Colors.white,
        child: Text(movie.title.characters.first.toUpperCase()),
      ),
      title: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(movie.year?.toString() ?? ''),
      trailing: Checkbox(
        value: movie.watched,
        onChanged: (v) {
          final watched = v ?? false;
          ref.read(trackingRepositoryProvider)?.saveMovie(movie.copyWith(
                watched: watched,
                watchedAt: watched ? DateTime.now() : null,
              ));
        },
      ),
    );
  }
}
