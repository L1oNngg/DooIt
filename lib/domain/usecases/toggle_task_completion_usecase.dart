import '../repositories/task_repository.dart';

class ToggleTaskCompletionUseCase {
  final TaskRepository repository;
  ToggleTaskCompletionUseCase(this.repository);

  Future<void> call(String taskId, DateTime date, bool isCompleted) {
    return repository.toggleCompletion(taskId, date, isCompleted);
  }
}
