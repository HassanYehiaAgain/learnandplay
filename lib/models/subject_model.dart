import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final Color color;
  final List<String> gradeYears;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.color,
    required this.gradeYears,
  });

  factory Subject.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Subject(
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconName: data['iconName'] ?? 'book',
      color: Color(data['color'] ?? Colors.blue.value),
      gradeYears: List<String>.from(data['gradeYears'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconName': iconName,
      'color': color.value,
      'gradeYears': gradeYears,
    };
  }

  IconData get icon {
    switch (iconName) {
      case 'math':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'language':
        return Icons.language;
      case 'history':
        return Icons.history_edu;
      case 'art':
        return Icons.palette;
      case 'music':
        return Icons.music_note;
      case 'sports':
        return Icons.sports;
      default:
        return Icons.book;
    }
  }
} 