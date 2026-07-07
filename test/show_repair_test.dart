import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/show.dart';

void main() {
  Show show({int? tmdbId, String? overview}) =>
      Show(tvdbId: 1, title: 'X', tmdbId: tmdbId, overview: overview);

  group('needsFrenchRepair', () {
    test('résumé français sans ID TMDB → rien à faire (TMDB ≠ source FR)', () {
      // Depuis la migration TheTVDB, l'absence d'ID TMDB n'implique plus un
      // affichage anglais : seul un synopsis anglophone déclenche la réparation.
      expect(
        show(tmdbId: null, overview: 'Un synopsis en français bien tourné.')
            .needsFrenchRepair,
        isFalse,
      );
    });

    test('résumé français avec ID TMDB → rien à faire', () {
      expect(
        show(
          tmdbId: 42,
          overview: 'Une famille déménage dans une petite ville '
              'et découvre un secret enfoui.',
        ).needsFrenchRepair,
        isFalse,
      );
    });

    test('résumé anglais malgré un ID TMDB → à réparer', () {
      expect(
        show(
          tmdbId: 42,
          overview: 'A family moves to a small town and they '
              'discover a secret that was buried.',
        ).needsFrenchRepair,
        isTrue,
      );
    });

    test('sans résumé mais rattachée à TMDB → rien à faire', () {
      expect(show(tmdbId: 42, overview: null).needsFrenchRepair, isFalse);
    });

    test('un mot anglais isolé ne suffit pas (pas de faux positif)', () {
      expect(
        show(tmdbId: 42, overview: 'Le personnage principal se nomme The Kid.')
            .needsFrenchRepair,
        isFalse,
      );
    });
  });
}
