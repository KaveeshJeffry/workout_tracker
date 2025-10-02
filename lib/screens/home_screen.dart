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
    final cs = Theme.of(context).colorScheme;

    return Consumer<WorkoutProvider>(
      builder: (context, wp, _) {
        if (!wp.initialized) {
          return Scaffold(
            backgroundColor: cs.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          extendBody: true,
          backgroundColor: cs.surface,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: const Text('2-Day Split'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cs.primary.withOpacity(.22), cs.secondary.withOpacity(.18)],
                ),
              ),
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
                    useSafeArea: true,
                    showDragHandle: true,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    builder: (_) {
                      if (logs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.hourglass_empty, size: 42, color: cs.primary),
                              const SizedBox(height: 12),
                              const Text('No logs yet. Complete a day to see history.'),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Workout History', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: logs.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (_, i) {
                                  final l = logs[logs.length - 1 - i];
                                  final dt = DateTime.parse(l['date']).toLocal();
                                  final pretty = _formatDateTime(dt);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: cs.primaryContainer,
                                      child: Icon(Icons.check, color: cs.onPrimaryContainer),
                                    ),
                                    title: Text('Completed Day ${l['dayId']}'),
                                    subtitle: Text(pretty),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _SegmentedTabs(controller: _tab, tabs: const [Tab(text: 'Day A'), Tab(text: 'Day B')]),
              ),
            ),
          ),

          body: TabBarView(
            controller: _tab,
            children: const [
              _DayView(dayId: 'A'),
              _DayView(dayId: 'B'),
            ],
          ),

          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary.withOpacity(.10), cs.secondary.withOpacity(.10)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.flag_outlined),
                    label: Text('Complete Today • Next: Day ${wp.nextDayId == 'A' ? 'B' : 'A'}'),
                    onPressed: () {
                      wp.completeToday();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Great job! Day completed.')),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
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
    final cs = Theme.of(context).colorScheme;
    final wp = context.watch<WorkoutProvider>();
    final day = wp.dayById(dayId);

    // Stats (safe calculations)
    final int exerciseCount = day.exercises.length;
    final int setCount = day.exercises.fold<int>(0, (sum, e) => sum + (e.sets?.length ?? 0));

    return Column(
      children: [
        // Day header card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.surfaceContainerHighest, cs.surfaceContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(day.label, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _StatChip(icon: Icons.fitness_center, label: '$exerciseCount exercises'),
                          const SizedBox(width: 8),
                          _StatChip(icon: Icons.list_alt, label: '$setCount sets'),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final ex = await Navigator.push<Exercise?>(
                        context,
                        MaterialPageRoute(builder: (_) => EditExerciseScreen(dayId: dayId)),
                      );
                      if (ex != null && context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Added ${ex.name}')));
                      }
                    },
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Exercises
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: day.exercises.isEmpty
                ? _EmptyState(
              key: const ValueKey('empty'),
              icon: Icons.self_improvement,
              title: 'No exercises yet',
              message: 'Tap “Add” to create your first exercise.',
            )
                : ListView.separated(
              key: const ValueKey('list'),
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
                        content: Text('Remove “${e.name}” from Day $dayId?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await wp.deleteExercise(dayId, e.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Deleted ${e.name}')));
                      }
                    }
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;
  const _SegmentedTabs({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(6),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        splashBorderRadius: BorderRadius.circular(10),
        indicator: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: cs.onPrimary,
        unselectedLabelColor: cs.onSurfaceVariant,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: cs.onPrimaryContainer)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({super.key, required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: cs.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  final y = dt.year.toString();
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  return '$y-$m-$d • $h:$min';
}
