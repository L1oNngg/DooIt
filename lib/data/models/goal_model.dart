import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/goal.dart';

class GoalModel {
  final String id;
  final String name;
  final String description;
  final List<String> taskIds;
  final int progress;
  final bool isHabit;
  final DateTime? checkpointDate;

  GoalModel({
    required this.id,
    required this.name,
    required this.description,
    required this.taskIds,
    required this.progress,
    required this.isHabit,
    this.checkpointDate,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json, String id) {
    return GoalModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      taskIds: List<String>.from(json['taskIds'] ?? []),
      progress: json['progress'] ?? 0,
      isHabit: json['isHabit'] ?? false,
      checkpointDate: json['checkpointDate'] != null
          ? (json['checkpointDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'taskIds': taskIds,
      'progress': progress,
      'isHabit': isHabit,
      'checkpointDate': checkpointDate,
    };
  }

  Goal toEntity() {
    return Goal(
      id: id,
      name: name,
      description: description,
      taskIds: taskIds,
      progress: progress,
      isHabit: isHabit,
      checkpointDate: checkpointDate,
    );
  }

  factory GoalModel.fromEntity(Goal goal) {
    return GoalModel(
      id: goal.id,
      name: goal.name,
      description: goal.description,
      taskIds: goal.taskIds,
      progress: goal.progress,
      isHabit: goal.isHabit,
      checkpointDate: goal.checkpointDate,
    );
  }
}
