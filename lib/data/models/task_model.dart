class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime? dueTime;
  final bool isCompleted;
  final String boardId;
  final int priority;
  final Duration? reminderTime;
  final String recurrence; // NEW

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.dueTime,
    required this.isCompleted,
    required this.boardId,
    required this.priority,
    required this.reminderTime,
    this.recurrence = 'none',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'dueTime': dueTime?.millisecondsSinceEpoch,
      'isCompleted': isCompleted,
      'boardId': boardId,
      'priority': priority,
      'reminderTime': reminderTime?.inMinutes,
      'recurrence': recurrence,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      dueTime: map['dueTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueTime'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      boardId: map['boardId'] ?? '',
      priority: map['priority'] ?? 0,
      reminderTime: map['reminderTime'] != null
          ? Duration(minutes: map['reminderTime'])
          : null,
      recurrence: map['recurrence'] ?? 'none',
    );
  }
}
