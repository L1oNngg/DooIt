import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dooit/domain/entities/task.dart'; // Adjusted import
import 'package:dooit/domain/usecases/create_task_use_case.dart'; // Adjusted import
import 'package:dooit/domain/repositories/task_repository.dart'; // Adjusted import

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  test('CreateTaskUseCase should create a task', () async {
    final mockRepository = MockTaskRepository();
    final useCase = CreateTaskUseCaseImpl(mockRepository);
    final task = Task(
      id: '1',
      title: 'Test Task',
      dueDate: DateTime.now(),
      boardId: 'board1',
    );

    await useCase(task);

    verify(mockRepository.createTask(task)).called(1);
  });
}