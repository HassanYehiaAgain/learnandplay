import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  late Future<List<Game>> _gamesFuture;
  
  @override
  void initState() {
    super.initState();
    _loadGames();
  }
  
  void _loadGames() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _gamesFuture = FirestoreHelpers.getGamesByOwner(user.uid);
    } else {
      _gamesFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'L&P',
              style: TextStyle(
                fontFamily: 'Retropix',
                fontSize: 24,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/profile/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  context.go('/');
                }
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadGames();
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Games Created',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Game>>(
                  future: _gamesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading games: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    
                    final games = snapshot.data ?? [];
                    
                    if (games.isEmpty) {
                      return const Center(
                        child: Text(
                          'No games created yet.\nTap + to create your first game!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return GameCard(game: game);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/game/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go('/game/${game.id}/students'),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _getTemplateIcon(game.template),
                ],
              ),
              const SizedBox(height: 8),
              Text('Subject: ${game.subject}'),
              const SizedBox(height: 4),
              Text('Grade Years: ${game.gradeYears.join(", ")}'),
              const SizedBox(height: 4),
              Text('Questions: ${game.questions.length}'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => context.go('/game/${game.id}'),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => context.go('/game/${game.id}/students'),
                    icon: const Icon(Icons.people),
                    label: const Text('Students'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getTemplateIcon(GameTemplate template) {
    IconData iconData;
    switch (template) {
      case GameTemplate.trueFalse:
        iconData = Icons.check_circle_outline;
        break;
      case GameTemplate.dragDrop:
        iconData = Icons.drag_indicator;
        break;
      case GameTemplate.matching:
        iconData = Icons.compare_arrows;
        break;
      case GameTemplate.memory:
        iconData = Icons.grid_view;
        break;
      case GameTemplate.flashCard:
        iconData = Icons.flip;
        break;
      case GameTemplate.fillBlank:
        iconData = Icons.text_fields;
        break;
      case GameTemplate.hangman:
        iconData = Icons.sports_score;
        break;
      case GameTemplate.crossword:
        iconData = Icons.apps;
        break;
    }
    return Icon(iconData, size: 24);
  }
} 