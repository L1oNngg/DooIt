import '../../domain/entities/task.dart';
import '../models/task_model.dart';

class TaskMapper {
  static Task toEntity(TaskModel model) {
    return Task(
      id: model.id,
      title: model.title,
      description: model.description,
      dueDate: DateTime.fromMillisecondsSinceEpoch(model.dueDate),
      dueTime: model.dueTime != null
          ? DateTime.fromMillisecondsSinceEpoch(model.dueTime!)
          : null,
      isCompleted: model.isCompleted,
      boardId: model.boardId,
      priority: model.priority,
      reminderTime: model.reminderTime != null
          ? Duration(milliseconds: model.reminderTime!)
          : null,
      recurrence: model.recurrence,
    );
  }

  static TaskModel toModel(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate.millisecondsSinceEpoch,
      dueTime: entity.dueTime?.millisecondsSinceEpoch,
      isCompleted: entity.isCompleted,
      boardId: entity.boardId,
      priority: entity.priority,
      reminderTime: entity.reminderTime?.inMilliseconds,
      recurrence: entity.recurrence,
    );
  }
}
