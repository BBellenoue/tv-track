import 'package:flutter/material.dart';

import '../theme.dart';

/// Section heading in monospaced caps with an amber rule, echoing the
/// markers on a printed TV schedule.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 2, color: tungsten),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: mono(size: 11, color: dust, letterSpacing: 1.6),
        ),
      ],
    );
  }
}
