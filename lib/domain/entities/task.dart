import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final TimeOfDay? dueTime; // Giữ dạng TimeOfDay, cần custom khi serialize
  final bool isCompleted;
  final String boardId;
  final String? priority;     // "Low", "Medium", "High"
  final String? recurrence;   // "None", "Daily", "Weekly", "Monthly"
  final Duration? reminderTime;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    required this.boardId,
    this.priority,
    this.recurrence,
    this.reminderTime,
  });

  // ✅ Tạo bản sao có thể thay đổi một vài trường
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TimeOfDay? dueTime,
    bool? isCompleted,
    String? boardId,
    String? priority,
    String? recurrence,
    Duration? reminderTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      boardId: boardId ?? this.boardId,
      priority: priority ?? this.priority,
      recurrence: recurrence ?? this.recurrence,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  // ✅ Nếu dùng Firebase/local storage – bạn sẽ cần các hàm này:
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'dueTime': dueTime != null ? '${dueTime!.hour}:${dueTime!.minute}' : null,
      'isCompleted': isCompleted,
      'boardId': boardId,
      'priority': priority,
      'recurrence': recurrence,
      'reminderTime': reminderTime?.inMinutes,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['dueTime'] as String?)?.split(':');
    TimeOfDay? parsedTime;
    if (timeParts != null && timeParts.length == 2) {
      parsedTime = TimeOfDay(
        hour: int.tryParse(timeParts[0]) ?? 0,
        minute: int.tryParse(timeParts[1]) ?? 0,
      );
    }

    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      dueTime: parsedTime,
      isCompleted: map['isCompleted'] ?? false,
      boardId: map['boardId'],
      priority: map['priority'],
      recurrence: map['recurrence'],
      reminderTime: map['reminderTime'] != null
          ? Duration(minutes: map['reminderTime'])
          : null,
    );
  }
}
