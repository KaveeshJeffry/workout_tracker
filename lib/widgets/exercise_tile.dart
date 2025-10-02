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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    List<Widget> _setChips() {
      return List.generate(exercise.sets.length, (i) {
        final s = exercise.sets[i];
        final hasW = s.weight != null;
        String? wStr;
        if (hasW) {
          final w = s.weight!;
          final isInt = w.remainder(1) == 0.0;
          wStr = isInt ? w.toStringAsFixed(0) : w.toString();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest, // pops nicely on true black
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('S${i + 1}', style: tt.labelMedium),
              const SizedBox(width: 8),
              Text('${s.reps} reps', style: tt.labelMedium),
              if (wStr != null) ...[
                const SizedBox(width: 8),
                const Text('•'),
                const SizedBox(width: 8),
                Text('$wStr kg', style: tt.labelMedium),
              ],
            ],
          ),
        );
      });
    }

    return Card(
      elevation: 0, // rely on outline for separation on black
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant.withOpacity(.7)),
      ),
      child: InkWell(
        onTap: onEdit,
        onLongPress: onEdit, // quick access
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
                child: Icon(Icons.fitness_center, size: 20, color: cs.onSurface),
              ),
              const SizedBox(width: 12),

              // Title + chips + optional notes
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (safe overflow)
                    Text(
                      exercise.name,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Set chips
                    Wrap(
                      spacing: 0,
                      runSpacing: 6,
                      children: _setChips(),
                    ),

                    // Notes (if any)
                    if ((exercise.notes ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        exercise.notes!,
                        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              OverflowBar(
                spacing: 0,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
