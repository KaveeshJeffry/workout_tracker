import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/workout_provider.dart';

class EditExerciseScreen extends StatefulWidget {
  final String dayId;
  final Exercise? existing;
  const EditExerciseScreen({Key? key, required this.dayId, this.existing}) : super(key: key);

  @override
  State<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends State<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _notes = TextEditingController();
  final List<_SetRow> _rows = [];

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _name.text = ex.name;
      _notes.text = ex.notes ?? '';
      for (final s in ex.sets) {
        _rows.add(_SetRow(reps: s.reps.toString(), weight: s.weight?.toString() ?? ''));
      }
    }
    if (_rows.isEmpty) {
      _rows.addAll([
        _SetRow(reps: '12'),
        _SetRow(reps: '10'),
        _SetRow(reps: '10'),
      ]);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  double? _parseWeight(String input) {
    final t = input.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  void _addSet({String reps = '10', String weight = ''}) {
    HapticFeedback.selectionClick();
    setState(() => _rows.add(_SetRow(reps: reps, weight: weight)));
  }

  void _duplicateLast() {
    if (_rows.isEmpty) return;
    final last = _rows.last;
    _addSet(reps: last.repsCtrl.text, weight: last.weightCtrl.text);
  }

  void _clearWeights() {
    HapticFeedback.selectionClick();
    setState(() {
      for (final r in _rows) {
        r.weightCtrl.text = '';
      }
    });
  }

  void _removeSet(int index) {
    if (_rows.length <= 1) return; // keep at least one
    HapticFeedback.selectionClick();
    setState(() {
      _rows.removeAt(index).dispose();
    });
  }

  void _bumpReps(int index, int delta) {
    final r = _rows[index];
    final cur = int.tryParse(r.repsCtrl.text.trim()) ?? 0;
    final next = (cur + delta).clamp(0, 999);
    setState(() => r.repsCtrl.text = next.toString());
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    // Build Exercise from form
    final sets = <ExerciseSet>[];
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      final reps = int.tryParse(r.repsCtrl.text.trim());
      if (reps == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid reps for each set')),
        );
        return;
      }
      sets.add(ExerciseSet(
        id: '${DateTime.now().microsecondsSinceEpoch}_$i',
        reps: reps,
        weight: _parseWeight(r.weightCtrl.text),
      ));
    }

    final wp = context.read<WorkoutProvider>();
    final ex = Exercise(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      sets: sets,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );

    if (widget.existing == null) {
      await wp.addExercise(widget.dayId, ex);
    } else {
      await wp.updateExercise(widget.dayId, ex);
    }

    if (!mounted) return;
    Navigator.pop(context, ex);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Exercise' : 'Add Exercise'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary.withOpacity(.18), Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Name + notes card
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Exercise name',
                          hintText: 'e.g., Bench Press',
                          prefixIcon: Icon(Icons.edit_outlined),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notes,
                        decoration: const InputDecoration(
                          labelText: 'Notes (optional)',
                          hintText: 'Cues, tempo, etc.',
                          prefixIcon: Icon(Icons.sticky_note_2_outlined),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sets header + actions
              Row(
                children: [
                  Text('Sets (${_rows.length})', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: _addSet,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add set'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _duplicateLast,
                        icon: const Icon(Icons.copy_all_outlined),
                        label: const Text('Duplicate'),
                      ),
                      TextButton.icon(
                        onPressed: _clearWeights,
                        icon: const Icon(Icons.scale_outlined),
                        label: const Text('Clear kg'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Set rows
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Column(
                  children: List.generate(_rows.length, (i) => _buildSetRow(context, i)),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Tip: Leave weight empty if it\'s a bodyweight set. You can use commas or dots for decimals.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.secondary),
              ),
              const SizedBox(height: 100), // space for bottom bar
            ],
          ),
        ),
      ),

      // Bottom action bar
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(isEdit ? 'Save Changes' : 'Add Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetRow(BuildContext context, int index) {
    final cs = Theme.of(context).colorScheme;
    final row = _rows[index];

    final containerColor = cs.brightness == Brightness.dark
        ? cs.surfaceVariant.withOpacity(.30)
        : cs.surfaceVariant.withOpacity(.60);

    return Dismissible(
      key: ValueKey('set-$index-${row.hashCode}'),
      direction: _rows.length > 1 ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (_) async {
        if (_rows.length <= 1) return false;
        _removeSet(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed set S${index + 1}')),
        );
        return false; // we already removed it above
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.25),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(.7)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Index chip
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('S${index + 1}', style: Theme.of(context).textTheme.labelLarge),
              ),
              const SizedBox(width: 10),

              // Reps + steppers
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: row.repsCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) => (v == null || int.tryParse(v) == null) ? 'Number' : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _MiniIconButton(
                      icon: Icons.remove,
                      onTap: () => _bumpReps(index, -1),
                      tooltip: '−1 rep',
                    ),
                    const SizedBox(width: 6),
                    _MiniIconButton(
                      icon: Icons.add,
                      onTap: () => _bumpReps(index, 1),
                      tooltip: '+1 rep',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Weight
              Expanded(
                child: TextFormField(
                  controller: row.weightCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    suffixText: 'kg',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Remove set',
                onPressed: () => _removeSet(index),
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  const _MiniIconButton({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip ?? '',
      child: SizedBox(
        width: 36,
        height: 36,
        child: Material(
          color: cs.primary.withOpacity(.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Icon(icon, size: 18, color: cs.onSurface),
          ),
        ),
      ),
    );
  }
}

class _SetRow {
  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;
  _SetRow({String reps = '10', String weight = ''})
      : repsCtrl = TextEditingController(text: reps),
        weightCtrl = TextEditingController(text: weight);

  void dispose() {
    repsCtrl.dispose();
    weightCtrl.dispose();
  }
}
