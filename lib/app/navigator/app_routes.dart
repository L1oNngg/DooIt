import 'package:flutter/material.dart';
import '../screens/task_list_screen.dart';
import '../screens/board_screen.dart';
import '../screens/goal_screen.dart';
import '../screens/calendar_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String taskList = '/task';
  static const String board = '/board';
  static const String goal = '/goal';
  static const String calendar = '/calendar';

  static final routes = <String, WidgetBuilder>{
    initial: (context) => TaskListScreen(),
    taskList: (context) => TaskListScreen(),
    board: (context) => BoardScreen(),
    goal: (context) => GoalScreen(),
    calendar: (context) => CalendarScreen(),
  };
}