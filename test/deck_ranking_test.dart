import 'package:flutter_test/flutter_test.dart';
import 'package:tv_track/data/tmdb/catalog_item.dart';
import 'package:tv_track/features/discover/discover_controller.dart';

CatalogItem _card(int id, {int votes = 1000, double rating = 7}) => CatalogItem(
  tmdbId: id,
  kind: MediaKind.tv,
  title: 'Show $id',
  voteAverage: rating,
  voteCount: votes,
);

List<int> _ids(List<CatalogItem> cards) => [for (final c in cards) c.tmdbId];

void main() {
  group('rankDeck', () {
    test('a title several seeds point at comes first', () {
      final ranked = rankDeck(
        fromSeeds: [
          [_card(1), _card(2)],
          [_card(2), _card(3)],
          [_card(2)],
        ],
        unseeded: const [],
        excluded: const {},
      );

      expect(_ids(ranked).first, 2);
    });

    test('equal co-occurrence breaks on rating', () {
      final ranked = rankDeck(
        fromSeeds: [
          [_card(1, rating: 6), _card(2, rating: 9)],
        ],
        unseeded: const [],
        excluded: const {},
      );

      expect(_ids(ranked), [2, 1]);
    });

    test('a title carried by a handful of votes is dropped', () {
      final ranked = rankDeck(
        fromSeeds: [
          [_card(1, votes: deckMinVotes - 1), _card(2)],
        ],
        unseeded: const [],
        excluded: const {},
      );

      expect(_ids(ranked), [2]);
    });

    test('tracked and swiped titles never reach the deck', () {
      final ranked = rankDeck(
        fromSeeds: [
          [_card(1), _card(2)],
        ],
        unseeded: [_card(3)],
        excluded: const {1, 3},
      );

      expect(_ids(ranked), [2]);
    });

    test('serendipity is dealt in, not appended at the end', () {
      final ranked = rankDeck(
        fromSeeds: [
          [for (var i = 1; i <= 6; i++) _card(i)],
        ],
        unseeded: [_card(90), _card(91)],
        excluded: const {},
      );

      // One unseeded card every deckSerendipityEvery recommendations.
      expect(_ids(ranked), [1, 2, 3, 90, 4, 5, 6, 91]);
    });

    test('with no seeds the deck is the unseeded pool alone', () {
      final ranked = rankDeck(
        fromSeeds: const [],
        unseeded: [_card(1), _card(2)],
        excluded: const {},
      );

      expect(_ids(ranked), [1, 2]);
    });
  });
}
