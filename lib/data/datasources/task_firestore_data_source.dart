import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';
import '../mappers/task_mapper.dart';
import '../models/task_model.dart';

class TaskFirestoreDataSource {
  final FirebaseFirestore _firestore;

  TaskFirestoreDataSource(this._firestore);

  CollectionReference get _taskCollection =>
      _firestore.collection('tasks');

  Future<List<Task>> getAllTasks() async {
    final snapshot = await _taskCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return TaskMapper.toEntity(TaskModel.fromMap(data));
    }).toList();
  }

  Future<void> createTask(Task task) async {
    final model = TaskMapper.toModel(task);
    await _taskCollection.doc(task.id).set(model.toMap());
  }

  Future<void> updateTask(Task task) async {
    final model = TaskMapper.toModel(task);
    await _taskCollection.doc(task.id).update(model.toMap());
  }

  Future<void> deleteTask(Task task) async {
    await _taskCollection.doc(task.id).delete();
  }
}
