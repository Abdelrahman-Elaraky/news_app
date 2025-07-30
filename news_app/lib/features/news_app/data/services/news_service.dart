import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_application_1/config/app_config.dart';
import '../models/article_model.dart';

class NewsService {
  final String _baseUrl = 'https://newsapi.org/v2';
  final String _apiKey = AppConfig.newsApiKey;
  final Duration _timeout = const Duration(seconds: 30);
  static const int _maxRetries = 1;

  Future<Map<String, dynamic>> _get(String endpoint, Map<String, String> params) async {
    final uri = Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: {
      ...params,
      'apiKey': _apiKey,
    });

    int retries = _maxRetries;

    while (true) {
      try {
        final response = await http.get(uri).timeout(_timeout);
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      } on SocketException {
        if (retries == 0) throw HttpException("Network Error.");
      } on TimeoutException {
        if (retries == 0) throw HttpException("Timeout Error.");
      } catch (e) {
        if (retries == 0) throw HttpException("Unhandled exception: $e");
      }

      retries--;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  List<Article> _parseArticles(dynamic raw) {
    if (raw is List) {
      return raw.map((json) => Article.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<Article>> getTopHeadlines({String country = 'us', int page = 1}) async {
    final data = await _get('top-headlines', {
      'country': country,
      'page': '$page',
    });
    return _parseArticles(data['articles']);
  }

  Future<List<Article>> searchNews(String query, {int page = 1}) async {
    final data = await _get('everything', {
      'q': query,
      'page': '$page',
      'sortBy': 'publishedAt',
    });
    return _parseArticles(data['articles']);
  }

  Future<List<Article>> getNewsByCategory(String category, {String country = 'us', int page = 1}) async {
    final data = await _get('top-headlines', {
      'country': country,
      'category': category,
      'page': '$page',
    });
    return _parseArticles(data['articles']);
  }

  Future<List<dynamic>> getNewsSources() async {
    final data = await _get('sources', {});
    return data['sources'] ?? [];
  }
}
