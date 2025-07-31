import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/article_model.dart';
import '../cubit/news_cubit.dart';
import 'bookmarks_screen.dart';

class NewsDetailScreen extends StatefulWidget {
  final Article article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> with SingleTickerProviderStateMixin {
  late bool isBookmarked;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.article.isBookmarked;
    _checkIfBookmarked();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

    _animationController.forward().then((_) => _animationController.reverse());

    setState(() => isBookmarked = !isBookmarked);

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

  void _shareArticle() {
    Share.share('${widget.article.title} - ${widget.article.url}');
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Detail'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share Article',
            onPressed: _shareArticle,
          ),
          ScaleTransition(
            scale: _scaleAnimation,
            child: IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked ? theme.colorScheme.primary : null,
              ),
              tooltip: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
              onPressed: _toggleBookmark,
            ),
          ),
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

            // Hero animation + Cached image
            Hero(
              tag: article.id ?? article.url,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl ?? '',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 200,
                    color: Colors.grey.shade200,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
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
                  article.publishedAt.toLocal().toString().split(' ')[0],
                  style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (article.author != null && article.author!.isNotEmpty)
              Text(
                'By ${article.author}',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
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
