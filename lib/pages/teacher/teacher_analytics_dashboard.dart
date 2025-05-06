import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:fl_chart/fl_chart.dart';
import 'package:learn_play_level_up_flutter/models/analytics_models.dart';
import 'package:learn_play_level_up_flutter/services/analytics_service.dart';
import 'package:learn_play_level_up_flutter/services/notification_service.dart';
import 'package:learn_play_level_up_flutter/widgets/analytics/performance_chart.dart';
import 'package:learn_play_level_up_flutter/widgets/analytics/student_progress_card.dart';
import 'package:learn_play_level_up_flutter/widgets/analytics/subject_progress_card.dart';
import 'package:learn_play_level_up_flutter/widgets/analytics/game_effectiveness_card.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:learn_play_level_up_flutter/services/analytics_export_service.dart';
import 'package:cross_file/cross_file.dart';

class TeacherAnalyticsDashboard extends StatefulWidget {
  const TeacherAnalyticsDashboard({super.key});

  @override
  State<TeacherAnalyticsDashboard> createState() => _TeacherAnalyticsDashboardState();
}

class _TeacherAnalyticsDashboardState extends State<TeacherAnalyticsDashboard> with SingleTickerProviderStateMixin {
  final AnalyticsService _analyticsService = AnalyticsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  late TabController _tabController;
  
  TeacherAnalyticsSummary? _summary;
  List<ClassPerformance> _classPerformance = [];
  List<GameEffectiveness> _gameEffectiveness = [];
  bool _isLoading = true;
  final bool _isExporting = false;
  String _selectedTimeRange = 'All Time';
  String? _selectedSubject;
  String? _selectedClass;
  
  final List<String> _timeRanges = ['Last 7 Days', 'Last 30 Days', 'Last 90 Days', 'All Time'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    _loadAnalytics();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
  
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }
  
  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;
      
      // Load teacher analytics summary
      final summary = await _analyticsService.getTeacherAnalyticsSummary(userId);
      
      // Load class performance
      final classesQuery = await _firestore.collection('classes')
          .where('teacherId', isEqualTo: userId)
          .get();
      
      final classIds = classesQuery.docs.map((doc) => doc.id).toList();
      
      List<ClassPerformance> classPerformance = [];
      for (var classId in classIds) {
        final performance = await _analyticsService.getClassPerformance(classId);
        if (performance != null) {
          classPerformance.add(performance);
        }
      }
      
      // Load game effectiveness
      final gameEffectiveness = await _analyticsService.getGamePerformanceAnalytics(userId);
      
      setState(() {
        _summary = summary;
        _classPerformance = classPerformance;
        _gameEffectiveness = gameEffectiveness;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  List<GameEffectiveness> _filterGameEffectiveness() {
    if (_selectedSubject == null) {
      return _gameEffectiveness;
    }
    
    // This is a placeholder - in a real implementation, you would filter by subject ID
    // based on the subject ID stored in the game data
    return _gameEffectiveness;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Student Progress'),
            Tab(text: 'Game Performance'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportAnalyticsData,
            tooltip: 'Export Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
            tooltip: 'Refresh Analytics',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildStudentProgressTab(),
                  _buildGamePerformanceTab(),
                ],
              ),
          if (_isExporting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Preparing export...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _tabController.index == 1 // Student Progress tab
          ? FloatingActionButton(
              onPressed: _showSendReminderDialog,
              tooltip: 'Send Reminders',
              child: const Icon(Icons.send),
            )
          : null,
    );
  }
  
  // Export analytics data as CSV
  Future<void> _exportAnalyticsData() async {
    final analyticsExportService = AnalyticsExportService();
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Preparing Export'),
          content: SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
      
      // Get current class name for the file name
      String className = 'All_Classes';
      if (_selectedClass != null) {
        final selectedClassData = _classPerformance.firstWhere(
          (c) => c.classId == _selectedClass,
          orElse: () => _classPerformance.first,
        );
        className = selectedClassData.className;
      }
      
      // Export data to CSV
      final directoryPath = await analyticsExportService.exportTeacherAnalyticsToCSV(
        TeacherAnalyticsSummary(
          teacherId: auth.FirebaseAuth.instance.currentUser!.uid,
          averageCompletionRate: _summary?.averageCompletionRate ?? 0,
          totalStudents: _summary?.totalStudents ?? 0,
          activeStudents: _summary?.activeStudents ?? 0,
          totalGamesAssigned: _summary?.totalGamesAssigned ?? 0,
          totalGamesCompleted: _summary?.totalGamesCompleted ?? 0,
        ),
        className,
      );
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show export options dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Complete'),
          content: const Text(
            'Analytics data has been exported to CSV format. What would you like to do with the exported files?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Share files
                final directory = Directory(directoryPath);
                final files = directory.listSync().where((e) => 
                  e.path.endsWith('.csv') && 
                  e.path.contains(className.replaceAll(' ', '_'))
                ).toList();
                
                if (files.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No export files found')),
                  );
                  return;
                }
                
                // Share the files using correct method
                final filePaths = files.map((f) => f.path).toList();
                await Share.shareXFiles(
                  filePaths.map((path) => XFile(path)).toList(),
                  subject: 'Analytics Export',
                  text: 'Here is your exported analytics data',
                );
              },
              child: const Text('Share Files'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if still showing
      Navigator.of(context, rootNavigator: true).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    }
  }
  
