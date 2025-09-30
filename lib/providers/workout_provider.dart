import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/storage.dart';
import '../models/exercise.dart';
import '../models/workout_day.dart';

class WorkoutProvider extends ChangeNotifier {
  final _store = Storage();
  late WorkoutDay dayA;
  late WorkoutDay dayB;
  String nextDayId = 'A';
  bool _initialized = false;
  bool get initialized => _initialized;

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  List<ExerciseSet> _sets(List<int> reps) =>
      reps.map((r) => ExerciseSet(id: _id(), reps: r)).toList();

  Future<void> init() async {
    try {
      // Try to load any plan (v2 or legacy v1)
      final raw = await _store.loadPlanAny();

      if (raw == null) {
        _seedDefaults();
        await _store.savePlan(_toMap());
        await _store.saveNextDay('A');
      } else {
        // migrate if needed, then parse
        final migrated = _migrateIfNeeded(raw);
        dayA = WorkoutDay.fromMap(migrated['dayA'] as Map<String, dynamic>);
        dayB = WorkoutDay.fromMap(migrated['dayB'] as Map<String, dynamic>);
        // Save back in v2 format to avoid re-migrating next launch
        await _store.savePlan(migrated);
        await _store.removeOldPlanV1();
      }

      nextDayId = (await _store.loadNextDay()) ?? 'A';
    } catch (e) {
      // Fall back to sane defaults if anything goes wrong
      _seedDefaults();
      nextDayId = 'A';
      await _store.savePlan(_toMap());
      await _store.saveNextDay('A');
      if (kDebugMode) {
        // Print for debugging; prevents silent spinner
        // ignore: avoid_print
        print('Init fallback due to: $e');
      }
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  void _seedDefaults() {
    dayA = WorkoutDay(id: 'A', label: 'Day A', exercises: [
      Exercise(id: _id(), name: 'Back Squat', sets: _sets([5, 5, 5, 5, 5])),
      Exercise(id: _id(), name: 'Bench Press', sets: _sets([5, 5, 5, 5, 5])),
      Exercise(id: _id(), name: 'Barbell Row', sets: _sets([8, 8, 8])),
    ]);
    dayB = WorkoutDay(id: 'B', label: 'Day B', exercises: [
      Exercise(id: _id(), name: 'Deadlift', sets: _sets([5, 5, 5])),
      Exercise(id: _id(), name: 'Overhead Press', sets: _sets([5, 5, 5, 5, 5])),
      Exercise(id: _id(), name: 'Pull-ups', sets: _sets([8, 8, 8])),
    ]);
  }

  Map<String, dynamic> _toMap() => {
    'dayA': dayA.toMap(),
    'dayB': dayB.toMap(),
  };

  /// Migrates legacy v1 shape (Exercise had: sets:int, reps:int, weight:double?)
  /// -> to v2 shape (Exercise has: sets: List<ExerciseSet>).
  Map<String, dynamic> _migrateIfNeeded(Map<String, dynamic> plan) {
    Map<String, dynamic> clone = {
      'dayA': Map<String, dynamic>.from(plan['dayA'] as Map),
      'dayB': Map<String, dynamic>.from(plan['dayB'] as Map),
    };

    for (final dayKey in ['dayA', 'dayB']) {
      final day = clone[dayKey] as Map<String, dynamic>;
      final exercises = List<Map<String, dynamic>>.from(day['exercises'] as List);
      for (var i = 0; i < exercises.length; i++) {
        final ex = Map<String, dynamic>.from(exercises[i]);
        final setsField = ex['sets'];
        final hasTopReps = ex.containsKey('reps'); // legacy marker
        if (setsField is int && hasTopReps) {
          final int setCount = setsField;
          final int reps = (ex['reps'] as num).toInt();
          final dynamic w = ex['weight']; // may be null/double/int

          final double? weight = (w == null)
              ? null
              : (w is int)
              ? w.toDouble()
              : (w as num).toDouble();

          final newSets = List.generate(setCount, (idx) {
            return {
              'id': '${DateTime.now().microsecondsSinceEpoch}_$idx',
              'reps': reps,
              'weight': weight,
              'done': false,
            };
          });

          ex.remove('reps');
          ex.remove('weight');
          ex['sets'] = newSets;
          exercises[i] = ex;
        } else if (setsField is List) {
          // already v2 → leave as-is
        } else {
          // unknown shape → reset this exercise to a safe default
          ex['sets'] = _sets([10, 10, 10]).map((s) => s.toMap()).toList();
          ex.remove('reps');
          ex.remove('weight');
          exercises[i] = ex;
        }
      }
      day['exercises'] = exercises;
      clone[dayKey] = day;
    }

    return clone;
  }

  WorkoutDay get currentDay => nextDayId == 'A' ? dayA : dayB;
  WorkoutDay dayById(String id) => id == 'A' ? dayA : dayB;

  Future<void> addExercise(String dayId, Exercise ex) async {
    dayById(dayId).exercises.add(ex);
    await _persist();
    notifyListeners();
  }

  Future<void> updateExercise(String dayId, Exercise ex) async {
    final list = dayById(dayId).exercises;
    final idx = list.indexWhere((e) => e.id == ex.id);
    if (idx != -1) list[idx] = ex;
    await _persist();
    notifyListeners();
  }

  Future<void> deleteExercise(String dayId, String exerciseId) async {
    dayById(dayId).exercises.removeWhere((e) => e.id == exerciseId);
    await _persist();
    notifyListeners();
  }

  Future<void> completeToday() async {
    final today = DateTime.now().toIso8601String();
    await _store.addLog({'date': today, 'dayId': nextDayId});
    nextDayId = nextDayId == 'A' ? 'B' : 'A';
    await _store.saveNextDay(nextDayId);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> loadLogs() => _store.loadLogs();

  Future<void> _persist() async => _store.savePlan(_toMap());
}
