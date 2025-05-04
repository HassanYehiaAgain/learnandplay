import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/models/gamification_models.dart' as gamification;
import 'package:learn_play_level_up_flutter/services/gamification_service.dart';
import 'package:learn_play_level_up_flutter/components/gamification/leaderboard.dart';

class LeaderboardPage extends StatefulWidget {
  final String userId;
  
  const LeaderboardPage({
    super.key,
    required this.userId,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GamificationService _gamificationService = GamificationService();
  
  // Leaderboard types
  final List<String> _leaderboardTypes = [
    'Global',
    'Mathematics',
    'Science',
    'Language',
    'History',
    'Class A', // Example class-specific leaderboard
  ];
  
  // Selected time period filter
  String _selectedTimePeriod = 'All Time';
  final List<String> _timePeriods = [
    'All Time',
    'This Week',
    'This Month',
  ];
  
  // Leaderboard data
  Map<String, List<gamification.LeaderboardEntry>> _leaderboardData = {};
  Map<String, int> _userRanks = {};
  bool _isLoading = true;
  bool _isPrivacyEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _leaderboardTypes.length, vsync: this);
    _loadLeaderboardData();
    _loadPrivacySettings();
  }
  
  Future<void> _loadPrivacySettings() async {
    // In a real app, this would load from the user's preferences
    // For now, we'll use a default value
    setState(() {
      _isPrivacyEnabled = false;
    });
  }
  
  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final leaderboardData = <String, List<gamification.LeaderboardEntry>>{};
      final userRanks = <String, int>{};
      
      // Load global leaderboard
      leaderboardData['Global'] = await _gamificationService.getLeaderboard('global', limit: 100);
      userRanks['Global'] = await _gamificationService.getUserLeaderboardRank('global', widget.userId);
      
      // Load subject leaderboards
      for (final subject in ['Mathematics', 'Science', 'Language', 'History']) {
        final leaderboardId = 'subject_${subject.toLowerCase()}';
        leaderboardData[subject] = await _gamificationService.getLeaderboard(leaderboardId, limit: 100);
        userRanks[subject] = await _gamificationService.getUserLeaderboardRank(leaderboardId, widget.userId);
      }
      
      // Load class leaderboard (example)
      leaderboardData['Class A'] = await _gamificationService.getLeaderboard('class_a', limit: 100);
      userRanks['Class A'] = await _gamificationService.getUserLeaderboardRank('class_a', widget.userId);
      
      setState(() {
        _leaderboardData = leaderboardData;
        _userRanks = userRanks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load leaderboard data: $e')),
      );
    }
  }
  
  Future<void> _togglePrivacyMode(bool value) async {
    // In a real app, this would save to the user's preferences
    setState(() {
      _isPrivacyEnabled = value;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value 
              ? 'Privacy mode enabled. Your scores will no longer appear on leaderboards.'
              : 'Privacy mode disabled. Your scores will now appear on leaderboards.',
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(_isPrivacyEnabled ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              _showPrivacyDialog();
            },
            tooltip: 'Privacy Settings',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _leaderboardTypes.map((type) => Tab(text: type)).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _leaderboardTypes.map((type) {
                return _buildLeaderboardTab(type);
              }).toList(),
            ),
    );
  }
  
  Widget _buildLeaderboardTab(String leaderboardType) {
    final entries = _leaderboardData[leaderboardType] ?? [];
    final userRank = _userRanks[leaderboardType] ?? -1;
    
    if (entries.isEmpty) {
      return const Center(
        child: Text('No data available for this leaderboard'),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadLeaderboardData,
      child: Column(
        children: [
          // Time period indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            alignment: Alignment.centerRight,
            child: Text(
              'Showing: $_selectedTimePeriod',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          
          // Privacy notice
          if (_isPrivacyEnabled)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility_off, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Privacy mode is enabled. Your scores are hidden from leaderboards.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Leaderboard display
          Expanded(
            child: LeaderboardDisplay(
              entries: entries,
              title: leaderboardType,
              currentUserId: _isPrivacyEnabled ? null : widget.userId,
              currentUserRank: _isPrivacyEnabled ? -1 : userRank,
              totalParticipants: entries.length,
              onRefresh: _loadLeaderboardData,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Leaderboard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Time Period'),
            const SizedBox(height: 8),
            ...List.generate(_timePeriods.length, (index) {
              return RadioListTile<String>(
                title: Text(_timePeriods[index]),
                value: _timePeriods[index],
                groupValue: _selectedTimePeriod,
                onChanged: (value) {
                  Navigator.of(context).pop();
                  setState(() {
                    _selectedTimePeriod = value!;
                    // In a real app, reload data with the new filter
                    // _loadLeaderboardData();
                  });
                },
                dense: true,
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose whether to show your scores on leaderboards.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Privacy Mode'),
              subtitle: const Text('Hide your scores from all leaderboards'),
              value: _isPrivacyEnabled,
              onChanged: (value) {
                Navigator.of(context).pop();
                _togglePrivacyMode(value);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'When privacy mode is enabled:\n'
              '• Your scores won\'t be visible to others\n'
              '• You won\'t appear in any leaderboards\n'
              '• You can still see your own ranking',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 