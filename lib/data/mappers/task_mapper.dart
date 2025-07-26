import '../../domain/entities/task.dart';
import '../models/task_model.dart';

class TaskMapper {
  static Task toEntity(TaskModel model) {
    return Task(
      id: model.id,
      title: model.title,
      description: model.description,
      dueDate: model.dueDate,
      dueTime: model.dueTime,
      isCompleted: model.isCompleted,
      boardId: model.boardId,
      priority: model.priority,
      reminderTime: model.reminderTime,
      recurrence: model.recurrence,
    );
  }

  static TaskModel toModel(Task entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      dueDate: entity.dueDate,
      dueTime: entity.dueTime,
      isCompleted: entity.isCompleted,
      boardId: entity.boardId,
      priority: entity.priority,
      reminderTime: entity.reminderTime,
      recurrence: entity.recurrence,
    );
  }
}
