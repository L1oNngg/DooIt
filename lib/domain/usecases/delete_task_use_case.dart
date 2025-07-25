import '../entities/task.dart';
import '../repositories/task_repository.dart';

// Abstract UseCase interface
abstract class DeleteTaskUseCase {
  Future<void> call(Task task);
}

// Implementation
class DeleteTaskUseCaseImpl implements DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCaseImpl(this._repository);

  @override
  Future<void> call(Task task) async {
    await _repository.deleteTask(task);
  }
}