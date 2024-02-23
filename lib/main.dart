import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:rate_review/util/common.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'controller/global_bindings.dart';
import 'helper/notification.dart';
import 'helper/notification_service.dart';
import 'helper/userdefault.dart';
import 'lang/translation_service.dart';
import 'ui/screen/progressive_screen.dart';
import 'ui/screen/splash_screen.dart';
import 'util/theming.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

var documentDirectory;
Directory? newDirectory;
UserDefault userDefault = Get.find();
String? languageCode;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  GlobalBindings().dependencies();
  await Firebase.initializeApp();
  String? initialRoute;
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();

  //TODO 07/04/2022
  await userDefault.getLanguageCode().then((value) {
    languageCode = value;
    AppUtil.langcode = value;
  });



  if (Platform.isAndroid) {
    documentDirectory = await getExternalStorageDirectory();
    newDirectory = Directory('${documentDirectory.path}/temp/');
  } else if (Platform.isIOS) {
    documentDirectory = await getApplicationDocumentsDirectory();
    newDirectory = Directory('${documentDirectory.path}/temp/');
  }
  if (newDirectory!.existsSync()) {
    newDirectory?.deleteSync(recursive: true);
  }


  if (notificationAppLaunchDetails != null &&
      notificationAppLaunchDetails.didNotificationLaunchApp) {
    initialRoute = '/Detail';
    print('payload ${notificationAppLaunchDetails.payload.toString()}');
  }

  await NotificationService().init();
  await FCM().setBackgroundNotificationListener();

  runApp(MyApp(
      initialRoute: initialRoute ?? '/',
      payload: notificationAppLaunchDetails?.payload));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  final String? payload;

  const MyApp({Key? key, this.initialRoute = '/', this.payload})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*User _user;
    UserDefault userDefault = Get.find();
    _user = userDefault.getUser() as User;*/
    return MaterialApp(

      builder: (context, widget) => ResponsiveWrapper.builder(
          BouncingScrollWrapper.builder(context, widget!),
          maxWidth: 1300,
          minWidth: 450,
          defaultScale: true,
          breakpoints: [
            const ResponsiveBreakpoint.autoScale(450, name: MOBILE),
            const ResponsiveBreakpoint.autoScale(500, name: TABLET),
            const ResponsiveBreakpoint.autoScale(600, name: TABLET),
            const ResponsiveBreakpoint.autoScale(700, name: TABLET),
            const ResponsiveBreakpoint.autoScale(800, name: TABLET),
            const ResponsiveBreakpoint.autoScale(1000, name: TABLET),
            const ResponsiveBreakpoint.autoScale(1050, name: TABLET),
            const ResponsiveBreakpoint.autoScale(1150, name: TABLET),
            const ResponsiveBreakpoint.autoScale(1250, name: TABLET),
          ],
          background: Container(color: const Color(0xFFF5F5F5))),
      home: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightThemeData(context),
        themeMode: ThemeMode.light,
        initialRoute: initialRoute,
        defaultTransition: Transition.cupertinoDialog,
        useInheritedMediaQuery: true,
        transitionDuration: const Duration(milliseconds: 500),
        //TODO 04/04/2022
        locale: languageCode == null ?  Locale(AppLanguages.en.name,'US') : languageCode == AppLanguages.en.name ? Locale(AppLanguages.en.name,'US'): Locale(AppLanguages.ar.name,'US'),
        fallbackLocale: TranslationService.fallbackLocale,
        translations: TranslationService(),
        initialBinding: GlobalBindings(),
        popGesture: true,
        enableLog: true,
        getPages: [
          GetPage(name: '/', page: () => const SplashScreen()),
          GetPage(name: '/Detail', page: () => ProgressiveScreen(payload: payload)),
        ],
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
