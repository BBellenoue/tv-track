import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../auth/auth_controller.dart';
import '../movies/movies_tab.dart';
import '../shows/shows_tab.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = useState(0);

    return Scaffold(
      appBar: AppBar(
        title: Text(tab.value == 0 ? 'Séries' : 'Films'),
        actions: [
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
        children: const [ShowsTab(), MoviesTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.value,
        onDestinationSelected: (i) => tab.value = i,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.tv), label: 'Séries'),
          NavigationDestination(icon: Icon(Icons.movie), label: 'Films'),
        ],
      ),
    );
  }
}
