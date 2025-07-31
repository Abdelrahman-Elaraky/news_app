import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_app_bar.dart';
import '../widgets/category_bar.dart';

import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';

import '../../data/models/article_model.dart';
import '../../data/models/category_model.dart';
import 'article_detail_screen.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';
 // 👈 Import SettingsScreen

class HomeScreen extends StatefulWidget {
  final String email;
  final String? username;

  const HomeScreen({super.key, required this.email, this.username});

  String get displayName =>
      username?.trim().isNotEmpty == true ? username! : email.split('@')[0];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final ScrollController _scrollController;
  late final NewsCubit _newsCubit;

  List<Category> categories = Category.defaultCategories();
  DateTime? _lastRefreshedAt;
  int bookmarkedCount = 0;

  Category get selectedCategory =>
      categories.firstWhere((c) => c.isSelected, orElse: () => categories[0]);

  @override
  void initState() {
    super.initState();
    _newsCubit = context.read<NewsCubit>();
    _newsCubit.fetchByCategory(selectedCategory.id);

    _scrollController = ScrollController()..addListener(_onScroll);
    _loadBookmarkCount();
  }

  Future<void> _loadBookmarkCount() async {
    final bookmarks = await _newsCubit.getBookmarkedArticles();
    if (mounted) {
      setState(() => bookmarkedCount = bookmarks.length);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _newsCubit.loadMoreArticles();
    }
  }

  Future<void> _handleRefresh() async {
    await _newsCubit.fetchByCategory(selectedCategory.id);
    if (mounted) {
      setState(() => _lastRefreshedAt = DateTime.now());
    }
    await _loadBookmarkCount();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feed refreshed!')),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('rememberedEmail');
    await prefs.remove('rememberedPassword');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/images/user.png'),
              ),
              const SizedBox(height: 10),
              Text(
                widget.displayName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Divider(height: 40),
              buildDrawerItem(
                icon: Icons.bookmark,
                title: 'Bookmarks',
                trailing: CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.primaryColor,
                  child: Text(
                    '$bookmarkedCount',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BookmarksScreen()),
                  );
                  _loadBookmarkCount();
                },
              ),
              buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      appBar: CustomAppBar(
        username: widget.displayName,
        notificationCount: 3,
        onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
        onSettingsTap: () {
          Navigator.pushNamed(context, '/settings'); // ✅ Navigate to settings screen
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        child: const Icon(Icons.search),
      ),
      body: BlocConsumer<NewsCubit, NewsState>(
        listener: (context, state) {
          if (state is NewsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
          if (state is NewsLoaded) {
            _loadBookmarkCount();
          }
        },
        builder: (context, state) {
          final articles = state is NewsLoaded ? state.articles : <Article>[];
          final hasMore = state is NewsLoaded ? state.hasMore : false;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Welcome back, ${widget.displayName}',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (_lastRefreshedAt != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    'Last updated: ${DateFormat('MMM d, hh:mm a').format(_lastRefreshedAt!)}',
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
              CategoryBar(
                categories: categories,
                onCategoryTap: (id) {
                  setState(() {
                    for (var c in categories) {
                      c.isSelected = c.id == id;
                    }
                  });
                  _newsCubit.fetchByCategory(id);
                },
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: theme.primaryColor,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  displacement: 60,
                  child: Builder(
                    builder: (context) {
                      if (state is NewsLoading && articles.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }

                      if (articles.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('No articles found.')),
                          ],
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: hasMore ? articles.length + 1 : articles.length,
                        itemBuilder: (context, index) {
                          if (index >= articles.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final article = articles[index];
                          return ListTile(
                            title: Text(article.title),
                            subtitle: Text(
                              article.description.isNotEmpty
                                  ? article.description
                                  : 'No description available',
                            ),
                            leading: article.imageUrl != null
                                ? Image.network(
                                    article.imageUrl!,
                                    width: 100,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const SizedBox(
                                        width: 100,
                                        height: 60,
                                        child: Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                  )
                                : const Icon(Icons.image_not_supported, size: 60),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      NewsDetailScreen(article: article),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
