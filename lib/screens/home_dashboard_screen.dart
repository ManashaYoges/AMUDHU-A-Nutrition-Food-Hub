// lib/screens/home_dashboard_screen.dart
//
// "Personalized Home Dashboard" from the blueprint:
// - Daily calorie summary
// - Protein / carbs / fat / fiber tracking
// - Nutrition progress visualization
// - Daily healthy eating tips
// - Quick access to every other feature

import 'package:flutter/material.dart';
import '../models/nutrition_model.dart';
import '../widgets/nutrient_progress_card.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  // Placeholder data — replace with a provider/bloc backed by Firestore.
  static const _goal = DailyGoal();
  static const _consumed = MacroNutrients(
    calories: 1240,
    proteinGrams: 54,
    carbsGrams: 140,
    fatGrams: 38,
    fiberGrams: 12,
  );

  static const _tip =
      'Add a handful of nuts to your breakfast for slow-release energy '
      'and healthy fats that keep you full longer.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hi, Manasa 👋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: CalorieRing(
                consumed: _consumed.calories,
                target: _goal.calorieTarget,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                NutrientProgressCard(
                  label: 'Protein',
                  consumed: _consumed.proteinGrams,
                  target: _goal.proteinTargetGrams,
                  color: Colors.deepOrange,
                  icon: Icons.egg_alt_outlined,
                ),
                NutrientProgressCard(
                  label: 'Carbs',
                  consumed: _consumed.carbsGrams,
                  target: _goal.carbsTargetGrams,
                  color: Colors.amber[800]!,
                  icon: Icons.rice_bowl_outlined,
                ),
                NutrientProgressCard(
                  label: 'Fat',
                  consumed: _consumed.fatGrams,
                  target: _goal.fatTargetGrams,
                  color: Colors.purple,
                  icon: Icons.opacity,
                ),
                NutrientProgressCard(
                  label: 'Fiber',
                  consumed: _consumed.fiberGrams,
                  target: _goal.fiberTargetGrams,
                  color: Colors.teal,
                  icon: Icons.grass_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _TipCard(tip: _tip),
            const SizedBox(height: 20),
            Text('Quick Actions',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _FeatureTile(
                  icon: Icons.camera_alt_outlined,
                  label: 'Smart Plate\nAnalysis',
                  onTap: () =>
                      Navigator.pushNamed(context, '/plate-analysis'),
                ),
                _FeatureTile(
                  icon: Icons.kitchen_outlined,
                  label: 'Fridge-to-\nRecipe',
                  onTap: () {},
                ),
                _FeatureTile(
                  icon: Icons.chat_bubble_outline,
                  label: 'AI Chat\nAssistant',
                  onTap: () => Navigator.pushNamed(context, '/ai-chat'),
                ),
                _FeatureTile(
                  icon: Icons.calendar_month_outlined,
                  label: 'Meal\nPlanner',
                  onTap: () => Navigator.pushNamed(context, '/meal-planner'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined), label: 'Hub'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined), label: 'Analytics'),
          NavigationDestination(
              icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  const _TipCard({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(tip, style: const TextStyle(height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
