import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rate_review/service/auth.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_ios/shared_preferences_ios.dart';
import '../model/user/user.dart';
import 'notification_service.dart';
import 'userdefault.dart';

@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  print('FirebaseMessaging onBackgroundMessage123');
  // await GetStorage.init(UserDefault.UDKey);
  // if (Platform.isAndroid) SharedPreferencesAndroid.registerWith();
  // if (Platform.isIOS) SharedPreferencesIOS.registerWith();
  await Firebase.initializeApp();

  if (Platform.isAndroid) SharedPreferencesAndroid.registerWith();
  if (Platform.isIOS) SharedPreferencesIOS.registerWith();

  NotificationService().showNotification(message);
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> setBackgroundNotificationListener() async {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    // await notificationPermission();

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      log('FirebaseMessaging getInitialMessage $message');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('FirebaseMessaging onMessageOpenedApp $message');
      //AppUtil.toast('FirebaseMessaging');
    });

    FirebaseMessaging.onMessage.listen(
      (message) async {
        log('FirebaseMessaging onMessage');
        NotificationService().showNotification(message);
      },
      onError: _onError,
      onDone: _onDone,
      cancelOnError: false,
    );

    _firebaseMessaging.getToken().then((value) async {
      log('firebaseMessaging Token: $value');
      var fToken = await UserDefault().readString(UserDefault.kFirebaseToken);
      if (fToken == null) {
        UserDefault().saveString(UserDefault.kFirebaseToken, value!);
      }
      if (value != null) {
        await AuthModel().saveTokenOnServer(value);
      }
    });
    var fToken = await UserDefault().readString(UserDefault.kFirebaseToken);
    if (fToken != null) {
      await AuthModel().saveTokenOnServer(fToken);
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      log('firebaseMessaging onTokenRefresh: $newToken');
      //fcmSubscribe();
      //await AuthModel().saveTokenOnServer(newToken);
    });
  }

  Future<void> notificationPermission() async {
    if (Platform.isIOS) {
      // NotificationSettings settings = await _firebaseMessaging.requestPermission(
      //   alert: true,
      //   announcement: false,
      //   badge: true,
      //   carPlay: false,
      //   criticalAlert: false,
      //   provisional: false,
      //   sound: true,
      // );

      // await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      //   alert: true,
      //   badge: true,
      //   sound: true,
      // );

      // if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      //   log('User granted permission');
      // }
      // else {
      //   log('User declined or has not accepted permission');
      // }
    }
  }

//TODO 30/03/2022
  Future<void> fcmSubscribe() async {
    User? _user = await UserDefault().getUser();
    ///TESTING
    if (Platform.isAndroid) {
      _firebaseMessaging.subscribeToTopic('AllBestAndroid');
     _firebaseMessaging.subscribeToTopic('Android${_user?.userEmail?.replaceAll("@", "-")??""}');
    } else if (Platform.isIOS) {
      _firebaseMessaging.subscribeToTopic('AllBestIOS');
     _firebaseMessaging.subscribeToTopic('Ios${_user?.userEmail?.replaceAll("@", "-")??""}');
    }

  }
//TODO Over

  Future<void> fcmUnSubscribe() async {
    User? _user = await UserDefault().getUser();
    ///Testing
    if (Platform.isAndroid) {
      _firebaseMessaging.unsubscribeFromTopic('AllBestAndroid');
      _firebaseMessaging.unsubscribeFromTopic('Android${_user?.userEmail?.replaceAll("@", "-")??""}');
    } else if (Platform.isIOS) {
      _firebaseMessaging.unsubscribeFromTopic('AllBestIOS');
      _firebaseMessaging.unsubscribeFromTopic('Ios${_user?.userEmail?.replaceAll("@", "-")??""}');
    }

    ////LIVE
    // if (Platform.isAndroid) {
    //   _firebaseMessaging.unsubscribeFromTopic('AllBestAndroid');
    // } else if (Platform.isIOS) {
    //   _firebaseMessaging.unsubscribeFromTopic('AllBestIOS');
    // }

  }

  void _onError(e) {
    log('firebaseMessaging _onError');
  }

  void _onDone() {
    log('firebaseMessaging _onDone');
  }
}
