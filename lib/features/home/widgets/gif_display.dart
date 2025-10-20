// lib/features/home/widgets/gif_display.dart
import 'package:flutter/material.dart';

class GifDisplay extends StatefulWidget {
  const GifDisplay({
    super.key,
    required this.url,
    required this.onPing,
    this.analyticsOnLoadUrl,
    this.analyticsOnClickUrl,
    // --- NOVOS PARÂMETROS ---
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  final String url;
  final String? analyticsOnLoadUrl;
  final String? analyticsOnClickUrl;
  final Future<void> Function(String?) onPing;
  // --- NOVOS PARÂMETROS ---
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  @override
  State<GifDisplay> createState() => _GifDisplayState();
}

class _GifDisplayState extends State<GifDisplay> {
  // ... (a lógica interna de _GifDisplayState permanece a mesma)
  bool _hasTrackedOnload = false;

  @override
  void didUpdateWidget(covariant GifDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      setState(() => _hasTrackedOnload = false);
    }
  }

  void _onFirstFrame() {
    if (!_hasTrackedOnload) {
      setState(() => _hasTrackedOnload = true);
      widget.onPing(widget.analyticsOnLoadUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: () => widget.onPing(widget.analyticsOnClickUrl),
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
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                    child: Icon(Icons.error_outline, color: Colors.red, size: 48));
              },
            ),
          ),
          // --- BOTÃO DE FAVORITAR ADICIONADO AQUI ---
          if (widget.onToggleFavorite != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                tooltip: widget.isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
                icon: Icon(
                  widget.isFavorite ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: widget.onToggleFavorite,
              ),
            ),
        ],
      ),
    );
  }
}