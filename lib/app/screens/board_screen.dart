import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_bottom_nav.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class BoardScreen extends StatefulWidget {
  final String boardId;
  final String boardName;

  const BoardScreen({super.key, required this.boardId, required this.boardName});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TaskProvider>(context, listen: false).fetchAllTasks());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    // Lọc task theo boardId
    final tasks = provider.tasks
        .where((task) => task.boardId == widget.boardId)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bảng: ${widget.boardName}'),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Không có nhiệm vụ nào trong bảng này'))
          : ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return ListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(task.description),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                Provider.of<TaskProvider>(context, listen: false)
                    .updateTask(task.copyWith(
                  isCompleted: value ?? false,
                ));
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<TaskProvider>(context, listen: false)
                    .deleteTaskById(task.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewTask(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  void _addNewTask(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nhiệm vụ mới',
      description: 'Tạo trong bảng ${widget.boardName}',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      dueTime: null,
      isCompleted: false,
      boardId: widget.boardId,
      priority: 1,
      reminderTime: const Duration(hours: 1),
      recurrence: 'none',
    );

    provider.addTask(newTask);
  }
}
