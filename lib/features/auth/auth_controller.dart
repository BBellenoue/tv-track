import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config.dart';
import '../../core/providers.dart';

part 'auth_controller.g.dart';

/// Initialisation unique du plugin google_sign_in.
@Riverpod(keepAlive: true)
Future<void> googleSignInInit(Ref ref) => GoogleSignIn.instance.initialize(
      serverClientId:
          googleServerClientId.isEmpty ? null : googleServerClientId,
    );

@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await ref.read(googleSignInInitProvider.future);
      final account = await GoogleSignIn.instance.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: account.authentication.idToken,
      );
      await ref.read(firebaseAuthProvider).signInWithCredential(credential);
      state = const AsyncValue.data(null);
    } on GoogleSignInException catch (e, st) {
      state = e.code == GoogleSignInExceptionCode.canceled
          ? const AsyncValue.data(null)
          : AsyncValue.error(e, st);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await ref.read(firebaseAuthProvider).signOut();
  }
}
