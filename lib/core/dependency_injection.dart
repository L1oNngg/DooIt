import 'package:dooit/core/services/notification_service.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../app/providers/goal_provider.dart';
import '../data/datasources/goal_firestore_data_source.dart';
import '../data/datasources/task_completion_data_source.dart';
import '../data/datasources/task_firestore_data_source.dart';
import '../data/repositories/goal_repository_impl.dart';
import '../data/repositories/task_repository_impl.dart';
import '../domain/repositories/goal_repository.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/usecases/create_task_return_id_usecase.dart';
import '../domain/usecases/create_task_use_case.dart';
import '../domain/usecases/delete_task_use_case.dart';
import '../domain/usecases/get_task_completions_usecase.dart';
import '../domain/usecases/toggle_task_completion_usecase.dart';
import '../domain/usecases/update_task_use_case.dart';
import '../domain/usecases/get_all_tasks_use_case.dart';

import '../app/providers/task_provider.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Firestore
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Service
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Data source
  getIt.registerLazySingleton<TaskFirestoreDataSource>(
        () => TaskFirestoreDataSource(getIt()));
  getIt.registerLazySingleton<TaskCompletionDataSource>(
          () => TaskCompletionDataSource(getIt()));
  getIt.registerLazySingleton<GoalFirestoreDataSource>(
          () => GoalFirestoreDataSource(getIt()));

  // Repository
  getIt.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(getIt<TaskFirestoreDataSource>(), getIt<TaskCompletionDataSource>()));
  getIt.registerLazySingleton<GoalRepository>(
          () => GoalRepositoryImpl(getIt()));

  // Use cases
  getIt.registerLazySingleton<CreateTaskUseCase>(
          () => CreateTaskUseCaseImpl(getIt()));
  getIt.registerLazySingleton<DeleteTaskUseCase>(
          () => DeleteTaskUseCaseImpl(getIt()));
  getIt.registerLazySingleton<UpdateTaskUseCase>(
          () => UpdateTaskUseCaseImpl(getIt()));
  getIt.registerLazySingleton<GetAllTasksUseCase>(
          () => GetAllTasksUseCaseImpl(getIt()));
  getIt.registerLazySingleton<GetTaskCompletionsUseCase>(
          () => GetTaskCompletionsUseCase(getIt<TaskRepository>()));
  getIt.registerLazySingleton<ToggleTaskCompletionUseCase>(
          () => ToggleTaskCompletionUseCase(getIt<TaskRepository>()));
  getIt.registerLazySingleton<CreateTaskReturnIdUseCase>(
          () => CreateTaskReturnIdUseCase(getIt<TaskRepository>()));

  // Provider
  getIt.registerFactory<TaskProvider>(() => TaskProvider(
    getIt<CreateTaskUseCase>(),
    getIt<DeleteTaskUseCase>(),
    getIt<UpdateTaskUseCase>(),
    getIt<GetAllTasksUseCase>(),
    getIt<GetTaskCompletionsUseCase>(),
    getIt<ToggleTaskCompletionUseCase>(),
    getIt<CreateTaskReturnIdUseCase>(),
    getIt<TaskRepository>(),
  ));

  getIt.registerFactory(() => GoalProvider(
      getIt(),            // GoalRepository
      getIt<TaskProvider>() // TaskProvider
  ));
}
