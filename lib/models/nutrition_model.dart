// lib/models/nutrition_model.dart
//
// Core data models for AMUDHU — AI Food & Nutrition Companion.
// These mirror the "Core Features" section of the project blueprint:
// calorie/macro tracking, plate analysis results, and meal planning.

class MacroNutrients {
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final double fiberGrams;

  const MacroNutrients({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.fiberGrams,
  });

  factory MacroNutrients.zero() => const MacroNutrients(
        calories: 0,
        proteinGrams: 0,
        carbsGrams: 0,
        fatGrams: 0,
        fiberGrams: 0,
      );

  factory MacroNutrients.fromJson(Map<String, dynamic> json) {
    return MacroNutrients(
      calories: (json['calories'] ?? 0).toDouble(),
      proteinGrams: (json['proteinGrams'] ?? 0).toDouble(),
      carbsGrams: (json['carbsGrams'] ?? 0).toDouble(),
      fatGrams: (json['fatGrams'] ?? 0).toDouble(),
      fiberGrams: (json['fiberGrams'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'calories': calories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'fiberGrams': fiberGrams,
      };

  MacroNutrients operator +(MacroNutrients other) {
    return MacroNutrients(
      calories: calories + other.calories,
      proteinGrams: proteinGrams + other.proteinGrams,
      carbsGrams: carbsGrams + other.carbsGrams,
      fatGrams: fatGrams + other.fatGrams,
      fiberGrams: fiberGrams + other.fiberGrams,
    );
  }
}

/// Daily target set from onboarding / Settings screen.
class DailyGoal {
  final double calorieTarget;
  final double proteinTargetGrams;
  final double carbsTargetGrams;
  final double fatTargetGrams;
  final double fiberTargetGrams;
  final double waterTargetMl;

  const DailyGoal({
    this.calorieTarget = 2000,
    this.proteinTargetGrams = 90,
    this.carbsTargetGrams = 250,
    this.fatTargetGrams = 65,
    this.fiberTargetGrams = 30,
    this.waterTargetMl = 2500,
  });
}

/// Result returned after "Smart Plate Analysis" (AI food image recognition).
class PlateAnalysisResult {
  final String id;
  final String imagePath;
  final List<DetectedFoodItem> detectedItems;
  final MacroNutrients totalMacros;
  final int healthScore; // 0-100
  final DateTime analyzedAt;

  const PlateAnalysisResult({
    required this.id,
    required this.imagePath,
    required this.detectedItems,
    required this.totalMacros,
    required this.healthScore,
    required this.analyzedAt,
  });

  factory PlateAnalysisResult.fromJson(Map<String, dynamic> json) {
    return PlateAnalysisResult(
      id: json['id'],
      imagePath: json['imagePath'],
      detectedItems: (json['detectedItems'] as List)
          .map((e) => DetectedFoodItem.fromJson(e))
          .toList(),
      totalMacros: MacroNutrients.fromJson(json['totalMacros']),
      healthScore: json['healthScore'],
      analyzedAt: DateTime.parse(json['analyzedAt']),
    );
  }
}

class DetectedFoodItem {
  final String name;
  final double portionGrams;
  final double confidence; // 0.0 - 1.0
  final MacroNutrients macros;

  const DetectedFoodItem({
    required this.name,
    required this.portionGrams,
    required this.confidence,
    required this.macros,
  });

  factory DetectedFoodItem.fromJson(Map<String, dynamic> json) {
    return DetectedFoodItem(
      name: json['name'],
      portionGrams: (json['portionGrams'] ?? 0).toDouble(),
      confidence: (json['confidence'] ?? 0).toDouble(),
      macros: MacroNutrients.fromJson(json['macros']),
    );
  }
}

enum MealSlot { breakfast, lunch, snacks, dinner }

/// A single planned or logged meal, used by the Meal Planner and
/// Home Dashboard.
class MealEntry {
  final String id;
  final String title;
  final MealSlot slot;
  final DateTime date;
  final MacroNutrients macros;
  final bool isLogged; // true once the user has actually eaten it
  final String? imagePath;

  const MealEntry({
    required this.id,
    required this.title,
    required this.slot,
    required this.date,
    required this.macros,
    this.isLogged = false,
    this.imagePath,
  });

  MealEntry copyWith({bool? isLogged}) {
    return MealEntry(
      id: id,
      title: title,
      slot: slot,
      date: date,
      macros: macros,
      isLogged: isLogged ?? this.isLogged,
      imagePath: imagePath,
    );
  }
}

/// Simple user profile used by the Home Dashboard and Profile screen.
class UserProfile {
  final String uid;
  final String name;
  final String? photoUrl;
  final String dietPreference; // e.g. Vegetarian, Vegan, Non-Vegetarian
  final DailyGoal goal;

  const UserProfile({
    required this.uid,
    required this.name,
    this.photoUrl,
    this.dietPreference = 'Vegetarian',
    this.goal = const DailyGoal(),
  });
}
