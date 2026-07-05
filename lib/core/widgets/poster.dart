import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Poster à taille fixe (ratio 2:3), coins arrondis, avec fallback dégradé +
/// initiale quand il n'y a pas d'image. La taille est réservée dans tous les
/// cas : aucun saut de layout au chargement.
class Poster extends StatelessWidget {
  const Poster({
    super.key,
    required this.title,
    required this.seed,
    this.url,
    this.width = 48,
  });

  final String title;
  final int seed;
  final String? url;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 3 / 2;
    final fallback = _Fallback(title: title, seed: seed, width: width);

    return ClipRRect(
      borderRadius: BorderRadius.circular(width / 6),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, _) =>
                    const ColoredBox(color: Color(0xFF1E1E2E)),
                errorWidget: (_, _, _) => fallback,
              ),
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.title, required this.seed, required this.width});

  final String title;
  final int seed;
  final double width;

  @override
  Widget build(BuildContext context) {
    final hue = (seed % 360).toDouble();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, hue, .45, .30).toColor(),
            HSLColor.fromAHSL(1, (hue + 40) % 360, .45, .18).toColor(),
          ],
        ),
      ),
      child: Center(
        child: Text(
          title.isEmpty ? '?' : title.characters.first.toUpperCase(),
          style: TextStyle(
            fontSize: width * .42,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
