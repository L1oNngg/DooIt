import 'package:flutter/material.dart';

import '../../core/dependency_injection.dart';
import '../../core/services/notification_service.dart';
import '../widgets/app_bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt & Tài khoản'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Đăng nhập'),
              subtitle: const Text('Sử dụng tài khoản để đồng bộ công việc'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Đăng ký tài khoản'),
              subtitle: const Text('Tạo tài khoản mới để cộng tác với nhóm'),
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
            ),
            const Divider(),
            const SizedBox(height: 40),
            const Text(
              'Trong tương lai:\n'
                  '- Khi đăng nhập: sẽ đồng bộ boards, tasks, goals với server.\n'
                  '- Khi có nhóm: quản lý thành viên, phân quyền.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await requestNotificationPermission();
          getIt<NotificationService>().showNotification(
            title: 'Test',
            body: 'Thông báo thử nghiệm',
          );
        },
        child: const Icon(Icons.notifications),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }
}
