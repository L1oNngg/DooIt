import 'package:flutter/material.dart';
import '../screens/task_list_screen.dart';
import '../screens/board_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/task_detail_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';

class AppRoutes {
  static const String taskList = '/';
  static const String board = '/board';
  static const String calendar = '/calendar';
  static const String taskDetail = '/task-detail';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String register = '/register';

  static Map<String, WidgetBuilder> get routes {
    return {
      taskList: (context) => const TaskListScreen(),
      board: (context) {
        final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;
        return BoardScreen(
          boardId: args['boardId'] as String,
          boardName: args['boardName'] as String,
        );
      },
      calendar: (context) => const CalendarScreen(),
      taskDetail: (context) => const TaskDetailScreen(),
      settings: (context) => const SettingsScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
    };
  }
}
