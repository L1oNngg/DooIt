import 'package:flutter/material.dart';
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

  // Danh sách toàn bộ task
  List<Task> _tasks = [];
  // Danh sách sau khi lọc (để hiển thị)
  List<Task> _filteredTasks = [];

  TaskProvider(
      this._createTaskUseCase,
      this._deleteTaskUseCase,
      this._updateTaskUseCase,
      this._getAllTasksUseCase,
      );

  List<Task> get tasks => _tasks;
  List<Task> get filteredTasks => _filteredTasks;

  /// Hàm tính thời gian còn lại trước khi hết hạn
  Duration? timeRemaining(Task task) {
    final now = DateTime.now();
    if (task.dueDate.isBefore(now)) {
      return Duration.zero;
    }
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

  Future<void> addTask(Task task) async {
    await _createTaskUseCase(task);
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await _updateTaskUseCase(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    await _deleteTaskUseCase(task);
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }

  // Lấy tất cả tasks từ usecase
  Future<void> fetchAllTasks() async {
    final all = await _getAllTasksUseCase();
    _tasks = all;
    _filteredTasks = List.from(_tasks);
    notifyListeners();
  }

  // Lọc tasks theo từ khóa (search)
  List<Task> filterTasks(String keyword) {
    _filteredTasks = _tasks
        .where((task) =>
    task.title.toLowerCase().contains(keyword.toLowerCase()) ||
        task.description.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
    notifyListeners();
    return _filteredTasks;
  }

  // Xóa task theo ID
  Future<void> deleteTaskById(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await _deleteTaskUseCase(task);
    _tasks.removeWhere((t) => t.id == id);
    _filteredTasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
