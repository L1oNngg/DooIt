import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/task.dart';
import '../../data/services/board_service.dart';
import '../../data/mappers/task_mapper.dart';
import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final BoardService _boardService = BoardService();
  final _searchController = TextEditingController();
  String? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boards')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm nhiệm vụ trong board...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _filterStatus,
              hint: Text('Lọc theo trạng thái'),
              items: ['All', 'Completed', 'Incomplete'].map((String status) {
                return DropdownMenuItem<String>(
                  value: status == 'All' ? null : status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _filterStatus = value);
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('boards').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Lỗi tải boards: ${snapshot.error}'));
                final boards = snapshot.data!.docs;
                if (boards.isEmpty) return Center(child: Text('Chưa có board nào'));
                return ListView.builder(
                  itemCount: boards.length,
                  itemBuilder: (context, index) {
                    final boardId = boards[index].id;
                    final boardData = boards[index].data() as Map<String, dynamic>;
                    final boardName = boardData['name'] as String? ?? 'Unnamed Board';
                    final boardDescription = boardData['description'] as String? ?? 'No description';

                    return ExpansionTile(
                      title: Text('Board: $boardName'),
                      subtitle: Text(boardDescription),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () =>
                                _showEditBoardDialog(context, boardId, boardName, boardDescription),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _showDeleteConfirmationDialog(context, boardId),
                          ),
                        ],
                      ),
                      children: [
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('tasks')
                              .where('boardId', isEqualTo: boardId)
                              .snapshots(),
                          builder: (context, taskSnapshot) {
                            if (!taskSnapshot.hasData)
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              );
                            if (taskSnapshot.hasError)
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Lỗi tải tasks: ${taskSnapshot.error}'),
                              );

                            final tasks = taskSnapshot.data!.docs
                                .map((doc) => TaskMapper.fromModel(
                                TaskModel.fromJson(doc.data() as Map<String, dynamic>)))
                                .where((task) {
                              final matchesSearch = _searchController.text.isEmpty ||
                                  task.title
                                      .toLowerCase()
                                      .contains(_searchController.text.toLowerCase()) ||
                                  (task.description
                                      ?.toLowerCase()
                                      .contains(_searchController.text.toLowerCase()) ??
                                      false);
                              final matchesStatus = _filterStatus == null ||
                                  (_filterStatus == 'Completed' && task.isCompleted) ||
                                  (_filterStatus == 'Incomplete' && !task.isCompleted);
                              return matchesSearch && matchesStatus;
                            }).toList();

                            if (tasks.isEmpty)
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text('Chưa có nhiệm vụ trong board này'),
                              );

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: tasks.length,
                              itemBuilder: (context, taskIndex) {
                                final task = tasks[taskIndex];
                                return ListTile(
                                  title: Text(task.title),
                                  subtitle: task.description != null
                                      ? Text(task.description!)
                                      : null,
                                  trailing: Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (value) {
                                      Provider.of<TaskProvider>(context, listen: false).updateTask(
                                        task.id,
                                        isCompleted: value ?? false,
                                      ); // ✅ Đã sửa
                                    },
                                  ),
                                  onTap: () {},
                                );
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBoardDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddBoardDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm Board mới'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên Board'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên board' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _boardService.createBoard(
                    _nameController.text, _descriptionController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditBoardDialog(
      BuildContext context, String boardId, String boardName, String boardDescription) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: boardName);
    final _descriptionController = TextEditingController(text: boardDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa Board'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Tên Board'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên board' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _boardService.updateBoard(
                    boardId, _nameController.text, _descriptionController.text);
                Navigator.pop(context);
              }
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String boardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text(
            'Bạn có chắc muốn xóa board này? Tất cả nhiệm vụ liên quan cũng sẽ bị xóa.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              _boardService.deleteBoard(boardId);
              Navigator.pop(context);
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
