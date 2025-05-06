import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user.dart';
import 'game.dart';
import 'game_completion.dart';

/// Helper class for Firestore operations
class FirestoreHelpers {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  static CollectionReference<Map<String, dynamic>> get usersCollection => 
      _firestore.collection('users');
  
  static CollectionReference<Map<String, dynamic>> get gamesCollection => 
      _firestore.collection('games');
  
  static CollectionReference<Map<String, dynamic>> getCompletionsCollection(String gameId) => 
      _firestore.collection('games').doc(gameId).collection('completions');
  
  // User operations
  static Future<AppUser?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    
    final doc = await usersCollection.doc(user.uid).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['uid'] = doc.id; // Ensure uid is included
    return AppUser.fromJson(data);
  }
  
  static Future<AppUser?> getUserById(String uid) async {
    final doc = await usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    data['uid'] = doc.id; // Ensure uid is included
    return AppUser.fromJson(data);
  }
  
  // Game operations
  static Future<List<Game>> getGamesByOwner(String ownerUid) async {
    final snapshot = await gamesCollection
        .where('ownerUid', isEqualTo: ownerUid)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Game.fromJson(data);
    }).toList();
  }
  
  static Future<List<Game>> getGamesBySubject(String subject) async {
    final snapshot = await gamesCollection
        .where('subject', isEqualTo: subject)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Game.fromJson(data);
    }).toList();
  }
  
  static Future<List<Game>> getGamesByGradeYear(int gradeYear) async {
    final snapshot = await gamesCollection
        .where('gradeYears', arrayContains: gradeYear)
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Game.fromJson(data);
    }).toList();
  }
  
  // Game completion operations
  static Future<List<GameCompletion>> getCompletionsByUser(String gameId, String uid) async {
    final snapshot = await getCompletionsCollection(gameId)
        .where('uid', isEqualTo: uid)
        .orderBy('completedAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['gameId'] = gameId;
      return GameCompletion.fromJson(data);
    }).toList();
  }
  
  static Future<List<GameCompletion>> getAllCompletions(String gameId) async {
    final snapshot = await getCompletionsCollection(gameId)
        .orderBy('completedAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['gameId'] = gameId;
      return GameCompletion.fromJson(data);
    }).toList();
  }
  
  // Analytics
  static Future<Map<String, dynamic>> getGameStats(String gameId) async {
    final completions = await getAllCompletions(gameId);
    
    if (completions.isEmpty) {
      return {
        'totalPlays': 0,
        'averageScore': 0,
        'highScore': 0,
      };
    }
    
    final totalPlays = completions.length;
    final totalScore = completions.fold(0, (sum, item) => sum + item.score);
    final averageScore = totalScore / totalPlays;
    final highScore = completions.map((e) => e.score).reduce((a, b) => a > b ? a : b);
    
    return {
      'totalPlays': totalPlays,
      'averageScore': averageScore,
      'highScore': highScore,
    };
  }
} 