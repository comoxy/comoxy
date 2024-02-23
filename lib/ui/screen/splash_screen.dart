import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
show Colors, LinearProgressIndicator, MaterialPageRoute, Scaffold;
import 'package:get/get.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/helper/notification.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/dialog/dialog_utils.dart';
import 'package:rate_review/ui/screen/dashboard_screen.dart';
import 'package:rate_review/ui/screen/post_detail_screen.dart';
import 'package:rate_review/ui/screen/required_detail_screen.dart';
import 'dart:ui' as ui;
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import 'user_login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  UserDefault userDefault = UserDefault();
  final AuthModel _authModel = AuthModel();
  final AuthModel _authProvider = Get.find();
  final MethodChannelHandler methodChannelHandler = MethodChannelHandler();

  final GlobalKey<State> _globalKey = GlobalKey<State>();

  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    log('SplashInit');
    controller = AnimationController(
        duration: const Duration(seconds: timeoutDuration + 2), vsync: this);
    animation = Tween(begin: 0.0, end: 2.0).animate(controller)
      ..addListener(() {
        setState(() {});
      });
    controller.repeat();
    splashFuture();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('Size: physicalSize ${WidgetsBinding.instance!.window.physicalSize.height}');
    // print('Size: MedeaQuery ${size(context).height}');
    return Scaffold(
      body: Container(
        color: const Color(0xfff3f4f5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 160, child: Image(image: ImageRes.appIcon)),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(resource.buzzleTitle.tr.toUpperCase(),
                  style: TextStyle(
                      color: splashBuzzelcolor,
                      fontSize: 57,
                      fontFamily: narrowcondesedmedium)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: Text(resource.splashScreenTitle1.tr,
                  style: TextStyle(
                      color: splashtextcolor,
                      fontFamily: narrowmedium,
                      fontWeight: FontWeight.w400,
                      fontSize: 25)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                resource.splashScreenTitle2.tr,
                style: TextStyle(
                    color: const Color(0xff888888),
                    fontFamily: narrowbook,
                    fontSize: 18),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  resource.splashScreenTitle3.tr,
                  style: TextStyle(
                      color: const Color(0xff888888),
                      fontFamily: narrowbook,
                      fontSize: 18),
                ),
                Text(
                  resource.buzzleTitle.tr,
                  style: TextStyle(
                      color: const Color(0xff888888),
                      fontSize: 18,
                      fontFamily: narrowbold),
                ),
                Text(
                  resource.splashScreenTitle4.tr,
                  style: TextStyle(
                      color: const Color(0xff888888),
                      fontFamily: narrowbook,
                      fontSize: 18),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 70, left: 80, right: 80),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: LinearProgressIndicator(
                  color: splashtextcolor,
                  backgroundColor: const Color(0xffdadbdc),
                  value: animation.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  splashFuture() async {
    Future.delayed(Duration.zero, () async {
      User? _user = await UserDefault().getUser();
      if (_user == null) {
        //Get.off(()=> const UserLogin());
        Get.off(() => const UserLogin());
      } else {
        var _isNetwork = await AppUtil.isInternetConnected();
        if (_isNetwork == false) {
          DialogUtils.showInternetDialog(context, true, onCloseTap: () {
            splashFuture();
          });
          return;
        } else {
          // DialogUtils.loadingDialog(context);

          String pwd = _user.user_password!;
          String _email = _user.userEmail!;

          log('encryptedPassword $pwd');
          Map<String, dynamic> userLoginSignUpRequestJson = {
            "user_email": _email,
            "password": pwd.trim(),
          };

          Map<AuthStatus, dynamic> loginResp =
              await _authModel.getSimpleLoginCheck(
                  // context: context,
                  // keyLoader: _globalKey,
                  userLoginSignUpRequestJson: userLoginSignUpRequestJson,
                  apiName: ServiceUrl.simpleLoginCheck);
          if (loginResp != null && loginResp.isNotEmpty) {
            // TODO handle
            await Future.delayed(const Duration(seconds: 5));
            switch (loginResp.keys.first) {
              case AuthStatus.error:
                DialogUtils.showErrorDialog(context, loginResp.values.first,
                    resource.retry.tr.toUpperCase(), onCloseTap: () {
                      Get.offAll(() => const UserLogin());
                });
                break;
              case AuthStatus.success:
                User _user = loginResp.values.first.data;
                _user.user_password = pwd.trim();
                userDefault.saveUser(_user);
                var fToken = await UserDefault().readString(UserDefault.kFirebaseToken);
                if (fToken != null) {
                  await _authProvider.saveTokenOnServer(fToken);
                  FCM().fcmSubscribe();
                }
                if (!(isCheck ?? false)) Get.offAll(() => DashboardScreen());

                /// TODO Phase2
                if(_user.gender == '' || _user.dateOfBirth == null || _user.dateOfBirth == '0' || _user.ethnicity == '' || _user.homeCountry == ''){
                  Get.offAll(()=> RequiredDetailScreen(user: _user));
                }

                //TODO 05/04/2022
                  //await AppUtil.switchLanguage();
                break;
              case AuthStatus.server_error:
                DialogUtils.showErrorDialog(context, resource.serverError.tr,
                    resource.tryAgain.tr.toUpperCase(), onCloseTap: () {
                  splashFuture();
                });
                break;
              case AuthStatus.invalid:
                userDefault.clearUserDefault();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const UserLogin(),
                    ),
                    (Route<dynamic> route) => false);
                break;
            }
          }
        }
      }
    });
  }
}

class ShadowText extends StatelessWidget {
  const ShadowText(this.data, {Key? key, this.style}) : super(key: key);

  final String data;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          Positioned(
            top: 1.0,
            left: 1.0,
            child: Text(
              data,
              style: style?.copyWith(color: Colors.black.withOpacity(0.5)),
            ),
          ),
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: Text(data, style: style),
          ),
        ],
      ),
    );
  }

}
