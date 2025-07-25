import '../../domain/entities/task.dart';
import '../repositories/task_repository.dart';

// Abstract UseCase interface
abstract class UpdateTaskUseCase {
  Future<void> call(Task task);
}

// Implementation
class UpdateTaskUseCaseImpl implements UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCaseImpl(this._repository);

  @override
  Future<void> call(Task task) async {
    await _repository.updateTask(task);
  }
}