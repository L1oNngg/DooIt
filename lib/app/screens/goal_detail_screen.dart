import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/goal.dart';
import '../../app/providers/task_provider.dart';
import '../../domain/entities/task.dart';
import '../widgets/heatmap_chart.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  DateTime from = DateTime.now().subtract(const Duration(days: 30));
  DateTime to = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load lại tasks khi mở màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks
        .where((t) => widget.goal.taskIds.contains(t.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            tooltip: 'Thêm Task vào Goal',
            onPressed: () {
              _showAddTaskDialog(context, taskProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<List<DateTime>>(
            future: _loadCompletions(taskProvider, tasks),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                );
              }
              final completions = snapshot.data!;
              final startMonth = _getStartMonth(tasks, completions);

              // Tiến độ = số ngày hoàn thành / số ngày theo chart
              final totalDays = completions.length;
              final doneDays = completions.length;
              final progress = totalDays == 0 ? 0.0 : doneDays / totalDays;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      color: Colors.green,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    HeatmapChart(
                      completions: completions,
                      startMonth: startMonth,
                      onToggle: (day, done) async {
                        for (final t in tasks) {
                          await taskProvider.toggleCompletion(
                              t.id!, day, done);
                        }
                        setState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final t = tasks[index];
                return ListTile(
                  title: Text(t.title),
                  subtitle: Text(t.description ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Hiển thị dialog thêm Task vào Goal
  void _showAddTaskDialog(BuildContext context, TaskProvider provider) {
    final allTasks = provider.tasks;
    final selectable = allTasks
        .where((t) => !widget.goal.taskIds.contains(t.id))
        .toList();
    String? selectedTaskId;

    // Tạo danh sách items từ selectable
    final taskItems = selectable.map((t) {
      return DropdownMenuItem<String>(
        value: t.id,
        child: Text(t.title),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Thêm Task vào Goal"),
          content: DropdownButtonFormField<String>(
            value: taskItems.isNotEmpty ? null : null,
            hint: const Text("Chọn một Task"),
            items: taskItems,
            onChanged: (val) {
              selectedTaskId = val;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedTaskId != null) {
                  setState(() {
                    widget.goal.taskIds.add(selectedTaskId!);
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text("Thêm"),
            ),
          ],
        );
      },
    );
  }

  /// Lấy completions cho các task trong Goal
  Future<List<DateTime>> _loadCompletions(
      TaskProvider provider, List<Task> tasks) async {
    final result = <DateTime>{};
    final now = DateTime.now();

    for (final t in tasks) {
      final list = await provider.getCompletionHistory(
          t.id!, t.recurrence ?? '');
      result.addAll(list);

      // Checkpoint
      if (t.description != null && t.description!.contains('checkpoint:')) {
        final parts = t.description!.split('checkpoint:');
        final ts = int.tryParse(parts.last.trim());
        if (ts != null &&
            DateTime.fromMillisecondsSinceEpoch(ts).isBefore(now)) {
          Future.microtask(() {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Đến mốc đánh giá"),
                content: Text("Bạn có muốn tiếp tục habit '${t.title}' không?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Dừng"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tiếp tục"),
                  ),
                ],
              ),
            );
          });
        }
      }
    }
    return result.toList();
  }

  DateTime _getStartMonth(List<Task> tasks, List<DateTime> completions) {
    DateTime? earliest;
    for (final t in tasks) {
      earliest ??= t.dueDate;
      if (t.dueDate.isBefore(earliest!)) {
        earliest = t.dueDate;
      }
    }
    for (final c in completions) {
      if (earliest == null || c.isBefore(earliest)) {
        earliest = c;
      }
    }
    if (earliest == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, 1);
    }
    return DateTime(earliest.year, earliest.month, 1);
  }
}
