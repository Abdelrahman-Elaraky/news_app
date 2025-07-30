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

  /// Load top headlines, with offline fallback
  Future<void> fetchTopHeadlines() async {
    emit(NewsLoading());

    try {
      // Try showing cached data first
      final cached = await newsRepository.fetchTopHeadlines(page: 1);
      if (cached.isNotEmpty) emit(NewsOffline(cached));

      // Then fetch fresh data
      final fresh = await newsRepository.fetchTopHeadlines(page: 1);
      _articles
        ..clear()
        ..addAll(fresh);
      _page = 1;
      _hasMore = fresh.length >= NewsRepository.pageSize;

      emit(NewsLoaded(_articles, _hasMore));
    } catch (e) {
      emit(_articles.isEmpty
          ? NewsError(e.toString(), true)
          : NewsLoaded(_articles, _hasMore));
    }
  }

  /// Fetch news for a specific category
  Future<void> fetchByCategory(String category) async {
    emit(NewsLoading());

    try {
      final result = await newsRepository.getNewsByCategory(category, page: 1);
      _articles
        ..clear()
        ..addAll(result);
      _page = 1;
      _hasMore = result.length >= NewsRepository.pageSize;

      emit(NewsLoaded(_articles, _hasMore));
    } catch (e) {
      emit(_articles.isEmpty
          ? NewsError(e.toString(), true)
          : NewsLoaded(_articles, _hasMore));
    }
  }

  /// Load more articles for pagination
  Future<void> loadMoreArticles() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _page += 1;

    try {
      final more = await newsRepository.fetchTopHeadlines(page: _page);
      _articles.addAll(more);
      _hasMore = more.length >= NewsRepository.pageSize;

      emit(NewsLoaded(_articles, _hasMore));
    } catch (e) {
      emit(NewsError(e.toString(), false));
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Pull-to-refresh from the top
  Future<void> refreshNews() async {
    _page = 1;
    emit(NewsRefreshing());

    try {
      final refreshed = await newsRepository.fetchTopHeadlines(page: 1);
      _articles
        ..clear()
        ..addAll(refreshed);
      _hasMore = refreshed.length >= NewsRepository.pageSize;

      emit(NewsLoaded(_articles, _hasMore));
    } catch (e) {
      emit(NewsError(e.toString(), true));
    }
  }

  /// Bookmark or unbookmark an article
  Future<void> toggleBookmark(Article article) async {
    try {
      await newsRepository.bookmarkArticle(article);
    } catch (e) {
      emit(NewsError('Bookmark failed: ${e.toString()}', false));
    }
  }

  /// Get all bookmarked articles
  Future<List<Article>> getBookmarkedArticles() {
    return newsRepository.getBookmarkedArticles();
  }
}
