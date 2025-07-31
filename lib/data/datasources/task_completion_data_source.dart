import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCompletionDataSource {
  final FirebaseFirestore firestore;

  TaskCompletionDataSource(this.firestore);

  Future<Map<String, bool>> getCompletionsForDate(String dateKey) async {
    final snapshot = await firestore
        .collection('task_completions')
        .where('date', isEqualTo: dateKey)
        .get();

    return {
      for (var doc in snapshot.docs)
        doc['taskId'] as String: doc['completed'] as bool
    };
  }

  /// Lấy danh sách completion của 1 task trong khoảng thời gian
  Future<List<DateTime>> getCompletions(String taskId, DateTime from, DateTime to) async {
    final snapshot = await firestore
        .collection('task_completions')
        .where('taskId', isEqualTo: taskId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .get();

    return snapshot.docs
        .where((doc) => (doc.data()['isCompleted'] ?? false) == true)
        .map((doc) => (doc.data()['date'] as Timestamp).toDate())
        .toList();
  }

  /// Toggle completion cho 1 ngày cụ thể
  Future<void> toggleCompletion(String taskId, DateTime date, bool isCompleted) async {
    final day = DateTime(date.year, date.month, date.day);
    final ref = firestore.collection('task_completions').doc('${taskId}_${day.toIso8601String()}');
    if (isCompleted) {
      await ref.set({
        'taskId': taskId,
        'date': Timestamp.fromDate(day),
        'isCompleted': true,
      });
    } else {
      // Nếu bỏ đánh dấu thì xóa document
      await ref.delete();
    }
  }

  Future<void> setCompletion(String taskId, String dateKey, bool completed) async {
    await firestore.collection('task_completions')
        .doc('${taskId}_$dateKey')
        .set({
      'taskId': taskId,
      'date': dateKey,
      'completed': completed,
    });
  }
}
