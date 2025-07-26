import 'package:flutter/material.dart';

import '../../core/services/notification_service.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_all_tasks_use_case.dart';
import '../../domain/usecases/create_task_use_case.dart';
import '../../domain/usecases/update_task_use_case.dart';
import '../../domain/usecases/delete_task_use_case.dart';

class TaskProvider extends ChangeNotifier {
  final GetAllTasksUseCase _getAllTasksUseCase;
  final CreateTaskUseCase _createTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  TaskProvider(
      this._getAllTasksUseCase,
      this._createTaskUseCase,
      this._updateTaskUseCase,
      this._deleteTaskUseCase,
      );

  Future<void> fetchTasks() async {
    _tasks = await _getAllTasksUseCase();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _createTaskUseCase(task);

    // Lên lịch notification nếu có dueDate và reminderTime
    if (task.dueDate != null && task.reminderTime != null) {
      final scheduledDateTime = task.dueDate!.subtract(task.reminderTime!);
      await NotificationService().scheduleTaskNotification(
        id: task.hashCode,
        title: 'Nhắc nhở công việc',
        body: task.title,
        scheduledDateTime: scheduledDateTime,
      );
    }

    await fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await _updateTaskUseCase(task);

    // Hủy notification cũ và lên lịch lại
    await NotificationService().cancelNotification(task.hashCode);

    if (task.dueDate != null && task.reminderTime != null) {
      final scheduledDateTime = task.dueDate!.subtract(task.reminderTime!);
      await NotificationService().scheduleTaskNotification(
        id: task.hashCode,
        title: 'Nhắc nhở công việc',
        body: task.title,
        scheduledDateTime: scheduledDateTime,
      );
    }

    await fetchTasks();
  }

  Future<void> deleteTaskById(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await NotificationService().cancelNotification(task.hashCode);
    await _deleteTaskUseCase(task);
    await fetchTasks();
  }

  Future<void> completeTask(Task task) async {
    // 1. Đánh dấu task hiện tại hoàn thành
    final updatedTask = task.copyWith(isCompleted: true);
    await _updateTaskUseCase(updatedTask);

    // 2. Hủy notification của task cũ
    await NotificationService().cancelNotification(task.hashCode);

    // 3. Nếu có recurrence thì tạo task mới với dueDate mới
    if (task.recurrence != 'none' && task.dueDate != null) {
      DateTime newDueDate;
      switch (task.recurrence) {
        case 'daily':
          newDueDate = task.dueDate!.add(const Duration(days: 1));
          break;
        case 'weekly':
          newDueDate = task.dueDate!.add(const Duration(days: 7));
          break;
        case 'monthly':
          newDueDate = DateTime(
            task.dueDate!.year,
            task.dueDate!.month + 1,
            task.dueDate!.day,
            task.dueDate!.hour,
            task.dueDate!.minute,
          );
          break;
        default:
          newDueDate = task.dueDate!;
      }

      final newTask = task.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        isCompleted: false,
        dueDate: newDueDate,
      );

      // addTask sẽ lo phần notification
      await addTask(newTask);
    }

    // 4. Refresh danh sách
    await fetchTasks();
  }

  List<Task> filterTasks(String keyword) {
    return _tasks
        .where((t) => t.title.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }
}
