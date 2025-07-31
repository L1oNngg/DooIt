import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/providers/task_provider.dart';
import '../../domain/entities/task.dart';
import '../widgets/app_bottom_nav.dart';
import 'task_detail_screen.dart';

/// Widget viền đỏ cho task quá hạn
class OverdueTaskCard extends StatelessWidget {
  final Widget child;
  const OverdueTaskCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: child,
    );
  }
}

/// 3 chế độ lọc
enum TaskFilterMode { oneDay, sevenDays, all }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';
  TaskFilterMode _filterMode = TaskFilterMode.sevenDays;

  @override
  void initState() {
    super.initState();
    _loadFilterMode();
    Future.microtask(() {
      Provider.of<TaskProvider>(context, listen: false).fetchAllTasks();
    });
  }

  Future<void> _loadFilterMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('task_filter_mode') ?? 1;
    setState(() {
      _filterMode = TaskFilterMode.values[index];
    });
  }

  Future<void> _saveFilterMode(TaskFilterMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('task_filter_mode', mode.index);
  }

  void _toggleFilterMode() {
    setState(() {
      switch (_filterMode) {
        case TaskFilterMode.oneDay:
          _filterMode = TaskFilterMode.sevenDays;
          break;
        case TaskFilterMode.sevenDays:
          _filterMode = TaskFilterMode.all;
          break;
        case TaskFilterMode.all:
          _filterMode = TaskFilterMode.oneDay;
          break;
      }
    });
    _saveFilterMode(_filterMode);
  }

  String _filterLabel(TaskFilterMode mode) {
    switch (mode) {
      case TaskFilterMode.oneDay:
        return "1D";
      case TaskFilterMode.sevenDays:
        return "7D";
      case TaskFilterMode.all:
        return "All";
    }
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
    provider.addTask(newTask, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách công việc'),
        actions: [
          // Toggle button màu đen và có label
          TextButton.icon(
            onPressed: _toggleFilterMode,
            icon: const Icon(Icons.filter_alt, color: Colors.black),
            label: Text(
              _filterLabel(_filterMode),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
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
          // Lọc theo từ khóa
          final allTasks = _searchKeyword.isEmpty
              ? taskProvider.tasks
              : taskProvider.filterTasks(_searchKeyword);

          // Áp dụng filter
          final now = DateTime.now();
          final in7Days = now.add(const Duration(days: 7));

          bool matchesRecurrence(Task task, DateTime date) {
            final diff = date.difference(task.dueDate).inDays;
            switch (task.recurrence) {
              case 'daily':
                return date.isAfter(task.dueDate) || DateUtils.isSameDay(task.dueDate, date);
              case 'weekly':
                return diff >= 0 && diff % 7 == 0;
              case 'monthly':
                return date.day == task.dueDate.day && date.isAfter(task.dueDate);
              default: // none
                return DateUtils.isSameDay(task.dueDate, date);
            }
          }

          List<Task> filteredTasks = allTasks.where((task) {
            switch (_filterMode) {
              case TaskFilterMode.oneDay:
                return matchesRecurrence(task, now);
              case TaskFilterMode.sevenDays:
                return List.generate(7, (i) => now.add(Duration(days: i)))
                    .any((date) => matchesRecurrence(task, date));
              case TaskFilterMode.all:
                return true;
            }
          }).toList();


          // Tạo danh sách ngày cần hiển thị
          List<DateTime> daysToShow;
          switch (_filterMode) {
            case TaskFilterMode.oneDay:
              daysToShow = [now];
              break;
            case TaskFilterMode.sevenDays:
              daysToShow = List.generate(7, (i) => now.add(Duration(days: i)));
              break;
            case TaskFilterMode.all:
            // Hiển thị tất cả task gốc (không tạo ngày mới)
              daysToShow = filteredTasks.map((t) => t.dueDate).toSet().toList();
              daysToShow.sort();
              break;
          }

          // Nhóm theo từng ngày cần hiển thị
          final Map<String, List<Task>> grouped = {};
          for (final date in daysToShow) {
            final key = DateFormat('yyyy-MM-dd').format(date);
            final tasksForDay = filteredTasks
                .where((task) => matchesRecurrence(task, date))
                .toList();
            if (tasksForDay.isNotEmpty) {
              grouped[key] = tasksForDay;
            }
          }


          // Sắp xếp ngày
          final sortedKeys = grouped.keys.toList()
            ..sort((a, b) => a.compareTo(b));

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
                child: filteredTasks.isEmpty
                    ? const Center(child: Text('Không có công việc nào'))
                    : ListView.builder(
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, groupIndex) {
                    final dateKey = sortedKeys[groupIndex];
                    final groupTasks = grouped[dateKey]!;

                    // Tách overdue và non-overdue
                    final overdue = groupTasks.where((task) {
                      final r = taskProvider.timeRemaining(task);
                      return r != null && r.isNegative;
                    }).toList();
                    final normal = groupTasks.where((task) {
                      final r = taskProvider.timeRemaining(task);
                      return !(r != null && r.isNegative);
                    }).toList();

                    // Gộp lại, overdue trước
                    final orderedGroup = [...overdue, ...normal];

                    final dateDisplay = DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(dateKey));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: Colors.grey[200],
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          child: Text(
                            dateDisplay,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...orderedGroup.map((task) {
                          final remaining =
                          taskProvider.timeRemaining(task);
                          final urgent = taskProvider.isUrgent(task);
                          final isOverdue = remaining != null &&
                              remaining.isNegative;

                          final card = Card(
                            color: urgent && !isOverdue
                                ? Colors.red[100]
                                : null,
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) {
                                  final updatedTask = task.copyWith(
                                    isCompleted: value ?? false,
                                  );
                                  taskProvider.updateTask(updatedTask);
                                },
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationThickness:
                                  task.isCompleted ? 2.0 : 1,
                                  decorationColor: task.isCompleted
                                      ? Colors.black
                                      : null,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(isOverdue
                                      ? 'ĐÃ TRỄ HẠN'
                                      : 'Còn lại: ${_formatRemaining(remaining)}'),
                                  if (urgent && !isOverdue)
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
                                  await taskProvider.deleteTaskById(task.id!);
                                },
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TaskDetailScreen(
                                          existingTask: task,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );

                          return isOverdue
                              ? OverdueTaskCard(child: card)
                              : card;
                        }),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _quickAddTask(context),
        child: const Icon(Icons.add),
      ),
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
