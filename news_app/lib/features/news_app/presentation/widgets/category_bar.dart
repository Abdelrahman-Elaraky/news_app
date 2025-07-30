import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

class CategoryBar extends StatefulWidget {
  final List<Category> categories;
  final Function(String categoryId) onCategoryTap;

  const CategoryBar({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  late List<Category> allCategories;
  List<Category> filteredCategories = [];
  String query = '';
  String selectedCategoryId = '';

  @override
  void initState() {
    super.initState();
    allCategories = widget.categories;
    filteredCategories = allCategories;
    selectedCategoryId = allCategories.firstWhere((cat) => cat.isSelected, orElse: () => allCategories.first).id;
  }

  void _filterCategories(String searchQuery) {
    setState(() {
      query = searchQuery;
      filteredCategories = allCategories
          .where((category) =>
              category.displayName.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void _onTap(String categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      for (var category in allCategories) {
        category.isSelected = category.id == categoryId;
      }
      filteredCategories = query.isEmpty
          ? allCategories
          : allCategories
              .where((category) => category.displayName.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });

    widget.onCategoryTap(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            onChanged: _filterCategories,
            decoration: InputDecoration(
              hintText: 'Search categories...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          child: SizedBox(
            height: 48,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(overscroll: false),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredCategories.length,
                itemBuilder: (_, index) {
                  final category = filteredCategories[index];
                  final isSelected = category.id == selectedCategoryId;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? category.color.withOpacity(0.2)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _onTap(category.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            Icon(category.icon, size: 18, color: category.color),
                            const SizedBox(width: 6),
                            Text(
                              category.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? category.color
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
