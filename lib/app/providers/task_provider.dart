import 'package:flutter/material.dart';
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

class TaskProvider with ChangeNotifier {
  final CreateTaskUseCase _createTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final GetAllTasksUseCase _getAllTasksUseCase;
  final GetTaskCompletionsUseCase _getTaskCompletionsUseCase;
  final ToggleTaskCompletionUseCase _toggleTaskCompletionUseCase;
  final CreateTaskReturnIdUseCase _createTaskReturnIdUseCase;
  final TaskRepository _taskRepository;


  // Danh sách toàn bộ task
  List<Task> _tasks = [];
  // Danh sách sau khi lọc (để hiển thị)
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

  Future<List<DateTime>> getCompletionHistory(String taskId, String recurrence) async {
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

  Future<void> toggleCompletion(String taskId, DateTime date, bool isCompleted) async {
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
    // Tìm task để xóa
    final task = _tasks.firstWhere((t) => t.id == id);

    // Xóa khỏi Firestore
    await _deleteTaskUseCase(task);

    // Xóa khỏi danh sách trong Provider
    _tasks.removeWhere((t) => t.id == id);
    _filteredTasks.removeWhere((t) => t.id == id);

    notifyListeners();
  }


  Future<String> createTaskAndGetId({
    required String title,
    required String description,
    required DateTime dueDate,
    required String recurrence,
  }) async {
    final task = Task(
      id: '', // để Firestore tự sinh id
      boardId: _defaultBoardId ?? '',
      title: title,
      description: description,
      dueDate: dueDate,
      dueTime: null,
      isCompleted: false,
      priority: 1,
      recurrence: recurrence,
      reminderTime: null,
    );

    return await _createTaskReturnIdUseCase(task);
  }

  /// Khởi tạo dữ liệu completion cho Habit (mặc định 30 ngày)
  Future<void> initHabitCompletions(String taskId, DateTime startDate) async {
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30));
    for (DateTime d = startDate;
    !d.isAfter(endDate);
    d = d.add(const Duration(days: 1))) {
      await _toggleTaskCompletionUseCase(taskId, d, false);
    }
  }

  /// Đặt checkpointDate cho habit
  Future<void> setCheckpointDate(String taskId, DateTime date) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await _updateTaskUseCase(task.copyWith(
      // thêm trường mới trong TaskModel nếu có hoặc lưu vào Firestore dạng milliseconds
      description: "${task.description}|checkpoint:${date.millisecondsSinceEpoch}",
    ));
  }

}
