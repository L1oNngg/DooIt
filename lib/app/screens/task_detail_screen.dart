import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/task.dart';
import '../../app/providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  final bool isEditing;

  TaskDetailScreen({this.task, this.isEditing = false});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String? _description;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late String _boardId;
  late String? _priority;
  late String? _recurrence;
  late Duration _reminderTime;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description;
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _dueTime = widget.task?.dueTime ?? TimeOfDay.now();
    _boardId = widget.task?.boardId ?? '';
    _priority = widget.task?.priority;
    _recurrence = widget.task?.recurrence;
    _reminderTime = widget.task?.reminderTime ?? Duration(minutes: 0);
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Chỉnh sửa Task' : 'Thêm Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
                onChanged: (value) => _title = value,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Mô tả'),
                onChanged: (value) => _description = value.isEmpty ? null : value,
              ),
              ListTile(
                title: Text('Ngày hết hạn: ${_dueDate.toString().split(' ')[0]}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
              ListTile(
                title: Text('Thời gian: ${_dueTime.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(context: context, initialTime: _dueTime);
                  if (picked != null) setState(() => _dueTime = picked);
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('boards').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final boards = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _boardId.isNotEmpty ? _boardId : null,
                    decoration: InputDecoration(labelText: 'Board'),
                    items: boards.map((doc) {
                      final boardName = doc['name'] ?? 'Unnamed';
                      return DropdownMenuItem(
                        value: doc.id,
                        child: Text(boardName),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _boardId = value ?? ''),
                    validator: (value) => value == null || value.isEmpty ? 'Vui lòng chọn board' : null,
                  );
                },
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: InputDecoration(labelText: 'Ưu tiên'),
                items: ['Low', 'Medium', 'High'].map((priority) {
                  return DropdownMenuItem(value: priority, child: Text(priority));
                }).toList(),
                onChanged: (value) => setState(() => _priority = value),
              ),
              DropdownButtonFormField<String>(
                value: _recurrence,
                decoration: InputDecoration(labelText: 'Lặp lại'),
                items: ['None', 'Daily', 'Weekly', 'Monthly'].map((recurrence) {
                  return DropdownMenuItem(value: recurrence, child: Text(recurrence));
                }).toList(),
                onChanged: (value) => setState(() => _recurrence = value),
              ),
              ListTile(
                title: Text('Nhắc nhở trước: ${_reminderTime.inMinutes} phút'),
                trailing: Icon(Icons.alarm),
                onTap: () async {
                  final minutes = await showDialog<int>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Chọn thời gian nhắc nhở'),
                      content: DropdownButton<int>(
                        value: _reminderTime.inMinutes,
                        items: [0, 15, 30, 60, 120].map((min) {
                          return DropdownMenuItem(value: min, child: Text('$min phút'));
                        }).toList(),
                        onChanged: (value) => Navigator.pop(context, value),
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy'))],
                    ),
                  );
                  if (minutes != null) setState(() => _reminderTime = Duration(minutes: minutes));
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (widget.isEditing && widget.task != null) {
                      await taskProvider.updateTask(
                        widget.task!.id,
                        title: _title,
                        description: _description,
                        isCompleted: widget.task!.isCompleted,
                        boardId: _boardId,
                        dueDate: _dueDate,
                        dueTime: _dueTime,
                        priority: _priority,
                        recurrence: _recurrence,
                        reminderTime: _reminderTime,
                      );
                    } else {
                      final newTask = Task(
                        id: UniqueKey().toString(),
                        title: _title,
                        description: _description,
                        dueDate: _dueDate,
                        dueTime: _dueTime,
                        isCompleted: false,
                        boardId: _boardId,
                        priority: _priority,
                        recurrence: _recurrence,
                        reminderTime: _reminderTime.inMinutes > 0 ? _reminderTime : null,
                      );
                      await taskProvider.addTask(newTask);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(widget.isEditing ? 'Đã cập nhật nhiệm vụ!' : 'Đã thêm nhiệm vụ!')),
                    );

                    Future.delayed(Duration(milliseconds: 500), () {
                      Navigator.pop(context);
                    });
                  }
                },
                child: Text(widget.isEditing ? 'Lưu' : 'Thêm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}