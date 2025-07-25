// ⚠️ Đã sửa lại chỗ gọi deleteTask() và filterTasks() cho đúng tham số
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';
import 'task_detail_screen.dart';
import '../navigator/app_routes.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  TimeOfDay? _dueTime;
  final _boardIdController = TextEditingController();
  final _searchController = TextEditingController();
  String _filterStatus = 'all';
  String _filterBoardId = 'all';

  void _showTaskDialog(BuildContext context, {Task? task}) {
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description ?? '';
      _dueDateController.text = task.dueDate?.toLocal().toString().split(' ')[0] ?? '';
      _dueTime = task.dueTime;
      _boardIdController.text = task.boardId;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _dueDateController.clear();
      _boardIdController.clear();
      _dueTime = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task == null ? 'Thêm nhiệm vụ nhanh' : 'Chỉnh sửa nhiệm vụ'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Tiêu đề'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Mô tả'),
                ),
                TextFormField(
                  controller: _dueDateController,
                  decoration: InputDecoration(labelText: 'Ngày hạn chót (YYYY-MM-DD)'),
                  validator: (value) {
                    if (value!.isEmpty) return 'Vui lòng nhập ngày';
                    try {
                      DateTime.parse(value);
                      return null;
                    } catch (e) {
                      return 'Định dạng ngày không hợp lệ';
                    }
                  },
                ),
                ListTile(
                  title: Text('Thời gian: ${_dueTime?.format(context) ?? 'Chưa chọn'}'),
                  trailing: Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _dueTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => _dueTime = picked);
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('boards').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return CircularProgressIndicator();
                    final boards = snapshot.data!.docs;
                    return DropdownButtonFormField<String>(
                      value: _boardIdController.text.isNotEmpty ? _boardIdController.text : null,
                      items: boards.map((doc) => DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc['name']),
                      )).toList(),
                      onChanged: (value) => _boardIdController.text = value ?? '',
                      decoration: InputDecoration(labelText: 'Chọn Board'),
                      validator: (value) => value == null ? 'Vui lòng chọn board' : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newTask = Task(
                  id: task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
                  dueDate: DateTime.parse(_dueDateController.text).toUtc(),
                  dueTime: _dueTime,
                  isCompleted: task?.isCompleted ?? false,
                  boardId: _boardIdController.text,
                );
                Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
                Navigator.pop(context);
              }
            },
            child: Text(task == null ? 'Thêm nhanh' : 'Lưu'),
          ),
          if (task != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task)),
                );
              },
              child: Text('Chi tiết'),
            ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, String taskId) {
    Provider.of<TaskProvider>(context, listen: false).deleteTaskById(taskId); // ✅ sửa lại hàm cho đúng
  }

  void _runFilter() {
    Provider.of<TaskProvider>(context, listen: false).filterTasks(
      query: _searchController.text,
      status: _filterStatus,
      boardId: _filterBoardId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('DooIt - Task List'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              provider.tasks.sort((a, b) =>
                  (a.dueDate ?? DateTime.now()).compareTo(b.dueDate ?? DateTime.now()));
              provider.notifyListeners();
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'board') Navigator.pushNamed(context, AppRoutes.board);
              if (value == 'goal') Navigator.pushNamed(context, AppRoutes.goal);
              if (value == 'calendar') Navigator.pushNamed(context, AppRoutes.calendar);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'board', child: Text('Go to Boards')),
              PopupMenuItem(value: 'goal', child: Text('Go to Goals')),
              PopupMenuItem(value: 'calendar', child: Text('Go to Calendar')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm nhiệm vụ...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _runFilter();
                  },
                ),
              ),
              onChanged: (_) => _runFilter(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _filterStatus == 'all' ? null : _filterStatus,
                    hint: Text('Lọc theo trạng thái'),
                    items: ['all', 'Completed', 'Incomplete'].map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _filterStatus = value ?? 'all');
                      _runFilter();
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('boards').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Container();
                      final boards = snapshot.data!.docs;
                      return DropdownButton<String>(
                        value: _filterBoardId == 'all' ? null : _filterBoardId,
                        hint: Text('Lọc theo Board'),
                        items: ['all', ...boards.map((doc) => doc.id)].map((id) {
                          final name = id == 'all'
                              ? 'All'
                              : boards.firstWhere((b) => b.id == id)['name'] ?? 'Unnamed';
                          return DropdownMenuItem(value: id, child: Text(name));
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _filterBoardId = value ?? 'all');
                          _runFilter();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                if (provider.tasks.isEmpty) return Center(child: Text('Không có nhiệm vụ'));
                return ListView.builder(
                  itemCount: provider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = provider.tasks[index];
                    return Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteTask(context, task.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (task.description != null) Text(task.description!),
                            if (task.dueDate != null)
                              Text('Hạn: ${task.dueDate!.toLocal().toString().split(' ')[0]} ${task.dueTime?.format(context) ?? ''}'),
                            if (task.priority != null) Text('Ưu tiên: ${task.priority}'),
                          ],
                        ),
                        trailing: Checkbox(
                          value: task.isCompleted,
                          onChanged: (value) {
                            Provider.of<TaskProvider>(context, listen: false)
                                .updateTask(task.id, isCompleted: value);
                          },
                        ),
                        onTap: () => _showTaskDialog(context, task: task),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
