// lib/screens/meal_planner_screen.dart
//
// "Meal Planner" from the blueprint:
// - Daily meal scheduling
// - Weekly meal plans
// - Calorie management
// - Nutrient-balanced diet planning

import 'package:flutter/material.dart';
import '../models/nutrition_model.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  late DateTime _selectedDay;
  final List<DateTime> _weekDays = [];

  // Placeholder plan — replace with Firestore-backed provider keyed by date.
  final Map<String, List<MealEntry>> _plansByDate = {};

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDay = DateTime(today.year, today.month, today.day);
    final monday = _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    for (int i = 0; i < 7; i++) {
      _weekDays.add(monday.add(Duration(days: i)));
    }
    _seedMockData();
  }

  void _seedMockData() {
    final key = _dateKey(_selectedDay);
    _plansByDate[key] = [
      MealEntry(
        id: 'b1',
        title: 'Idli & Sambar',
        slot: MealSlot.breakfast,
        date: _selectedDay,
        macros: const MacroNutrients(
            calories: 280, proteinGrams: 8, carbsGrams: 52, fatGrams: 4, fiberGrams: 5),
        isLogged: true,
      ),
      MealEntry(
        id: 'l1',
        title: 'Brown rice, dal, vegetable curry',
        slot: MealSlot.lunch,
        date: _selectedDay,
        macros: const MacroNutrients(
            calories: 520, proteinGrams: 18, carbsGrams: 88, fatGrams: 9, fiberGrams: 10),
      ),
      MealEntry(
        id: 's1',
        title: 'Mixed nuts & fruit',
        slot: MealSlot.snacks,
        date: _selectedDay,
        macros: const MacroNutrients(
            calories: 180, proteinGrams: 5, carbsGrams: 18, fatGrams: 10, fiberGrams: 4),
      ),
      MealEntry(
        id: 'd1',
        title: 'Grilled fish & sautéed greens',
        slot: MealSlot.dinner,
        date: _selectedDay,
        macros: const MacroNutrients(
            calories: 420, proteinGrams: 38, carbsGrams: 12, fatGrams: 18, fiberGrams: 6),
      ),
    ];
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  List<MealEntry> get _mealsForSelectedDay =>
      _plansByDate[_dateKey(_selectedDay)] ?? [];

  MacroNutrients get _dayTotal {
    var total = MacroNutrients.zero();
    for (final m in _mealsForSelectedDay) {
      total = total + m.macros;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Planner')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMealSheet(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _WeekStrip(
              days: _weekDays,
              selectedDay: _selectedDay,
              onSelect: (d) => setState(() => _selectedDay = d),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Planned total',
                      style: Theme.of(context).textTheme.titleSmall),
                  Text('${_dayTotal.calories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: _mealsForSelectedDay.isEmpty
                  ? const Center(child: Text('No meals planned for this day yet.'))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: MealSlot.values
                          .map((slot) => _MealSlotSection(
                                slot: slot,
                                meals: _mealsForSelectedDay
                                    .where((m) => m.slot == slot)
                                    .toList(),
                                onToggleLogged: (meal) {
                                  setState(() {
                                    final list =
                                        _plansByDate[_dateKey(_selectedDay)]!;
                                    final idx =
                                        list.indexWhere((m) => m.id == meal.id);
                                    list[idx] = meal.copyWith(
                                        isLogged: !meal.isLogged);
                                  });
                                },
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMealSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddMealSheet(),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelect;

  const _WeekStrip(
      {required this.days, required this.selectedDay, required this.onSelect});

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = day.day == selectedDay.day &&
              day.month == selectedDay.month &&
              day.year == selectedDay.year;
          return GestureDetector(
            onTap: () => onSelect(day),
            child: Container(
              width: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_labels[i],
                      style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : Colors.black54)),
                  const SizedBox(height: 4),
                  Text('${day.day}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MealSlotSection extends StatelessWidget {
  final MealSlot slot;
  final List<MealEntry> meals;
  final ValueChanged<MealEntry> onToggleLogged;

  const _MealSlotSection(
      {required this.slot, required this.meals, required this.onToggleLogged});

  String get _label {
    switch (slot) {
      case MealSlot.breakfast:
        return 'Breakfast';
      case MealSlot.lunch:
        return 'Lunch';
      case MealSlot.snacks:
        return 'Snacks';
      case MealSlot.dinner:
        return 'Dinner';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          if (meals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text('Nothing planned', style: TextStyle(color: Colors.black38)),
            ),
          ...meals.map((meal) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Checkbox(
                    value: meal.isLogged,
                    onChanged: (_) => onToggleLogged(meal),
                  ),
                  title: Text(meal.title),
                  subtitle: Text('${meal.macros.calories.toStringAsFixed(0)} kcal'),
                ),
              )),
        ],
      ),
    );
  }
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet();

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _titleController = TextEditingController();
  MealSlot _slot = MealSlot.breakfast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Add a meal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
                labelText: 'Meal name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<MealSlot>(
            initialValue: _slot,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: MealSlot.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                .toList(),
            onChanged: (v) => setState(() => _slot = v ?? _slot),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save meal'),
          ),
        ],
      ),
    );
  }
}
