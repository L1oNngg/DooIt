import '../entities/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getAllGoals();
  Future<void> createGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<String> createGoalReturnId(Goal goal);
}
