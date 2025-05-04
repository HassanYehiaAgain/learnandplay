import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart';
import 'package:learn_play_level_up_flutter/services/analytics_service.dart';
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';

class GameSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GamificationService _gamificationService = GamificationService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  // Complete a game session
  Future<void> completeGameSession(
    GameSession session, 
    User currentUser, 
    {bool awardXpAndCoins = true}
  ) async {
    try {
      // Save the game session
      final sessionRef = _firestore.collection('game_sessions').doc(session.id);
      await sessionRef.set(session.toFirestore());
      
      if (awardXpAndCoins) {
        // Award XP and coins
        await _gamificationService.addXp(currentUser.uid, session.xpEarned);
        await _gamificationService.addCoins(currentUser.uid, session.coinsEarned);
      }
      
      // Update streak if needed
      await _gamificationService.updateLoginStreak(currentUser.uid);
      
      // Record analytics data
      final gameDoc = await _firestore.collection('games').doc(session.gameId).get();
      final subjectId = gameDoc.data()?['subjectId'] ?? '';
      
      if (subjectId.isNotEmpty) {
        await _analyticsService.recordGameSession(session, currentUser.uid, subjectId);
      }
      
      // Update user's subject progress
      if (subjectId.isNotEmpty) {
        // Update subject progress via UserProgress
        final userProgress = await _gamificationService.getUserProgress(currentUser.uid);
        if (userProgress != null && !userProgress.subjectProgress.containsKey(subjectId)) {
          userProgress.subjectProgress[subjectId] = SubjectProgress(
            subjectId: subjectId,
            personalBests: {},
          );
          
          // Increment games completed count
          userProgress.subjectProgress[subjectId]!.gamesCompleted++;
          
          // Update perfect scores if applicable
          if (session.scorePercentage >= 90) {
            userProgress.subjectProgress[subjectId]!.perfectScores++;
          }
          
          // Update in Firestore
          await _firestore.collection('user_progress').doc(currentUser.uid).update({
            'subjectProgress.$subjectId.gamesCompleted': userProgress.subjectProgress[subjectId]!.gamesCompleted,
            'subjectProgress.$subjectId.perfectScores': userProgress.subjectProgress[subjectId]!.perfectScores,
          });
        }
      }
    } catch (e) {
      debugPrint('Error completing game session: $e');
      rethrow;
    }
  }
} 