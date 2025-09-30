import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseTile extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExerciseTile({
    super.key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Build small chips like: S1 10 | 20kg
    List<Widget> _setChips() {
      return List.generate(exercise.sets.length, (i) {
        final s = exercise.sets[i];
        final hasW = s.weight != null;
        final isInt = hasW ? (s.weight == s.weight!.roundToDouble()) : false;
        final w = hasW ? (isInt ? s.weight!.toStringAsFixed(0) : s.weight!.toString()) : null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('S${i + 1}', style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(width: 8),
              Text('${s.reps} reps', style: Theme.of(context).textTheme.labelMedium),
              if (w != null) ...[
                const SizedBox(width: 8),
                const Text('•'),
                const SizedBox(width: 8),
                Text('$w kg', style: Theme.of(context).textTheme.labelMedium),
              ],
            ],
          ),
        );
      });
    }

    return Card(
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              // Leading icon bubble
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.fitness_center, size: 20),
              ),
              const SizedBox(width: 12),

              // Title + chips + optional notes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(children: _setChips()),
                    if ((exercise.notes ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        exercise.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.secondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
