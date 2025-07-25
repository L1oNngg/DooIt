import '../entities/task.dart';
import '../repositories/task_repository.dart';

// Abstract UseCase interface
abstract class GetAllTasksUseCase {
  Future<List<Task>> call();
}

// Implementation
class GetAllTasksUseCaseImpl implements GetAllTasksUseCase {
  final TaskRepository _taskRepository;

  GetAllTasksUseCaseImpl(this._taskRepository);

  @override
  Future<List<Task>> call() async {
    return await _taskRepository.getAllTasks();
  }
}