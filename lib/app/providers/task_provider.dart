import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';

import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task_return_id_usecase.dart';
import '../../domain/usecases/create_task_use_case.dart';
import '../../domain/usecases/delete_task_use_case.dart';
import '../../domain/usecases/get_task_completions_usecase.dart';
import '../../domain/usecases/toggle_task_completion_usecase.dart';
import '../../domain/usecases/update_task_use_case.dart';
import '../../domain/usecases/get_all_tasks_use_case.dart';
import 'board_provider.dart';
import '../../core/services/notification_service.dart';

class TaskProvider with ChangeNotifier {
  final CreateTaskUseCase _createTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final GetAllTasksUseCase _getAllTasksUseCase;
  final GetTaskCompletionsUseCase _getTaskCompletionsUseCase;
  final ToggleTaskCompletionUseCase _toggleTaskCompletionUseCase;
  final CreateTaskReturnIdUseCase _createTaskReturnIdUseCase;
  final TaskRepository _taskRepository;
  final NotificationService _notificationService = NotificationService();

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];

  String? _defaultBoardId;
  void setDefaultBoardId(String id) {
    _defaultBoardId = id;
  }

  TaskProvider(
      this._createTaskUseCase,
      this._deleteTaskUseCase,
      this._updateTaskUseCase,
      this._getAllTasksUseCase,
      this._getTaskCompletionsUseCase,
      this._toggleTaskCompletionUseCase,
      this._createTaskReturnIdUseCase,
      this._taskRepository,
      );

  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;

  Duration? timeRemaining(Task task) {
    final now = DateTime.now();
    if (task.dueDate.isBefore(now)) return Duration.zero;
    return task.dueDate.difference(now);
  }

  bool isUrgent(Task task) {
    final remaining = timeRemaining(task);
    if (remaining == null) return false;
    return remaining.inMinutes <= 5 && remaining.inSeconds > 0;
  }

  Future<void> loadTasks() async {
    _tasks = await _getAllTasksUseCase();
    notifyListeners();
  }

  Future<List<DateTime>> getCompletionHistory(
      String taskId, String recurrence) async {
    final now = DateTime.now();
    late DateTime from;
    if (recurrence == 'daily') {
      from = now.subtract(const Duration(days: 30));
    } else if (recurrence == 'weekly') {
      from = now.subtract(const Duration(days: 60));
    } else {
      from = DateTime(now.year, now.month - 6, now.day);
    }
    return _getTaskCompletionsUseCase(taskId, from, now);
  }

  Future<void> toggleCompletion(
      String taskId, DateTime date, bool isCompleted) async {
    await _toggleTaskCompletionUseCase(taskId, date, isCompleted);
    notifyListeners();
  }

  Future<void> addTask(Task task, BuildContext context) async {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final boardId = task.boardId.isNotEmpty
        ? task.boardId
        : (boardProvider.getDefaultBoardId() ?? '');
    final newTask = task.copyWith(boardId: boardId);

    await _taskRepository.addTask(newTask);

    // Gọi notification countdown
    await scheduleTaskNotifications(newTask);

    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    // Tìm task cũ để so sánh dueDate
    final oldTaskIndex = _tasks.indexWhere((t) => t.id == task.id);
    DateTime? oldDueDate =
    oldTaskIndex != -1 ? _tasks[oldTaskIndex].dueDate : null;

    await _updateTaskUseCase(task);

    // Kiểm tra nếu dueDate bị thay đổi hoặc gần tới hạn thì reschedule notification
    if (oldDueDate == null || oldDueDate != task.dueDate) {
      await scheduleTaskNotifications(task);
    }

    if (oldTaskIndex != -1) {
      _tasks[oldTaskIndex] = task;
      notifyListeners();
    }
  }


  Future<void> deleteTask(Task task) async {
    await _deleteTaskUseCase(task);
    await cancelTaskNotifications(task);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  Future<void> fetchAllTasks() async {
    final all = await _getAllTasksUseCase();
    _tasks = all;
    _filteredTasks = List.from(_tasks);
    notifyListeners();
  }

  List<Task> filterTasks(String keyword) {
    _filteredTasks = _tasks
        .where((task) =>
    task.title.toLowerCase().contains(keyword.toLowerCase()) ||
        task.description.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    notifyListeners();
    return _filteredTasks;
  }

  Future<void> deleteTaskById(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await _deleteTaskUseCase(task);
    await cancelTaskNotifications(task);
    _tasks.removeWhere((t) => t.id == id);
    _filteredTasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<String> createTaskAndGetId({
    required BuildContext context,
    required String title,
    required String description,
    required DateTime dueDate,
    required String recurrence,
  }) async {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    final defaultId = boardProvider.getDefaultBoardId() ?? '';

    final task = Task(
      id: '',
      boardId: defaultId,
      title: title,
      description: description,
      dueDate: dueDate,
      dueTime: null,
      isCompleted: false,
      priority: 1,
      recurrence: recurrence,
      reminderTime: null,
    );

    final id = await _createTaskReturnIdUseCase(task);
    // tạo xong vẫn cần schedule
    await scheduleTaskNotifications(task.copyWith(id: id));
    return id;
  }

  Future<void> initHabitCompletions(String taskId, DateTime startDate) async {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30));
    for (DateTime d = startDate;
    !d.isAfter(endDate);
    d = d.add(const Duration(days: 1))) {
      await _toggleTaskCompletionUseCase(taskId, d, false);
    }
  }

  Future<void> setCheckpointDate(String taskId, DateTime date) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await _updateTaskUseCase(task.copyWith(
      description:
      "${task.description}|checkpoint:${date.millisecondsSinceEpoch}",
    ));
  }

  Future<void> scheduleTaskNotifications(Task task) async {
    await _notificationService.cancelNotification(task.id.hashCode);

    final dueDateTime = task.dueDate;

    // Thông báo nhắc trước (reminder)
    if (task.reminderTime != null) {
      final reminderDateTime = dueDateTime.subtract(task.reminderTime!);
      if (reminderDateTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: task.id.hashCode,
          title: 'Nhắc nhở: ${task.title}',
          body:
          'Sắp đến hạn vào lúc ${DateFormat('HH:mm dd/MM').format(dueDateTime)}',
          scheduledTime: reminderDateTime,
        );
      }
    }

    // Nếu còn <= 10 phút thì show ngay 1 notification
    final remaining = dueDateTime.difference(DateTime.now());
    if (remaining.inMinutes < 10 && !remaining.isNegative) {
      final minutesLeft = remaining.inMinutes;
      await _notificationService.showNotification(
        id: task.id.hashCode,
        title: 'Sắp hết hạn: ${task.title}',
        body: 'Còn $minutesLeft phút nữa đến hạn',
      );
    }

    // Đặt countdown 10 phút cuối
    final tenMinBefore = dueDateTime.subtract(const Duration(minutes: 10));
    if (tenMinBefore.isAfter(DateTime.now())) {
      _startCountdownNotifications(task);
    } else if (remaining.inMinutes > 0) {
      // Nếu đã trong khoảng 10 phút thì cũng bắt đầu countdown ngay
      _startCountdownNotifications(task);
    }
  }


  Future<void> cancelTaskNotifications(Task task) async {
    await _notificationService.cancelNotification(task.id.hashCode);
  }

  void _startCountdownNotifications(Task task) {
    final dueDateTime = task.dueDate;

    Timer.periodic(const Duration(minutes: 1), (timer) async {
      final remaining = dueDateTime.difference(DateTime.now());

      if (remaining.isNegative) {
        await _notificationService.showNotification(
          id: task.id.hashCode,
          title: 'Hết hạn: ${task.title}',
          body: 'Nhiệm vụ đã đến hạn!',
        );
        timer.cancel();
      } else if (remaining.inMinutes <= 10) {
        // 10 phút cuối
        await _notificationService.showNotification(
          id: task.id.hashCode,
          title: 'Sắp hết hạn: ${task.title}',
          body: 'Còn ${remaining.inMinutes} phút nữa đến hạn',
        );

        if (remaining.inMinutes == 0) {
          timer.cancel();
        }
      }
    });
  }
}
