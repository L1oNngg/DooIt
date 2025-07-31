class Goal {
  final String id;
  final String name;
  final String description;
  final List<String> taskIds;
  final int progress;

  // thêm lại isHabit
  final bool isHabit;

  // checkpointDate để lưu lần cuối tiến trình/habit
  final DateTime? checkpointDate;

  Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.taskIds,
    required this.progress,
    required this.isHabit,
    this.checkpointDate,
  });

  Goal copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? taskIds,
    int? progress,
    bool? isHabit,
    DateTime? checkpointDate,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      taskIds: taskIds ?? this.taskIds,
      progress: progress ?? this.progress,
      isHabit: isHabit ?? this.isHabit,
      checkpointDate: checkpointDate ?? this.checkpointDate,
    );
  }
}
