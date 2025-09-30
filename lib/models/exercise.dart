class ExerciseSet {
  String id;

  int reps; // reps for this specific set
  double? weight; // optional weight for this set (kg)
  bool done; // reserved for future per-set completion
  ExerciseSet({
    required this.id,
    required this.reps,
    this.weight,
    this.done = false,
  });
  factory ExerciseSet.fromMap(Map<String, dynamic> m) => ExerciseSet(
    id: m['id'] as String,
    reps: (m['reps'] as num).toInt(),
    weight: m['weight'] == null
        ? null
        : (m['weight'] is int)
        ? (m['weight'] as int).toDouble()
        : (m['weight'] as num).toDouble(),
    done: m['done'] == true,
  );
  Map<String, dynamic> toMap() => {
    'id': id,
    'reps': reps,
    'weight': weight,
    'done': done,
  };
}
class Exercise {
  String id;
  String name;
  List<ExerciseSet> sets; // variable-length per-set reps/weight
  String? notes;
  Exercise({
    required this.id,
    required this.name,
    required this.sets,
    this.notes,
  });
  factory Exercise.fromMap(Map<String, dynamic> m) => Exercise(
    id: m['id'] as String,
    name: m['name'] as String,
    sets: (m['sets'] as List)
        .map((e) => ExerciseSet.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    notes: m['notes'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'sets': sets.map((s) => s.toMap()).toList(),
    'notes': notes,
  };
}
