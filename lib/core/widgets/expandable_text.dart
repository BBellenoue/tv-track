import 'package:flutter/material.dart';

import '../theme.dart';

/// Texte tronqué à [collapsedLines] lignes, dépliable d'un tap avec un
/// libellé « plus / moins ». N'affiche le bouton que si le texte déborde.
class ExpandableText extends StatefulWidget {
  const ExpandableText(this.text, {super.key, this.collapsedLines = 4});

  final String text;
  final int collapsedLines;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: linen.withValues(alpha: .82), height: 1.45);

    return LayoutBuilder(builder: (context, constraints) {
      final overflows = _overflows(widget.text, style, constraints.maxWidth);
      return GestureDetector(
        onTap: overflows ? () => setState(() => _expanded = !_expanded) : null,
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _expanded ? null : widget.collapsedLines,
                overflow:
                    _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (overflows) ...[
              const SizedBox(height: 4),
              Text(_expanded ? 'moins' : 'plus',
                  style: mono(size: 11, color: tungsten)),
            ],
          ],
        ),
      );
    });
  }

  bool _overflows(String text, TextStyle? style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: widget.collapsedLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp.didExceedMaxLines;
  }
}
