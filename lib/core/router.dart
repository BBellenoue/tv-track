import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/sign_in_screen.dart';
import '../features/home/home_screen.dart';
import '../features/movies/movie_detail_screen.dart';
import '../features/shows/show_detail_screen.dart';
import 'providers.dart';

part 'router.g.dart';

@riverpod
GoRouter router(Ref ref) {
  final loggedIn = ref.watch(authStateProvider).value != null;

  return GoRouter(
    initialLocation: loggedIn ? '/' : '/signin',
    redirect: (context, state) {
      final signingIn = state.matchedLocation == '/signin';
      if (!loggedIn) return signingIn ? null : '/signin';
      return signingIn ? '/' : null;
    },
    routes: [
      GoRoute(path: '/signin', builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: '/',
        builder: (_, _) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'show/:id',
            builder: (_, state) => ShowDetailScreen(
              tvdbId: int.parse(state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: 'movie/:id',
            builder: (_, state) => MovieDetailScreen(
              tvdbId: int.parse(state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
}
