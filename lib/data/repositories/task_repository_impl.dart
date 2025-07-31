import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_firestore_data_source.dart';
import '../datasources/task_completion_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskFirestoreDataSource _dataSource;
  final TaskCompletionDataSource completionDataSource;

  TaskRepositoryImpl(this._dataSource, this.completionDataSource);

  @override
  Future<List<Task>> getAllTasks() async {
    return await _dataSource.getAllTasks();
  }

  @override
  Future<void> addTask(Task task) async {
    return await _dataSource.createTask(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    return await _dataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(Task task) async {
    return await _dataSource.deleteTask(task);
  }

  @override
  Future<List<DateTime>> getCompletions(String taskId, DateTime from, DateTime to) async {
    return completionDataSource.getCompletions(taskId, from, to);
  }

  @override
  Future<void> toggleCompletion(String taskId, DateTime date, bool isCompleted) async {
    return completionDataSource.toggleCompletion(taskId, date, isCompleted);
  }

  @override
  Future<String> createTaskReturnId(Task task) async {
    return _dataSource.createTaskReturnId(task);
  }

}
