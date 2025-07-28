import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/dependency_injection.dart' as di;
import 'app/navigator/app_routes.dart';
import 'app/providers/task_provider.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kết nối với emulator Firestore khi chạy cục bộ
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

  // Khởi tạo NotificationService (bao gồm timezone)
  await NotificationService().init();
  NotificationService().debugShowTestNotification();


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskProvider>(
          create: (_) => di.getIt<TaskProvider>(),
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
      initialRoute: AppRoutes.taskList,
      routes: AppRoutes.routes,
    );
  }
}
