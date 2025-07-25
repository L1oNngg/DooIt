import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      // Sử dụng emulator nếu được định nghĩa
        const String? emulatorHost = String.fromEnvironment('FIRESTORE_EMULATOR_HOST');
        if (emulatorHost != null) {
          return FirebaseOptions(
            appId: '1:388101868129:android:84d7a780e76f60f0773820',
            apiKey: 'AIzaSyA1yHKWF-Wd7FAcZ-zi3xFPxQ7ya0ItPdY',
            projectId: 'my-dooit-app',
            messagingSenderId: '388101868129',
            storageBucket: 'my-dooit-app.firebasestorage.app',
          );
        }
        return android;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1yHKWF-Wd7FAcZ-zi3xFPxQ7ya0ItPdY',
    appId: '1:388101868129:android:84d7a780e76f60f0773820',
    messagingSenderId: '388101868129',
    projectId: 'my-dooit-app',
    storageBucket: 'my-dooit-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAbndqDJmjLlC_p3W_GBxYfaib9-lw4VlU',
    appId: '1:388101868129:ios:23eb7642c21bb610773820',
    messagingSenderId: '388101868129',
    projectId: 'my-dooit-app',
    storageBucket: 'my-dooit-app.firebasestorage.app',
    iosBundleId: 'com.example.dooit',
  );
}