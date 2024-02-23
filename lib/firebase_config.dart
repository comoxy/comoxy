import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
        appId: '1:448618578101:web:0b650370bb29e29cac3efc',
        apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
        projectId: 'react-native-firebase-testing',
        messagingSenderId: '448618578101',
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '1:606879734435:ios:d71a987273ea103651bd16',
        apiKey: 'AIzaSyC8mDb3dwMfmMNAxauf5KD0SmYcATxbtpE',
        projectId: 'fir-test-8473c',
        messagingSenderId: '606879734435',
        iosBundleId: 'com.subscription.subscriptionApp',
      );
    } else {
      // Android
      return const FirebaseOptions(
        appId: '1:606879734435:android:a87bf08acc7661ad51bd16',
        apiKey: 'AIzaSyCuu4tbv9CwwTudNOweMNstzZHIDBhgJxA',
        projectId: 'fir-test-8473c',
        messagingSenderId: '448618578101',
      );
    }
  }
}