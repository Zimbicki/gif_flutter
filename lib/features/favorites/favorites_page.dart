// lib/features/favorites/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/favorites_service.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_app_bar.dart';
import '../home/widgets/gif_display.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final _favoritesService = FavoritesService();
  List<Map<String, dynamic>> _favoriteGifs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await _favoritesService.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteGifs = favorites;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> gifData) async {
    final gifId = gifData['id'] as String;
    await _favoritesService.removeFavorite(gifId);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removido dos favoritos'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    
    _loadFavorites(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: '❤️ Favoritos',
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SkeletonLoader();
    }

    if (_favoriteGifs.isEmpty) {
      return EmptyState(
        title: 'Nenhum favorito ainda',
        message: 'Toque no coração ❤️ nos GIFs\nque você gostar para salvá-los aqui!',
        icon: Icons.favorite_border,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _favoriteGifs.length,
      itemBuilder: (context, index) {
        final gifData = _favoriteGifs[index];
        final images = (gifData['images'] ?? {}) as Map<String, dynamic>;
        final fixedWidth =
            (images['fixed_width'] ?? {}) as Map<String, dynamic>;
        final url = fixedWidth['url'] as String?;

        if (url == null) return const Card(child: Icon(Icons.broken_image));

        return GifDisplay(
          url: url,
          isFavorite: true,
          onToggleFavorite: () => _toggleFavorite(gifData),
          onPing: (_) async {},
        );
      },
    ).animate().fadeIn(duration: 400.ms);
  }
}