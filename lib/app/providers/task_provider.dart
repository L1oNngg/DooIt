import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task_use_case.dart';
import '../../domain/usecases/delete_task_use_case.dart';
import '../../domain/usecases/update_task_use_case.dart';
import '../../domain/usecases/get_all_tasks_use_case.dart';

class TaskProvider with ChangeNotifier {
  final CreateTaskUseCase _createTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final GetAllTasksUseCase _getAllTasksUseCase;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];

  TaskProvider(this._createTaskUseCase, this._deleteTaskUseCase, this._updateTaskUseCase, this._getAllTasksUseCase, this._notificationsPlugin) {
    _loadTasks();
  }

  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;

  Future<void> _loadTasks() async {
    try {
      _tasks = await _getAllTasksUseCase();
      _filteredTasks = List.from(_tasks);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi tải tasks: $e');
    }
  }

  void filterTasks({String query = '', String? status, String? boardId}) {
    _filteredTasks = _tasks.where((task) {
      final matchesSearch = query.isEmpty ||
          task.title.toLowerCase().contains(query.toLowerCase()) ||
          (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      final matchesStatus = status == null ||
          (status == 'Completed' && task.isCompleted) ||
          (status == 'Incomplete' && !task.isCompleted);
      final matchesBoard = boardId == null || task.boardId == boardId;
      return matchesSearch && matchesStatus && matchesBoard;
    }).toList();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    try {
      await _createTaskUseCase(task);
      await _scheduleTaskNotification(task);
      await _loadTasks();
    } catch (e) {
      print('Lỗi khi thêm task: $e');
    }
  }

  Future<void> deleteTaskById(String taskId) async {
    try {
      await _deleteTaskUseCase(taskId);
      await _cancelTaskNotification(taskId);
      await _loadTasks();
    } catch (e) {
      print('Lỗi khi xóa task: $e');
    }
  }

  Future<void> updateTask(String taskId, {String? title, String? description, bool? isCompleted, String? boardId, DateTime? dueDate, TimeOfDay? dueTime, String? priority, Duration? reminderTime, String? recurrence}) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = task.copyWith(
        title: title ?? task.title,
        description: description ?? task.description,
        isCompleted: isCompleted ?? task.isCompleted,
        boardId: boardId ?? task.boardId,
        dueDate: dueDate ?? task.dueDate,
        dueTime: dueTime ?? task.dueTime,
        priority: priority ?? task.priority,
        recurrence: recurrence ?? task.recurrence,
        reminderTime: reminderTime ?? task.reminderTime,
      );
      await _updateTaskUseCase(updatedTask);
      if (isCompleted == true) {
        await _cancelTaskNotification(taskId);
      } else {
        await _scheduleTaskNotification(updatedTask);
      }
      await _loadTasks();
    } catch (e) {
      print('Lỗi khi cập nhật task: $e');
    }
  }

  Future<void> _scheduleTaskNotification(Task task) async {
    try {
      if (task.dueDate == null || task.dueTime == null || task.reminderTime == null) {
        print('Không thể lên lịch thông báo: dueDate, dueTime hoặc reminderTime là null');
        return;
      }
      final dueDateTime = tz.TZDateTime(
        tz.local,
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
        task.dueTime!.hour,
        task.dueTime!.minute,
      );
      final reminderDateTime = dueDateTime.subtract(task.reminderTime!);
      if (reminderDateTime.isBefore(DateTime.now())) {
        print('Không thể lên lịch thông báo: reminderDateTime ($reminderDateTime) đã qua');
        return;
      }
      final result = await _notificationsPlugin.zonedSchedule(
        task.id.hashCode,
        'Nhắc nhở: ${task.title}',
        'Đã đến thời gian nhắc nhở task: ${task.description ?? 'Không có mô tả'}',
        reminderDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      if (result == null) {
        print('Lỗi: Không thể lên lịch thông báo cho task: ${task.id}');
      } else {
        print('Đã lên lịch thông báo cho task: ${task.id} tại $reminderDateTime');
      }
    } catch (e) {
      print('Lỗi khi lên lịch thông báo: $e');
    }
  }

  Future<void> _cancelTaskNotification(String taskId) async {
    try {
      await _notificationsPlugin.cancel(taskId.hashCode);
      print('Đã hủy thông báo cho task: $taskId');
    } catch (e) {
      print('Lỗi khi hủy thông báo: $e');
    }
  }

  void notifyListeners() {
    super.notifyListeners();
  }
}