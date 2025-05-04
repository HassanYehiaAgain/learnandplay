import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:learn_play_level_up_flutter/services/local_storage_service.dart';

enum UserRole { teacher, student }

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) => AuthService());
final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService should be provided by the app');
});

class GameListPage extends ConsumerStatefulWidget {
  const GameListPage({super.key});

  @override
  ConsumerState<GameListPage> createState() => _GameListPageState();
}

class _GameListPageState extends ConsumerState<GameListPage> {
  List<EducationalGame> _games = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final firebaseService = ref.read(firebaseServiceProvider);
      final localStorageService = ref.read(localStorageServiceProvider);

      if (authService.currentUser == null) {
        throw Exception('User not logged in');
      }

      List<EducationalGame> games;
      if (authService.currentUser!.role == 'teacher') {
        // Try Firebase first
        try {
          games = await firebaseService.getTeacherGames(authService.currentUser!.id);
        } catch (e) {
          // Fall back to local storage
          games = await localStorageService.getTeacherGames(authService.currentUser!.id);
        }
      } else {
        // Try Firebase first
        try {
          games = await firebaseService.getGamesForStudent(authService.currentUser!.id);
        } catch (e) {
          // Fall back to local storage
          games = await localStorageService.getStudentGames(authService.currentUser!.id);
        }
      }

      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadGames,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_games.isEmpty) {
      return const Center(
        child: Text('No games found'),
      );
    }

    return ListView.builder(
      itemCount: _games.length,
      itemBuilder: (context, index) {
        final game = _games[index];
        return ListTile(
          title: Text(game.title),
          subtitle: Text(game.description),
          onTap: () {
            // TODO: Navigate to game details
          },
        );
      },
    );
  }
} 