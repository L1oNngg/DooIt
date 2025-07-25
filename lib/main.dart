import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz; // Thêm import này
import 'app/navigator/app_routes.dart';
import 'app/providers/task_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/dependency_injection.dart' as di;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz.initializeTimeZones(); // Khởi tạo dữ liệu timezone
  // Thiết lập timezone cục bộ (ví dụ: Asia/Ho_Chi_Minh cho Việt Nam, múi giờ +07)
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('app_icon'); // Đảm bảo file app_icon.png đã thêm
  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);
  try {
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  } catch (e) {
    print('Lỗi khởi tạo thông báo: $e'); // Log lỗi nhưng không crash
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kết nối với emulator khi chạy cục bộ
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    FirebaseFirestore.instance.settings = const Settings(
      host: '127.0.0.1:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
  }

  if (const String.fromEnvironment('FIRESTORE_EMULATOR_HOST') != null) {
    FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  }

  // Khởi tạo dependency injection
  di.setupDependencies();

  await initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => di.getIt<TaskProvider>(param1: flutterLocalNotificationsPlugin),
        ),
      ],
      child: DooItApp(),
    ),
  );
}

class DooItApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DooIt',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.taskList, // Cập nhật route name
      routes: AppRoutes.routes,
    );
  }
}