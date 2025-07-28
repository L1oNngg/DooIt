import 'package:mockito/annotations.dart';
import 'package:dooit/domain/usecases/get_all_tasks_use_case.dart';
import 'package:dooit/domain/usecases/create_task_use_case.dart';
import 'package:dooit/domain/usecases/update_task_use_case.dart';
import 'package:dooit/domain/usecases/delete_task_use_case.dart';

@GenerateMocks([
  GetAllTasksUseCase,
  CreateTaskUseCase,
  UpdateTaskUseCase,
  DeleteTaskUseCase,
])
void main() {}
