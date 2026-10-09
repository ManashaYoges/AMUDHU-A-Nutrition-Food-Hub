// lib/screens/smart_plate_analysis_screen.dart
//
// "Smart Plate Analysis" from the blueprint:
// - AI-powered food image recognition
// - Nutritional breakdown, portion estimation, calorie calculation
// - Health score generation
//
// Uses image_picker for capture/selection. Wire `_analyzeImage` up to
// your CV backend (TFLite on-device model, or Gemini/OpenAI vision API).
// Add to pubspec.yaml: image_picker: ^1.1.2

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/nutrition_model.dart';

// NOTE: this screen was originally written against dart:io File, which
// does not compile on Flutter Web. It now stores the picked image as
// bytes (Uint8List) via XFile.readAsBytes(), which works on every
// platform image_picker supports (web, Android, iOS, desktop).

class SmartPlateAnalysisScreen extends StatefulWidget {
  const SmartPlateAnalysisScreen({super.key});

  @override
  State<SmartPlateAnalysisScreen> createState() =>
      _SmartPlateAnalysisScreenState();
}

class _SmartPlateAnalysisScreenState extends State<SmartPlateAnalysisScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImageBytes;
  bool _isAnalyzing = false;
  PlateAnalysisResult? _result;
  String? _error;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _result = null;
        _error = null;
      });
      await _analyzeImage(picked.name);
    } catch (e) {
      setState(() => _error = 'Could not access camera/gallery: $e');
    }
  }

  /// Replace this with a real call to your food-recognition backend.
  /// e.g. upload to Cloud Function -> Gemini Vision -> structured JSON,
  /// or run a bundled TFLite model on-device.
  Future<void> _analyzeImage(String imageName) async {
    setState(() => _isAnalyzing = true);
    try {
      await Future.delayed(const Duration(seconds: 2)); // simulate network

      final mockResult = PlateAnalysisResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imageName,
        detectedItems: const [
          DetectedFoodItem(
            name: 'Grilled chicken breast',
            portionGrams: 150,
            confidence: 0.92,
            macros: MacroNutrients(
                calories: 250,
                proteinGrams: 46,
                carbsGrams: 0,
                fatGrams: 6,
                fiberGrams: 0),
          ),
          DetectedFoodItem(
            name: 'Steamed rice',
            portionGrams: 180,
            confidence: 0.88,
            macros: MacroNutrients(
                calories: 210,
                proteinGrams: 4,
                carbsGrams: 45,
                fatGrams: 0.5,
                fiberGrams: 1),
          ),
          DetectedFoodItem(
            name: 'Mixed sautéed vegetables',
            portionGrams: 100,
            confidence: 0.81,
            macros: MacroNutrients(
                calories: 70,
                proteinGrams: 2,
                carbsGrams: 10,
                fatGrams: 3,
                fiberGrams: 4),
          ),
        ],
        totalMacros: const MacroNutrients(
            calories: 530,
            proteinGrams: 52,
            carbsGrams: 55,
            fatGrams: 9.5,
            fiberGrams: 5),
        healthScore: 78,
        analyzedAt: DateTime.now(),
      );

      setState(() => _result = mockResult);
    } catch (e) {
      setState(() => _error = 'Analysis failed: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Plate Analysis')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ImagePreview(imageBytes: _selectedImageBytes),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isAnalyzing) const _AnalyzingIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_result != null) _ResultCard(result: _result!),
          ],
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final Uint8List? imageBytes;
  const _ImagePreview({required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(18),
          image: imageBytes != null
              ? DecorationImage(
                  image: MemoryImage(imageBytes!), fit: BoxFit.cover)
              : null,
        ),
        child: imageBytes == null
            ? const Center(
                child: Icon(Icons.restaurant_outlined,
                    size: 48, color: Colors.black38),
              )
            : null,
      ),
    );
  }
}

class _AnalyzingIndicator extends StatelessWidget {
  const _AnalyzingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 12),
          Text('Analyzing your plate...'),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final PlateAnalysisResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${result.totalMacros.calories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                _HealthScoreBadge(score: result.healthScore),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _MacroChip(
                    label: 'Protein',
                    value: result.totalMacros.proteinGrams),
                _MacroChip(
                    label: 'Carbs', value: result.totalMacros.carbsGrams),
                _MacroChip(label: 'Fat', value: result.totalMacros.fatGrams),
                _MacroChip(
                    label: 'Fiber', value: result.totalMacros.fiberGrams),
              ],
            ),
            const Divider(height: 28),
            const Text('Detected items',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...result.detectedItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                          '${item.name} · ${item.portionGrams.toStringAsFixed(0)}g'),
                    ),
                    Text('${(item.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final double value;
  const _MacroChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${value.toStringAsFixed(0)}g',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}

class _HealthScoreBadge extends StatelessWidget {
  final int score;
  const _HealthScoreBadge({required this.score});

  Color get _color {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('Health Score: $score',
          style: TextStyle(color: _color, fontWeight: FontWeight.bold)),
    );
  }
}
