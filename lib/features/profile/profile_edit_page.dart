import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../models/firestore_helpers.dart';

// Profile state providers
final profileLoadingProvider = StateProvider<bool>((ref) => true);
final profileSavingProvider = StateProvider<bool>((ref) => false);
final userProvider = StateProvider<AppUser?>((ref) => null);
final selectedGradeYearsProvider = StateProvider<List<int>>((ref) => []);
final selectedSubjectsProvider = StateProvider<List<String>>((ref) => []);
final selectedGradeYearProvider = StateProvider<int>((ref) => 1);

// Profile data providers
final userDataProvider = FutureProvider<AppUser?>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return null;
  
  final user = await FirestoreHelpers.getUserById(uid);
  if (user != null) {
    // Update other providers with user data
    ref.read(userProvider.notifier).state = user;
    ref.read(selectedGradeYearsProvider.notifier).state = List.from(user.gradeYears);
    ref.read(selectedSubjectsProvider.notifier).state = List.from(user.subjects);
    
    if (user.role == 'student' && user.gradeYears.isNotEmpty) {
      ref.read(selectedGradeYearProvider.notifier).state = user.gradeYears.first;
    }
  }
  
  // Set loading to false
  ref.read(profileLoadingProvider.notifier).state = false;
  return user;
});

// Save profile function
Future<void> saveProfile({
  required BuildContext context, 
  required WidgetRef ref,
  required String fullName,
  required String nickName,
}) async {
  final formKey = ref.read(formKeyProvider);
  if (!(formKey.currentState?.validate() ?? false)) return;

  ref.read(profileSavingProvider.notifier).state = true;

  final uid = FirebaseAuth.instance.currentUser?.uid;
  final user = ref.read(userProvider);

  if (uid == null || user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not found')),
    );
    ref.read(profileSavingProvider.notifier).state = false;
    return;
  }

  final userData = <String, dynamic>{
    'fullName': fullName,
    'nickName': nickName,
  };

  if (user.role == 'teacher') {
    userData['gradeYears'] = ref.read(selectedGradeYearsProvider);
    userData['subjects'] = ref.read(selectedSubjectsProvider);
  } else {
    userData['gradeYears'] = [ref.read(selectedGradeYearProvider)];
  }

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update(userData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated')),
    );
    context.go('/dashboard');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating profile: $e')),
    );
  } finally {
    ref.read(profileSavingProvider.notifier).state = false;
  }
}

// Form key provider for validation
final formKeyProvider = Provider<GlobalKey<FormState>>((ref) => GlobalKey<FormState>());

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _fullNameController = TextEditingController();
  final _nickNameController = TextEditingController();

  final List<int> _gradeYears = List.generate(12, (i) => i + 1);
  final List<String> _subjects = [
    'Math', 'Science', 'English', 'History', 'Geography',
    'Art', 'Music', 'Physical Education', 'Computer Science'
  ];

  @override
  void initState() {
    super.initState();
    // Trigger data loading
    ref.read(userDataProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update text controllers when user data is available
    final user = ref.read(userProvider);
    if (user != null) {
      _fullNameController.text = user.fullName;
      _nickNameController.text = user.nickName ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nickNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileLoadingProvider);
    final isSaving = ref.watch(profileSavingProvider);
    final user = ref.watch(userProvider);
    final selectedGradeYears = ref.watch(selectedGradeYearsProvider);
    final selectedSubjects = ref.watch(selectedSubjectsProvider);
    final selectedGradeYear = ref.watch(selectedGradeYearProvider);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: ref.read(formKeyProvider),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  labelText: 'Full Name',
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Please enter your full name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nickNameController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  labelText: 'Nickname',
                ),
              ),
              const SizedBox(height: 16),

              if (user.role == 'student') ...[
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Grade Year',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGradeYear,
                  items: _gradeYears
                      .map((g) => DropdownMenuItem(value: g, child: Text('Grade $g')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(selectedGradeYearProvider.notifier).state = v;
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],

              if (user.role == 'teacher') ...[
                const Text('Grade Years', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: _gradeYears.map((g) {
                    final sel = selectedGradeYears.contains(g);
                    return FilterChip(
                      label: Text('Grade $g'),
                      selected: sel,
                      onSelected: (on) {
                        final newList = List<int>.from(selectedGradeYears);
                        if (on) {
                          newList.add(g);
                        } else {
                          newList.remove(g);
                        }
                        ref.read(selectedGradeYearsProvider.notifier).state = newList;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Subjects', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: _subjects.map((s) {
                    final sel = selectedSubjects.contains(s);
                    return FilterChip(
                      label: Text(s),
                      selected: sel,
                      onSelected: (on) {
                        final newList = List<String>.from(selectedSubjects);
                        if (on) {
                          newList.add(s);
                        } else {
                          newList.remove(s);
                        }
                        ref.read(selectedSubjectsProvider.notifier).state = newList;
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              ElevatedButton(
                onPressed: isSaving 
                  ? null 
                  : () => saveProfile(
                      context: context,
                      ref: ref,
                      fullName: _fullNameController.text,
                      nickName: _nickNameController.text,
                    ),
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Profile'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isSaving ? null : () => context.go('/dashboard'),
                child: const Text('Cancel'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}