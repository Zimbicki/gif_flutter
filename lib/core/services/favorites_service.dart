// lib/core/services/favorites_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _favoritesKey = 'favorite_gifs';

class FavoritesService {
 
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteStrings = prefs.getStringList(_favoritesKey) ?? [];
    return favoriteStrings
        .map((gifString) => jsonDecode(gifString) as Map<String, dynamic>)
        .toList();
  }

  Future<void> _saveFavorites(List<Map<String, dynamic>> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteStrings =
        favorites.map((gifData) => jsonEncode(gifData)).toList();
    await prefs.setStringList(_favoritesKey, favoriteStrings);
  }

  /// Adiciona um GIF à lista de favoritos, se ainda não existir.
  Future<void> addFavorite(Map<String, dynamic> gifData) async {
    final favorites = await getFavorites();
    // Evita adicionar duplicatas com base no ID
    if (!favorites.any((fav) => fav['id'] == gifData['id'])) {
      favorites.add(gifData);
      await _saveFavorites(favorites);
    }
  }

  /// Remove um GIF da lista de favoritos usando seu ID.
  Future<void> removeFavorite(String gifId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((fav) => fav['id'] == gifId);
    await _saveFavorites(favorites);
  }

  /// Verifica se um GIF específico já está na lista de favoritos.
  Future<bool> isFavorite(String gifId) async {
    final favorites = await getFavorites();
    return favorites.any((fav) => fav['id'] == gifId);
  }
}