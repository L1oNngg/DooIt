import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../widgets/app_bottom_nav.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TaskProvider>(context, listen: false).fetchTasks());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final tasks = provider.tasks
        .where((task) =>
    task.dueDate != null &&
        DateFormat('yyyy-MM-dd').format(task.dueDate!) ==
            DateFormat('yyyy-MM-dd').format(_selectedDate))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch công việc'),
      ),
      body: Column(
        children: [
          // Date picker
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 30,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(_selectedDate);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('dd/MM').format(date),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text('Không có nhiệm vụ nào'))
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
                      // Dùng copyWith để update
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewTask(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  void _addNewTask(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context, listen: false);

    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Nhiệm vụ ngày ${DateFormat('dd/MM').format(_selectedDate)}',
      description: 'Tự động tạo từ CalendarScreen',
      dueDate: _selectedDate,
      dueTime: null,
      isCompleted: false,
      boardId: '',
      priority: 1,
      reminderTime: const Duration(hours: 1),
      recurrence: 'none',
    );

    provider.addTask(newTask);
  }
}
