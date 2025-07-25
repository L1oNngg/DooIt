import 'package:cloud_firestore/cloud_firestore.dart';

class GoalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createGoal(String title, DateTime targetDate, String priority, List<String> taskIds) async {
    await _firestore.collection('goals').add({
      'title': title,
      'targetDate': targetDate.toUtc(),
      'priority': priority,
      'taskIds': taskIds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateGoal(String goalId, String title, DateTime targetDate, String priority, List<String> taskIds) async {
    await _firestore.collection('goals').doc(goalId).update({
      'title': title,
      'targetDate': targetDate.toUtc(),
      'priority': priority,
      'taskIds': taskIds,
    });
  }

  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection('goals').doc(goalId).delete();
  }
}