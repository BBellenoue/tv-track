import 'package:flutter/material.dart';

import '../theme.dart';

/// Cartouche façon guide TV pour un code épisode ("S02E05") ou une donnée
/// courte : mono, encadré fin.
class EpisodeTag extends StatelessWidget {
  const EpisodeTag(this.text, {super.key, this.emphasis = false});

  final String text;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final color = emphasis ? tungsten : dust;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: .55), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: mono(size: 10.5, color: color)),
    );
  }
}
