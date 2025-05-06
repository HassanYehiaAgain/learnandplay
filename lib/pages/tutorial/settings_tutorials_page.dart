import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/tutorial_models.dart';
import 'package:learn_play_level_up_flutter/services/tutorial_service.dart';
import 'package:learn_play_level_up_flutter/pages/tutorial/game_tutorial_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Settings page for accessing and managing tutorials
class SettingsTutorialsPage extends StatefulWidget {
  const SettingsTutorialsPage({super.key});

  @override
  State<SettingsTutorialsPage> createState() => _SettingsTutorialsPageState();
}

class _SettingsTutorialsPageState extends State<SettingsTutorialsPage> {
  final TutorialService _tutorialService = TutorialService();
  TutorialProgress? _progress;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProgress();
  }
  
  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      final progress = await _tutorialService.getUserTutorialProgress(userId);
      
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading tutorial progress: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _resetAllTutorials() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      await _tutorialService.resetTutorialProgress(userId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tutorial progress has been reset')),
      );
      
      _loadProgress();
    } catch (e) {
      debugPrint('Error resetting tutorials: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset tutorials: $e')),
      );
    }
  }
  
  Future<void> _toggleTutorialsEnabled() async {
    if (_progress == null) return;
    
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      if (_progress!.tutorialDisabled) {
        await _tutorialService.enableTutorials(userId);
      } else {
        await _tutorialService.disableTutorials(userId);
      }
      
      _loadProgress();
    } catch (e) {
      debugPrint('Error toggling tutorials: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update tutorial settings: $e')),
      );
    }
  }
  
  Future<void> _showConfirmResetDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Tutorial Progress?'),
        content: const Text(
          'This will reset all tutorial progress and you\'ll see tutorials again as if you were a new user. Are you sure?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      _resetAllTutorials();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial Settings'),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _progress == null
              ? const Center(child: Text('Unable to load tutorial settings'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Toggle for enabling/disabling tutorials
                    Card(
                      child: SwitchListTile(
                        title: const Text('Show Tutorials'),
                        subtitle: const Text('Turn tutorials on or off'),
                        value: !_progress!.tutorialDisabled,
                        onChanged: (value) => _toggleTutorialsEnabled(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Available tutorials section
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8),
                      child: Text(
                        'Available Tutorials',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // App Introduction
                    _buildTutorialCard(
                      title: 'App Introduction',
                      description: 'Learn the basics of navigating the app',
                      icon: Icons.home,
                      color: Colors.blue,
                      completed: _progress!.hasCompletedIntro,
                      onTap: () => _launchTutorial('intro'),
                    ),
                    
                    // Gamification tutorial
                    _buildTutorialCard(
                      title: 'Rewards & Progress System',
                      description: 'Learn about XP, levels, and rewards',
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                      completed: _progress!.hasCompletedGamification,
                      onTap: () => _launchTutorial('gamification'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Game tutorials section
                    Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
                      child: Text(
                        'Game Tutorials',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Game tutorials
                    ..._tutorialService.getGameTutorials().map((tutorial) {
                      final completed = _progress!.hasCompletedGameTutorial(tutorial.gameType);
                      
                      return _buildTutorialCard(
                        title: tutorial.title,
                        description: tutorial.description,
                        icon: _getIconForGameType(tutorial.gameType),
                        color: _getColorForGameType(tutorial.gameType),
                        completed: completed,
                        onTap: () => _launchGameTutorial(tutorial.gameType),
                      );
                    }),
                    
                    const SizedBox(height: 24),
                    
                    // Reset button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ElevatedButton.icon(
                        onPressed: _showConfirmResetDialog,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset Tutorial Progress'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
  
  Widget _buildTutorialCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool completed,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (completed)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
  
  Future<void> _launchTutorial(String type) async {
    // For demo purposes, just navigate to game tutorial with appropriate type
    // In a real implementation, you'd have dedicated tutorial flows for each type
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameTutorialPage(
          gameType: type,
        ),
      ),
    ).then((_) => _loadProgress());
  }
  
  Future<void> _launchGameTutorial(String gameType) async {
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GameTutorialPage(
          gameType: gameType,
        ),
      ),
    ).then((_) => _loadProgress());
  }
  
  IconData _getIconForGameType(String gameType) {
    switch (gameType) {
      case 'quiz':
        return Icons.quiz;
      case 'matching':
        return Icons.grid_view;
      case 'flashcard':
        return Icons.flip_to_back;
      case 'sorting':
        return Icons.sort;
      default:
        return Icons.videogame_asset;
    }
  }
  
  Color _getColorForGameType(String gameType) {
    switch (gameType) {
      case 'quiz':
        return Colors.blue;
      case 'matching':
        return Colors.green;
      case 'flashcard':
        return Colors.orange;
      case 'sorting':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }
} 