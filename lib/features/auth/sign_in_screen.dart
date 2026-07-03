import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'auth_controller.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.live_tv_rounded,
                  size: 96, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('TV Track', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Ton suivi de séries et films',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              if (auth.isLoading)
                const CircularProgressIndicator()
              else
                FilledButton.icon(
                  onPressed: () => ref
                      .read(authControllerProvider.notifier)
                      .signInWithGoogle(),
                  icon: const Icon(Icons.login),
                  label: const Text('Continuer avec Google'),
                ),
              if (auth.hasError) ...[
                const SizedBox(height: 16),
                Text(
                  'Échec de connexion : ${auth.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
