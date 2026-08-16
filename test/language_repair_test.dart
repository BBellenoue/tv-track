import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/models/show.dart';

void main() {
  Show show(String? overview) => Show(
    tvdbId: 1,
    title: 'X',
    tmdbId: 42,
    overview: overview,
    poster: 'https://img/poster.jpg',
    seasons: [
      Season(
        number: 1,
        episodes: [
          Episode(
            tvdbId: 10,
            number: 1,
            name: 'Pilot',
            airDate: DateTime(2020, 1, 1),
            still: 'https://img/still.jpg',
            overview: 'An enriched episode.',
          ),
        ],
      ),
    ],
  );

  const english =
      'A family moves to a small town and they discover a secret '
      'that was buried for years.';
  const french =
      'Une famille déménage dans une petite ville et découvre un '
      'secret enfoui depuis des années.';

  group('looksEnglish', () {
    test('reads a clearly English overview as English', () {
      expect(looksEnglish(english), isTrue);
    });

    test('reads a clearly French overview as not English', () {
      expect(looksEnglish(french), isFalse);
    });

    test('stays undecided on text too short to judge', () {
      expect(looksEnglish('The Kid'), isNull);
      expect(looksEnglish(null), isNull);
    });

    test('one stray English word is not enough to decide', () {
      expect(looksEnglish('Le personnage principal se nomme The Kid.'), isNull);
    });
  });

  group('Show.needsRepair', () {
    test('leaves a record that matches the chosen language alone', () {
      expect(show(english).needsRepair(wantEnglish: true), isFalse);
      expect(show(french).needsRepair(wantEnglish: false), isFalse);
    });

    test('flags a record left in the other language', () {
      expect(show(english).needsRepair(wantEnglish: false), isTrue);
      expect(show(french).needsRepair(wantEnglish: true), isTrue);
    });

    test('does not flag undecidable text, which would loop forever', () {
      expect(show('Le Kid.').needsRepair(wantEnglish: true), isFalse);
    });

    test(
      'still flags a record with content missing, whatever the language',
      () {
        expect(
          show(english).copyWith(poster: null).needsRepair(wantEnglish: true),
          isTrue,
        );
      },
    );
  });
}
