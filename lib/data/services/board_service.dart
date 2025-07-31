import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/board.dart';

class BoardService {
  final _firestore = FirebaseFirestore.instance;
  static const defaultBoardName = 'DailyLife';

  /// Đảm bảo board mặc định tồn tại, trả về id của nó
  Future<String> ensureDefaultBoard() async {
    final query = await _firestore
        .collection('boards')
        .where('isDefault', isEqualTo: true)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }

    final ref = await _firestore.collection('boards').add({
      'name': defaultBoardName,
      'description': 'Default board for daily habits and tasks',
      'isDefault': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<List<Board>> getBoards() async {
    final snap = await _firestore.collection('boards').get();
    return snap.docs
        .map((doc) => Board.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> createBoard(Board board) async {
    await _firestore.collection('boards').add(board.toMap());
  }

  Future<void> updateBoard(Board board) async {
    await _firestore.collection('boards').doc(board.id).update(board.toMap());
  }

  Future<void> deleteBoard(String boardId) async {
    final doc = await _firestore.collection('boards').doc(boardId).get();
    final data = doc.data();
    if (data != null && data['isDefault'] == true) {
      throw Exception("Cannot delete default board");
    }
    await _firestore.collection('boards').doc(boardId).delete();
  }
}
