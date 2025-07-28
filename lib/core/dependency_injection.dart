import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/datasources/task_firestore_data_source.dart';
import '../data/repositories/task_repository_impl.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/usecases/create_task_use_case.dart';
import '../domain/usecases/delete_task_use_case.dart';
import '../domain/usecases/update_task_use_case.dart';
import '../domain/usecases/get_all_tasks_use_case.dart';

import '../app/providers/task_provider.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Firestore
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Data source
  getIt.registerLazySingleton<TaskFirestoreDataSource>(
        () => TaskFirestoreDataSource(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton<CreateTaskUseCase>(
          () => CreateTaskUseCaseImpl(getIt()));
  getIt.registerLazySingleton<DeleteTaskUseCase>(
          () => DeleteTaskUseCaseImpl(getIt()));
  getIt.registerLazySingleton<UpdateTaskUseCase>(
          () => UpdateTaskUseCaseImpl(getIt()));
  getIt.registerLazySingleton<GetAllTasksUseCase>(
          () => GetAllTasksUseCaseImpl(getIt()));

  // Provider
  getIt.registerFactory<TaskProvider>(() => TaskProvider(
    getIt<CreateTaskUseCase>(),
    getIt<DeleteTaskUseCase>(),
    getIt<UpdateTaskUseCase>(),
    getIt<GetAllTasksUseCase>(),
  ));
}
