import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/theme.dart';
import 'auth_controller.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wordmark façon enseigne : condensé, souligné au tungstène.
              Text('TV TRACK',
                  style: condensed(
                      size: 44, weight: FontWeight.w700, letterSpacing: 3)),
              const SizedBox(height: 6),
              Container(width: 56, height: 4, color: tungsten),
              const SizedBox(height: 14),
              Text('Où tu t\'es arrêté, épisode par épisode.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: dust)),
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
                  'Connexion impossible. Réessaie — si ça persiste, '
                  'vérifie ta connexion.\n($auth)',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
