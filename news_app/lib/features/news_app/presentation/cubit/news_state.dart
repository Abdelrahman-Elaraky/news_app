import 'package:equatable/equatable.dart';
import '../../data/models/article_model.dart';


// Base abstract state class
abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

// Before any data loaded
class NewsInitial extends NewsState {}

// During API calls
class NewsLoading extends NewsState {}

// Data loaded successfully
class NewsLoaded extends NewsState {
  final List<Article> articles;
  final bool hasMore;

  const NewsLoaded(this.articles, this.hasMore);

  @override
  List<Object?> get props => [articles, hasMore];
}

// Error state with message and retry option flag
class NewsError extends NewsState {
  final String message;
  final bool canRetry;

  const NewsError(this.message, this.canRetry);

  @override
  List<Object?> get props => [message, canRetry];
}

// No articles found
class NewsEmpty extends NewsState {
  final String message;

  const NewsEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

// Offline cached data
class NewsOffline extends NewsState {
  final List<Article> cachedArticles;

  const NewsOffline(this.cachedArticles);

  @override
  List<Object?> get props => [cachedArticles];
}

// Pull-to-refresh state
class NewsRefreshing extends NewsState {}
