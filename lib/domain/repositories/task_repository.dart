import '../entities/task.dart';

/// domain/repositories/task_repository.dart
abstract class TaskRepository {
  Future<List<Task>> getAllTasks();
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(Task task);
  Future<List<DateTime>> getCompletions(String taskId, DateTime from, DateTime to);
  Future<void> toggleCompletion(String taskId, DateTime date, bool isCompleted);
  Future<String> createTaskReturnId(Task task);
}
