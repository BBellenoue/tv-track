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
  late final CurvedAnimation _curve;
  Offset _drag = Offset.zero;
  Offset _animFrom = Offset.zero;
  Offset _animTo = Offset.zero;
  bool _flyingOut = false;
  int _index = 0;
  bool _loadingMore = false;

  static const _flyThreshold = 110.0;
  static const _stampFull = 60.0; // intention à pleine opacité dès ~60px

  static const _likeColor = Color(0xFF6BD08A);

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    _curve = CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic);
    _anim
      ..addListener(() {
        setState(() =>
            _drag = Offset.lerp(_animFrom, _animTo, _curve.value) ?? _drag);
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _onAnimComplete();
      });
  }

  @override
  void dispose() {
    _curve.dispose();
    _anim.dispose();
    super.dispose();
  }

  TmdbTv? get _top =>
      _index < widget.cards.length ? widget.cards[_index] : null;

  void _onAnimComplete() {
    if (_flyingOut) {
      // Avancement ATOMIQUE : on commit et on passe à la carte suivante dans
      // le même setState — pas de frame où l'ancienne carte réapparaît.
      final card = _top;
      final liked = _animTo.dx > 0;
      if (card != null) {
        liked
            ? ref.read(discoverDeckProvider.notifier).like(card)
            : ref.read(discoverDeckProvider.notifier).pass(card);
      }
      setState(() {
        _index++;
        _drag = Offset.zero;
        _flyingOut = false;
      });
      _maybeLoadMore();
    } else {
      setState(() => _drag = Offset.zero); // fin du ressort de retour
    }
  }

  void _maybeLoadMore() {
    if (_loadingMore) return;
    if (widget.cards.length - _index > 4) return;
    _loadingMore = true;
    ref
        .read(discoverDeckProvider.notifier)
        .loadMore()
        .whenComplete(() => _loadingMore = false);
  }

  void _springBack() {
    _animFrom = _drag;
    _animTo = Offset.zero;
    _flyingOut = false;
    _anim.duration = const Duration(milliseconds: 220);
    _anim.forward(from: 0);
  }

  void _flyOut(bool liked) {
    final card = _top;
    if (card == null) return;
    HapticFeedback.mediumImpact();

    // Motion réduite : validation immédiate, sans animation de sortie.
    if (MediaQuery.of(context).disableAnimations) {
      liked
          ? ref.read(discoverDeckProvider.notifier).like(card)
          : ref.read(discoverDeckProvider.notifier).pass(card);
      setState(() {
        _index++;
        _drag = Offset.zero;
      });
      _maybeLoadMore();
      return;
    }

    final width = MediaQuery.of(context).size.width;
    _flyingOut = true;
    _animFrom = _drag;
    _animTo = Offset(liked ? width * 1.5 : -width * 1.5, _drag.dy - 40);
    _anim.duration = const Duration(milliseconds: 240);
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    final top = _top;

    // Plus de cartes chargées : on en redemande et on patiente.
    if (top == null) {
      _maybeLoadMore();
      return const Center(child: CircularProgressIndicator());
    }

    final behind = _index + 1 < cards.length ? cards[_index + 1] : null;
    final busy = _anim.isAnimating;

    final likeT = (_drag.dx / _stampFull).clamp(0.0, 1.0);
    final passT = (-_drag.dx / _stampFull).clamp(0.0, 1.0);
    final dragProgress = (_drag.dx.abs() / _flyThreshold).clamp(0.0, 1.0);

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
                          if (_drag.dx.abs() > _flyThreshold) {
                            _flyOut(_drag.dx > 0);
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
                        tint: likeT > passT ? likeT : passT,
                        tintColor: _drag.dx >= 0 ? _likeColor : dust,
                      ),
                    ),
                  ),
                ),
                // Tampons d'intention FIXES (hors de la carte), donc toujours
                // visibles pendant le swipe même quand la carte s'en va.
                Positioned(
                  top: 16,
                  left: 8,
                  child: _Stamp(
                      text: 'PLUS TARD',
                      color: linen,
                      opacity: passT,
                      angle: 0.16),
                ),
                Positioned(
                  top: 16,
                  right: 8,
                  child: _Stamp(
                      text: 'ENVIE',
                      color: _likeColorConst,
                      opacity: likeT,
                      angle: -0.16),
                ),
              ],
            ),
          ),
        ),
        _Actions(
          onPass: busy ? null : () => _flyOut(false),
          onLike: busy ? null : () => _flyOut(true),
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
    this.tint = 0,
    this.tintColor = const Color(0xFF6BD08A),
  });

  final TmdbTv card;
  final double scale;
  final double tint;
  final Color tintColor;

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
            // Teinte d'intention sur toute la carte pendant le drag.
            if (tint > 0)
              ColoredBox(color: tintColor.withValues(alpha: 0.28 * tint)),
            // Bordure colorée d'intention.
            if (tint > 0)
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: tintColor.withValues(alpha: tint), width: 3),
                ),
              ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 22,
              child: _CardInfo(card: card),
            ),
          ],
        ),
      ),
    );
  }
}

const _likeColorConst = Color(0xFF6BD08A);

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
    required this.angle,
  });

  final String text;
  final Color color;
  final double opacity;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xCC12100D),
              border: Border.all(color: color, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(text,
                style: condensed(size: 22, weight: FontWeight.w700, color: color)
                    .copyWith(letterSpacing: 2)),
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
