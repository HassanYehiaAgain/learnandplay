import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Service for sending notifications to users in the app
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collections
  final _notificationsCollection = 'notifications';
  final _usersCollection = 'users';
  
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() {
    return _instance;
  }
  
  NotificationService._internal();
  
  /// Send assignment reminders to multiple students
  Future<void> sendAssignmentReminders({
    required List<String> studentIds,
    required String message,
    required String teacherId,
  }) async {
    try {
      if (studentIds.isEmpty) return;
      
      // Get teacher name for the notification
      final teacherDoc = await _firestore.collection(_usersCollection).doc(teacherId).get();
      final teacherName = teacherDoc.exists 
          ? (teacherDoc.data()?['name'] ?? 'Your Teacher') 
          : 'Your Teacher';
      
      // Create a batch write for better performance
      final batch = _firestore.batch();
      
      // Create notifications for each student
      for (final studentId in studentIds) {
        final notificationRef = _firestore
            .collection(_usersCollection)
            .doc(studentId)
            .collection(_notificationsCollection)
            .doc();
        
        batch.set(notificationRef, {
          'title': 'Assignment Reminder',
          'message': message,
          'senderName': teacherName,
          'senderId': teacherId,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'assignment_reminder',
          'relatedId': teacherId, // Using teacherId as a reference
        });
      }
      
      // Commit the batch
      await batch.commit();
      
      // Log this action for monitoring
      await _firestore.collection('notification_logs').add({
        'teacherId': teacherId,
        'teacherName': teacherName,
        'studentCount': studentIds.length,
        'studentIds': studentIds,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'assignment_reminder',
      });
      
      debugPrint('Reminders sent to ${studentIds.length} students');
    } catch (e) {
      debugPrint('Error sending reminders: $e');
      throw Exception('Failed to send reminders: $e');
    }
  }
  
  /// Mark a notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
  
  /// Get notifications for a user
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_notificationsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? '',
          'message': data['message'] ?? '',
          'senderName': data['senderName'] ?? '',
          'senderId': data['senderId'] ?? '',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'isRead': data['isRead'] ?? false,
          'type': data['type'] ?? 'general',
          'relatedId': data['relatedId'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Error getting user notifications: $e');
      return [];
    }
  }
  
  /// Get unread notification count for a user
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_notificationsCollection)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      
      return snapshot.count;
    } catch (e) {
      debugPrint('Error getting unread notification count: $e');
      return 0;
    }
  }
} 