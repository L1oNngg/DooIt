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

  /// Load boards trực tiếp từ Firestore và cập nhật _defaultBoardId
  Future<void> loadBoards() async {
    final snapshot = await FirebaseFirestore.instance.collection('boards').get();

    if (snapshot.docs.isEmpty) {
      // Không có board nào -> tạo board mặc định
      final newBoardRef = FirebaseFirestore.instance.collection('boards').doc();
      await newBoardRef.set({
        'name': 'DailyLife',
        'description': 'Default board for daily habits and tasks',
        'isDefault': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _defaultBoardId = newBoardRef.id;
      _boards = [
        Board(
          id: _defaultBoardId!,
          name: 'Default Board',
          description: 'Board mặc định tự động tạo',
          isDefault: true,
        ),
      ];
    } else {
      _boards = snapshot.docs.map((doc) {
        final data = doc.data();
        return Board(
          id: doc.id,
          name: data['name'] ?? 'Unnamed',
          description: data['description'] ?? '',
          isDefault: (data['isDefault'] ?? false) as bool,
        );
      }).toList();

      // Chọn board mặc định
      final defaultBoard = _boards.where((b) => b.isDefault).toList();
      if (defaultBoard.isNotEmpty) {
        _defaultBoardId = defaultBoard.first.id;
      } else {
        _defaultBoardId = _boards.first.id; // fallback
      }
    }

    notifyListeners();
  }

  /// Trả về boardId mặc định
  String? getDefaultBoardId() {
    return _defaultBoardId ?? (_boards.isNotEmpty ? _boards.first.id : null);
  }

  /// Fetch từ service (có thể là stream hoặc API riêng)
  Future<void> fetchBoards() async {
    _isLoading = true;
    notifyListeners();
    try {
      _boards = await _boardService.getBoards();

      // Xác định _defaultBoardId từ danh sách boards lấy được
      final defaultBoard = _boards.where((b) => b.isDefault).toList();
      if (defaultBoard.isNotEmpty) {
        _defaultBoardId = defaultBoard.first.id;
      } else if (_boards.isNotEmpty) {
        _defaultBoardId = _boards.first.id;
      } else {
        _defaultBoardId = null;
      }
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
