import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_app_bar.dart';
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import '../../data/models/article_model.dart';
import '../widgets/error_empty_state.dart';

class HomeScreen extends StatefulWidget {
  final String email;
  final String? username;

  const HomeScreen({super.key, required this.email, this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late ScrollController _scrollController;
  late NewsCubit _newsCubit;
  DateTime? _lastRefreshedAt;
  int bookmarkedCount = 0;

  String get displayName =>
      widget.username?.trim().isNotEmpty == true
          ? widget.username!
          : widget.email.split('@')[0];

  @override
  void initState() {
    super.initState();
    _newsCubit = context.read<NewsCubit>();
    _newsCubit.fetchTopHeadlines();

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

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('rememberedEmail');
    await prefs.remove('rememberedPassword');

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _handleRefresh() async {
    try {
      await _newsCubit.refreshNews();
      setState(() {
        _lastRefreshedAt = DateTime.now();
      });
      // Refresh bookmark count as well, in case of bookmark changes
      await _loadBookmarkCount();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refresh failed: $e')),
        );
      }
    }
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
                displayName,
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
                onTap: () {
                  // TODO: Navigate to bookmarks screen
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
        username: displayName,
        notificationCount: 3,
        onDrawerTap: () => _scaffoldKey.currentState?.openDrawer(),
        onSearchTap: () {
          // TODO: Implement search functionality
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement search or other action
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
          // Update bookmarks count if necessary
          if (state is NewsLoaded) {
            _loadBookmarkCount();
          }
        },
        builder: (context, state) {
          if (state is NewsEmpty) {
            return ErrorEmptyState(
              image: 'assets/images/empty_state.png',
              message: 'No articles found. Try again later!',
              buttonText: 'Refresh',
              onRetry: () => _newsCubit.fetchTopHeadlines(),
            );
          }

          final articles = state is NewsLoaded ? state.articles : <Article>[];
          final hasMore = state is NewsLoaded ? state.hasMore : false;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Welcome back, $displayName',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (_lastRefreshedAt != null)
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    'Last updated: ${DateFormat('MMM d, hh:mm a').format(_lastRefreshedAt!)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: theme.primaryColor,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  displacement: 60,
                  child: ListView.builder(
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
                        subtitle: Text(article.description ?? ''),
                        leading: article.imageUrl != null
                            ? Image.network(
                                article.imageUrl!,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : null,
                        onTap: () {
                          // TODO: Open article detail page
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
