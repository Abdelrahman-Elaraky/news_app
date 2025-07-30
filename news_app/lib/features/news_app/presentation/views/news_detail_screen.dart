import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/article_model.dart';
import '../cubit/news_cubit.dart';
import 'bookmarks_screen.dart'; // Make sure you import your Bookmarks screen

class NewsDetailScreen extends StatefulWidget {
  final Article article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late bool isBookmarked;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.article.isBookmarked;
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    final bookmarked = await context.read<NewsCubit>().isBookmarked(widget.article);
    if (mounted) {
      setState(() => isBookmarked = bookmarked);
    }
  }

  Future<void> _toggleBookmark() async {
    await context.read<NewsCubit>().toggleBookmark(widget.article);
    final wasBookmarked = isBookmarked;

    setState(() => isBookmarked = !isBookmarked);

    // Only navigate to Bookmarks if it was just bookmarked
    if (!wasBookmarked && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BookmarksScreen()),
      );
    }
  }

  void _launchURL() async {
    final uri = Uri.parse(widget.article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the article URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Detail'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? theme.colorScheme.primary : null,
            ),
            tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
            onPressed: _toggleBookmark,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.imageUrl!,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              )
            else
              Container(
                height: 180,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.broken_image, size: 40),
              ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  article.source,
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
                Text(
                  '${article.publishedAt.toLocal().toString().split(' ')[0]}',
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              article.content.isNotEmpty ? article.content : article.description,
              style: theme.textTheme.bodyLarge,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Read Full Article'),
              onPressed: _launchURL,
            ),
          ],
        ),
      ),
    );
  }
}
