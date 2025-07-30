import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';


class ArticleCacheManager {
  static const _cacheKey = 'cached_articles';
  static const _cacheTimestampKey = 'cache_timestamp';
  static const cacheExpiration = Duration(minutes: 30);

  final SharedPreferences _prefs;

  ArticleCacheManager(this._prefs);

  // Save articles and timestamp to cache
  Future<void> cacheArticles(List<Article> articles) async {
    final jsonString = Article.encodeList(articles);
    await _prefs.setString(_cacheKey, jsonString);
    await _prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get cached articles if not expired; else return empty list
  List<Article> getCachedArticles() {
    final jsonString = _prefs.getString(_cacheKey);
    if (jsonString == null) return [];

    final cacheTimeMillis = _prefs.getInt(_cacheTimestampKey) ?? 0;
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(cacheTimeMillis);

    if (DateTime.now().difference(cacheTime) > cacheExpiration) {
      // Cache expired, clear it
      clearCache();
      return [];
    }

    return Article.decodeList(jsonString);
  }

  // Clear cache selectively
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_cacheTimestampKey);
  }
}
