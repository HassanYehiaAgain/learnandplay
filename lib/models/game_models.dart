import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CategoryItem {
  final String id;
  final String name;
  final String? description;
  final Color color;

  CategoryItem({
    String? id,
    required this.name,
    this.description,
    required this.color,
  }) : id = id ?? const Uuid().v4();

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? '',
      description: map['description'],
      color: Color(map['color'] ?? Colors.blue.value),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
    };
  }
}

class DraggableItem {
  final String id;
  final String content;
  final String contentType;
  final String correctCategoryId;
  final String? hint;

  DraggableItem({
    String? id,
    required this.content,
    required this.contentType,
    required this.correctCategoryId,
    this.hint,
  }) : id = id ?? const Uuid().v4();

  factory DraggableItem.fromMap(Map<String, dynamic> map) {
    return DraggableItem(
      id: map['id'] ?? const Uuid().v4(),
      content: map['content'] ?? '',
      contentType: map['contentType'] ?? 'text',
      correctCategoryId: map['correctCategoryId'] ?? '',
      hint: map['hint'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'contentType': contentType,
      'correctCategoryId': correctCategoryId,
      'hint': hint,
    };
  }
}

class SortingCategory {
  final String id;
  final String name;
  final String description;
  final Color color;

  SortingCategory({
    String? id,
    required this.name,
    required this.description,
    required this.color,
  }) : id = id ?? const Uuid().v4();

  factory SortingCategory.fromMap(Map<String, dynamic> map) {
    return SortingCategory(
      id: map['id'] ?? const Uuid().v4(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      color: Color(map['color'] ?? Colors.blue.value),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color.value,
    };
  }
}

class SortingItem {
  final String id;
  final String content;
  final String contentType;
  final List<String> correctCategoryIds;
  final String? hint;

  SortingItem({
    String? id,
    required this.content,
    required this.contentType,
    required this.correctCategoryIds,
    this.hint,
  }) : id = id ?? const Uuid().v4();

  factory SortingItem.fromMap(Map<String, dynamic> map) {
    return SortingItem(
      id: map['id'] ?? const Uuid().v4(),
      content: map['content'] ?? '',
      contentType: map['contentType'] ?? 'text',
      correctCategoryIds: List<String>.from(map['correctCategoryIds'] ?? []),
      hint: map['hint'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'contentType': contentType,
      'correctCategoryIds': correctCategoryIds,
      'hint': hint,
    };
  }
} 