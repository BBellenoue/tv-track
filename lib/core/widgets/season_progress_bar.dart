import 'package:flutter/material.dart';

import '../../data/models/show.dart';
import '../theme.dart';

/// Progress split per season, each segment sized by that season's episode
/// count, so the shape of the show is readable straight off the bar.
class SeasonProgressBar extends StatelessWidget {
  const SeasonProgressBar({super.key, required this.show, this.height = 5});

  final Show show;
  final double height;

  @override
  Widget build(BuildContext context) {
    final seasons = show.regularSeasons
        .where((s) => s.episodes.isNotEmpty)
        .toList();
    if (seasons.isEmpty) return SizedBox(height: height);

    return Row(
      children: [
        for (final (i, season) in seasons.indexed) ...[
          if (i > 0) const SizedBox(width: 3),
          Expanded(
            flex: season.episodes.length,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: SizedBox(
                height: height,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: charcoalHigh),
                    ),
                    FractionallySizedBox(
                      widthFactor: season.watchedCount / season.episodes.length,
                      heightFactor: 1,
                      child: const ColoredBox(color: tungsten),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
