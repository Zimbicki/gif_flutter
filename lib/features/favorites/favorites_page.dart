// lib/features/favorites/favorites_page.dart
import 'package:flutter/material.dart';
import '../../core/services/favorites_service.dart';
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
    // Nesta tela, favoritar significa remover da lista
    await _favoritesService.removeFavorite(gifId);
    // Recarrega a lista para refletir a mudança
    _loadFavorites(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favoriteGifs.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não favoritou nenhum GIF.\nToque na estrela ✩ nos GIFs que gostar!',
          textAlign: TextAlign.center,
        ),
      );
    }

    // Usamos o mesmo GridView da HomePage para consistência
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
          isFavorite: true, // Todos aqui são favoritos
          onToggleFavorite: () => _toggleFavorite(gifData),
          onPing: (_) async {}, // Analytics não é necessário aqui
        );
      },
    );
  }
}