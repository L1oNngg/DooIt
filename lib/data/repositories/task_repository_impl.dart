
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_firestore_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskFirestoreDataSource _dataSource;

  TaskRepositoryImpl(this._dataSource);

  @override
  Future<List<Task>> getAllTasks() async {
    try {
      return await _dataSource.getAllTasks();
    } catch (e) {
      throw Exception('Lỗi repository khi tải danh sách nhiệm vụ: $e');
    }
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      await _dataSource.createTask(task); // Sử dụng createTask của data source, giả định chúng tương đương
    } catch (e) {
      throw Exception('Lỗi repository khi thêm nhiệm vụ: $e');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      await _dataSource.updateTask(task);
    } catch (e) {
      throw Exception('Lỗi repository khi cập nhật nhiệm vụ: $e');
    }
  }

  @override
  Future<void> deleteTask(Task task) async {
    try {
      await _dataSource.deleteTask(task.id);
    } catch (e) {
      throw Exception('Lỗi repository khi xóa nhiệm vụ: $e');
    }
  }
}