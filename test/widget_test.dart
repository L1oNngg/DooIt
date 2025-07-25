import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:dooit/app/screens/task_list_screen.dart';
import 'package:dooit/app/providers/task_provider.dart';
import 'package:dooit/domain/entities/task.dart';
import 'package:dooit/domain/repositories/task_repository.dart';
import 'mocks/mocks.mocks.dart'; // mock generated file

void main() {
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
  });

  testWidgets('Task List Screen smoke test', (WidgetTester tester) async {
    when(mockRepository.getAllTasks()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider(mockRepository)),
        ],
        child: MaterialApp(home: TaskListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('DooIt - Task List'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.sort), findsOneWidget);
  });

  testWidgets('Task List Screen adds task', (WidgetTester tester) async {
    final newTask = Task(
      id: 'new_task_id',
      title: 'New Task',
      dueDate: DateTime.now(),
      isCompleted: false,
      boardId: 'board1',
    );

    late Task capturedTask;

    when(mockRepository.getAllTasks()).thenAnswer((_) async => []);
    when(mockRepository.createTask(any)).thenAnswer((invocation) async {
      capturedTask = invocation.positionalArguments.first as Task;
      when(mockRepository.getAllTasks()).thenAnswer((_) async => [capturedTask]);
      return Future.value(); // Trả về Future<void>
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider(mockRepository)),
        ],
        child: MaterialApp(home: TaskListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'New Task');
    await tester.tap(find.text('Thêm'));
    await tester.pumpAndSettle(Duration(seconds: 1)); // Chờ đồng bộ

    verify(mockRepository.createTask(argThat(isA<Task>()))).called(1);
    expect(capturedTask.title, equals('New Task'));
    await tester.pumpAndSettle();
    expect(find.text('New Task'), findsOneWidget);
  });

  testWidgets('Task List Screen toggles task completion', (WidgetTester tester) async {
    final initialTask = Task(
      id: '1',
      title: 'Test Task',
      dueDate: DateTime.now(),
      isCompleted: false,
      boardId: 'board1',
    );

    final updatedTask = initialTask.copyWith(isCompleted: true);
    late Task capturedUpdate;

    when(mockRepository.getAllTasks()).thenAnswer((_) async => [initialTask]);
    when(mockRepository.updateTask(any)).thenAnswer((invocation) async {
      capturedUpdate = invocation.positionalArguments.first as Task;
      when(mockRepository.getAllTasks()).thenAnswer((_) async => [capturedUpdate.copyWith(isCompleted: true)]);
      return; // Trả về Future<void>
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider(mockRepository)),
        ],
        child: MaterialApp(home: TaskListScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Test Task'), findsOneWidget);
    expect(find.byType(Checkbox).first, findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    verify(mockRepository.updateTask(argThat(isA<Task>()))).called(1);
    expect(capturedUpdate.isCompleted, isTrue);
    await tester.pumpAndSettle();
  });
}