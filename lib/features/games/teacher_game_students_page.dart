import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';

class TeacherGameStudentsPage extends StatefulWidget {
  final String gameId;
  
  const TeacherGameStudentsPage({
    super.key,
    required this.gameId,
  });

  @override
  State<TeacherGameStudentsPage> createState() => _TeacherGameStudentsPageState();
}

class _TeacherGameStudentsPageState extends State<TeacherGameStudentsPage> {
  bool _isLoading = true;
  Game? _game;
  List<GameCompletion> _completions = [];
  Map<String, AppUser> _students = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      // In a real implementation, these would be loaded from Firestore
      // For now, this is a placeholder
      await Future.delayed(const Duration(seconds: 1));
      
      // This is where we would fetch the actual game and completions
      // final gameDoc = await FirebaseFirestore.instance
      //     .collection('games')
      //     .doc(widget.gameId)
      //     .get();
      
      // final completions = await FirestoreHelpers.getAllCompletions(widget.gameId);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          // _game = Game.fromFirestore(gameDoc);
          // _completions = completions;
        });
      }
      
      // Load student data
      // await _loadStudentData();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading game data: $e')),
        );
      }
    }
  }
  
  Future<void> _loadStudentData() async {
    try {
      // In a real implementation, this would fetch student data for all completions
      final studentIds = _completions.map((c) => c.uid).toSet().toList();
      
      for (final id in studentIds) {
        final user = await FirestoreHelpers.getUserById(id);
        if (user != null) {
          setState(() {
            _students[id] = user;
          });
        }
      }
    } catch (e) {
      // Handle errors
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _game != null 
            ? Text('Students - ${_game!.title}') 
            : Text('Students - Game ${widget.gameId}'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _game == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Game not found or not yet implemented'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Progress',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // This would be a real list of completions in the full implementation
                  const Center(
                    child: Text(
                      'Student progress tracking will be implemented in future updates',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Center(
                    child: ElevatedButton(
                      onPressed: () => context.go('/dashboard'),
                      child: const Text('Back to Dashboard'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 