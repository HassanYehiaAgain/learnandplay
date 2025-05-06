import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../common/section_card.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ← Login button only
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontFamily: 'Retropix',
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    height: 160,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),

                  // Accent underline
                  Center(
                    child: Container(
                      height: 4,
                      width: 100,
                      color: const Color(0xFFFF6F61),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1️⃣ Welcome section
                  const SectionCard(
                    title: 'Welcome to Learn & Play',
                    subtitle: 'The interactive learning platform for students and teachers',
                    useLargeFont: true,
                  ),
                  const SizedBox(height: 16),

                  // 2️⃣ Teacher section
                  const SectionCard(
                    title: 'Teachers',
                    subtitle: 'Create engaging games and track progress',
                    subtitleStyle: TextStyle(color: Colors.black),
                    icon: Icons.school,
                    routePath: '/register',
                    queryParams: {'role': 'teacher'},
                  ),
                  const SizedBox(height: 16),

                  // 3️⃣ Student section
                  const SectionCard(
                    title: 'Students',
                    subtitle: 'Learn through fun interactive games',
                    subtitleStyle: TextStyle(color: Colors.black),
                    icon: Icons.person,
                    routePath: '/register',
                    queryParams: {'role': 'student'},
                  ),
                  const SizedBox(height: 24),

                  // 4️⃣ Slogan
                  Text(
                    'Empowering Teachers – Engaging Students',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                          fontFamily: 'Retropix',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}