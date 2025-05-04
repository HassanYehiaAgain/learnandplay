import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String role; // 'teacher' or 'student'
  final String? avatarUrl;
  final int level;
  final int xp;
  final int coins;
  final List<String> badges;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    this.level = 1,
    this.xp = 0,
    this.coins = 0,
    this.badges = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return UserModel(
      id: snapshot.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'student',
      avatarUrl: data['avatarUrl'],
      level: data['level'] ?? 1,
      xp: data['xp'] ?? 0,
      coins: data['coins'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'avatarUrl': avatarUrl,
      'level': level,
      'xp': xp,
      'coins': coins,
      'badges': badges,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? role,
    String? avatarUrl,
    int? level,
    int? xp,
    int? coins,
    List<String>? badges,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      badges: badges ?? this.badges,
    );
  }
} 