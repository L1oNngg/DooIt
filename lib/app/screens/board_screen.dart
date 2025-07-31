import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/board_provider.dart';
import '../widgets/app_bottom_nav.dart';

class BoardScreen extends StatefulWidget {
  final String? boardId;
  final String? boardName;

  const BoardScreen({super.key, this.boardId, this.boardName});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  String? _selectedBoardId;

  @override
  void initState() {
    super.initState();
    // Nếu có tham số truyền vào, set sẵn
    _selectedBoardId = widget.boardId;
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final boardProvider = Provider.of<BoardProvider>(context);

    final boards = boardProvider.boards;

    final tasks = taskProvider.tasks.where((task) {
      if (_selectedBoardId == null) return true;
      return task.boardId == _selectedBoardId;
    }).toList();

    // Lấy tên board
    final selectedBoardName = _selectedBoardId == null
        ? "Tất cả Boards"
        : (boards.isNotEmpty
        ? boards.firstWhere(
          (b) => b.id == _selectedBoardId,
      orElse: () => boards.first,
    ).name
        : (widget.boardName ?? "Board"));

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return ListView(
                  children: [
                    ListTile(
                      title: const Text('Tất cả Boards'),
                      onTap: () {
                        setState(() {
                          _selectedBoardId = null;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ...boards.map(
                          (b) => ListTile(
                        title: Text(b.name),
                        onTap: () {
                          setState(() {
                            _selectedBoardId = b.id;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            'Bảng: ${widget.boardName ?? selectedBoardName}',
          ),
        ),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Không có nhiệm vụ nào trong bảng này'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(task.title),
              subtitle: Text(task.description),
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }
}
