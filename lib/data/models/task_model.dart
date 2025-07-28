class TaskModel {
  final String id;
  final String title;
  final String description;
  final int dueDate;
  final int? dueTime;
  final bool isCompleted;
  final String boardId;
  final int priority;
  final int? reminderTime; // lưu milliseconds
  final String recurrence;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime,
    required this.isCompleted,
    required this.boardId,
    required this.priority,
    this.reminderTime,
    this.recurrence = 'none',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'dueTime': dueTime,
      'isCompleted': isCompleted,
      'boardId': boardId,
      'priority': priority,
      'reminderTime': reminderTime,
      'recurrence': recurrence,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] ?? DateTime.now().millisecondsSinceEpoch,
      dueTime: map['dueTime'],
      isCompleted: map['isCompleted'] ?? false,
      boardId: map['boardId'] ?? '',
      priority: map['priority'] ?? 0,
      reminderTime: map['reminderTime'],
      recurrence: map['recurrence'] ?? 'none',
    );
  }
}
