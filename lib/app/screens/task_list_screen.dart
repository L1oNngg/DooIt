import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/providers/task_provider.dart';
import '../../domain/entities/task.dart';
import '../widgets/app_bottom_nav.dart';
import 'task_detail_screen.dart'; // thêm import màn hình chi tiết

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    // Lấy danh sách tasks khi vào màn hình
    Future.microtask(() {
      Provider.of<TaskProvider>(context, listen: false).fetchAllTasks();
    });
  }

  void _quickAddTask(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Task nhanh ${DateTime.now().hour}:${DateTime.now().minute}',
      description: 'Tạo nhanh từ FAB',
      dueDate: DateTime.now().add(const Duration(hours: 1)),
      dueTime: null,
      isCompleted: false,
      boardId: '',
      priority: 1,
      reminderTime: const Duration(minutes: 30),
      recurrence: 'none',
    );
    provider.addTask(newTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).fetchAllTasks();
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = _searchKeyword.isEmpty
              ? taskProvider.tasks
              : taskProvider.filterTasks(_searchKeyword);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Tìm kiếm công việc',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchKeyword = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(child: Text('Không có công việc nào'))
                    : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final Task task = tasks[index];
                    final remaining = taskProvider.timeRemaining(task);
                    final urgent = taskProvider.isUrgent(task);

                    return Card(
                      color: urgent ? Colors.red[100] : null,
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Còn lại: ${_formatRemaining(remaining)}'),
                            if (urgent)
                              const Text(
                                'Sắp đến hạn!',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            await taskProvider.deleteTask(task);
                          },
                        ),
                        // thêm điều hướng sang TaskDetailScreen
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(
                                existingTask: task,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // Thêm nút tạo Task nhanh
      floatingActionButton: FloatingActionButton(
        onPressed: () => _quickAddTask(context),
        child: const Icon(Icons.add),
      ),
      // Thêm BottomNavigationBar
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  String _formatRemaining(Duration? remaining) {
    if (remaining == null) return "Không có hạn";
    if (remaining.isNegative) return "Đã quá hạn";
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
