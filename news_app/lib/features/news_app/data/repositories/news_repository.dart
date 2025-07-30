import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';
import '../services/news_service.dart';

class NewsRepository {
  final NewsService _newsService;
  final SharedPreferences _prefs;
  final String? userId;

  static const int pageSize = 20;

  List<Article> _cachedTopHeadlines = [];
  List<Article> _cachedBookmarkedArticles = [];

  NewsRepository(this._newsService, this._prefs, {this.userId});

  String _cacheKey(String baseKey) =>
      userId?.isNotEmpty == true ? '${baseKey}_$userId' : baseKey;

  Future<List<Article>> fetchTopHeadlines({String country = 'us', int page = 1}) async {
    try {
      final articles = await _newsService.getTopHeadlines(country: country, page: page);
      if (page == 1) {
        _cachedTopHeadlines = articles;
        await _cacheArticles(_cacheKey('topHeadlines'), articles);
      }
      return articles;
    } catch (e) {
      if (_cachedTopHeadlines.isNotEmpty) {
        return _cachedTopHeadlines;
      }
      return await getCachedArticles();
    }
  }

  Future<List<Article>> getCachedArticles() async {
    final json = _prefs.getString(_cacheKey('topHeadlines'));
    if (json != null) {
      return Article.decodeList(json);
    }
    return [];
  }

  Future<List<Article>> getNewsByCategory(String category, {String country = 'us', int page = 1}) {
    return _newsService.getNewsByCategory(category, country: country, page: page);
  }

  Future<List<Article>> searchNews(String query, {int page = 1}) {
    return _newsService.searchNews(query, page: page);
  }

  Future<void> bookmarkArticle(Article article) async {
    _cachedBookmarkedArticles.removeWhere((a) => a.id == article.id);
    _cachedBookmarkedArticles.add(article);
    await _cacheArticles(_cacheKey('bookmarkedArticles'), _cachedBookmarkedArticles);
  }

  Future<void> removeBookmark(Article article) async {
    _cachedBookmarkedArticles.removeWhere((a) => a.id == article.id);
    await _cacheArticles(_cacheKey('bookmarkedArticles'), _cachedBookmarkedArticles);
  }

  Future<List<Article>> getBookmarkedArticles() async {
    if (_cachedBookmarkedArticles.isNotEmpty) return _cachedBookmarkedArticles;
    _cachedBookmarkedArticles = await _getCachedArticles(_cacheKey('bookmarkedArticles'));
    return _cachedBookmarkedArticles;
  }

  Future<void> clearCache() async {
    _cachedTopHeadlines.clear();
    await _prefs.remove(_cacheKey('topHeadlines'));
  }

  Future<void> clearUserData() async {
    _cachedTopHeadlines.clear();
    _cachedBookmarkedArticles.clear();
    await _prefs.remove(_cacheKey('topHeadlines'));
    await _prefs.remove(_cacheKey('bookmarkedArticles'));
  }

  Future<void> _cacheArticles(String key, List<Article> articles) async {
    final encoded = Article.encodeList(articles);
    await _prefs.setString(key, encoded);
  }

  Future<List<Article>> _getCachedArticles(String key) async {
    final json = _prefs.getString(key);
    if (json != null) {
      return Article.decodeList(json);
    }
    return [];
  }
}
