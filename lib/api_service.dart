import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'models/anime.dart';

class ApiService {
  static const String baseUrl = 'https://api.jikan.moe/v4';
  static Map<String, dynamic> safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (e) {
      throw Exception('Invalid JSON response');
    }
  }


  static Future<http.Response> _makeRequest(Uri uri) async {
    try {
      final response = await http.get(uri);
      if (response.statusCode == 429) {
        await Future.delayed(const Duration(seconds: 2));
        return await http.get(uri);
      }
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Anime> fetchAnimeById(int malId) async {
    final response = await http.get(Uri.parse('$baseUrl/anime/$malId'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Anime.fromJson(data['data']);
    } else {
      throw Exception('Failed to load anime by ID');
    }
  }


  static Future<Anime> fetchRandomAnime() async {
    final randomPage = Random().nextInt(20) + 1; // Pages 1 to 20
    final url = Uri.parse('https://api.jikan.moe/v4/top/anime?page=$randomPage');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final animeList = (json['data'] as List)
          .map((e) => Anime.fromJson(e))
          .toList();

      if (animeList.isNotEmpty) {
        return animeList[Random().nextInt(animeList.length)];
      } else {
        throw Exception("Anime list is empty");
      }
    } else {
      throw Exception("Failed to fetch anime: ${response.statusCode}");
    }
  }

  static Future<List<Anime>> fetchTopAnime() async {
    final response = await _makeRequest(Uri.parse('$baseUrl/top/anime'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Invalid API response format');
      }
    } else {
      throw Exception('Failed to load top anime: ${response.statusCode}');
    }
  }

  static Future<List<Anime>> fetchSeasonalAnime() async {
    final response = await _makeRequest(Uri.parse('$baseUrl/seasons/now'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Invalid API response format');
      }
    } else {
      throw Exception('Failed to load seasonal anime: ${response.statusCode}');
    }
  }

  static Future<List<Anime>> fetchTopManga() async {
    final response = await _makeRequest(Uri.parse('$baseUrl/top/manga'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Invalid API response format');
      }
    } else {
      throw Exception('Failed to load top manga: ${response.statusCode}');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchTopCharacters() async {
    final response = await _makeRequest(Uri.parse('$baseUrl/top/characters'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).cast<Map<String, dynamic>>();
      } else {
        throw Exception('Invalid API response format');
      }
    } else {
      throw Exception('Failed to load top characters: ${response.statusCode}');
    }
  }

  static Future<List<Anime>> searchAnime(String query) async {
    final response = await _makeRequest(Uri.parse('$baseUrl/anime?q=$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map && data['data'] is List) {
        return (data['data'] as List).map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Invalid API response format');
      }


      safeJsonDecode(String body) {} } else {
      throw Exception('Failed to search anime: ${response.statusCode}');
    }
  }

  static Future<List<Anime>> fetchAnimeByGenre(int genreId) async {
    final url = Uri.parse('$baseUrl/anime?genres=$genreId');
    final response = await _makeRequest(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List).map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load anime by genre');
    }
  }
}

class ApiNews {
  static const String _apiKey = 'fb1c3c0de28b47c49f207cb60a0fc671';
  static const String _baseUrl = 'https://newsapi.org/v2';

  static Future<List<NewsArticle>> fetchAnimeNews({int page = 1}) async {
    final uri = Uri.parse('$_baseUrl/everything').replace(queryParameters: {
      'q': 'anime',
      'language': 'en',
      'sortBy': 'publishedAt',
      'pageSize': '100',
      'page': '$page',
      'apiKey': _apiKey,
    });

    try {
      final stopwatch = Stopwatch()..start();
      final response = await http.get(uri);
      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['articles'] is List) {
          final articles = (data['articles'] as List)
              .map((json) => NewsArticle.fromJson(json))
              .where((article) {
            final title = article.title.toLowerCase();
            final description = article.description.toLowerCase();
            return title.contains('anime') || description.contains('anime');
          }).toList();

          print('Filtered ${articles.length} anime articles in ${stopwatch.elapsedMilliseconds}ms');
          return articles;
        } else {
          throw Exception('Unexpected response format: articles field is not a list');
        }
      } else {
        final reason = jsonDecode(response.body)['message'] ?? 'Unknown error';
        throw Exception('NewsAPI Error ${response.statusCode}: $reason');
      }
    } catch (e) {
      throw Exception('Exception during fetchAnimeNews: $e');
    }
  }
}




