import 'package:flutter/material.dart';
import 'package:learn_play_level_up_flutter/components/navbar.dart';
import 'package:learn_play_level_up_flutter/components/ui/button.dart';
import 'package:learn_play_level_up_flutter/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:learn_play_level_up_flutter/services/auth_service.dart';
import 'package:learn_play_level_up_flutter/services/firebase_service.dart';
import 'package:learn_play_level_up_flutter/models/firebase_models.dart';

class SubjectManagementPage extends StatefulWidget {
  const SubjectManagementPage({super.key});

  @override
  State<SubjectManagementPage> createState() => _SubjectManagementPageState();
}

class _SubjectManagementPageState extends State<SubjectManagementPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Subject> _subjects = [];
  Map<String, FirebaseUser> _userCache = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Load subjects based on user role
      if (currentUser.role == 'teacher') {
        _subjects = await firebaseService.getTeacherSubjects(currentUser.id);
      } else {
        _subjects = await firebaseService.getStudentSubjects(currentUser.id);
      }
      
      // Pre-cache user data for students and teachers in these subjects
      final userIds = <String>{};
      
      // Add teacher IDs
      for (final subject in _subjects) {
        userIds.add(subject.teacherId);
        userIds.addAll(subject.studentIds);
      }
      
      // Fetch user details for these IDs
      for (final userId in userIds) {
        try {
          final user = await _fetchUserDetails(userId, firebaseService);
          if (user != null) {
            _userCache[userId] = user;
          }
        } catch (e) {
          // Skip this user if there's an error
          debugPrint('Error fetching user $userId: $e');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading subjects: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Helper to fetch user details with caching
  Future<FirebaseUser?> _fetchUserDetails(String userId, FirebaseService firebaseService) async {
    // Check cache first
    if (_userCache.containsKey(userId)) {
      return _userCache[userId];
    }
    
    // Use the getUserById method from FirebaseService
    return await firebaseService.getUserById(userId);
  }
  
  // Get user name from cache
  String _getUserName(String userId) {
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!.name;
    }
    return 'User $userId';
  }

  void _showCreateSubjectDialog(BuildContext context, String teacherId) {
    final _nameController = TextEditingController();
    final _descController = TextEditingController();
    int _gradeYear = 1;
    bool _isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Subject'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Subject Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _gradeYear,
                    decoration: const InputDecoration(labelText: 'Grade Year'),
                    items: List.generate(13, (i) => i).map((grade) => DropdownMenuItem(
                      value: grade,
                      child: Text(grade == 0 ? 'Kindergarten' : 'Grade $grade'),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _gradeYear = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isSaving ? null : () async {
                    if (_nameController.text.trim().isEmpty) return;
                    setState(() => _isSaving = true);
                    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
                    final subject = Subject(
                      id: '',
                      name: _nameController.text.trim(),
                      description: _descController.text.trim(),
                      gradeYear: _gradeYear,
                      teacherId: teacherId,
                      studentIds: [],
                      createdAt: DateTime.now(),
                    );
                    await firebaseService.createSubject(subject);
                    setState(() => _isSaving = false);
                    Navigator.of(context).pop();
                    _loadData();
                  },
                  child: _isSaving ? const CircularProgressIndicator() : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 768;
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    final isTeacher = currentUser?.role == 'teacher';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          const Navbar(isAuthenticated: true),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      )
                    : _subjects.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  size: 80,
                                  color: colorScheme.primary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isTeacher 
                                      ? 'You haven\'t created any subjects yet' 
                                      : 'You aren\'t enrolled in any subjects yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (isTeacher)
                                  AppButton(
                                    text: 'Create Subject',
                                    variant: ButtonVariant.gradient,
                                    onPressed: () {
                                      _showCreateSubjectDialog(context, currentUser!.id);
                                    },
                                  ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isTeacher ? 'Your Subjects' : 'Enrolled Subjects',
                                      style: TextStyle(
                                        fontFamily: 'PressStart2P',
                                        fontSize: 20,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    if (isTeacher)
                                      AppButton(
                                        text: 'Create Subject',
                                        variant: ButtonVariant.gradient,
                                        onPressed: () {
                                          _showCreateSubjectDialog(context, currentUser!.id);
                                        },
                                      ),
                                  ],
                                ).animate().fadeIn(duration: 400.ms),
                                const SizedBox(height: 24),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _subjects.length,
                                    itemBuilder: (context, index) {
                                      final subject = _subjects[index];
                                      return _buildSubjectCard(subject, index, isTeacher);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Subject subject, int index, bool isTeacher) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ExpansionTile(
        title: Text(
          subject.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.primary,
          ),
        ),
        subtitle: Text(
          'Grade ${subject.gradeYear} - ${subject.studentIds.length} students',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            subject.name.substring(0, 1).toUpperCase(),
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject.description ?? '',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Teacher section
                Text(
                  'Teacher',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.secondary,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(_getUserName(subject.teacherId)),
                ),
                const SizedBox(height: 16),
                
                // Students section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Students (${subject.studentIds.length})',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (isTeacher)
                      TextButton.icon(
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Add Students'),
                        onPressed: () {
                          // TODO: Show dialog to add students
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Student list
                if (subject.studentIds.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No students enrolled yet',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: subject.studentIds.length,
                    itemBuilder: (context, index) {
                      final studentId = subject.studentIds[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.tertiary.withOpacity(0.8),
                          child: const Icon(Icons.school, color: Colors.white, size: 18),
                        ),
                        title: Text(_getUserName(studentId)),
                        trailing: isTeacher
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () {
                                  // TODO: Implement removing student
                                },
                              )
                            : null,
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: 100 * index),
    );
  }
} 