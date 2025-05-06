import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  final String role;
  const RegisterPage({super.key, required this.role});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nickNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _selectedGradeYear = 1;
  final List<int> _selectedGradeYears = [];
  final List<String> _selectedSubjects = [];

  final List<int> _gradeYears = List.generate(12, (i) => i + 1);
  final List<String> _subjects = [
    'Math','Science','English','History','Geography',
    'Art','Music','Physical Education','Computer Science'
  ];

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _fullNameController.dispose();
    _nickNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final user = cred.user!;
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      if (widget.role == 'student') {
        await userDoc.set({
          'fullName': _fullNameController.text,
          'nickName': _nickNameController.text,
          'email': _emailController.text,
          'role': 'student',
          'gradeYears': [_selectedGradeYear],
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userDoc.set({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'role': 'teacher',
          'gradeYears': _selectedGradeYears,
          'subjects': _selectedSubjects,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (mounted) context.go('/dashboard');
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Registration failed. Please try again.';
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = widget.role == 'student';
    final teal = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Register as ${isStudent ? 'Student' : 'Teacher'}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Full Name
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
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your full name' : null,
                ),
                const SizedBox(height: 16),

                // Nickname (students)
                if (isStudent) ...[
                  TextFormField(
                    controller: _nickNameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Nickname',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Enter a nickname' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // Teacher subjects
                if (!isStudent) ...[
                  const Text('Select Subjects',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _subjects.map((s) {
                      final sel = _selectedSubjects.contains(s);
                      return FilterChip(
                        label: Text(s),
                        selected: sel,
                        onSelected: (on) => setState(() {
                          on ? _selectedSubjects.add(s) : _selectedSubjects.remove(s);
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter a password';
                    if (v.length < 6) return 'Min 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirm your password';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Grade year (student)
                if (isStudent) ...[
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Grade Year',
                    ),
                    value: _selectedGradeYear,
                    items: _gradeYears
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text('Grade $g'),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedGradeYear = v);
                    },
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Teacher grade years
                  const Text('Select Grade Years',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _gradeYears.map((g) {
                      final sel = _selectedGradeYears.contains(g);
                      return FilterChip(
                        label: Text('Grade $g'),
                        selected: sel,
                        onSelected: (on) => setState(() {
                          on ? _selectedGradeYears.add(g) : _selectedGradeYears.remove(g);
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Error
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // Register button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontFamily: 'Retropix',
                      fontSize: 16,
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Register'),
                ),
                const SizedBox(height: 16),

                // Back to Login
                TextButton(
                  onPressed: () => context.go('/login'),
                  style: TextButton.styleFrom(
                    backgroundColor: teal,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'Retropix',
                      fontSize: 16,
                    ),
                  ),
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}