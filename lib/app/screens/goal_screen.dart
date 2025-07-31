import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/providers/task_provider.dart';
import '../../domain/entities/task.dart';
import '../../app/providers/goal_provider.dart';
import '../widgets/app_bottom_nav.dart';
import 'goal_detail_screen.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController _goalNameController = TextEditingController();
  List<String> _selectedTaskIds = [];
  bool _isHabit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalProvider>(context, listen: false).loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              _showCreateGoalDialog(context, tasks);
            },
            child: const Text("Tạo Goal"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: goalProvider.goals.length,
              itemBuilder: (context, index) {
                final goal = goalProvider.goals[index];
                final goalTasks =
                tasks.where((t) => goal.taskIds.contains(t.id)).toList();
                final completed =
                    goalTasks.where((t) => t.isCompleted).length;
                final percent =
                goalTasks.isEmpty ? 0.0 : (completed / goalTasks.length);

                return ListTile(
                  title: Text(goal.name),
                  subtitle: LinearProgressIndicator(value: percent),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever_rounded,
                        color: Colors.redAccent),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa Goal'),
                          content: Text(
                              'Bạn có chắc muốn xóa goal "${goal.name}"?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await goalProvider.deleteGoal(goal.id!);
                      }
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GoalDetailScreen(goal: goal),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }

  void _showCreateGoalDialog(BuildContext context, List<Task> tasks) {
    final habitTitleController = TextEditingController();
    final habitDescController = TextEditingController();
    DateTime habitDate = DateTime.now();
    TimeOfDay habitTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setStateDialog) {
            return AlertDialog(
              title: const Text("Tạo Goal mới"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _goalNameController,
                      decoration: const InputDecoration(labelText: "Tên Goal"),
                    ),
                    Row(
                      children: [
                        const Text("Goal này là Habit?"),
                        Switch(
                          value: _isHabit,
                          onChanged: (val) {
                            setStateDialog(() {
                              _isHabit = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Nếu là Habit → hiển thị form Task Habit
                    if (_isHabit)
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Thông tin Task Habit",
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: habitTitleController,
                                decoration: const InputDecoration(
                                    labelText: "Tiêu đề Task"),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: habitDescController,
                                decoration:
                                const InputDecoration(labelText: "Mô tả"),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: ctx,
                                        initialDate: habitDate,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        setStateDialog(() {
                                          habitDate = picked;
                                        });
                                      }
                                    },
                                    child: Text(
                                        "${habitDate.day}/${habitDate.month}/${habitDate.year}"),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time, size: 18),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () async {
                                      final picked = await showTimePicker(
                                        context: ctx,
                                        initialTime: habitTime,
                                      );
                                      if (picked != null) {
                                        setStateDialog(() {
                                          habitTime = picked;
                                        });
                                      }
                                    },
                                    child: Text(habitTime.format(ctx)),
                                  ),
                                ],
                              ),
                              const Text(
                                "Task sẽ tự động được lặp lại hàng ngày.",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                      ),

                    // Nếu không phải Habit → hiển thị danh sách checkbox task
                    if (!_isHabit)
                      Expanded(
                        child: ListView(
                          children: tasks.map((t) {
                            final selected = _selectedTaskIds.contains(t.id);
                            return CheckboxListTile(
                              value: selected,
                              title: Text(t.title),
                              onChanged: (val) {
                                setStateDialog(() {
                                  if (val == true) {
                                    _selectedTaskIds.add(t.id!);
                                  } else {
                                    _selectedTaskIds.remove(t.id!);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                  },
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final goalProvider =
                    Provider.of<GoalProvider>(context, listen: false);

                    if (_isHabit) {
                      final startDate = DateTime(
                        habitDate.year,
                        habitDate.month,
                        habitDate.day,
                        habitTime.hour,
                        habitTime.minute,
                      );

                      // checkpoint mặc định sau 30 ngày
                      final checkpointDate =
                      startDate.add(const Duration(days: 30));

                      await goalProvider.createGoal(
                        _goalNameController.text,
                        [],
                        isHabit: true,
                        habitTitle: habitTitleController.text,
                        habitDesc: habitDescController.text,
                        habitDueDate: startDate,
                        checkpointDate: checkpointDate,
                      );
                    } else {
                      await goalProvider.createGoal(
                        _goalNameController.text,
                        _selectedTaskIds,
                        isHabit: false,
                      );
                    }

                    _goalNameController.clear();
                    _selectedTaskIds.clear();
                    _isHabit = false;
                    Navigator.pop(ctx);
                  },
                  child: const Text("Lưu"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
