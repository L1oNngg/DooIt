import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  // Đăng ký Firestore
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Đăng ký Data Source
  getIt.registerLazySingleton<TaskFirestoreDataSource>(
        () => TaskFirestoreDataSource(getIt()),
  );

  // Đăng ký Repository
  getIt.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(getIt()),
  );

  // Đăng ký Use Cases
  getIt.registerLazySingleton<CreateTaskUseCase>(
        () => CreateTaskUseCaseImpl(getIt()),
  );
  getIt.registerLazySingleton<DeleteTaskUseCase>(
        () => DeleteTaskUseCaseImpl(getIt()),
  );
  getIt.registerLazySingleton<UpdateTaskUseCase>(
        () => UpdateTaskUseCaseImpl(getIt()),
  );
  getIt.registerLazySingleton<GetAllTasksUseCase>(
        () => GetAllTasksUseCaseImpl(getIt()),
  );

  // Đăng ký Provider
  getIt.registerFactory<TaskProvider>(
        () => TaskProvider(
      getIt(),
      getIt(),
      getIt(),
      getIt(),
    ),
  );
}