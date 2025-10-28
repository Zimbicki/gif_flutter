// lib/features/home/widgets/gif_display.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GifDisplay extends StatefulWidget {
  const GifDisplay({
    super.key,
    required this.url,
    required this.onPing,
    this.analyticsOnLoadUrl,
    this.analyticsOnClickUrl,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final String url;
  final String? analyticsOnLoadUrl;
  final String? analyticsOnClickUrl;
  final Future<void> Function(String?) onPing;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  State<GifDisplay> createState() => _GifDisplayState();
}

class _GifDisplayState extends State<GifDisplay> {
  bool _hasTrackedOnload = false;
  bool _isHovered = false;
  bool _isFavoriteAnimating = false;

  @override
  void didUpdateWidget(covariant GifDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      setState(() => _hasTrackedOnload = false);
    }
    
    // Anima quando favoritar/desfavoritar
    if (widget.isFavorite != oldWidget.isFavorite) {
      setState(() => _isFavoriteAnimating = true);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _isFavoriteAnimating = false);
      });
    }
  }

  void _onFirstFrame() {
    if (!_hasTrackedOnload) {
      setState(() => _hasTrackedOnload = true);
      widget.onPing(widget.analyticsOnLoadUrl);
    }
  }

  void _handleFavoriteToggle() {
    HapticFeedback.mediumImpact();
    widget.onToggleFavorite?.call();
  }

  void _handleLongPress() {
    HapticFeedback.heavyImpact();
    // Pode abrir um dialog com opções
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: _isHovered ? 8 : 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // GIF Image
            GestureDetector(
              onTap: () => widget.onPing(widget.analyticsOnClickUrl),
              onLongPress: _handleLongPress,
              child: Image.network(
                widget.url,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _onFirstFrame());
                  }
                  return child;
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 48),
                          SizedBox(height: 8),
                          Text('Erro ao carregar'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),

            // Overlay escuro no hover
            if (_isHovered)
              Container(
                color: Colors.black.withOpacity(0.2),
              ).animate().fadeIn(duration: 200.ms),

            // Botão de favoritar
            if (widget.onToggleFavorite != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: widget.isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.red : Colors.white,
                      size: 24,
                    ),
                    onPressed: _handleFavoriteToggle,
                  ),
                )
                    .animate(target: _isFavoriteAnimating ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.3, 1.3),
                      duration: 300.ms,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.3, 1.3),
                      end: const Offset(1, 1),
                      duration: 300.ms,
                    ),
              ),
          ],
        ),
      )
          .animate(delay: (widget.url.hashCode % 5 * 100).ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, end: 0),
    );
  }
}