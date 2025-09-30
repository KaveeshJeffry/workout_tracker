import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/workout_provider.dart';
import '../widgets/exercise_tile.dart';
import 'edit_exercise_screen.dart';
import '../models/exercise.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutProvider>(
      builder: (context, wp, _) {
        if (!wp.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('2-Day Split'),
            bottom: TabBar(
              controller: _tab,
              tabs: const [Tab(text: 'Day A'), Tab(text: 'Day B')],
            ),
            actions: [
              IconButton(
                tooltip: 'View Logs',
                icon: const Icon(Icons.history),
                onPressed: () async {
                  final logs = await wp.loadLogs();
                  if (!context.mounted) return;
                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    useSafeArea: true,
                    builder: (_) => logs.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No logs yet. Complete a day to see history.'),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (_, i) {
                        final l = logs[logs.length - 1 - i];
                        return ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text('Completed Day ${l['dayId']}'),
                          subtitle: Text(DateTime.parse(l['date']).toLocal().toString()),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: logs.length,
                    ),
                  );
                },
              ),
            ],
          ),

          body: TabBarView(
            controller: _tab,
            children: const [
              _DayView(dayId: 'A'),
              _DayView(dayId: 'B'),
            ],
          ),

          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                icon: const Icon(Icons.flag_outlined),
                label: Text('Complete Today (Next: Day ${'${''}'}${wp.nextDayId == 'A' ? 'B' : 'A'})'),
                onPressed: () {
                  wp.completeToday();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Great job! Day completed.')),
                  );
                },
              ),
            ),
          ),
          backgroundColor: cs.surface,
        );
      },
    );
  }
}

class _DayView extends StatelessWidget {
  final String dayId;
  const _DayView({required this.dayId});

  @override
  Widget build(BuildContext context) {
    final wp = context.watch<WorkoutProvider>();
    final day = wp.dayById(dayId);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(day.label, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: () async {
                      final ex = await Navigator.push<Exercise?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditExerciseScreen(dayId: dayId),
                        ),
                      );
                      if (ex != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${ex.name}')),
                        );
                      }
                    },
                    child: const Text('Add Exercise'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Exercises
        Expanded(
          child: day.exercises.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fitness_center, size: 42, color: cs.primary),
                  const SizedBox(height: 12),
                  const Text('No exercises yet.\nTap "Add Exercise" to get started.',
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: day.exercises.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final e = day.exercises[i];
              return ExerciseTile(
                exercise: e,
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditExerciseScreen(dayId: dayId, existing: e),
                    ),
                  );
                },
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete exercise?'),
                      content: Text('Remove "${e.name}" from Day $dayId?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await wp.deleteExercise(dayId, e.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deleted ${e.name}')),
                      );
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
