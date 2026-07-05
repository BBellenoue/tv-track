import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../data/tmdb/tmdb_api.dart';
import 'discover_controller.dart';

class DiscoverTab extends ConsumerWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(tmdbApiProvider) == null) {
      return _message(context, Icons.explore_off_outlined,
          'Découverte indisponible', 'Aucune clé TMDB configurée.');
    }

    final deck = ref.watch(discoverDeckProvider);
    return deck.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _message(context, Icons.wifi_off_rounded,
          'Chargement impossible', 'Vérifie ta connexion et réessaie.'),
      data: (cards) {
        if (cards.isEmpty) {
          return _message(context, Icons.done_all_rounded, 'Tu as tout vu',
              'Reviens plus tard pour de nouvelles séries à découvrir.');
        }
        return _Deck(cards: cards);
      },
    );
  }

  Widget _message(
      BuildContext context, IconData icon, String title, String body) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: dust),
            const SizedBox(height: 12),
            Text(title, style: condensed(size: 17)),
            const SizedBox(height: 6),
            Text(body,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: dust)),
          ],
        ),
      ),
    );
  }
}

class _Deck extends ConsumerStatefulWidget {
  const _Deck({required this.cards});

  final List<TmdbTv> cards;

  @override
  ConsumerState<_Deck> createState() => _DeckState();
}

class _DeckState extends ConsumerState<_Deck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  Offset _drag = Offset.zero;
  Offset _animFrom = Offset.zero;
  Offset _animTo = Offset.zero;
  bool _flyingOut = false;
  TmdbTv? _flying;

  static const _threshold = 110.0;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    // Décélération exponentielle (pas de rebond).
    final curved = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim
      ..addListener(() {
        setState(() =>
            _drag = Offset.lerp(_animFrom, _animTo, curved.value) ?? _drag);
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          if (_flyingOut && _flying != null) {
            final card = _flying!;
            final liked = _animTo.dx > 0;
            (liked
                ? ref.read(discoverDeckProvider.notifier).like(card)
                : ref.read(discoverDeckProvider.notifier).pass(card));
          }
          setState(() {
            _drag = Offset.zero;
            _flyingOut = false;
            _flying = null;
          });
        }
      });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  // Ressort de retour : ease-out doux, un peu plus rapide que le fly-out.
  void _springBack() {
    _animFrom = _drag;
    _animTo = Offset.zero;
    _flyingOut = false;
    _anim.duration = const Duration(milliseconds: 220);
    _anim.forward(from: 0);
  }

  void _flyOut(TmdbTv card, bool liked) {
    HapticFeedback.mediumImpact();
    // Motion réduite : on valide sans animation de sortie.
    if (MediaQuery.of(context).disableAnimations) {
      liked
          ? ref.read(discoverDeckProvider.notifier).like(card)
          : ref.read(discoverDeckProvider.notifier).pass(card);
      setState(() => _drag = Offset.zero);
      return;
    }
    final width = MediaQuery.of(context).size.width;
    _flying = card;
    _flyingOut = true;
    _animFrom = _drag;
    _animTo = Offset(liked ? width * 1.5 : -width * 1.5, _drag.dy - 40);
    // Sortie franche et rapide.
    _anim.duration = const Duration(milliseconds: 240);
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    final top = cards.first;
    final behind = cards.length > 1 ? cards[1] : null;
    final busy = _anim.isAnimating;

    final likeT = (_drag.dx / _threshold).clamp(0.0, 1.0);
    final passT = (-_drag.dx / _threshold).clamp(0.0, 1.0);
    final dragProgress = (_drag.dx.abs() / _threshold).clamp(0.0, 1.0);

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (behind != null)
                  _CardFrame(
                    key: ValueKey('behind-${behind.id}'),
                    card: behind,
                    scale: 0.94 + 0.06 * dragProgress,
                  ),
                GestureDetector(
                  onPanUpdate: busy
                      ? null
                      : (d) => setState(() => _drag += d.delta),
                  onPanEnd: busy
                      ? null
                      : (_) {
                          if (_drag.dx.abs() > _threshold) {
                            _flyOut(top, _drag.dx > 0);
                          } else {
                            _springBack();
                          }
                        },
                  child: Transform.translate(
                    offset: _drag,
                    child: Transform.rotate(
                      angle: _drag.dx / 1400,
                      child: _CardFrame(
                        key: ValueKey('top-${top.id}'),
                        card: top,
                        likeOpacity: likeT,
                        passOpacity: passT,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _Actions(
          onPass: busy ? null : () => _flyOut(top, false),
          onLike: busy ? null : () => _flyOut(top, true),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _CardFrame extends StatelessWidget {
  const _CardFrame({
    super.key,
    required this.card,
    this.scale = 1,
    this.likeOpacity = 0,
    this.passOpacity = 0,
  });

  final TmdbTv card;
  final double scale;
  final double likeOpacity;
  final double passOpacity;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (card.posterUrl != null)
              CachedNetworkImage(
                imageUrl: card.posterUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ColoredBox(color: charcoal),
                errorWidget: (_, _, _) => const ColoredBox(color: charcoal),
              )
            else
              const ColoredBox(color: charcoal),
            // Dégradé bas pour la lisibilité du texte.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xF0100E0B)],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: _CardInfo(card: card),
            ),
            _Stamp(
                text: 'ENVIE',
                color: const Color(0xFF6BD08A),
                opacity: likeOpacity,
                alignment: Alignment.topRight,
                angle: -0.2),
            _Stamp(
                text: 'PLUS TARD',
                color: dust,
                opacity: passOpacity,
                alignment: Alignment.topLeft,
                angle: 0.2),
          ],
        ),
      ),
    );
  }
}

