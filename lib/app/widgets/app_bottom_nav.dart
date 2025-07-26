import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return; // không làm gì nếu chọn tab hiện tại
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/');
        } else if (index == 1) {
          Navigator.pushReplacementNamed(
            context,
            '/board',
            arguments: {
              'boardId': 'sample-board',
              'boardName': 'Công việc',
            },
          );
        } else if (index == 2) {
          Navigator.pushReplacementNamed(context, '/calendar');
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Nhiệm vụ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Board',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Lịch',
        ),
      ],
    );
  }
}
