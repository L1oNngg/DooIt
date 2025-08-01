import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';

class TestNotificationScreen extends StatelessWidget {
  const TestNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notification')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Hiện thông báo ngay lập tức
            await NotificationService().showNotification(
              id: 999,
              title: 'Thông báo test ngay lập tức',
              body: 'Bạn vừa bấm nút test',
            );

            // Giả lập countdown 3 phút
            int remainingMinutes = 3;
            Timer.periodic(const Duration(minutes: 1), (timer) async {
              remainingMinutes--;
              if (remainingMinutes <= 0) {
                await NotificationService().showNotification(
                  id: 1000,
                  title: 'Hết hạn',
                  body: 'Đã đến hạn test!',
                );
                timer.cancel();
              } else {
                await NotificationService().showNotification(
                  id: 1000,
                  title: 'Đếm ngược test',
                  body: 'Còn $remainingMinutes phút nữa (test)',
                );
              }
            });
          },
          child: const Text('Test thông báo và countdown'),
        ),
      ),
    );
  }
}
