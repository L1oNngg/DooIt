import '../repositories/task_repository.dart';

class GetTaskCompletionsUseCase {
  final TaskRepository repository;
  GetTaskCompletionsUseCase(this.repository);

  Future<List<DateTime>> call(String taskId, DateTime from, DateTime to) {
    return repository.getCompletions(taskId, from, to);
  }
}
