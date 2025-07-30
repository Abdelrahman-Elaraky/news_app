import 'dart:convert';
import 'package:uuid/uuid.dart';

class Article {
  final String id;
  final String title;
  final String description;
  final String content;
  final String? imageUrl;
  final DateTime publishedAt;
  final String source;
  final String? author;
  final String url;
  final String category;
  final bool isBookmarked;

  Article({
    String? id,
    required this.title,
    required this.description,
    required this.content,
    this.imageUrl,
    required this.publishedAt,
    required this.source,
    this.author,
    required this.url,
    required this.category,
    this.isBookmarked = false,
  }) : id = id ?? const Uuid().v4();

  /// Creates an Article instance from a JSON map
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? const Uuid().v4(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['urlToImage'] ?? json['imageUrl'],
      publishedAt: DateTime.tryParse(json['publishedAt'] ?? '') ?? DateTime.now(),
      source: json['source'] is Map ? json['source']['name'] ?? '' : json['source'] ?? '',
      author: json['author'],
      url: json['url'] ?? '',
      category: json['category'] ?? '',
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }

  /// Converts the Article instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'urlToImage': imageUrl ?? '',
      'publishedAt': publishedAt.toIso8601String(),
      'source': {'name': source},
      'author': author ?? '',
      'url': url,
      'category': category,
      'isBookmarked': isBookmarked,
    };
  }

  /// Encodes a list of Article objects to a JSON string
  static String encodeList(List<Article> articles) => json.encode(
        articles.map<Map<String, dynamic>>((article) => article.toJson()).toList(),
      );

  /// Decodes a JSON string to a list of Article objects
  static List<Article> decodeList(String articlesJson) =>
      (json.decode(articlesJson) as List<dynamic>)
          .map<Article>((item) => Article.fromJson(item))
          .toList();

  /// Creates a copy of this Article with optional new values
  Article copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? imageUrl,
    DateTime? publishedAt,
    String? source,
    String? author,
    String? url,
    String? category,
    bool? isBookmarked,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      source: source ?? this.source,
      author: author ?? this.author,
      url: url ?? this.url,
      category: category ?? this.category,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  @override
  String toString() {
    return 'Article{id: $id, title: $title, publishedAt: $publishedAt, source: $source, isBookmarked: $isBookmarked}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Article && runtimeType == other.runtimeType && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
