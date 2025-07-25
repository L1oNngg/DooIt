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

  // Lấy toàn bộ tasks
  Future<void> fetchTasks() async {
    _tasks = await _getAllTasksUseCase();
    notifyListeners();
  }

  // Thêm task
  Future<void> addTask(Task task) async {
    await _createTaskUseCase(task);

    // Notification: nếu có dueDate + reminderTime
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

  // Cập nhật task
  Future<void> updateTask(Task task) async {
    await _updateTaskUseCase(task);

    // Hủy notification cũ
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

  // Xóa task theo id
  Future<void> deleteTaskById(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await NotificationService().cancelNotification(task.hashCode);
    await _deleteTaskUseCase(task);
    await fetchTasks();
  }

  // Hoàn thành task
  Future<void> completeTask(Task task) async {
    final updated = task.copyWith(isCompleted: true);
    await _updateTaskUseCase(updated);
    await NotificationService().cancelNotification(task.hashCode);
    await fetchTasks();
  }

  // Lọc tasks theo keyword (đơn giản)
  List<Task> filterTasks(String keyword) {
    return _tasks
        .where((t) => t.title.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }
}
