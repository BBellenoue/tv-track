import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/core/search_match.dart';

void main() {
  group('searchFold', () {
    test('folds case and accents', () {
      expect(searchFold('Nouvelle École'), 'nouvelle ecole');
      expect(searchFold('Ça Va Où ?'), 'ca va ou ?');
    });

    test('expands ligatures', () {
      expect(searchFold('Cœur'), 'coeur');
      expect(searchFold('Encyclopædia'), 'encyclopaedia');
    });

    test('matches a query typed without accents', () {
      expect(
        searchFold('Nouvelle École').contains(searchFold('ecole')),
        isTrue,
      );
    });

    test('leaves everything else alone', () {
      expect(searchFold('The 8 Show'), 'the 8 show');
      expect(searchFold('進撃の巨人'), '進撃の巨人');
    });
  });
}
