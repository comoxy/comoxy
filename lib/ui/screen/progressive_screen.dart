import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/model/notification/user_notification.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/screen/splash_screen.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_ios/shared_preferences_ios.dart';

import 'post_detail_screen.dart';

class ProgressiveScreen extends StatefulWidget {
  final String? payload;
  const ProgressiveScreen({Key? key, this.payload}) : super(key: key);

  @override
  _ProgressiveScreenState createState() => _ProgressiveScreenState();
}

class _ProgressiveScreenState extends State<ProgressiveScreen> {
  bool isLoading = true;

  final UserDefault userDefault = Get.find();
  final AuthModel _authProvider = Get.find();
  User? _user;

  @override
  void initState() {
    if (Platform.isAndroid) SharedPreferencesAndroid.registerWith();
    if (Platform.isIOS) SharedPreferencesIOS.registerWith();

    userDefault.getUser().then((value) {
      _user = value;
      UserNotification userNotification;
      if (_user == null) {
        Get.offAll(() => const SplashScreen());
      } else {
        String payload = widget.payload.toString();
        if (payload == null.toString()) {
          return;
        }
        var mJson = json.decode(payload);
        userNotification = UserNotification.fromJson(json.decode(mJson['payload']));
        if (userNotification.notificationType == "general") {
          Get.offAll(() => const SplashScreen());
        } else {
          getDetails(userNotification);
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext buildContext) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(
        child: Column(
          children: [
            ...AppToolbar(buildContext,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Get.offAll(() => const SplashScreen());
                    },
                    child: const Icon(
                      CupertinoIcons.clear,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
                showStatusBar: true),
            Expanded(
              child: Scaffold(
                  backgroundColor: CupertinoColors.white,
                  body: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Center(
                          child: SizedBox(width: 50, height: 50, child: Center(child: CupertinoActivityIndicator())),
                        )
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getDetails(UserNotification userNotification) async {
    // String payload = widget.payload.toString();
    // if (payload == null.toString()) {
    //   return;
    // }
    // var mJson = json.decode(payload);
    // UserNotification userNotification = UserNotification.fromJson(json.decode(mJson['payload']));
    Map<String, dynamic> getPostByIdRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail,
      RequestParam.kPostId: userNotification.postid,
    };

    var postDetail = await _authProvider.getPostById(
      // context: context,
      // keyLoader: _globalKey,
      getPostByIdRequestJson: getPostByIdRequestJson,
      apiName: ServiceUrl.kGetPostById,
    );
    if (postDetail != null) {
      if (postDetail.status!.isTrue && postDetail.data != null) {
        Get.offAll(() => PostDetailScreen(data: postDetail.data!.first, isFromPost: true, isFromNotification: true));
      }
    }
  }
}
