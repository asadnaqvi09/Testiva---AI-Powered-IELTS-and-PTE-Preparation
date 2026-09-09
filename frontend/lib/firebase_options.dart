// Generated manually from android/app/google-services.json (project testivafyp).
// For iOS, add GoogleService-Info.plist and run `flutterfire configure`, or
// extend this file with an iOS [FirebaseOptions] entry.
// ignore_for_file: lines_longer_than_80_chars

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS. '
          'Add ios/Runner/GoogleService-Info.plist and run flutterfire configure.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDIImVloEv8mUPG1dMOF5hRYt_zgR9vVuk',
    appId: '1:298829936456:android:114edb3a7c7bd036ef657d',
    messagingSenderId: '298829936456',
    projectId: 'testivafyp',
    storageBucket: 'testivafyp.firebasestorage.app',
  );
}
