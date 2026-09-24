// lib/widgets/nutrient_progress_card.dart
//
// Reusable card showing progress of a single nutrient/macro against
// its daily target. Used on Home Dashboard and Dashboard Analytics.

import 'package:flutter/material.dart';

class NutrientProgressCard extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final String unit;
  final Color color;
  final IconData icon;

  const NutrientProgressCard({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    required this.icon,
    this.unit = 'g',
  });

  double get _progress =>
      target <= 0 ? 0 : (consumed / target).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${consumed.toStringAsFixed(0)}$unit / ${target.toStringAsFixed(0)}$unit',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular ring used for the headline "daily calorie summary" figure.
class CalorieRing extends StatelessWidget {
  final double consumed;
  final double target;

  const CalorieRing({super.key, required this.consumed, required this.target});

  @override
  Widget build(BuildContext context) {
    final progress = target <= 0 ? 0.0 : (consumed / target).clamp(0.0, 1.0);
    final remaining = (target - consumed).clamp(0, target);

    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                remaining.toStringAsFixed(0),
                style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text('kcal left', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}
