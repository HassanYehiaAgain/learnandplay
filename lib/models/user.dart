import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String role; // 'student' or 'teacher'
  final DateTime createdAt;
  final List<String>? enrolledGames;
  final List<String>? createdGames;
  final Map<String, dynamic>? stats;
  final List<String>? badges;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    required this.role,
    required this.createdAt,
    this.enrolledGames,
    this.createdGames,
    this.stats,
    this.badges,
  });

  // Create a factory constructor for creating a new User instance from JSON
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Create a method for converting User instance to JSON
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Create a method for copying User instance with some changes
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    String? role,
    DateTime? createdAt,
    List<String>? enrolledGames,
    List<String>? createdGames,
    Map<String, dynamic>? stats,
    List<String>? badges,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      enrolledGames: enrolledGames ?? this.enrolledGames,
      createdGames: createdGames ?? this.createdGames,
      stats: stats ?? this.stats,
      badges: badges ?? this.badges,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, name: $name, role: $role)';
  }
} 