import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/board.dart';
import '../../data/services/board_service.dart';

class BoardProvider with ChangeNotifier {
  final BoardService _boardService = BoardService();

  List<Board> _boards = [];
  String? _defaultBoardId;
  List<Board> get boards => _boards;
  String? get defaultBoardId => _defaultBoardId;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BoardProvider() {
    fetchBoards();
  }

  Future<void> loadBoards() async {
    final snapshot = await FirebaseFirestore.instance.collection('boards').get();

    if (snapshot.docs.isEmpty) {
      // Tạo board mặc định
      final newBoardRef = FirebaseFirestore.instance.collection('boards').doc();
      await newBoardRef.set({
        'name': 'Default',
        'description': 'Default board',
        'isDefault': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _defaultBoardId = newBoardRef.id;
      _boards = [
        Board(
          id: _defaultBoardId!,
          name: 'Default',
          description: 'Default board',
          isDefault: true,
        ),
      ];
    } else {
      _boards = snapshot.docs.map((doc) {
        return Board(
          id: doc.id,
          name: doc['name'] ?? 'Unnamed',
          description: doc['description'] ?? '',
          isDefault: doc['isDefault'] ?? false,
        );
      }).toList();

      _defaultBoardId = _boards.firstWhere(
            (b) => b.isDefault,
        orElse: () => _boards.first,
      ).id;
    }

    notifyListeners();
  }

  String? getDefaultBoardId() {
    return _defaultBoardId ?? (_boards.isNotEmpty ? _boards.first.id : null);
  }

  Future<void> fetchBoards() async {
    _isLoading = true;
    notifyListeners();
    try {
      _boards = await _boardService.getBoards();
    } catch (e) {
      debugPrint('Error fetching boards: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBoard(Board board) async {
    await _boardService.createBoard(board);
    await fetchBoards();
  }

  Future<void> updateBoard(Board board) async {
    await _boardService.updateBoard(board);
    await fetchBoards();
  }

  Future<void> deleteBoard(String id) async {
    await _boardService.deleteBoard(id);
    await fetchBoards();
  }
}
