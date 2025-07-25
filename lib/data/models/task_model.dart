import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TimeOfDay? dueTime; // Thêm thời gian
  final bool isCompleted;
  final String boardId;
  final String? priority;
  final String? recurrence;
  final Duration? reminderTime; // Thêm thời gian nhắc nhở

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    required this.boardId,
    this.priority,
    this.recurrence,
    this.reminderTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'dueTime': dueTime != null ? '${dueTime?.hour.toString().padLeft(2, '0')}:${dueTime?.minute.toString().padLeft(2, '0')}' : null, // Lưu dưới dạng HH:MM
    'isCompleted': isCompleted,
    'boardId': boardId,
    'priority': priority,
    'recurrence': recurrence,
    'reminderTime': reminderTime?.inMinutes, // Lưu dưới dạng phút
  };

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      dueTime: json['dueTime'] != null
          ? TimeOfDay(
        hour: int.parse(json['dueTime'].toString().split(':')[0]),
        minute: int.parse(json['dueTime'].toString().split(':')[1]),
      )
          : null,
      isCompleted: json['isCompleted'],
      boardId: json['boardId'],
      priority: json['priority'],
      recurrence: json['recurrence'],
      reminderTime: json['reminderTime'] != null ? Duration(minutes: json['reminderTime']) : null,
    );
  }
}