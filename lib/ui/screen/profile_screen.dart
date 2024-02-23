import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/dialog/dialog_utils.dart';
import 'package:rate_review/ui/screen/payment_setup_screen.dart';
import 'package:rate_review/ui/screen/post_screen.dart';
import 'package:rate_review/ui/screen/required_detail_screen.dart';
import 'package:rate_review/ui/screen/verify_otp_screen.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import '../../model/post/all_post_response.dart';
import '../dialog/rating_dialog.dart';
import 'dashboard_screen.dart';
import 'personal_detail_screen.dart';
import 'terms_and_conditions_screen.dart';
import 'user_login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  UserDefault userDefault = Get.find();
  User? _user;
  final GlobalKey<State> _globalKey = GlobalKey<State>();
  final AuthModel _authProvider = Get.find();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() {
    userDefault.getUser().then((value) {
      if (_user == null) {
        setState(() {});
      }
      _user = value!;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        child: Scaffold(
            backgroundColor: backgroundColor,
            body: Column(
              children: [
                //TODO 16/03/2022 remove from here to put dashboard screen
/*                ...AppToolbar(context,
                    children: [
                      Expanded(
                          child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'profile'.tr.toUpperCase(),
                                style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontFamily: narrowmedium,
                                    fontSize: 20,
                                    letterSpacing: 4.0),
                              ))),
                    ],
                    showStatusBar: true),*/
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 30),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_user != null) ...[
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              child: ListTile(
                                title: Text(
                                    '${resource.userGreting.tr} ${_user!.userName} !',
                                    style: TextStyle(
                                        color: lablecolor,
                                        fontFamily: narrowbook,
                                        fontSize: 20)),
                              ),
                              elevation: 0,
                            )
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: 0,
                              child: Column(
                                children: [
                                  ListTile(
                                    onTap: () async {
                                      _user = await userDefault.getUser();

                                      final res = await Get.to(
                                          () =>

                                              // RequiredDetailScreen(user: _user!,isFromHome: false));

                                              PersonalDetailScreen(
                                                user: _user!,
                                                verifyAcc: false,
                                                isFrom: 'fromProfile',
                                              ));
                                      getUser();
                                      setState(() {});
                                    },
                                    title: Text(resource.personalDetails.tr,
                                        style: TextStyle(
                                            color: lablecolor,
                                            fontFamily: narrowbook,
                                            fontSize: 20)),
                                  ),
                                  //divider,
                                  Visibility(
                                    visible: false,
                                    child: ListTile(
                                      onTap: () {
                                        Get.to(
                                            () => const PaymentSetupScreen());
                                      },
                                      title: Text(resource.paymentSetup.tr,
                                          style: TextStyle(
                                              color: lablecolor,
                                              fontFamily: narrowbook,
                                              fontSize: 20)),
                                    ),
                                  ),
                                  divider,
                                  ListTile(
                                    onTap: () {
                                      sendFeedback();
                                      /* Get.to(() => const GeInTouchScreen(),
                                          fullscreenDialog: true);*/
                                    },
                                    title: Text(resource.talkToUS.tr,
                                        style: TextStyle(
                                            color: lablecolor,
                                            fontFamily: narrowbook,
                                            fontSize: 20)),
                                  ),
                                  divider,
                                  ListTile(
                                    onTap: () async {
                                      showRatingDialog(context);
                                    },
                                    title: Text(resource.feedback.tr,
                                        style: TextStyle(
                                            color: lablecolor,
                                            fontFamily: narrowbook,
                                            fontSize: 20)),
                                  ),
                                  divider,
                                  ListTile(
                                    onTap: () {
                                      Get.to(
                                          () =>
                                              const TermsAndConditionsScreen(),
                                          fullscreenDialog: true);
                                    },
                                    title: Text(resource.termsAndConditions.tr,
                                        style: TextStyle(
                                            color: lablecolor,
                                            fontFamily: narrowbook,
                                            fontSize: 20)),
                                  ),
                                  divider,
                                  ListTile(
                                    onTap: () async {
                                      // Get.to(() => const DeleteAccountDialog(), fullscreenDialog: true);

                                      bool _hasInternet =
                                          await AppUtil.isInternetAvailable(
                                              context);
                                      if (!_hasInternet) {
                                        return;
                                      }

                                      DialogUtils.showDeleteDailogForUser(
                                          context,
                                          resource.deleteTitle.tr,
                                          resource.deleteContent.tr,
                                          resource.ok.tr, (bool action) {
                                        if (action) {
                                          sendOTPForDeleteAccount(context);
                                        }
                                      });
                                    },
                                    title: Text(resource.deleteAccount.tr,
                                        style: TextStyle(
                                            color: lablecolor,
                                            fontFamily: narrowbook,
                                            fontSize: 20)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: true,
                            // TODO visibility based on client preference
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: 0,
                                child: ListTile(
                                  onTap: () {
                                    DialogUtils.showDeleteDailogForUser(
                                        context,
                                        resource.switchLanguage.tr,
                                        resource.switchlanguagecontent.tr,
                                        resource.ok.tr, (bool action) async {
                                      if (action) {
                                        userDefault.getLanguageCode().then((value) async {
                                          Locale locale;
                                          Locale? devLocale = Get.locale;
                                          if (devLocale != null && value != AppLanguages.en.name) {
                                            locale = Locale(AppLanguages.en.name, 'US');
                                            userDefault.setLanguageCode(AppLanguages.en.name);
                                            AppUtil.langcode = AppLanguages.en.name;
                                          } else {
                                            locale = Locale(AppLanguages.ar.name, 'US');
                                            userDefault.setLanguageCode(AppLanguages.ar.name);
                                            AppUtil.langcode = AppLanguages.ar.name;
                                          }
                                          Get.updateLocale(locale);
                                          //TODO 15/04/2022
                                          isLanguageSwitch = true;
                                        });
                                        setState(() {});
                                      }
                                    });
                                  },
                                  title: Text(resource.switchLanguage.tr,
                                      style: TextStyle(
                                          color: lablecolor,
                                          fontFamily: narrowbook,
                                          fontSize: 20)),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: 0,
                              child: ListTile(
                                onTap: () {
                                  DialogUtils.showDeleteDailogForUser(
                                      context,
                                      resource.logoutTitle.tr,
                                      resource.logoutContent.tr,
                                      resource.ok.tr, (bool action) {
                                    if (action) {
                                      userDefault.clearUserDefault();
                                      Get.offAll(() => const UserLogin());
                                    }
                                  });
                                },
                                title: Text(resource.logoutTitle.tr,
                                    style: TextStyle(
                                        color: CupertinoColors.systemRed,
                                        fontFamily: narrowbook,
                                        fontSize: 20)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Padding get divider {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Divider(
        height: 1,
        color: Colors.grey,
      ),
    );
  }

  Future sendOTPForDeleteAccount(BuildContext context) async {
    _user = await userDefault.getUser();

    Map<String, dynamic> deleteAccountRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail,
    };

    _authProvider.deleteAccount(
      context: context,
      keyLoader: _globalKey,
      deleteAccountRequestJson: deleteAccountRequestJson,
      apiName: ServiceUrl.kDeleteAccount,
    );

    Get.to(() => VerifyOtpScreen(
          OTPVerificationType.DELETE_ACCOUNT,
          user: _user,
        ));
  }

  void showRatingDialog(BuildContext context) {
    final ratingDialog = RatingDialog(
      ratingColor: Colors.amber,
      title: resource.buzzleTitle.tr,
      message: resource.ratingReviewContent.tr,
      image: Image(image: ImageRes.appIcon, width: 70, height: 70),
      submitButton: resource.submit.tr.toUpperCase(),
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) async {
        print('rating: ${response.rating},' 'comment: ${response.comment}');
      },
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ratingDialog,
    );
  }

// TODO 25.03.2022 emailBodyContent and support@buzzle.cc
  Future<void> sendFeedback() async {
    final Email email = Email(
      body: resource.emailBodyContent.tr,
      subject: resource.emailSubjectContent.tr,
      recipients: ['support@buzzle.cc'],
      // cc: ['cc@example.com'],
      // bcc: ['bcc@example.com'],
      // attachmentPaths: ['/path/to/attachment.zip'],
      isHTML: false,
    );
    try {
      return await FlutterEmailSender.send(email);
    } catch (e) {
      return await AppUtil.toast(resource.noSuitableAppFound.tr);
    }
  }

}
