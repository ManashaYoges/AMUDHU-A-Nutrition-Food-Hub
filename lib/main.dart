// lib/main.dart
//
// AMUDHU — Your AI Food & Nutrition Companion
// Flutter port of the app flow described in the project blueprint:
// Welcome -> Login/Sign Up/Guest -> Home Dashboard -> feature screens.

import 'package:flutter/material.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/smart_plate_analysis_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/ai_chat_screen.dart';

void main() {
  runApp(const AmudhuApp());
}

class AmudhuApp extends StatelessWidget {
  const AmudhuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF2E7D32); // fresh, food/health green

    return MaterialApp(
      title: 'AMUDHU',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: baseColor),
        scaffoldBackgroundColor: const Color(0xFFF6F8F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          color: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/home': (_) => const HomeDashboardScreen(),
        '/plate-analysis': (_) => const SmartPlateAnalysisScreen(),
        '/meal-planner': (_) => const MealPlannerScreen(),
        '/ai-chat': (_) => const AiChatScreen(),
      },
    );
  }
}

/// Welcome Screen -> Login / Sign Up / Guest, per the blueprint's App Flow.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.eco_rounded,
                  size: 96, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'AMUDHU',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your AI Food & Nutrition Companion',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black54),
              ),
              const Spacer(),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/home'),
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pushNamed(context, '/home'),
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/home'),
                child: const Text('Continue as Guest'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
