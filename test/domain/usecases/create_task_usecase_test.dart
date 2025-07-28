import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dooit/domain/entities/task.dart';
import 'package:dooit/domain/usecases/create_task_use_case.dart';

import '../../mocks/mocks.mocks.dart';

void main() {
  late MockCreateTaskUseCase mockCreateTaskUseCase;

  setUp(() {
    mockCreateTaskUseCase = MockCreateTaskUseCase();
  });

  test('Gọi CreateTaskUseCase thành công', () async {
    final task = Task(
      id: '1',
      title: 'Task test',
      description: 'desc',
      dueDate: DateTime.now(),
      dueTime: null,
      isCompleted: false,
      boardId: '',
      priority: 1,
      reminderTime: const Duration(hours: 1),
      recurrence: 'none',
    );

    // Sử dụng use case
    when(mockCreateTaskUseCase(task)).thenAnswer((_) async {});

    await mockCreateTaskUseCase(task);

    verify(mockCreateTaskUseCase(task)).called(1);
  });
}
