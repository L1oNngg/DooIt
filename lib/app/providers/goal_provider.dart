import 'package:flutter/material.dart';
import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import 'package:get_it/get_it.dart';

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
      String name,
      List<String> taskIds, {
        bool isHabit = false,
        String? habitTitle,
        String? habitDesc,
        DateTime? habitDueDate,
        DateTime? checkpointDate,
      }) async {
    DateTime? finalCheckpointDate = checkpointDate;

    // Nếu là habit, tạo task mới cho habit và khởi tạo lịch completions
    if (isHabit && habitTitle != null) {
      final start = habitDueDate ?? DateTime.now();
      final newTaskId = await taskProvider.createTaskAndGetId(
        title: habitTitle,
        description: habitDesc ?? '',
        dueDate: start,
        recurrence: 'daily',
      );

      // tạo dữ liệu completions 1 tháng
      await taskProvider.initHabitCompletions(newTaskId, start);

      // Nếu chưa có checkpointDate thì mặc định 30 ngày kể từ start
      finalCheckpointDate ??= start.add(const Duration(days: 30));

      taskIds.add(newTaskId);
    }

    // Tạo Goal entity
    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // tự sinh id tạm
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
      checkpointDate: DateTime.now(), // mỗi lần update cập nhật checkpoint
    );
    await _repository.updateGoal(updatedGoal);
    await loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
    await loadGoals();
  }
}
