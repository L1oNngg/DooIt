import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

import 'package:dooit/app/screens/task_list_screen.dart';
import 'package:dooit/app/providers/task_provider.dart';
import 'package:dooit/domain/entities/task.dart';

import 'mocks/mocks.mocks.dart';

void main() {
  late MockGetAllTasksUseCase mockGetAllTasksUseCase;
  late MockCreateTaskUseCase mockCreateTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;

  setUp(() {
    mockGetAllTasksUseCase = MockGetAllTasksUseCase();
    mockCreateTaskUseCase = MockCreateTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();
  });

  Widget buildTestableWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            mockGetAllTasksUseCase,
            mockCreateTaskUseCase,
            mockUpdateTaskUseCase,
            mockDeleteTaskUseCase,
          ),
        ),
      ],
      child: MaterialApp(
        home: const TaskListScreen(),
        routes: {
          '/task-detail': (context) {
            // Tạo một widget giả cho màn hình TaskDetail để test thôi
            return const Scaffold(
              body: Center(child: Text('Mock Task Detail Screen')),
            );
          },
        },
      ),
    );
  }


  // testWidgets('Task List Screen smoke test', (WidgetTester tester) async {
  //   when(mockGetAllTasksUseCase()).thenAnswer((_) async => []);
  //
  //   await tester.pumpWidget(buildTestableWidget());
  //   await tester.pumpAndSettle();
  //
  //   // Kiểm tra tiêu đề màn hình
  //   expect(find.text('Danh sách nhiệm vụ'), findsOneWidget);
  //   expect(find.byIcon(Icons.add), findsOneWidget);
  // });
  //
  // testWidgets('Task List Screen adds task', (WidgetTester tester) async {
  //   final newTask = Task(
  //     id: 'new_task_id',
  //     title: 'New Task',
  //     description: '',
  //     dueDate: DateTime.now(),
  //     dueTime: null,
  //     isCompleted: false,
  //     boardId: 'board1',
  //     priority: 1,
  //     reminderTime: const Duration(hours: 1),
  //     recurrence: 'none',
  //   );
  //
  //   late Task capturedTask;
  //
  //   when(mockGetAllTasksUseCase()).thenAnswer((_) async => []);
  //   when(mockCreateTaskUseCase(any)).thenAnswer((invocation) async {
  //     capturedTask = invocation.positionalArguments.first as Task;
  //     when(mockGetAllTasksUseCase()).thenAnswer((_) async => [capturedTask]);
  //     return Future.value();
  //   });
  //
  //   await tester.pumpWidget(buildTestableWidget());
  //   await tester.pumpAndSettle();
  //
  //   // Bấm nút thêm
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pumpAndSettle();
  //   expect(find.text('Mock Task Detail Screen'), findsOneWidget);
  //
  //
  //   // Nhập dữ liệu vào dialog (dùng TextField đầu tiên)
  //   await tester.enterText(find.byType(TextField).first, 'New Task');
  //   await tester.tap(find.text('Thêm'));
  //   await tester.pumpAndSettle(const Duration(seconds: 1));
  //
  //   verify(mockCreateTaskUseCase(argThat(isA<Task>()))).called(1);
  //   expect(capturedTask.title, equals('New Task'));
  // });

  testWidgets('Task List Screen opens TaskDetailScreen when pressing add', (WidgetTester tester) async {
    when(mockGetAllTasksUseCase()).thenAnswer((_) async => []);

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap vào nút "+"
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Kiểm tra rằng màn hình TaskDetailScreen (mock) đã được mở
    expect(find.text('Mock Task Detail Screen'), findsOneWidget);
  });


  testWidgets('Task List Screen toggles task completion', (WidgetTester tester) async {
    final initialTask = Task(
      id: '1',
      title: 'Test Task',
      description: '',
      dueDate: DateTime.now(),
      dueTime: null,
      isCompleted: false,
      boardId: 'board1',
      priority: 1,
      reminderTime: const Duration(hours: 1),
      recurrence: 'none',
    );

    final updatedTask = initialTask.copyWith(isCompleted: true);
    late Task capturedUpdate;

    when(mockGetAllTasksUseCase()).thenAnswer((_) async => [initialTask]);
    when(mockUpdateTaskUseCase(any)).thenAnswer((invocation) async {
      capturedUpdate = invocation.positionalArguments.first as Task;
      when(mockGetAllTasksUseCase()).thenAnswer((_) async => [capturedUpdate]);
      return;
    });

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    expect(find.text('Test Task'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    verify(mockUpdateTaskUseCase(argThat(isA<Task>()))).called(1);
    expect(capturedUpdate.isCompleted, isTrue);
  });
}
