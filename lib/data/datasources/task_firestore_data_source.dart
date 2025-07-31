import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';

class TaskFirestoreDataSource {
  final FirebaseFirestore firestore;
  TaskFirestoreDataSource(this.firestore);

  CollectionReference get _tasks => firestore.collection('tasks');

  // ================== CREATE ==================
  Future<void> createTask(Task task) async {
    await _tasks.doc(task.id).set({
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.millisecondsSinceEpoch,
      'dueTime': task.dueTime,
      'priority': task.priority,
      'isCompleted': task.isCompleted,
      'recurrence': task.recurrence,
      'boardId': task.boardId,
      'reminderTime': task.reminderTime?.inMilliseconds,
    });
  }

  // ================== READ ==================
  Future<List<Task>> getAllTasks() async {
    final snapshot = await _tasks.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Task(
        id: data['id'] ?? '',
        title: data['title'] ?? '',
        description: data['description'] ?? '',
        dueDate: DateTime.fromMillisecondsSinceEpoch(data['dueDate']),
        dueTime: data['dueTime'],
        priority: data['priority'] ?? 0,
        isCompleted: data['isCompleted'] ?? false,
        recurrence: data['recurrence'] ?? 'none',
        boardId: data['boardId'] ?? '',
        reminderTime: data['reminderTime'] != null
            ? Duration(milliseconds: data['reminderTime'])
            : null,
      );
    }).toList();
  }

  // ================== UPDATE ==================
  Future<void> updateTask(Task task) async {
    await _tasks.doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.millisecondsSinceEpoch,
      'dueTime': task.dueTime,
      'priority': task.priority,
      'isCompleted': task.isCompleted,
      'recurrence': task.recurrence,
      'boardId': task.boardId,
      'reminderTime': task.reminderTime?.inMilliseconds,
    });
  }

  // ================== DELETE ==================
  Future<void> deleteTask(Task task) async {
    await _tasks.doc(task.id).delete();
  }

  /// Kiểm tra xem đã có task trùng title và dueDate chưa
  Future<bool> existsTaskWithTitleAndDate(String title, DateTime dueDate) async {
    final snapshot = await firestore
        .collection('tasks')
        .where('title', isEqualTo: title)
        .where('dueDate', isEqualTo: Timestamp.fromDate(dueDate))
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  Future<String> createTaskReturnId(Task task) async {
    final doc = await firestore.collection('tasks').add({
      'boardId': task.boardId,
      'title': task.title,
      'description': task.description,
      'dueDate': task.dueDate.millisecondsSinceEpoch,
      'dueTime': task.dueTime,
      'isCompleted': task.isCompleted,
      'priority': task.priority,
      'recurrence': task.recurrence,
      'reminderTime': task.reminderTime != null ? task.reminderTime!.inMilliseconds : null,
    });
    return doc.id;
  }

}
