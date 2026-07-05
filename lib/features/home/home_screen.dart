import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../auth/auth_controller.dart';
import '../discover/discover_tab.dart';
import '../movies/movies_tab.dart';
import '../shows/refresh_controller.dart';
import '../shows/shows_tab.dart';
import '../upcoming/upcoming_tab.dart';

const _titles = ['À VENIR', 'SÉRIES', 'FILMS', 'DÉCOUVERTE'];

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = useState(0);
    final refreshing = ref.watch(metadataRefreshProvider);

    // Rafraîchit les métadonnées périmées à l'ouverture (fire-and-forget).
    useEffect(() {
      Future.microtask(
          () => ref.read(metadataRefreshProvider.notifier).run());
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[tab.value]),
        actions: [
          if (refreshing)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signout') {
                ref.read(authControllerProvider.notifier).signOut();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'signout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Se déconnecter'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: tab.value,
        children: const [
          UpcomingTab(),
          ShowsTab(),
          MoviesTab(),
          DiscoverTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.value,
        onDestinationSelected: (i) => tab.value = i,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined), label: 'À venir'),
          NavigationDestination(icon: Icon(Icons.tv), label: 'Séries'),
          NavigationDestination(icon: Icon(Icons.movie), label: 'Films'),
          NavigationDestination(
              icon: Icon(Icons.explore_outlined), label: 'Découverte'),
        ],
      ),
    );
  }
}
