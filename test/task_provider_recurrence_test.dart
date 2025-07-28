import 'package:dooit/core/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dooit/domain/entities/task.dart';
import 'package:dooit/app/providers/task_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'mocks/mocks.mocks.dart';


class FakeNotificationService implements NotificationService {
  @override
  Future<void> cancelNotification(int id) async {}

  @override
  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
  }) async {}

  @override
  Future<void> init() async {}

  // Trả về một plugin thật nhưng không được cấu hình,
  // chỉ để thỏa mãn kiểu trả về
  @override
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();
}



void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockGetAllTasksUseCase mockGetAllTasksUseCase;
  late MockCreateTaskUseCase mockCreateTaskUseCase;
  late MockUpdateTaskUseCase mockUpdateTaskUseCase;
  late MockDeleteTaskUseCase mockDeleteTaskUseCase;
  late TaskProvider provider;

  setUp(() {
    mockGetAllTasksUseCase = MockGetAllTasksUseCase();
    mockCreateTaskUseCase = MockCreateTaskUseCase();
    mockUpdateTaskUseCase = MockUpdateTaskUseCase();
    mockDeleteTaskUseCase = MockDeleteTaskUseCase();

    provider = TaskProvider(
      mockGetAllTasksUseCase,
      mockCreateTaskUseCase,
      mockUpdateTaskUseCase,
      mockDeleteTaskUseCase,
      notificationService: FakeNotificationService(),
    );
  });

  group('Recurrence Logic', () {
    test('completeTask tạo task mới khi recurrence=daily', () async {
      final task = Task(
        id: '1',
        title: 'Học bài',
        description: '',
        dueDate: DateTime(2025, 7, 25, 10, 0),
        dueTime: null,
        isCompleted: false,
        boardId: '',
        priority: 1,
        reminderTime: const Duration(hours: 1),
        recurrence: 'daily',
      );

      when(mockGetAllTasksUseCase()).thenAnswer((_) async => []);
      when(mockUpdateTaskUseCase(any)).thenAnswer((_) async {});
      when(mockCreateTaskUseCase(any)).thenAnswer((_) async {});

      await provider.completeTask(task);

      verify(mockUpdateTaskUseCase(any)).called(1);
      verify(mockCreateTaskUseCase(argThat(
        isA<Task>().having(
              (t) => t.dueDate?.day,
          'dueDate.day',
          task.dueDate!.add(const Duration(days: 1)).day,
        ),
      ))).called(1);
    });

    test('completeTask không tạo task mới nếu recurrence=none', () async {
      final task = Task(
        id: '1',
        title: 'Học bài',
        description: '',
        dueDate: DateTime(2025, 7, 25, 10, 0),
        dueTime: null,
        isCompleted: false,
        boardId: '',
        priority: 1,
        reminderTime: const Duration(hours: 1),
        recurrence: 'none',
      );

      when(mockGetAllTasksUseCase()).thenAnswer((_) async => []);
      when(mockUpdateTaskUseCase(any)).thenAnswer((_) async {});
      when(mockCreateTaskUseCase(any)).thenAnswer((_) async {});

      await provider.completeTask(task);

      verify(mockUpdateTaskUseCase(any)).called(1);
      verifyNever(mockCreateTaskUseCase(any));
    });
  });
}