  // Show dialog to send reminders to students
  void _showSendReminderDialog() {
    final students = _getIncompleteStudents();
    
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students with incomplete assignments')),
      );
      return;
    }
    
    // Track selected students
    final selectedStudents = <String, bool>{};
    for (var student in students) {
      selectedStudents[student.studentId] = true;
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Send Assignment Reminders'),
              content: SizedBox(
                width: 600,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select students to send reminders:'),
                    const SizedBox(height: 8),
                    
                    // Select all / None buttons
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (var key in selectedStudents.keys) {
                                selectedStudents[key] = true;
                              }
                            });
                          },
                          child: const Text('Select All'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (var key in selectedStudents.keys) {
                                selectedStudents[key] = false;
                              }
                            });
                          },
                          child: const Text('Select None'),
                        ),
                      ],
                    ),
                    const Divider(),
                    
                    // Student list
                    Expanded(
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return CheckboxListTile(
                            value: selectedStudents[student.studentId] ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                selectedStudents[student.studentId] = value ?? false;
                              });
                            },
                            title: Text(student.studentName),
                            subtitle: Text(
                              '${student.gamesCompleted}/${student.gamesAssigned} games completed',
                            ),
                            secondary: CircleAvatar(
                              backgroundImage: student.avatar != null ? NetworkImage(student.avatar!) : null,
                              child: student.avatar == null
                                  ? Text(student.studentName.substring(0, 1).toUpperCase())
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                    
                    // Message input
                    const SizedBox(height: 16),
                    const Text('Reminder message:'),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'E.g., Please complete your assigned games as soon as possible.',
                      ),
                      controller: TextEditingController(
                        text: 'You have incomplete game assignments. Please complete them at your earliest convenience.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Get the selected student IDs
                    final List<String> studentIds = [];
                    for (var entry in selectedStudents.entries) {
                      if (entry.value) {
                        studentIds.add(entry.key);
                      }
                    }
                    
                    if (studentIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No students selected')),
                      );
                      return;
                    }
                    
                    Navigator.pop(context);
                    
                    // Show sending dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AlertDialog(
                        title: Text('Sending Reminders'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Sending reminders to selected students...'),
                          ],
                        ),
                      ),
                    );
                    
                    try {
                      // Send notifications to students
                      await _notificationService.sendAssignmentReminders(
                        studentIds: studentIds,
                        message: 'You have incomplete game assignments. Please complete them at your earliest convenience.',
                        teacherId: auth.FirebaseAuth.instance.currentUser!.uid,
                      );
                      
                      // Close dialog and show success
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reminders sent to ${studentIds.length} students'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Close dialog and show error
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to send reminders: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Send Reminders'),
                ),
              ],
            );
          }
        );
      },
    );
  }
  
  // Get students with incomplete assignments
  List<StudentPerformanceSummary> _getIncompleteStudents() {
    final incompleteStudents = <StudentPerformanceSummary>[];
    
    for (var classPerf in _classPerformance) {
      for (var student in classPerf.studentSummaries) {
        if (student.completionRate < 100) {
          incompleteStudents.add(student);
        }
      }
    }
    
    // Sort by completion rate (ascending)
    incompleteStudents.sort((a, b) => a.completionRate.compareTo(b.completionRate));
    
    return incompleteStudents;
  }
  
  Widget _buildOverviewTab() {
    if (_summary == null) {
      return const Center(
        child: Text('No analytics data available'),
      );
    }
    
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Students',
                  '${_summary!.totalStudents}',
                  Icons.people,
                  colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Active Students',
                  '${_summary!.activeStudents}',
                  Icons.person_outline,
                  colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Games Assigned',
                  '${_summary!.totalGamesAssigned}',
                  Icons.games,
                  colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Completion Rate',
                  '${_summary!.averageCompletionRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Subject completion stats
          Text(
            'Subject Completion Rates',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          SizedBox(
            height: 200,
            child: _buildSubjectCompletionChart(),
          ),
          
          const SizedBox(height: 24),
          
          // Top performing games
          Text(
            'Top Performing Games',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          ..._summary!.topPerformingGames.map((game) => 
            GameEffectivenessCard(game: game, onTap: () {})
          ),
          
          const SizedBox(height: 24),
          
          // Lowest performing games
          Text(
            'Games Needing Improvement',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          
          ..._summary!.lowestPerformingGames.map((game) => 
            GameEffectivenessCard(game: game, onTap: () {})
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubjectCompletionChart() {
    if (_summary == null || _summary!.subjectCompletionRates.isEmpty) {
      return const Center(
        child: Text('No subject data available'),
      );
    }
    
    final subjectRates = _summary!.subjectCompletionRates.values.toList();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final subject = subjectRates[groupIndex];
              return BarTooltipItem(
                '${subject.subjectName}\n${subject.completionRate.toStringAsFixed(1)}%',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= subjectRates.length) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    subjectRates[value.toInt()].subjectName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 20 != 0) {
                  return const SizedBox();
                }
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          getDrawingHorizontalLine: (value) {
            return const FlLine(
              color: Colors.grey,
              strokeWidth: 0.5,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          subjectRates.length, 
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: subjectRates[index].completionRate,
                color: _getColorForCompletion(subjectRates[index].completionRate),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getColorForCompletion(double completionRate) {
    if (completionRate >= 80) {
      return Colors.green;
    } else if (completionRate >= 60) {
      return Colors.amber;
    } else if (completionRate >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  Widget _buildStudentProgressTab() {
    if (_classPerformance.isEmpty) {
      return const Center(
        child: Text('No student progress data available'),
      );
    }
    
    final theme = Theme.of(context);
    
    // Flat list of all students across all classes
    final allStudents = _classPerformance
        .expand((classData) => classData.studentSummaries)
        .toList();
    
    // Sort by completion rate (descending)
    allStudents.sort((a, b) => b.completionRate.compareTo(a.completionRate));
    
    return Column(
      children: [
        // Filter options
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Class filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Classes')),
                    ..._classPerformance.map((classData) => DropdownMenuItem(
                      value: classData.classId,
                      child: Text(classData.className),
                    )),
                  ],
                  value: _selectedClass,
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // Subject filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Subjects')),
                    // Add subject items here
                  ],
                  value: _selectedSubject,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Class management actions
        if (_selectedClass != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Adjust Due Dates'),
                  onPressed: _showDueDateAdjustmentDialog,
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.assessment, size: 18),
                  label: const Text('Detailed Analytics'),
                  onPressed: () {
                    // Navigate to detailed class analytics
                  },
                ),
              ],
            ),
          ),
        
        // Progress list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filterStudentsByClass(allStudents).length,
            itemBuilder: (context, index) {
              final student = _filterStudentsByClass(allStudents)[index];
              return StudentProgressCard(
                student: student,
                onTap: () {
                  // Navigate to detailed student view
                  _showStudentDetailDialog(student);
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Add this helper method for filtering students by selected class
  List<StudentPerformanceSummary> _filterStudentsByClass(List<StudentPerformanceSummary> students) {
    if (_selectedClass == null) {
      return students;
    }
    
    final classPerformance = _classPerformance.firstWhere(
      (classPerf) => classPerf.classId == _selectedClass,
      orElse: () => _classPerformance.first,
    );
    
    return classPerformance.studentSummaries;
  }
  
  // Add this method to show due date adjustment dialog
  void _showDueDateAdjustmentDialog() async {
    // First, fetch assignments for the selected class
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a class first')),
      );
      return;
    }
    
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          title: Text('Loading Assignments'),
          content: SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      );
      
      // Fetch assignments
      final assignmentsSnapshot = await _firestore
          .collection('games')
          .where('classIds', arrayContains: _selectedClass)
          .orderBy('dueDate', descending: false)
          .get();
      
      // Dismiss loading dialog
      Navigator.pop(context);
      
      if (assignmentsSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No assignments found for this class')),
        );
        return;
      }
      
      // Get class name for display
      final className = _classPerformance
          .firstWhere((c) => c.classId == _selectedClass)
          .className;
      
      // Show assignment list dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Adjust Due Dates - $className'),
            content: SizedBox(
              width: 600,
              height: 400,
              child: ListView.builder(
                itemCount: assignmentsSnapshot.docs.length,
                itemBuilder: (context, index) {
                  final doc = assignmentsSnapshot.docs[index];
                  final data = doc.data();
                  final gameTitle = data['title'] ?? 'Unknown Game';
                  final dueDate = (data['dueDate'] as Timestamp).toDate();
                  final isOverdue = dueDate.isBefore(DateTime.now());
                  
                  return ListTile(
                    title: Text(gameTitle),
                    subtitle: Text('Due: ${_formatDate(dueDate)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isOverdue)
                          Chip(
                            label: const Text('Overdue'),
                            backgroundColor: Colors.red.withOpacity(0.1),
                            labelStyle: const TextStyle(color: Colors.red),
                          ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          tooltip: 'Change due date',
                          onPressed: () async {
                            // Show date picker
                            final newDate = await showDatePicker(
                              context: context,
                              initialDate: dueDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            
                            if (newDate != null) {
                              // Update the due date
                              await _firestore
                                  .collection('games')
                                  .doc(doc.id)
                                  .update({
                                'dueDate': Timestamp.fromDate(newDate),
                              });
                              
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Due date for "$gameTitle" updated to ${_formatDate(newDate)}'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              
                              // Refresh the dialog
                              Navigator.pop(context);
                              _showDueDateAdjustmentDialog();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              // Option to extend all due dates by a week
              ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final shouldProceed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Extend All Due Dates'),
                      content: const Text(
                        'This will extend all assignment due dates by 7 days. Continue?'
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Extend All'),
                        ),
                      ],
                    ),
                  ) ?? false;
                  
                  if (shouldProceed) {
                    // Show loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const AlertDialog(
                        title: Text('Updating Due Dates'),
                        content: SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    );
                    
                    try {
                      // Update each assignment
                      for (final doc in assignmentsSnapshot.docs) {
                        final data = doc.data();
                        final currentDueDate = (data['dueDate'] as Timestamp).toDate();
                        final newDueDate = currentDueDate.add(const Duration(days: 7));
                        
                        await _firestore
                            .collection('games')
                            .doc(doc.id)
                            .update({
                          'dueDate': Timestamp.fromDate(newDueDate),
                        });
                      }
                      
                      // Close loading dialog
                      Navigator.pop(context);
                      
                      // Close the assignments dialog
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All due dates extended by 7 days'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Close loading dialog
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating due dates: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Extend All by 7 Days'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Dismiss loading dialog if still showing
      Navigator.of(context, rootNavigator: true).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading assignments: $e')),
      );
    }
  }
  
  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  Widget _buildGamePerformanceTab() {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Filter options
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Time range filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Time Range',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _timeRanges.map((range) => DropdownMenuItem(
                    value: range,
                    child: Text(range),
                  )).toList(),
                  value: _selectedTimeRange,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTimeRange = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // Subject filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Subjects')),
                    // Add subject items here
                  ],
                  value: _selectedSubject,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Games effectiveness list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Game Effectiveness',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              if (_gameEffectiveness.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No game performance data available'),
                  ),
                )
              else
                ..._filterGameEffectiveness().map((game) => 
                  GameEffectivenessCard(
                    game: game,
                    onTap: () {
                      // Navigate to detailed game analytics
                      _showGameDetailDialog(game);
                    },
                  )
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showStudentDetailDialog(StudentPerformanceSummary student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${student.studentName} - Performance Details'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            children: [
              // Student stats
              Row(
                children: [
                  _buildStudentStatCard('Average Score', '${student.averageScore.toStringAsFixed(1)}%', Icons.score),
                  const SizedBox(width: 8),
                  _buildStudentStatCard('Completion Rate', '${student.completionRate.toStringAsFixed(1)}%', Icons.check_circle),
                  const SizedBox(width: 8),
                  _buildStudentStatCard('Games Completed', '${student.gamesCompleted}/${student.gamesAssigned}', Icons.games),
                ],
              ),
              const SizedBox(height: 16),
              
              // Subject performance
              const Text('Subject Performance'),
              const SizedBox(height: 8),
              
              Expanded(
                child: ListView(
                  children: [
                    for (var entry in student.subjectPerformance.entries)
                      ListTile(
                        title: Text(entry.key), // In real app, get subject name
                        trailing: Text('${entry.value.toStringAsFixed(1)}%'),
                        leading: Icon(
                          Icons.subject,
                          color: _getColorForCompletion(entry.value),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to detailed student analytics page
              Navigator.pop(context);
              // TODO: Navigate to student detail page
            },
            child: const Text('View Full Analytics'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStudentStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showGameDetailDialog(GameEffectiveness game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(game.gameTitle),
        content: SizedBox(
          width: 600,
          height: 400,
          child: Column(
            children: [
              // Game stats
              Row(
                children: [
                  _buildGameStatCard('Avg. Score', '${game.averageScore.toStringAsFixed(1)}%', Icons.score),
                  const SizedBox(width: 8),
                  _buildGameStatCard('Completion', '${game.completionRate.toStringAsFixed(1)}%', Icons.check_circle),
                  const SizedBox(width: 8),
                  _buildGameStatCard('Avg. Time', '${(game.averageDuration / 60).toStringAsFixed(1)} min', Icons.timer),
                ],
              ),
              const SizedBox(height: 24),
              
              // More detailed stats would go here
              // This is a placeholder
              const Expanded(
                child: Center(
                  child: Text('Detailed game analytics will be shown here'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to detailed game analytics page
              Navigator.pop(context);
              // TODO: Navigate to game detail page
            },
            child: const Text('View Full Analytics'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGameStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 