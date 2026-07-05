import 'package:flutter/material.dart';

import '../theme.dart';

/// Intitulé de section en mono capitales avec un filet ambre à gauche,
/// façon repère de grille de programme.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 2, color: tungsten),
        const SizedBox(width: 8),
        Text(text.toUpperCase(),
            style: mono(size: 11, color: dust, letterSpacing: 1.6)),
      ],
    );
  }
}
