import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/article_model.dart';
import '../cubit/news_cubit.dart';
import 'article_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Article> _searchResults = [];
  bool _isSearching = false;
  String _lastQuery = "";
  String _selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Business',
    'Entertainment',
    'General',
    'Health',
    'Science',
    'Sports',
    'Technology',
  ];

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query == _lastQuery && _selectedCategory == _lastCategory) return;
    _lastQuery = query;
    _lastCategory = _selectedCategory;

    if (query.isEmpty && (_selectedCategory == 'All' || _selectedCategory.isEmpty)) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final cubit = context.read<NewsCubit>();

    if (_selectedCategory != 'All') {
      await cubit.fetchByCategory(_selectedCategory.toLowerCase());
    } else {
      await cubit.fetchTopHeadlines();
    }

    final allArticles = cubit.getAllArticles();

    final filtered = allArticles.where((article) {
      if (query.isEmpty) return true;
      final titleMatch = article.title.toLowerCase().contains(query.toLowerCase());
      final descMatch = article.description.toLowerCase().contains(query.toLowerCase());
      return titleMatch || descMatch;
    }).toList();

    setState(() {
      _searchResults = filtered;
      _isSearching = false;
    });
  }

  String _lastCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Search Articles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search TextField on top
            TextField(
              controller: _searchController,
              onChanged: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filter Dropdown with icon instead of label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  icon: const Icon(Icons.filter_list), // Funnel icon for filter
                  isExpanded: true,
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedCategory = value;
                    });
                    _performSearch();
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Results area
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchController.text.trim().isEmpty && (_selectedCategory == 'All')
                      ? const Center(child: Text('Start typing or select a category to search...'))
                      : _searchResults.isEmpty
                          ? const Center(child: Text('No results found.'))
                          : ListView.builder(
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final article = _searchResults[index];
                                return ListTile(
                                  title: Text(article.title),
                                  subtitle: Text(
                                    article.description.isNotEmpty
                                        ? article.description
                                        : 'No description',
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NewsDetailScreen(article: article),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
