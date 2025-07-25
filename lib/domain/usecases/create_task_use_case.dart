import '../entities/task.dart';
import '../repositories/task_repository.dart';

// Abstract UseCase interface
abstract class CreateTaskUseCase {
  Future<void> call(Task task);
}

// Implementation
class CreateTaskUseCaseImpl implements CreateTaskUseCase {
  final TaskRepository _taskRepository;

  CreateTaskUseCaseImpl(this._taskRepository);

  @override
  Future<void> call(Task task) async {
    await _taskRepository.addTask(task);
  }
}