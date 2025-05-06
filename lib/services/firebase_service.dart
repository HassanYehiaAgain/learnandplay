import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _usersCollection => 
      _firestore.collection('users');
  
  CollectionReference<Map<String, dynamic>> get _subjectsCollection => 
      _firestore.collection('subjects');
  
  CollectionReference<Map<String, dynamic>> get _gamesCollection => 
      _firestore.collection('educational_games');
  
  CollectionReference<Map<String, dynamic>> get _progressCollection => 
      _firestore.collection('game_progress');

  // USER OPERATIONS
  Future<FirebaseUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    final docSnap = await _usersCollection.doc(user.uid).get();
    if (!docSnap.exists) return null;
    
    return FirebaseUser.fromFirestore(
      docSnap, 
      null
    );
  }

  Future<void> updateUserStats({
    required String userId,
    int? addXp,
    int? addCoins,
    int? newStreak,
    List<String>? badgesToAdd,
  }) async {
    final userRef = _usersCollection.doc(userId);
    final userDoc = await userRef.get();
    
    if (!userDoc.exists) {
      throw Exception('User not found');
    }
    
    final updates = <String, dynamic>{};
    
    if (addXp != null) {
      updates['xp'] = FieldValue.increment(addXp);
    }
    
    if (addCoins != null) {
      updates['coins'] = FieldValue.increment(addCoins);
    }
    
    if (newStreak != null) {
      updates['currentStreak'] = newStreak;
      updates['longestStreak'] = FieldValue.arrayUnion([newStreak]);
    }
    
    if (badgesToAdd != null && badgesToAdd.isNotEmpty) {
      updates['badges'] = FieldValue.arrayUnion(badgesToAdd);
    }
    
    if (updates.isNotEmpty) {
      await userRef.update(updates);
    }
  }

  // Add methods for updating teacher and student profiles
  Future<void> updateTeacherProfile({
    required String teacherId,
    required String name,
    required List<int> teachingGradeYears,
    required List<String> teachingSubjects,
  }) async {
    await _usersCollection.doc(teacherId).update({
      'name': name,
      'teachingGradeYears': teachingGradeYears,
      'teachingSubjects': teachingSubjects,
    });
  }
  
  Future<void> updateStudentProfile({
    required String studentId,
    required String name,
    required int studentGradeYear,
  }) async {
    await _usersCollection.doc(studentId).update({
      'name': name,
      'studentGradeYear': studentGradeYear,
    });
  }

  // SUBJECT/CLASS OPERATIONS
  Future<List<Subject>> getTeacherSubjects(String teacherId) async {
    final querySnap = await _subjectsCollection
        .where('teacherId', isEqualTo: teacherId)
        .get();
    
    return querySnap.docs
        .map((doc) => Subject.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>, 
              null
            ))
        .toList();
  }

  Future<List<Subject>> getStudentSubjects(String studentId) async {
    try {
      final querySnap = await _subjectsCollection
          .where('studentIds', arrayContains: studentId)
          .get();
      
      return querySnap.docs
          .map((doc) => Subject.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>, 
                null
              ))
          .toList();
    } catch (e) {
      // Handle the missing index error specifically
      if (e.toString().contains('failed-precondition') && 
          e.toString().contains('requires an index')) {
        print('Firebase index error: $e');
        print('Please create the required index in your Firebase console.');
        // Return empty list instead of throwing to prevent crashes
        return [];
      }
      // Re-throw other errors
      rethrow;
    }
  }

  Future<String> createSubject(Subject subject) async {
    final docRef = await _subjectsCollection.add(subject.toFirestore());
    return docRef.id;
  }

  Future<void> addStudentToSubject(
      String subjectId, String studentId) async {
    await _subjectsCollection.doc(subjectId).update({
      'studentIds': FieldValue.arrayUnion([studentId]),
    });
    
    // Also update user's enrolledClasses
    await _usersCollection.doc(studentId).update({
      'enrolledClasses': FieldValue.arrayUnion([subjectId]),
    });
  }

  // GAME OPERATIONS
  Future<String> createGame(EducationalGame game) async {
    final docRef = await _gamesCollection.add(game.toFirestore());
    return docRef.id;
  }

  Future<List<EducationalGame>> getTeacherGames(String teacherId) async {
    final querySnap = await _gamesCollection
        .where('teacherId', isEqualTo: teacherId)
        .where('isActive', isEqualTo: true)
        .get();
    
    return querySnap.docs
        .map((doc) => EducationalGame.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>, 
              null
            ))
        .toList();
  }

  Future<List<EducationalGame>> getSubjectGames(String subjectId) async {
    final querySnap = await _gamesCollection
        .where('subjectId', isEqualTo: subjectId)
        .where('isActive', isEqualTo: true)
        .get();
    
    return querySnap.docs
        .map((doc) => EducationalGame.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>, 
              null
            ))
        .toList();
  }

  Future<List<EducationalGame>> getGamesForStudent(String studentId) async {
    try {
      // First get all subjects the student is enrolled in
      final subjects = await getStudentSubjects(studentId);
      final subjectIds = subjects.map((s) => s.id).toList();
      
      if (subjectIds.isEmpty) {
        print('No subjects found for student: $studentId');
        return [];
      }
      
      // Then get all active games for those subjects
      // Note: Firestore doesn't directly support "IN" queries with "arrayContains"
      // so we need to make separate queries for each subject
      final List<EducationalGame> games = [];
      
      for (final subjectId in subjectIds) {
        try {
          final subjectGames = await getSubjectGames(subjectId);
          games.addAll(subjectGames);
        } catch (e) {
          print('Error fetching games for subject $subjectId: $e');
          // Continue with other subjects if one fails
          continue;
        }
      }
      
      // Filter out any expired games
      final now = DateTime.now();
      return games.where((game) => 
        game.isActive && game.dueDate.isAfter(now)
      ).toList();
    } catch (e) {
      print('Error in getGamesForStudent: $e');
      // Return empty list instead of crashing
      return [];
    }
  }

  Future<void> deactivateExpiredGames() async {
    final now = DateTime.now();
    
    // Get all active games that are past their due date
    final querySnap = await _gamesCollection
        .where('isActive', isEqualTo: true)
        .where('dueDate', isLessThan: now)
        .get();
    
    // Create a batch to update all games in one go
    final batch = _firestore.batch();
    
    for (final doc in querySnap.docs) {
      batch.update(doc.reference, {'isActive': false});
    }
    
    // Commit the batch
    await batch.commit();
  }

  // GAME PROGRESS OPERATIONS
  Future<String> startGameSession({
    required String gameId,
    required String studentId,
    required String subjectId,
  }) async {
    final gameProgress = GameProgress(
      id: '', // Will be set by Firestore
      gameId: gameId,
      studentId: studentId,
      subjectId: subjectId,
      startedAt: DateTime.now(),
      completedAt: null,
      score: 0,
      totalPossibleScore: 0,
      completionPercentage: 0,
      answers: [],
      xpEarned: 0,
      coinsEarned: 0,
      badgesEarned: [],
    );
    
    final docRef = await _progressCollection.add(gameProgress.toFirestore());
    return docRef.id;
  }

  Future<void> submitGameAnswer({
    required String progressId,
    required QuestionAnswer answer,
  }) async {
    await _progressCollection.doc(progressId).update({
      'answers': FieldValue.arrayUnion([answer.toMap()]),
      'score': FieldValue.increment(answer.pointsEarned),
    });
  }

  Future<void> completeGameSession({
    required String progressId,
    required int totalScore,
    required int totalPossibleScore,
    required double completionPercentage,
    required int xpEarned,
    required int coinsEarned,
    required List<String> badgesEarned,
  }) async {
    final progressRef = _progressCollection.doc(progressId);
    final progressDoc = await progressRef.get();
    
    if (!progressDoc.exists) {
      throw Exception('Game progress not found');
    }
    
    final data = progressDoc.data() as Map<String, dynamic>;
    final studentId = data['studentId'] as String;
    
    // Update the progress document
    await progressRef.update({
      'completedAt': FieldValue.serverTimestamp(),
      'score': totalScore,
      'totalPossibleScore': totalPossibleScore,
      'completionPercentage': completionPercentage,
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
      'badgesEarned': badgesEarned,
    });
    
    // Update the user's stats
    await updateUserStats(
      userId: studentId,
      addXp: xpEarned,
      addCoins: coinsEarned,
      badgesToAdd: badgesEarned,
    );
  }

  Future<List<GameProgress>> getStudentGameProgress(String studentId) async {
    try {
      final querySnap = await _progressCollection
          .where('studentId', isEqualTo: studentId)
          .orderBy('startedAt', descending: true)
          .get();
      
      return querySnap.docs
          .map((doc) => GameProgress.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>, 
                null
              ))
          .toList();
    } catch (e) {
      print('Error in getStudentGameProgress: $e');
      return [];
    }
  }

  Future<List<GameProgress>> getGameProgressForSubject(
      String subjectId, {bool completedOnly = false}) async {
    Query<Map<String, dynamic>> query = _progressCollection
        .where('subjectId', isEqualTo: subjectId);
    
    if (completedOnly) {
      query = query.where('completedAt', isNull: false);
    }
    
    final querySnap = await query.get();
    
    return querySnap.docs
        .map((doc) => GameProgress.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>, 
              null
            ))
        .toList();
  }

  // Get user by ID
  Future<FirebaseUser?> getUserById(String userId) async {
    try {
      final docSnap = await _usersCollection.doc(userId).get();
      
      if (!docSnap.exists) return null;
      
      return FirebaseUser.fromFirestore(
        docSnap, 
        null
      );
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }
} 