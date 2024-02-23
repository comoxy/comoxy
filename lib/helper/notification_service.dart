import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:rate_review/model/notification/user_notification.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/screen/progressive_screen.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';

import 'userdefault.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(iOS: initializationSettingsIOS, android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    bool isFromNotification = await _wasApplicationLaunchedFromNotification();
    log('isFromNotification $isFromNotification');
    handleApplicationWasLaunchedFromNotification();
    return;
  }

  Future<bool> requestPermissions() async {
    if (!Platform.isIOS) {
      return true;
    }
    final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings = InitializationSettings(iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result != null && result == true;
  }

  void showNotification(RemoteMessage remoteMessage) async {
    print('Show notification');
    bool hasPermission = await requestPermissions();
    if (!hasPermission) {
      return;
    }
    Map<String, dynamic> data = remoteMessage.data;
    UserNotification userNotification = UserNotification.fromJson(jsonDecode(data['payload']));
    /*final String? bigPicturePath = await _downloadAndSaveFile(userNotification.photoName, 'bigPicture.jpg');
    BigPictureStyleInformation? bigPictureStyleInformation;
    if (bigPicturePath != null) {
      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        contentTitle: '<b>${userNotification.postTitle}</b>',
        htmlFormatContentTitle: true,
        summaryText: userNotification.postTitle,
        htmlFormatSummaryText: true,
      );

      final String bigPicture = await _base64encodedImage(userNotification.photoName!);
    BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(bigPicture),
        contentTitle: '<b>${userNotification.postTitle}</b>',
        htmlFormatContentTitle: true,
        summaryText: userNotification.postTitle,
        htmlFormatSummaryText: true);

    }*/

    print('FirebaseMessaging ${userNotification.toJson().toString()}');

    User? _user = await UserDefault().getUser();
    String? languagecode = await UserDefault().getLanguageCode();
    print('FirebaseMessaging userMap ${_user != null}');
    if (_user == null) {
      return;
    }

    if(userNotification.type == 1 ) {
      var indexOfExclude = -1;
      if (userNotification.excluded != null) {
        indexOfExclude = userNotification.excluded!.indexWhere((element) => _user.userEmail == element.userEmail);
      }

      AppUtil.langcode = _user.languageCode;

      if (((userNotification.isTargetdateAll != null && userNotification.isTargetdateAll == '1' && 1 == 1) ||
          (_user.age != null &&
              _user.age!.toInt >= userNotification.targetFromAge!.toInt &&
              _user.age!.toInt <= userNotification.targetToAge!.toInt)) &&
          (
              // TODO 14/03/2022
              (userNotification.targetGender == 'all' ||
                  userNotification.targetGender?.toLowerCase() == _user.gender!.toLowerCase()) &&
                  (userNotification.targetEthnicity == 'all' ||
                      userNotification.targetEthnicity!.isCaseInsensitiveContains(_user.ethnicity!)) &&
                  (userNotification.targetLocation == 'all' ||
                      userNotification.targetLocation!.isCaseInsensitiveContains(_user.homeCountry!))) &&
          //todo changed rp
          // (userNotification.languageCode == languagecode) &&
          indexOfExclude == -1) {
        await notify(userNotification, remoteMessage);
      }
    }
    else if( userNotification.type == 2) ///from CMS
      {
        await notify(userNotification, remoteMessage);
      }
  }

  Future<void> notify(UserNotification userNotification, RemoteMessage remoteMessage) async {
    print('FirebaseMessaging showNotification');
    int rndInt = Random().nextInt(1000);
    int id = userNotification.postid != null ? int.tryParse(userNotification.postid!) ?? rndInt : rndInt;
    String? title = userNotification.header;
    String? body = userNotification.postTitle;

    BigPictureStyleInformation? bigPictureStyleInformation;
    String? bigPicture;
    if (Platform.isIOS) {
      // bigPicture = await _downloadAndSaveFile(userNotification.photoName, 'bigPicture.jpg');
    } else {
      // bigPicture = await _base64encodedImage(userNotification.photoName);
    }
    if (bigPicture != null && !Platform.isIOS) {
      bigPictureStyleInformation = BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(bigPicture),
        contentTitle: '<b>$title</b>',
        htmlFormatContentTitle: true,
        // summaryText: body,
        // htmlFormatSummaryText: true,
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(bigPicture),
        hideExpandedLargeIcon: true,
        htmlFormatContent: true,
        htmlFormatTitle: true,
      );
    }

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(
          android: AndroidNotificationDetails(
            userNotification.postid ?? 'notify',
            title ?? AppUtil.appName,
            icon: 'ic_notification',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: bigPictureStyleInformation,
            playSound: true,
            // subText: body
          ),
          iOS: IOSNotificationDetails(
              presentBadge: true,
              presentSound: true,
              presentAlert: true,
              threadIdentifier: title,
              // subtitle: body,
              attachments: bigPicture == null ? null : [IOSNotificationAttachment(bigPicture)])),
      payload: json.encode(remoteMessage.data),
    );
  }

  Future<String?> _base64encodedImage(String? url) async {
    if (url == null) {
      return null;
    }
    if (url.isEmpty) {
      return null;
    }
    final http.Response response = await http.get(Uri.parse(url)).timeout(Duration(seconds: timeoutDuration), onTimeout: () {
      //loge(resource.connectionTimeout);
      AppUtil.toast(resource.connectionTimeout.tr);
      throw TimeoutException(resource.connectionTimeout.tr);
    });
    final String base64Data = base64Encode(response.bodyBytes);
    return base64Data;
  }

  Future<String?> _downloadAndSaveFile(String? url, String fileName) async {
    if (url == null) {
      return null;
    }
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      String mFilePath = '${directory.path}/$fileName';
      bool hasImage = await File(mFilePath).exists();
      if (hasImage) {
        await File(mFilePath).delete(recursive: false);
      }
      final String filePath = mFilePath;
      final http.Response response = await http.get(Uri.parse(url)).timeout(Duration(seconds: timeoutDuration), onTimeout: () {
        //loge(resource.connectionTimeout);
        AppUtil.toast(resource.connectionTimeout.tr);
        throw TimeoutException(resource.connectionTimeout.tr);
      });
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } catch (e) {
      log('exception _downloadAndSaveFile');
      return null;
    }
  }

  void cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  void handleApplicationWasLaunchedFromNotification() async {
    log('Notification handleApplicationWasLaunchedFromNotification');
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    if (notificationAppLaunchDetails != null && notificationAppLaunchDetails.didNotificationLaunchApp) {
      // AppUtil.toast('Launched From Notification');
      // UserNotification userNotification = getUserNotificationFromPayload(notificationAppLaunchDetails.payload!);
      onSelectNotification(notificationAppLaunchDetails.payload);
    }
  }

  UserNotification getUserNotificationFromPayload(String payload) {
    Map<String, dynamic> json = jsonDecode(payload);
    UserNotification userNotification = UserNotification.fromJson(json);
    return userNotification;
  }

  Future<bool> _wasApplicationLaunchedFromNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    return notificationAppLaunchDetails!.didNotificationLaunchApp;
  }

  Future<int> getPendingNotificationCount() async {
    List<PendingNotificationRequest> p = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> onSelectNotification(String? payload) async {
    log('Notification onSelectNotification 0 $payload');
    // TODO get response and handle

    Get.to(() => ProgressiveScreen(payload: payload));
    // handle notification tapped if required¸ ̰
  }

  void onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    log('Notification onSelectNotification 1');
    // TODO get response and handle
    Get.to(() => ProgressiveScreen(payload: payload));
  }
}
