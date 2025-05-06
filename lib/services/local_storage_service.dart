import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';

class LocalStorageService {
  static const String _gamesKey = 'local_games';
  static const String _teacherSubjectsKey = 'teacher_subjects';
  static const String _teacherGradeYearsKey = 'teacher_grade_years';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Save a game locally
  Future<void> saveGame(EducationalGame game) async {
    final games = await getGames();
    games.add(game);
    await _prefs.setString('games', jsonEncode(games.map((g) => g.toJson()).toList()));
  }

  // Get all games
  Future<List<EducationalGame>> getGames() async {
    final gamesJson = _prefs.getString('games');
    if (gamesJson == null) return [];
    
    final List<dynamic> gamesList = jsonDecode(gamesJson);
    return gamesList.map((game) => EducationalGame.fromJson(game)).toList();
  }

  // Get games for a specific teacher
  Future<List<EducationalGame>> getTeacherGames(String teacherId) async {
    final games = await getGames();
    return games.where((game) => game.teacherId == teacherId).toList();
  }

  // Get games for a specific student based on their grade year
  Future<List<EducationalGame>> getStudentGames(String studentId) async {
    final games = await getGames();
    return games.where((game) => game.isActive).toList(); // For now, return all active games
  }

  // Save teacher subjects
  Future<void> saveTeacherSubjects(String teacherId, List<Subject> subjects) async {
    await _prefs.setString(
      'teacher_${teacherId}_subjects',
      jsonEncode(subjects.map((s) => s.toJson()).toList()),
    );
  }

  // Get teacher subjects
  Future<List<Subject>> getTeacherSubjects(String teacherId) async {
    final subjectsJson = _prefs.getString('teacher_${teacherId}_subjects');
    if (subjectsJson == null) return [];
    
    final List<dynamic> subjectsList = jsonDecode(subjectsJson);
    return subjectsList.map((subject) => Subject.fromJson(subject)).toList();
  }

  // Save teacher grade years
  Future<void> saveTeacherGradeYears(String teacherId, List<int> gradeYears) async {
    await _prefs.setString(
      'teacher_${teacherId}_grade_years',
      jsonEncode(gradeYears),
    );
  }

  // Get teacher grade years
  Future<List<int>> getTeacherGradeYears(String teacherId) async {
    final gradeYearsJson = _prefs.getString('teacher_${teacherId}_grade_years');
    if (gradeYearsJson == null) return [];
    
    final List<dynamic> gradeYearsList = jsonDecode(gradeYearsJson);
    return gradeYearsList.map((year) => year as int).toList();
  }
} 