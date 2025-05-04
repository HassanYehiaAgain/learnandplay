import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/game_template_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/subject_model.dart';

enum LoadingState { initial, loading, loaded, error }

class GameTemplatesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  Subject? _selectedSubject;
  int? _selectedGradeYear;

  UserModel? get currentUser => _currentUser;
  Subject? get selectedSubject => _selectedSubject;
  int? get selectedGradeYear => _selectedGradeYear;

  // Templates state
  List<UniversalGameTemplateInfo> _templates = [];
  List<UniversalGameTemplateInfo> get templates => _templates;
  
  // Loading state
  LoadingState _loadingState = LoadingState.initial;
  LoadingState get loadingState => _loadingState;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  // Selected template
  UniversalGameTemplateInfo? _selectedTemplate;
  UniversalGameTemplateInfo? get selectedTemplate => _selectedTemplate;
  
  // Currently created games
  List<GameTemplate> _createdGames = [];
  List<GameTemplate> get createdGames => _createdGames;
  bool _isLoadingCreatedGames = false;
  bool get isLoadingCreatedGames => _isLoadingCreatedGames;
  
  // Constructor
  GameTemplatesProvider() {
    loadTemplates();
  }
  
  // Load all templates
  void loadTemplates() {
    _loadingState = LoadingState.loading;
    notifyListeners();
    
    try {
      _templates = getAllTemplates();
      _loadingState = LoadingState.loaded;
    } catch (e) {
      _loadingState = LoadingState.error;
      _errorMessage = 'Failed to load templates: $e';
    }
    
    notifyListeners();
  }
  
  // Select a template
  void selectTemplate(String templateType) {
    _selectedTemplate = _templates.firstWhere(
      (template) => template.templateType == templateType,
      orElse: () => throw Exception('Template not found: $templateType'),
    );
    notifyListeners();
  }
  
  // Get created games for the current user
  Future<void> loadCreatedGames(String teacherId) async {
    _isLoadingCreatedGames = true;
    notifyListeners();
    
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('game_templates')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      _createdGames = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        switch (data['templateType']) {
          case 'drag_drop_categories':
            return DragDropCategoriesGame.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
          case 'true_false':
            return TrueFalseGame.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
          default:
            throw Exception('Unknown template type: ${data['templateType']}');
        }
      }).toList();
      
      _isLoadingCreatedGames = false;
    } catch (e) {
      _isLoadingCreatedGames = false;
      _errorMessage = 'Failed to load created games: $e';
    }
    
    notifyListeners();
  }
  
  // Create a new game in Firebase
  Future<bool> createGame(Map<String, dynamic> gameData) async {
    try {
      await _firestore.collection('game_templates').add(gameData);
      // Reload created games
      if (gameData['teacherId'] != null) {
        await loadCreatedGames(gameData['teacherId']);
      }
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create game: $e';
      return false;
    }
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void setSelectedSubject(Subject subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setSelectedGradeYear(int gradeYear) {
    _selectedGradeYear = gradeYear;
    notifyListeners();
  }

  Future<void> saveGame(GameTemplate game) async {
    if (_currentUser == null) {
      throw Exception('No user selected');
    }
    if (_selectedSubject == null) {
      throw Exception('No subject selected');
    }
    if (_selectedGradeYear == null) {
      throw Exception('No grade year selected');
    }

    final gameData = game.toFirestore();
    await _firestore
        .collection('game_templates')
        .add(gameData);

    notifyListeners();
  }

  Future<List<GameTemplate>> getGamesForTeacher() async {
    if (_currentUser == null) {
      throw Exception('No user selected');
    }

    final snapshot = await _firestore
        .collection('game_templates')
        .where('teacherId', isEqualTo: _currentUser!.id)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      switch (data['templateType']) {
        case 'drag_drop_categories':
          return DragDropCategoriesGame.fromFirestore(doc);
        case 'true_false':
          return TrueFalseGame.fromFirestore(doc);
        default:
          throw Exception('Unknown template type: ${data['templateType']}');
      }
    }).toList();
  }

  Future<List<GameTemplate>> getGamesForStudent() async {
    if (_selectedSubject == null || _selectedGradeYear == null) {
      throw Exception('Subject and grade year must be selected');
    }

    final snapshot = await _firestore
        .collection('game_templates')
        .where('subjectId', isEqualTo: _selectedSubject!.id)
        .where('gradeYear', isEqualTo: _selectedGradeYear)
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      switch (data['templateType']) {
        case 'drag_drop_categories':
          return DragDropCategoriesGame.fromFirestore(doc);
        case 'true_false':
          return TrueFalseGame.fromFirestore(doc);
        default:
          throw Exception('Unknown template type: ${data['templateType']}');
      }
    }).toList();
  }

  // Get predefined list of all available universal game templates
  static List<UniversalGameTemplateInfo> getAllTemplates() {
    return [
      UniversalGameTemplateInfo(
        type: 'drag_drop_categories',
        title: 'Drag & Drop Categories',
        description: 'Sort items into their correct categories by dragging and dropping',
        icon: Icons.category,
        color: Colors.blue,
        tags: ['interactive', 'categorization'],
        estimatedDuration: 15,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/create/drag-drop-categories',
      ),
      UniversalGameTemplateInfo(
        type: 'true_false',
        title: 'True/False Challenge',
        description: 'Create a series of true/false statements with explanations',
        icon: Icons.check_circle,
        color: Colors.green,
        tags: ['quiz', 'assessment'],
        estimatedDuration: 10,
        maxPoints: 100,
        xpReward: 50,
        coinReward: 25,
        routePath: '/create/true-false',
      ),
    ];
  }
} 