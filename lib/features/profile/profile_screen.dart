import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/widgets/section_label.dart';
import '../../data/models/movie.dart';
import '../../data/models/show.dart';
import '../auth/auth_controller.dart';

const _avgEpisodeMinutes = 42; // estimation pour le temps de visionnage séries
const _avgMovieMinutes = 115;

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final shows = ref.watch(showsProvider).value ?? const <Show>[];
    final movies = ref.watch(moviesProvider).value ?? const <Movie>[];

    final watchedEpisodes =
        shows.fold<int>(0, (n, s) => n + s.watchedEpisodes);
    final watchedMovies = movies.where((m) => m.watched).toList();
    final seriesInProgress =
        shows.where((s) => s.isStarted && !s.isUpToDate).length;
    final seriesMinutes = watchedEpisodes * _avgEpisodeMinutes;
    final movieMinutes = watchedMovies.fold<int>(
        0, (n, m) => n + (m.runtime ?? _avgMovieMinutes));
    final totalMinutes = seriesMinutes + movieMinutes;
    final days = totalMinutes / 60 / 24;

    final topShow = shows.isEmpty
        ? null
        : shows.reduce((a, b) => a.watchedEpisodes >= b.watchedEpisodes ? a : b);

    return Scaffold(
      appBar: AppBar(title: const Text('PROFIL')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _AccountHeader(
              name: user?.displayName, email: user?.email, photo: user?.photoURL),
          const SizedBox(height: 28),

          // Chiffre phare "fun".
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              color: charcoal,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: tungsten.withValues(alpha: .35)),
            ),
            child: Column(children: [
              Text(days >= 1
                  ? days.toStringAsFixed(1)
                  : (totalMinutes / 60).toStringAsFixed(0),
                  style: condensed(size: 52, weight: FontWeight.w700, color: tungsten)),
              const SizedBox(height: 4),
              Text(days >= 1 ? 'JOURS DEVANT L\'ÉCRAN' : 'HEURES DE VISIONNAGE',
                  style: mono(size: 11, letterSpacing: 1.6)),
            ]),
          ),
          const SizedBox(height: 20),

          Row(children: [
            _Stat(value: '$watchedEpisodes', label: 'épisodes vus'),
            const SizedBox(width: 12),
            _Stat(value: '${watchedMovies.length}', label: 'films vus'),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _Stat(value: '${shows.length}', label: 'séries suivies'),
            const SizedBox(width: 12),
            _Stat(value: '$seriesInProgress', label: 'séries en cours'),
          ]),

          if (topShow != null && topShow.watchedEpisodes > 0) ...[
            const SizedBox(height: 28),
            const SectionLabel('Ta série la plus regardée'),
            const SizedBox(height: 10),
            Text(topShow.title, style: condensed(size: 20)),
            Text('${topShow.watchedEpisodes} épisodes',
                style: mono(size: 11, color: tungsten)),
          ],

          const SizedBox(height: 40),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE07A6B),
              side: BorderSide(color: const Color(0xFFE07A6B).withValues(alpha: .5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.logout),
            label: Text('Se déconnecter', style: condensed(size: 15)),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({this.name, this.email, this.photo});
  final String? name;
  final String? email;
  final String? photo;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
        radius: 30,
        backgroundColor: charcoalHigh,
        backgroundImage: photo != null ? NetworkImage(photo!) : null,
        child: photo == null ? const Icon(Icons.person, color: dust) : null,
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name ?? 'Toi', style: condensed(size: 20)),
            if (email != null)
              Text(email!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: mono(size: 11)),
          ],
        ),
      ),
    ]);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: charcoal,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Text(value, style: condensed(size: 30, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: mono(size: 10.5)),
        ]),
      ),
    );
  }
}
