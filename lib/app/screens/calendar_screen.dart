import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/task_provider.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.week,
            eventLoader: (day) {
              return Provider.of<TaskProvider>(context, listen: false)
                  .tasks
                  .where((task) => task.dueDate != null && isSameDay(task.dueDate, day))
                  .toList();
            },
          ),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final tasks = provider.tasks
                    .where((task) =>
                task.dueDate != null &&
                    isSameDay(task.dueDate, _selectedDay))
                    .toList();

                if (tasks.isEmpty) {
                  return Center(child: Text('Không có nhiệm vụ cho ngày này'));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle:
                      task.description != null ? Text(task.description!) : null,
                      trailing: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          if (value != null) {
                            Provider.of<TaskProvider>(context, listen: false)
                                .updateTask(task.id, isCompleted: value);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _dueDateController = TextEditingController(
      text: _selectedDay?.toLocal().toString().split(' ')[0] ?? '',
    );
    final _boardIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm nhiệm vụ mới'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) =>
                value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Mô tả'),
              ),
              TextFormField(
                controller: _dueDateController,
                decoration:
                InputDecoration(labelText: 'Ngày hạn chót (YYYY-MM-DD)'),
                validator: (value) {
                  if (value!.isEmpty) return 'Vui lòng nhập ngày';
                  try {
                    DateTime.parse(value);
                    return null;
                  } catch (e) {
                    return 'Định dạng ngày không hợp lệ';
                  }
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('boards').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final boards = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _boardIdController.text.isNotEmpty
                        ? _boardIdController.text
                        : null,
                    items: boards.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    onChanged: (value) => _boardIdController.text = value ?? '',
                    decoration: InputDecoration(labelText: 'Chọn Board'),
                    validator: (value) =>
                    value == null ? 'Vui lòng chọn board' : null,
                  );
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  description: _descriptionController.text.isEmpty
                      ? null
                      : _descriptionController.text,
                  dueDate: DateTime.parse(_dueDateController.text).toUtc(),
                  isCompleted: false,
                  boardId: _boardIdController.text,
                );
                Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
                Navigator.pop(context);
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
