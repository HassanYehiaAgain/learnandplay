// lib/features/games/student_browse_games_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// State providers for selected grade and subject
final selectedGradeProvider = StateProvider<String?>((ref) => null);
final selectedSubjectProvider = StateProvider<String?>((ref) => null);

// Stream provider for filtered games list
final gamesStreamProvider = StreamProvider.autoDispose<List<QueryDocumentSnapshot<Map<String, dynamic>>>>((ref) {
  final grade = ref.watch(selectedGradeProvider);
  final subject = ref.watch(selectedSubjectProvider);

  if (grade == null || subject == null) {
    return Stream.value(<QueryDocumentSnapshot<Map<String, dynamic>>>[]);
  }

  return FirebaseFirestore.instance
      .collection('games')
      .where('gradeYears', arrayContains: grade)
      .where('subject', isEqualTo: subject)
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

class StudentBrowseGamesPage extends ConsumerStatefulWidget {
  const StudentBrowseGamesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentBrowseGamesPage> createState() => _StudentBrowseGamesPageState();
}

class _StudentBrowseGamesPageState extends ConsumerState<StudentBrowseGamesPage> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream;
  final List<String> _subjects = ['Math', 'Science', 'English', 'History'];

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
    } else {
      // Fallback empty stream if no user
      _userStream = Stream.fromFuture(FirebaseFirestore.instance.collection('users').doc('null').get());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Browse Games', style: GoogleFonts.poppins()),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _userStream,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          final data = userSnapshot.data!.data()!;
          final gradeYears = List<String>.from(data['gradeYears'] ?? []);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Grade selector
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Grade',
                    labelStyle: GoogleFonts.poppins(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                  ),
                  items: gradeYears.map((grade) {
                    return DropdownMenuItem(
                      value: grade,
                      child: Text(grade, style: GoogleFonts.poppins(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) => ref.read(selectedGradeProvider.notifier).state = value,
                ),
                const SizedBox(height: 16),

                // Subject selector
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Subject',
                    labelStyle: GoogleFonts.poppins(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),
                  ),
                  items: _subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject,
                      child: Text(subject, style: GoogleFonts.poppins(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) => ref.read(selectedSubjectProvider.notifier).state = value,
                ),
                const SizedBox(height: 24),

                // Games list
                Expanded(
                  child: ref.watch(gamesStreamProvider).when(
                    data: (games) {
                      if (games.isEmpty) {
                        return Center(
                          child: Text(
                            'No games found for selected criteria',
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          final game = games[index];
                          final gameData = game.data();
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(gameData['title'] ?? 'Untitled', style: GoogleFonts.poppins()),
                              subtitle: Text(gameData['template'] ?? '', style: GoogleFonts.poppins()),
                              onTap: () => context.go('/game/${game.id}'),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(
                      child: Text('Error loading games', style: GoogleFonts.poppins()),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}