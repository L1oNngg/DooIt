import 'package:cloud_firestore/cloud_firestore.dart';

class BoardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBoard(String name, String description) async {
    await _firestore.collection('boards').add({
      'name': name,
      'description': description.isEmpty ? null : description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBoard(String boardId, String name, String description) async {
    await _firestore.collection('boards').doc(boardId).update({
      'name': name,
      'description': description.isEmpty ? null : description,
    });
  }

  Future<void> deleteBoard(String boardId) async {
    final taskSnapshot = await _firestore.collection('tasks').where('boardId', isEqualTo: boardId).get();
    for (var doc in taskSnapshot.docs) {
      await _firestore.collection('tasks').doc(doc.id).delete();
    }
    await _firestore.collection('boards').doc(boardId).delete();
  }
}