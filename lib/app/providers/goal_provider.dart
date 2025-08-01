import 'package:flutter/material.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../providers/task_provider.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _repository;
  final TaskProvider taskProvider;

  GoalProvider(this._repository, this.taskProvider);

  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  Future<void> loadGoals() async {
    _goals = await _repository.getAllGoals();
    notifyListeners();
  }

  Future<void> createGoal(
      BuildContext context,
      String name,
      List<String> taskIds, {
        bool isHabit = false,
        String? habitTitle,
        String? habitDesc,
        DateTime? habitDueDate,
        DateTime? checkpointDate,
      }) async {
    DateTime? finalCheckpointDate = checkpointDate;

    if (isHabit && habitTitle != null) {
      final start = habitDueDate ?? DateTime.now();
      final newTaskId = await taskProvider.createTaskAndGetId(
        context: context,
        title: habitTitle,
        description: habitDesc ?? '',
        dueDate: start,
        recurrence: 'daily',
      );

      await taskProvider.initHabitCompletions(newTaskId, start);

      finalCheckpointDate ??= start.add(const Duration(days: 30));
      taskIds.add(newTaskId);
    }

    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: '',
      taskIds: taskIds,
      progress: 0,
      isHabit: isHabit,
      checkpointDate: finalCheckpointDate ?? DateTime.now(),
    );

    await _repository.createGoal(newGoal);
    await loadGoals();
  }

  Future<void> updateGoal(Goal goal) async {
    final updatedGoal = goal.copyWith(
      checkpointDate: DateTime.now(),
    );
    await _repository.updateGoal(updatedGoal);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
    await loadGoals();
  }
}
