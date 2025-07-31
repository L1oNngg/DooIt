import 'package:dooit/app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import '../screens/task_list_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/goal_screen.dart';
import '../screens/board_screen.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  const AppBottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = const TaskListScreen();
        break;
      case 1:
        screen = const CalendarScreen();
        break;
      case 2:
        screen = GoalScreen();
        break;
      case 3:
        screen = const BoardScreen(
          boardId: 'default',
          boardName: 'Tất cả Boards',
        );
      case 4:
        screen = SettingsScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.grey[900], // Nền tối
      selectedItemColor: Colors.white,   // Màu icon/text khi chọn
      unselectedItemColor: Colors.grey[400], // Màu icon/text chưa chọn
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (i) => _onTap(context, i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.flag),
          label: 'Goals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Boards',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: 'Settings',
        )
      ],
    );
  }
}
