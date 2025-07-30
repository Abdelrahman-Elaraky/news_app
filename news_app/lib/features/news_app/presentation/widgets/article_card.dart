import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/article_model.dart';

class ArticleCard extends StatefulWidget {
  final Article article;
  final VoidCallback? onTap;
  final VoidCallback? onCategoryTap;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.onCategoryTap,
  });

  @override
  State<ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<ArticleCard> {
  bool isBookmarked = false;

  String get readingTimeEstimate {
    final wordCount = widget.article.description?.split(' ').length ?? 0;
    final minutes = (wordCount / 200).ceil();
    return '$minutes min read';
  }

  String get formattedDate {
    final publishedAt = widget.article.publishedAt;
    if (publishedAt == null) return '';
    return DateFormat.yMMMd().add_jm().format(publishedAt);
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Save to bookmarks'),
            onTap: () {
              Navigator.pop(context);
              if (mounted) {
                setState(() => isBookmarked = !isBookmarked);
              }
            },
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Hero(
                tag: article.imageUrl!,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    article.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (article.description != null && article.description!.isNotEmpty)
                    Text(
                      article.description!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (article.category != null && article.category!.isNotEmpty)
                        GestureDetector(
                          onTap: widget.onCategoryTap,
                          child: Chip(
                            label: Text(article.category!),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        ),
                      Text(
                        readingTimeEstimate,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.source != null && article.source!.isNotEmpty)
                            Text(
                              article.source!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? Colors.blue : null,
                            ),
                            onPressed: () {
                              setState(() => isBookmarked = !isBookmarked);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () async {
                              final title = article.title;
                              final url = article.url;
                              if (title.isNotEmpty && url != null && url.isNotEmpty) {
                                await Share.share('$title\n$url');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
