import '../../domain/entities/task.dart';
import '../models/task_model.dart';

class TaskMapper {
  static Task fromModel(TaskModel model) => Task(
    id: model.id,
    title: model.title,
    description: model.description,
    dueDate: model.dueDate,
    dueTime: model.dueTime,
    isCompleted: model.isCompleted,
    boardId: model.boardId,
    priority: model.priority,
    recurrence: model.recurrence,
    reminderTime: model.reminderTime,
  );

  static TaskModel toModel(Task task) => TaskModel(
    id: task.id,
    title: task.title,
    description: task.description ?? '',
    dueDate: task.dueDate ?? DateTime.now(),
    dueTime: task.dueTime,
    isCompleted: task.isCompleted,
    boardId: task.boardId,
    priority: task.priority,
    recurrence: task.recurrence,
    reminderTime: task.reminderTime,
  );
}