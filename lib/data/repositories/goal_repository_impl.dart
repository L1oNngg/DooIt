import '../../domain/entities/goal.dart';
import '../../domain/repositories/goal_repository.dart';
import '../datasources/goal_firestore_data_source.dart';
import '../models/goal_model.dart';

class GoalRepositoryImpl implements GoalRepository {
  final GoalFirestoreDataSource dataSource;
  GoalRepositoryImpl(this.dataSource);

  @override
  Future<List<Goal>> getAllGoals() async {
    final models = await dataSource.getAllGoals();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createGoal(Goal goal) async {
    final model = GoalModel(
      id: goal.id,
      name: goal.name,
      description: goal.description,
      taskIds: goal.taskIds,
      progress: goal.progress,
      isHabit: goal.isHabit,
      checkpointDate: goal.checkpointDate,
    );
    await dataSource.createGoal(model);
  }

  @override
  Future<String> createGoalReturnId(Goal goal) async {
    final model = GoalModel(
      id: goal.id,
      name: goal.name,
      description: goal.description,
      taskIds: goal.taskIds,
      progress: goal.progress,
      isHabit: goal.isHabit,
      checkpointDate: goal.checkpointDate,
    );
    return dataSource.createGoalReturnId(model);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    final model = GoalModel(
      id: goal.id,
      name: goal.name,
      description: goal.description,
      taskIds: goal.taskIds,
      progress: goal.progress,
      isHabit: goal.isHabit,
      checkpointDate: goal.checkpointDate,
    );
    await dataSource.updateGoal(model);
  }

  @override
  Future<void> deleteGoal(String id) async {
    return dataSource.deleteGoal(id);
  }
}
