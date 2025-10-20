// lib/core/services/giphy_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;


const _giphyApiKey = String.fromEnvironment('GIPHY_API_KEY', defaultValue: 'ZmQjBKeltbRmRkTtDqwSP7bI5xfEvIjp');
const _baseUrl = 'https://api.giphy.com/v1';

class GiphyService {
  String? _randomId;

 
  Future<List<dynamic>> searchGifs({
    required String query,
    int limit = 24,
    int offset = 0,
    String rating = 'g',
  }) async {
 
    if (_giphyApiKey.isEmpty) {
      throw Exception('A chave da API do Giphy não foi definida.');
    }

    final endpoint = query.trim().isEmpty ? 'trending' : 'search';
    final params = <String, String>{
      'api_key': _giphyApiKey,
      'q': query,
      'limit': '$limit',
      'offset': '$offset',
      'rating': rating,
    };

    final uri = Uri.https('api.giphy.com', '/v1/gifs/$endpoint', params);

    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    final json = jsonDecode(res.body) as Map<String, dynamic>;

    
    if (res.statusCode == 200) {
      final data = json['data'] as List<dynamic>?;
      if (data == null) {
        throw Exception('A resposta da API não continha dados de GIFs.');
      }
      return data;
    } else {
      
      final message = json['message'] as String? ?? 'Erro desconhecido da API';
      throw Exception('Erro ${res.statusCode}: $message');
    }
  }

  
  Future<void> pingAnalytics(String? url) async {
    if (url == null) return;
    try {
      final uri = Uri.parse(url).replace(queryParameters: {
        ...Uri.parse(url).queryParameters,
        if (_randomId != null) 'random_id': _randomId!,
        'ts': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      await http.get(uri).timeout(const Duration(seconds: 3));
    } catch (_) {
      
    }
  }
}