
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

  // Manual implementation of fromJson
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      createdAt: json['createdAt'] is DateTime 
          ? json['createdAt'] 
          : DateTime.parse(json['createdAt'] as String),
      enrolledGames: (json['enrolledGames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdGames: (json['createdGames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      stats: json['stats'] as Map<String, dynamic>?,
      badges: (json['badges'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  // Manual implementation of toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'enrolledGames': enrolledGames,
      'createdGames': createdGames,
      'stats': stats,
      'badges': badges,
    };
  }

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