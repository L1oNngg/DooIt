import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/app_bottom_nav.dart';
import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../../data/datasources/task_completion_data_source.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> _completions = {}; // lưu trạng thái completion theo ngày

  late final TaskCompletionDataSource _completionDataSource;

  @override
  void initState() {
    super.initState();
    _completionDataSource =
        TaskCompletionDataSource(FirebaseFirestore.instance);

    Future.microtask(() async {
      await Provider.of<TaskProvider>(context, listen: false).fetchAllTasks();
      await _loadCompletions();
    });
  }

  Future<void> _loadCompletions() async {
    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final data =
    await _completionDataSource.getCompletionsForDate(dateKey);
    setState(() {
      _completions = data;
    });
  }

  bool _isTaskCompletedForSelectedDate(Task task) {
    // Nếu task có recurrence thì lấy trạng thái từ completions
    if (task.recurrence != 'none') {
      return _completions[task.id] == true;
    }
    // Task bình thường thì lấy từ field gốc
    return task.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final tasks = provider.tasks.where((task) {
      final taskDate = DateFormat('yyyy-MM-dd').format(task.dueDate);
      final selectedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      switch (task.recurrence) {
        case 'daily':
          return _selectedDate.isAfter(task.dueDate) || taskDate == selectedDate;
        case 'weekly':
          final diff = _selectedDate.difference(task.dueDate).inDays;
          return diff >= 0 && diff % 7 == 0;
        case 'monthly':
          return _selectedDate.day == task.dueDate.day &&
              _selectedDate.isAfter(task.dueDate);
        default: // none
          return taskDate == selectedDate;
      }
    }).toList();

    final dateKey = DateFormat('yyyy-MM-dd').format(_selectedDate);

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
                  onTap: () async {
                    setState(() {
                      _selectedDate = date;
                    });
                    await _loadCompletions();
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
                final isCompleted = _isTaskCompletedForSelectedDate(task);

                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: Text(task.description),
                  leading: Checkbox(
                    value: isCompleted,
                    onChanged: (value) async {
                      if (task.recurrence != 'none') {
                        // recurrence: lưu completion theo ngày
                        await _completionDataSource.setCompletion(
                            task.id, dateKey, value ?? false);
                        await _loadCompletions();
                      } else {
                        // non recurrence: update trực tiếp trong Firestore
                        Provider.of<TaskProvider>(context,
                            listen: false)
                            .updateTask(task.copyWith(
                          isCompleted: value ?? false,
                        ));
                      }
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await Provider.of<TaskProvider>(context, listen: false)
                          .deleteTaskById(task.id!);
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
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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

    provider.addTask(newTask, context);
  }
}
