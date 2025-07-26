import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_firestore_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskFirestoreDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

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
}
