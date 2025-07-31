import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

class CreateTaskReturnIdUseCase {
  final TaskRepository repository;
  CreateTaskReturnIdUseCase(this.repository);

  Future<String> call(Task task) {
    return repository.createTaskReturnId(task);
  }
}
