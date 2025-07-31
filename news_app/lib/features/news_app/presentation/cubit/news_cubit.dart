import 'package:bloc/bloc.dart';
import '../../data/models/article_model.dart';
import '../../data/repositories/news_repository.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository newsRepository;

  NewsCubit(this.newsRepository) : super(NewsInitial());

  final List<Article> _articles = [];
  bool _hasMore = true;
  int _page = 1;
  bool _isLoadingMore = false;

  String? _currentCategory;
  String? _searchQuery;

  /// Load latest top headlines (page 1)
  Future<void> fetchTopHeadlines() async {
    _searchQuery = null;
    _currentCategory = null;
    emit(NewsLoading());

    try {
      // Emit cached articles if available (offline mode)
      final cached = await newsRepository.getCachedArticles();
      if (cached.isNotEmpty) emit(NewsOffline(cached));

      // Fetch fresh top headlines from API
      final fresh = await newsRepository.fetchTopHeadlines(page: 1);
      _articles
        ..clear()
        ..addAll(fresh);
      _page = 1;
      _hasMore = fresh.length >= NewsRepository.pageSize;

      emit(NewsLoaded(List.unmodifiable(_articles), _hasMore));
    } catch (e) {
      emit(_articles.isEmpty
          ? NewsError(e.toString(), true)
          : NewsLoaded(List.unmodifiable(_articles), _hasMore));
    }
  }

  /// Fetch articles by a specific category (page 1)
  Future<void> fetchByCategory(String category) async {
    _currentCategory = category;
    _searchQuery = null;
    emit(NewsLoading());

    try {
      final result = await newsRepository.getNewsByCategory(category, page: 1);
      _articles
        ..clear()
        ..addAll(result);
      _page = 1;
      _hasMore = result.length >= NewsRepository.pageSize;

      emit(NewsLoaded(List.unmodifiable(_articles), _hasMore));
    } catch (e) {
      emit(_articles.isEmpty
          ? NewsError(e.toString(), true)
          : NewsLoaded(List.unmodifiable(_articles), _hasMore));
    }
  }

  /// Search articles by a query (page 1)
  Future<void> searchArticles(String query) async {
    _searchQuery = query;
    _currentCategory = null;
    emit(NewsLoading());

    try {
      final results = await newsRepository.searchNews(query, page: 1);
      _articles
        ..clear()
        ..addAll(results);
      _page = 1;
      _hasMore = results.length >= NewsRepository.pageSize;

      emit(NewsLoaded(List.unmodifiable(_articles), _hasMore));
    } catch (e) {
      emit(NewsError(e.toString(), true));
    }
  }

  /// Load next page articles based on current filters/search
  Future<void> loadMoreArticles() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _page += 1;

    try {
      final more = _currentCategory != null
          ? await newsRepository.getNewsByCategory(_currentCategory!, page: _page)
          : _searchQuery != null
              ? await newsRepository.searchNews(_searchQuery!, page: _page)
              : await newsRepository.fetchTopHeadlines(page: _page);

      _articles.addAll(more);
      _hasMore = more.length >= NewsRepository.pageSize;

      emit(NewsLoaded(List.unmodifiable(_articles), _hasMore));
    } catch (e) {
      _page -= 1;
      emit(NewsError(e.toString(), false));
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Refresh current list (pull-to-refresh)
  Future<void> refreshNews() async {
    _page = 1;
    emit(NewsRefreshing());

    try {
      final refreshed = _currentCategory != null
          ? await newsRepository.getNewsByCategory(_currentCategory!, page: 1)
          : _searchQuery != null
              ? await newsRepository.searchNews(_searchQuery!, page: 1)
              : await newsRepository.fetchTopHeadlines(page: 1);

      _articles
        ..clear()
        ..addAll(refreshed);
      _hasMore = refreshed.length >= NewsRepository.pageSize;

      emit(NewsLoaded(List.unmodifiable(_articles), _hasMore));
    } catch (e) {
      emit(NewsError(e.toString(), true));
    }
  }

  /// Toggle bookmark status of an article
  Future<void> toggleBookmark(Article article) async {
    try {
      final isBookmarked = article.isBookmarked;
      final updatedArticle = article.copyWith(isBookmarked: !isBookmarked);

      if (!isBookmarked) {
        await newsRepository.bookmarkArticle(updatedArticle);
      } else {
        await newsRepository.removeBookmark(updatedArticle);
      }

      // Update article list and emit new state
      final index = _articles.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        _articles[index] = updatedArticle;
        emit(NewsLoaded(List.unmodifiable(_articles), _hasMore));
      }
    } catch (e) {
      emit(NewsError('Bookmark failed: ${e.toString()}', false));
    }
  }

  /// Get list of bookmarked articles
  Future<List<Article>> getBookmarkedArticles() async {
    return newsRepository.getBookmarkedArticles();
  }

  /// Check if an article is bookmarked
  Future<bool> isBookmarked(Article article) async {
    final bookmarks = await getBookmarkedArticles();
    return bookmarks.any((a) => a.url == article.url);
  }

  /// Returns a copy of all currently loaded articles
  List<Article> getAllArticles() {
    return List.unmodifiable(_articles);
  }
}
