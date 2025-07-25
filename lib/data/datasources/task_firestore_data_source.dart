import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../../domain/entities/task.dart';
import '../mappers/task_mapper.dart';

class TaskFirestoreDataSource {
  final FirebaseFirestore _firestore;

  TaskFirestoreDataSource(this._firestore);

  Future<List<Task>> getAllTasks() async {
    try {
      final querySnapshot = await _firestore.collection('tasks').get();
      return querySnapshot.docs
          .map((doc) => TaskMapper.fromModel(TaskModel.fromJson(doc.data())))
          .toList();
    } catch (e) {
      print('Lỗi khi tải danh sách nhiệm vụ: $e');
      throw Exception('Lỗi khi tải danh sách nhiệm vụ: $e');
    }
  }

  Future<void> createTask(Task task) async {
    try {
      final taskModel = TaskMapper.toModel(task);
      print('Đang lưu task: $taskModel vào Firestore với ID: ${task.id}');
      await _firestore.collection('tasks').doc(task.id).set(taskModel.toJson());
      print('Task đã được lưu thành công: ${task.id}');
    } catch (e) {
      print('Lỗi khi tạo nhiệm vụ: $e');
      throw Exception('Lỗi khi tạo nhiệm vụ: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final taskModel = TaskMapper.toModel(task);
      print('Đang cập nhật task: $taskModel với ID: ${task.id}');
      await _firestore.collection('tasks').doc(task.id).update(taskModel.toJson());
      print('Task đã được cập nhật thành công: ${task.id}');
    } catch (e) {
      print('Lỗi khi cập nhật nhiệm vụ: $e');
      throw Exception('Lỗi khi cập nhật nhiệm vụ: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      print('Đang xóa task với ID: $taskId');
      await _firestore.collection('tasks').doc(taskId).delete();
      print('Task đã được xóa thành công: $taskId');
    } catch (e) {
      print('Lỗi khi xóa nhiệm vụ: $e');
      throw Exception('Lỗi khi xóa nhiệm vụ: $e');
    }
  }
}