class _CardInfo extends StatelessWidget {
  const _CardInfo({required this.card});

  final TmdbTv card;

  @override
  Widget build(BuildContext context) {
    final meta = [
      if (card.year != null) '${card.year}',
      if (card.voteAverage != null && card.voteAverage! > 0)
        '★ ${card.voteAverage!.toStringAsFixed(1)}',
    ].join('   ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(card.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: condensed(size: 26, weight: FontWeight.w700)),
        if (meta.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(meta, style: mono(size: 12, color: tungsten)),
        ],
        if (card.overview != null) ...[
          const SizedBox(height: 10),
          Text(card.overview!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: linen.withValues(alpha: .85), height: 1.4)),
        ],
      ],
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.text,
    required this.color,
    required this.opacity,
    required this.alignment,
    required this.angle,
  });

  final String text;
  final Color color;
  final double opacity;
  final Alignment alignment;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(text,
                  style: condensed(
                      size: 24, weight: FontWeight.w700, color: color)
                      .copyWith(letterSpacing: 2)),
            ),
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onPass, required this.onLike});

  final VoidCallback? onPass;
  final VoidCallback? onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundButton(
          onTap: onPass,
          icon: Icons.close_rounded,
          color: dust,
          size: 58,
        ),
        const SizedBox(width: 36),
        _RoundButton(
          onTap: onLike,
          icon: Icons.favorite_rounded,
          color: tungsten,
          size: 68,
          filled: true,
        ),
      ],
    );
  }
}

class _RoundButton extends StatefulWidget {
  const _RoundButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.size,
    this.filled = false,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final Color color;
  final double size;
  final bool filled;

  @override
  State<_RoundButton> createState() => _RoundButtonState();
}

class _RoundButtonState extends State<_RoundButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.filled ? widget.color : charcoal,
              shape: BoxShape.circle,
              border: Border.all(
                  color: widget.color
                      .withValues(alpha: widget.filled ? 1 : .5),
                  width: 1.5),
            ),
            child: Icon(widget.icon,
                color: widget.filled ? const Color(0xFF221603) : widget.color,
                size: widget.size * 0.42),
          ),
        ),
      ),
    );
  }
}
