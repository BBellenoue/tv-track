import 'package:flutter/material.dart';

import '../theme.dart';

/// Onglets de filtre façon "chaînes" : libellé condensé en capitales,
/// compteur en mono, soulignement ambre sur l'onglet actif.
class FilterTabs<T> extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final List<(T value, String label, int count)> items;
  final T selected;
  final ValueChanged<T> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (value, label, count) in items)
          Expanded(
            child: InkWell(
              onTap: () => onSelect(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color:
                          value == selected ? tungsten : Colors.transparent,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: condensed(
                        size: 13.5,
                        letterSpacing: 1.4,
                        color: value == selected ? linen : dust,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('$count',
                        style: mono(
                            size: 11,
                            color: value == selected ? tungsten : dust)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
