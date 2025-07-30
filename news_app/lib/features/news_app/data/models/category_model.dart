import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;
  bool isSelected;
  int? articleCount;

  Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.articleCount,
  });

  // fromJson factory constructor
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      icon: IconData(json['icon'] ?? 0, fontFamily: 'MaterialIcons'), // assuming stored as int
      color: Color(json['color'] ?? 0xFF000000), // assuming stored as int
      isSelected: json['isSelected'] ?? false,
      articleCount: json['articleCount'],
    );
  }

  // toJson method for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'icon': icon.codePoint,
      'color': color.value,
      'isSelected': isSelected,
      'articleCount': articleCount,
    };
  }

  // Default list of categories
  static List<Category> defaultCategories() {
    return [
      Category(
        id: 'general',
        name: 'general',
        displayName: 'General',
        icon: Icons.public,
        color: Colors.blue,
        isSelected: true,
        articleCount: 0,
      ),
      Category(
        id: 'business',
        name: 'business',
        displayName: 'Business',
        icon: Icons.business_center,
        color: Colors.orange,
      ),
      Category(
        id: 'entertainment',
        name: 'entertainment',
        displayName: 'Entertainment',
        icon: Icons.movie,
        color: Colors.purple,
      ),
      Category(
        id: 'health',
        name: 'health',
        displayName: 'Health',
        icon: Icons.health_and_safety,
        color: Colors.red,
      ),
      Category(
        id: 'science',
        name: 'science',
        displayName: 'Science',
        icon: Icons.science,
        color: Colors.green,
      ),
      Category(
        id: 'sports',
        name: 'sports',
        displayName: 'Sports',
        icon: Icons.sports_soccer,
        color: Colors.teal,
      ),
    ];
  }

  // Category selection logic (toggle selection)
  void toggleSelection() {
    isSelected = !isSelected;
  }
}
