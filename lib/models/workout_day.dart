import 'exercise.dart';
class WorkoutDay {
  String id; // 'A' or 'B'
  String label;
  List<Exercise> exercises;
  WorkoutDay({
    required this.id,
    required this.label,
    required this.exercises,
  });
  factory WorkoutDay.fromMap(Map<String, dynamic> m) => WorkoutDay(
    id: m['id'] as String,
    label: m['label'] as String,
    exercises: (m['exercises'] as List)
        .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'exercises': exercises.map((e) => e.toMap()).toList(),
  };
}
