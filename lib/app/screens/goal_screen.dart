import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/app_bottom_nav.dart';

class GoalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Goals')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('goals').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Lỗi tải goals: ${snapshot.error}'));
          final goals = snapshot.data!.docs;
          if (goals.isEmpty) return Center(child: Text('Chưa có mục tiêu nào'));
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goalData = goals[index].data() as Map<String, dynamic>;
              final goalId = goals[index].id;
              final priority = goalData['priority'] ?? 'Medium';
              final taskIds = List<String>.from(goalData['taskIds'] ?? []);
              final taskProvider = Provider.of<TaskProvider>(context, listen: false);
              final completedTasks = taskProvider.tasks
                  .where((task) => taskIds.contains(task.id) && task.isCompleted)
                  .length;
              final progress = taskIds.isEmpty ? 0.0 : completedTasks / taskIds.length;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(goalData['title'] ?? 'No Title'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hạn chót: ${goalData['targetDate']?.toDate()?.toLocal().toString().split(' ')[0] ?? 'N/A'}'),
                      Text('Ưu tiên: $priority'),
                      if (taskIds.isNotEmpty)
                        Text('Tasks: ${completedTasks}/${taskIds.length} hoàn thành'),
                      SizedBox(height: 8),
                      LinearProgressIndicator(value: progress),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: Icon(Icons.edit), onPressed: () => _showEditGoalDialog(context, goalId, goalData['title'], goalData['targetDate'], priority, taskIds)),
                      IconButton(icon: Icon(Icons.delete), onPressed: () => _showDeleteConfirmationDialog(context, goalId)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddGoalDialog(context), child: Icon(Icons.add)),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _dateController = TextEditingController();
    final _priorityController = TextEditingController(text: 'Medium');
    final _taskIdsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm Mục tiêu mới'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tên Mục tiêu'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Ngày hạn chót (YYYY-MM-DD)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập ngày';
                  try { DateTime.parse(value); return null; } catch (e) { return 'Định dạng ngày không hợp lệ'; }
                },
              ),
              TextFormField(
                controller: _priorityController,
                decoration: InputDecoration(labelText: 'Ưu tiên (Low/Medium/High)'),
                validator: (value) => !['Low', 'Medium', 'High'].contains(value) ? 'Vui lòng chọn Low, Medium, hoặc High' : null,
              ),
              TextFormField(
                controller: _taskIdsController,
                decoration: InputDecoration(labelText: 'Task IDs (dùng dấu phẩy ngăn cách)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final taskIds = _taskIdsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                FirebaseFirestore.instance.collection('goals').add({
                  'title': _titleController.text,
                  'targetDate': DateTime.parse(_dateController.text).toUtc(),
                  'priority': _priorityController.text,
                  'taskIds': taskIds,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, String goalId, String? title, dynamic targetDate, String priority, List<String> taskIds) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController(text: title);
    final _dateController = TextEditingController(text: targetDate?.toDate()?.toLocal().toString().split(' ')[0] ?? '');
    final _priorityController = TextEditingController(text: priority);
    final _taskIdsController = TextEditingController(text: taskIds.join(','));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa Mục tiêu'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tên Mục tiêu'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Ngày hạn chót (YYYY-MM-DD)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập ngày';
                  try { DateTime.parse(value); return null; } catch (e) { return 'Định dạng ngày không hợp lệ'; }
                },
              ),
              TextFormField(
                controller: _priorityController,
                decoration: InputDecoration(labelText: 'Ưu tiên (Low/Medium/High)'),
                validator: (value) => !['Low', 'Medium', 'High'].contains(value) ? 'Vui lòng chọn Low, Medium, hoặc High' : null,
              ),
              TextFormField(
                controller: _taskIdsController,
                decoration: InputDecoration(labelText: 'Task IDs (dùng dấu phẩy ngăn cách)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final taskIds = _taskIdsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                FirebaseFirestore.instance.collection('goals').doc(goalId).update({
                  'title': _titleController.text,
                  'targetDate': DateTime.parse(_dateController.text).toUtc(),
                  'priority': _priorityController.text,
                  'taskIds': taskIds,
                });
                Navigator.pop(context);
              }
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa mục tiêu này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('goals').doc(goalId).delete();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi xóa: $e')));
              }
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}