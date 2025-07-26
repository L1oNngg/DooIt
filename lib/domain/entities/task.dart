class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime? dueTime;
  final bool isCompleted;
  final String boardId;
  final int priority;
  final Duration? reminderTime;

  /// NEW: recurrence field
  final String recurrence; // "none", "daily", "weekly", "monthly"

  Task({
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

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? dueTime,
    bool? isCompleted,
    String? boardId,
    int? priority,
    Duration? reminderTime,
    String? recurrence,
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
      reminderTime: reminderTime ?? this.reminderTime,
      recurrence: recurrence ?? this.recurrence,
    );
  }
}
