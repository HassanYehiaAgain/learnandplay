import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:learn_play_level_up_flutter/models/game.dart';

class GameService with ChangeNotifier {
  List<Game> _games = [];
  Game? _currentGame;
  bool _isLoading = false;
  String? _error;
  final String _baseUrl = 'https://api.example.com'; // Replace with actual API URL
  
  List<Game> get games => _games;
  Game? get currentGame => _currentGame;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all games
  Future<void> fetchGames({String? category, String? searchQuery}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }
      
      final uri = Uri.parse('$_baseUrl/games').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _games = data.map((game) => Game.fromJson(game)).toList();
        _isLoading = false;
        notifyListeners();
      } else {
        _error = 'Failed to load games: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error fetching games: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a specific game by ID
  Future<Game?> fetchGameById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/games/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentGame = Game.fromJson(data);
        _isLoading = false;
        notifyListeners();
        return _currentGame;
      } else {
        _error = 'Failed to load game: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error fetching game: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Create a new game
  Future<Game?> createGame(Map<String, dynamic> gameData, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/games'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(gameData),
      );
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newGame = Game.fromJson(data);
        
        // Add to local games list
        _games.add(newGame);
        _currentGame = newGame;
        
        _isLoading = false;
        notifyListeners();
        return newGame;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to create game';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error creating game: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update an existing game
  Future<Game?> updateGame(String id, Map<String, dynamic> gameData, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/games/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(gameData),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedGame = Game.fromJson(data);
        
        // Update in local games list
        final index = _games.indexWhere((game) => game.id == id);
        if (index != -1) {
          _games[index] = updatedGame;
        }
        
        _currentGame = updatedGame;
        _isLoading = false;
        notifyListeners();
        return updatedGame;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to update game';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error updating game: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete a game
  Future<bool> deleteGame(String id, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/games/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local games list
        _games.removeWhere((game) => game.id == id);
        
        // If current game is the deleted one, clear it
        if (_currentGame?.id == id) {
          _currentGame = null;
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to delete game';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error deleting game: $e';
      debugPrint(_error);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Rate a game
  Future<bool> rateGame(String gameId, int rating, String? comment, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/games/$gameId/reviews'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );
      
      if (response.statusCode == 201) {
        // Refresh game details to get updated rating
        await fetchGameById(gameId);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _error = data['message'] ?? 'Failed to rate game';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error rating game: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  // Get featured games
  Future<List<Game>> getFeaturedGames() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/games/featured'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((game) => Game.fromJson(game)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching featured games: $e');
      return [];
    }
  }

  // Get game categories
  Future<List<String>> getGameCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/games/categories'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((category) => category.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching game categories: $e');
      return [];
    }
  }
} 