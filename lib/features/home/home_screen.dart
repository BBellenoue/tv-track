import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../discover/discover_tab.dart';
import '../movies/movies_tab.dart';
import '../shows/refresh_controller.dart';
import '../shows/shows_tab.dart';
import '../upcoming/upcoming_tab.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tab = useState(0);
    final refreshing = ref.watch(metadataRefreshProvider);
    final titles = [
      l10n.tabUpcoming,
      l10n.tabShows,
      l10n.tabMovies,
      l10n.tabDiscover,
    ];

    // Fire-and-forget refresh of stale metadata when the app opens.
    useEffect(() {
      Future.microtask(() => ref.read(metadataRefreshProvider.notifier).run());
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[tab.value].toUpperCase()),
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
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: l10n.search,
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.profile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: IndexedStack(
        index: tab.value,
        children: const [UpcomingTab(), ShowsTab(), MoviesTab(), DiscoverTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.value,
        onDestinationSelected: (i) => tab.value = i,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            label: l10n.tabUpcoming,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tv),
            label: l10n.tabShows,
          ),
          NavigationDestination(
            icon: const Icon(Icons.movie),
            label: l10n.tabMovies,
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            label: l10n.tabDiscover,
          ),
        ],
      ),
    );
  }
}
