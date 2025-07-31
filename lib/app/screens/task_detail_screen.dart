import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';
import '../providers/task_provider.dart';
import '../providers/board_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? existingTask;

  const TaskDetailScreen({super.key, this.existingTask});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  Duration? _reminderTime;
  String _boardId = '';
  int _priority = 1;
  String _recurrence = 'none';

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate;
    _dueTime = task?.dueDate != null
        ? TimeOfDay.fromDateTime(task!.dueDate!)
        : null;
    _reminderTime = task?.reminderTime;
    _boardId = task?.boardId ?? '';
    _priority = task?.priority ?? 1;
    _recurrence = task?.recurrence ?? 'none';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingTask != null;
    final taskProvider = Provider.of<TaskProvider>(context);
    final boardProvider = Provider.of<BoardProvider>(context);
    final boards = boardProvider.boards;

    // Nếu chưa có board chọn
    String dropdownValue;
    if (_boardId.isNotEmpty) {
      dropdownValue = _boardId;
    } else {
      if (boards.isNotEmpty) {
        dropdownValue = boards.first.id;
      } else {
        dropdownValue = 'default';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa nhiệm vụ' : 'Thêm nhiệm vụ'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Nhập tiêu đề' : null,
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              ListTile(
                title: Text(
                  _dueDate == null
                      ? 'Chọn ngày đến hạn'
                      : DateFormat('dd/MM/yyyy').format(_dueDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: widget.existingTask?.dueDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
              ),

              ListTile(
                title: Text(
                  _dueTime == null ? 'Chọn giờ' : _dueTime!.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _dueTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dueTime = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Dropdown chọn Board
              DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: const InputDecoration(labelText: 'Chọn Board'),
                items: (boards.isNotEmpty
                    ? boards
                    .map((b) => DropdownMenuItem(
                  value: b.id,
                  child: Text(b.name),
                ))
                    .toList()
                    : [
                  const DropdownMenuItem(
                    value: 'default',
                    child: Text('Mặc định'),
                  )
                ]),
                onChanged: (value) {
                  setState(() {
                    _boardId = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Độ ưu tiên'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value ?? 1;
                  });
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _recurrence,
                decoration: const InputDecoration(labelText: 'Lặp lại'),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('Không lặp')),
                  DropdownMenuItem(value: 'daily', child: Text('Hàng ngày')),
                  DropdownMenuItem(value: 'weekly', child: Text('Hàng tuần')),
                  DropdownMenuItem(value: 'monthly', child: Text('Hàng tháng')),
                ],
                onChanged: (value) {
                  setState(() {
                    _recurrence = value ?? 'none';
                  });
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveTask,
                child: Text(isEdit ? 'Cập nhật' : 'Thêm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? combinedDateTime;
    if (_dueDate != null) {
      combinedDateTime = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        _dueTime?.hour ?? 0,
        _dueTime?.minute ?? 0,
      );
    }

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final selectedBoardId = _boardId.isNotEmpty ? _boardId : 'default';

    if (widget.existingTask == null) {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: combinedDateTime ?? DateTime.now(),
        dueTime: null,
        isCompleted: false,
        boardId: selectedBoardId,
        priority: _priority,
        reminderTime: _reminderTime ?? const Duration(hours: 1),
        recurrence: _recurrence,
      );
      taskProvider.addTask(newTask, context);
    } else {
      final updatedTask = widget.existingTask!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: combinedDateTime,
        dueTime: null,
        boardId: selectedBoardId,
        priority: _priority,
        reminderTime: _reminderTime,
        recurrence: _recurrence,
      );
      taskProvider.updateTask(updatedTask);
    }

    Navigator.pop(context);
  }
}
