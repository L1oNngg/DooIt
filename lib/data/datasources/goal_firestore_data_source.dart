import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalFirestoreDataSource {
  final FirebaseFirestore _firestore;
  GoalFirestoreDataSource(this._firestore);

  Future<List<GoalModel>> getAllGoals() async {
    final snapshot = await _firestore.collection('goals').get();
    // Lấy dữ liệu và convert sang GoalModel
    return snapshot.docs.map((doc) {
      final data = doc.data();
      // Đảm bảo doc.id được truyền
      return GoalModel.fromJson(data, doc.id);
    }).toList();
  }

  Future<void> createGoal(GoalModel goal) async {
    await _firestore.collection('goals').add(goal.toJson());
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _firestore.collection('goals').doc(goal.id).update(goal.toJson());
  }

  Future<void> deleteGoal(String id) async {
    await _firestore.collection('goals').doc(id).delete();
  }

  Future<String> createGoalReturnId(GoalModel goal) async {
    final doc = await _firestore.collection('goals').add(goal.toJson());
    return doc.id;
  }
}
