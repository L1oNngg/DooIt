import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'app/providers/board_provider.dart';
import 'app/providers/goal_provider.dart';
import 'data/services/board_service.dart';
import 'firebase_options.dart';
import 'core/dependency_injection.dart' as di;
import 'app/navigator/app_routes.dart';
import 'app/providers/task_provider.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kiểm tra nếu đang chạy trên emulator Android
  final bool isEmulator = await _checkIfEmulator();
  if (isEmulator) {
    // Khi chạy emulator, dùng Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
    FirebaseFirestore.instance.settings = const Settings(
      sslEnabled: false,
      persistenceEnabled: false,
    );
    debugPrint('Đang chạy trên emulator -> dùng Firestore emulator.');
  } else {
    debugPrint('Đang chạy trên thiết bị thật -> dùng Firebase thật.');
  }

  // Dependency injection
  di.setupDependencies();

  // Đảm bảo board mặc định tồn tại
  final boardService = BoardService();
  final defaultBoardId = await boardService.ensureDefaultBoard();
  di.getIt<TaskProvider>().setDefaultBoardId(defaultBoardId);

  // Khởi tạo NotificationService
  await di.getIt<NotificationService>().init();
  // NotificationService().debugShowTestNotification();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => di.getIt<TaskProvider>(),
        ),
        ChangeNotifierProvider(create: (_) => di.getIt<GoalProvider>()),
        ChangeNotifierProvider(create: (_) => BoardProvider()),
      ],
      child: DooItApp(),
    ),
  );
}

Future<bool> _checkIfEmulator() async {
  final deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.isPhysicalDevice == false;
  }

  if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.isPhysicalDevice == false;
  }

  return false;
}

class DooItApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DooIt',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.taskList,
      routes: AppRoutes.routes,
    );
  }
}
