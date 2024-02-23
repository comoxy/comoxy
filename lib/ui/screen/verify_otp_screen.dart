import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/component/otptextfield.dart';
import 'package:rate_review/ui/component/pin_theme.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import '../dialog/dialog_utils.dart';
import 'required_detail_screen.dart';
import 'user_login.dart';

class VerifyOtpScreen extends StatefulWidget {
  final OTPVerificationType otpVerificationType;
  final User? user;

  const VerifyOtpScreen(this.otpVerificationType, {Key? key, this.user})
      : super(key: key);

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpCodeController = TextEditingController();
  final GlobalKey<State> _globalKey = GlobalKey<State>();
  late User user;
  final AuthModel _authProvider = Get.find();

  UserDefault userDefault = Get.find();

  int secondsRemaining = 60;
  bool enableResend = true;
  bool enablesecondtext = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    user = widget.user!;
    return Material(
      color: CupertinoColors.white,
      child: Column(
        children: [
          ...AppToolbar(context,
              children: [
               /* IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      CupertinoIcons.back,
                      color: CupertinoColors.white,
                        size: 37
                    )),*/
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Image(
                        image: ImageRes.backIcon, height: 25, width: 25)),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            resource.verifyOtp.tr.toUpperCase(),
                            style: TextStyle(
                                color: CupertinoColors.white,
                                fontFamily: narrowmedium,
                                fontSize: 20,
                                letterSpacing: 4.0),
                          )),
                    )),
              ],
              showStatusBar: true),
          GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Container(
              width: size(context).width,
              height: size(context).height -
                  bottomViewPad(context) -
                  topViewPad(context) -
                  statusBarViewPad,
              color: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(
                          image: ImageRes.otpVerificationImg,
                          height: 65,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          child: Center(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                resource.otpverification.tr,
                                style: TextStyle(
                                    color: lablecolor,
                                    fontFamily: narrowbook,
                                    fontSize: 24),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 270,
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: size(context).width / 1.4,
                                    child: OTPTextField(
                                      appContext: context,
                                      length: 6,
                                      obscureText: false,
                                      keyboardType: TextInputType.number,
                                      pinTheme: PinTheme(
                                        shape: OTPFieldShape.box,
                                        fieldHeight: 40,
                                        fieldWidth: 40,
                                        activeFillColor: Colors.white,
                                        activeColor: Colors.black26,
                                      ),
                                      animationDuration:
                                          const Duration(milliseconds: 0),
                                      backgroundColor: Colors.white,
                                      enableActiveFill: true,
                                      controller: _otpCodeController,
                                      onCompleted: (v) {
                                        // print("OTP Completed");
                                      },
                                      onChanged: (value) {
                                        // print(value);
                                      },
                                      keyboardAppearance: Brightness.dark,
                                      textStyle: TextStyle(
                                          fontSize: normalFontSize,
                                          fontFamily: primaryFF),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: GestureDetector(
                                      onTap: () async {
                                        if (_otpCodeController
                                            .text.length <
                                            6) {
                                          AppUtil.toast(resource.otpValidation.tr);
                                          return;
                                        } else {
                                          bool _hasInternet =
                                              await AppUtil
                                              .isInternetAvailable(
                                              context);
                                          if (!_hasInternet) {
                                            return;
                                          }

                                          if (widget.otpVerificationType ==
                                              OTPVerificationType.DELETE_ACCOUNT) {
                                            DialogUtils.showDeleteDailogForUser(context,resource.permanentAccDelete.tr,resource.permanentAccDeleteDesc.tr,resource.sureDelete.tr,(bool action) {
                                              if (action) {
                                                verifyOTP(context);
                                              }
                                            });
                                          } else {
                                            verifyOTP(context);
                                          }
                                        }
                                      },
                                      child: Container(
                                          height: 80,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                btnEndColor,
                                                btnStartColor
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: Center(
                                            child: SizedBox(
                                              child: Text(
                                                resource.verify.tr.toUpperCase(),
                                                style: boldBtnStyle,
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: enablesecondtext,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Center(
                                            child: Text(
                                              resource.resendOtp.tr,
                                              style: TextStyle(
                                                  color: lablecolor,
                                                  fontFamily: narrowbold,
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: enablesecondtext,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            '$secondsRemaining',
                                            style: TextStyle(
                                                color: lablecolor,
                                                fontFamily: narrowbold,
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: enableResend,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: GestureDetector(
                                            onTap:() async {
                                              bool _hasInternet = await AppUtil.isInternetAvailable(context);
                                              if (!_hasInternet) {
                                                return;
                                              }
                                              //TODO 08/04/2022
                                              if(widget.otpVerificationType == OTPVerificationType.FORGOT_PASS)
                                                {
                                                  await resendForgotOTP(context);
                                                }
                                              else if(widget.otpVerificationType == OTPVerificationType.SIGN_UP)
                                                {
                                                  await resendSignupOTP(context);
                                                }
                                              else if (widget.otpVerificationType == OTPVerificationType.DELETE_ACCOUNT)
                                                {
                                                  await sendOTPForDeleteAccount(context);
                                                }

                                            },
                                            child: Text(resource.resendOtp.tr.toUpperCase(),style: TextStyle(
                                                color: lablecolor,
                                                decoration: TextDecoration.underline,
                                                fontFamily: narrowbold,
                                                fontSize: 18),),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  ///changed
  resendForgotOTP(context) async {
    Map<String, dynamic> forgetPasswordRequestJson = {
      'user_email': user.userEmail.toString().trim(),
    };

    _authProvider
        .forgetPassword(
        context: context,
        keyLoader: _globalKey,
        forgetPasswordRequestJson: forgetPasswordRequestJson,
        apiName: ServiceUrl.kForgetPassword)
        .then((result) async {
      if (result == null) {
        return;
      }
      if (result.status.isTrue) {
        AppUtil.toast(resource.sentOtp.tr);
        _resendCode();
      } else {
        AppUtil.toast(result.message);
        return;
      }
    });
  }
  //TODO 08/04/2022
  resendSignupOTP(context) async {
    Map<String, dynamic> resendOtpRequestJson = {
      RequestParam.kUserEmail : user.userEmail.toString().trim(),
      RequestParam.kFullName : user.userName,
      RequestParam.kUserId : user.user_id
    };

    _authProvider.signUpResendOTP(
        context: context,
        keyLoader: _globalKey,
        resendOTPRequestJson: resendOtpRequestJson,
        apiName: ServiceUrl.kResendSignUpOTP)
        .then((result) async {
      if (result == null) {
        return;
      }
      if (result.status.isTrue) {
        AppUtil.toast(resource.sentOtp.tr);
        _resendCode();
      } else {
        AppUtil.toast(result.message);
        return;
      }
    });
  }
//TODO 08/04/2022
  Future sendOTPForDeleteAccount(BuildContext context) async {
    user = (await userDefault.getUser())!;

    Map<String, dynamic> deleteAccountRequestJson = {
      RequestParam.kUserEmail: user.userEmail,
    };

    _authProvider.deleteAccount(
      context: context,
      keyLoader: _globalKey,
      deleteAccountRequestJson: deleteAccountRequestJson,
      apiName: ServiceUrl.kDeleteAccount,
    ).then((result) async {
      if (result == null) {
        return;
      }
      if (result.status.isTrue) {
        AppUtil.toast(resource.sentOtp.tr);
        _resendCode();
      } else {
        AppUtil.toast(result.message);
        return;
      }
    });


  }

  verifyOTP(context) async {
    if (widget.otpVerificationType == OTPVerificationType.SIGN_UP) {
      Map<String, dynamic> generateOtpRequestJson = {
        'user_email': widget.user!.userEmail,
        'otp_code': _otpCodeController.text.toString().trim(),
        'user_id': widget.user!.user_id,
      };

      _authProvider
          .generateVerifyOtp(
              context: context,
              keyLoader: _globalKey,
              generateVerifyOtpRequestJson: generateOtpRequestJson,
              apiName: ServiceUrl.kVerifyOtpForSignUp)
          .then((result) {
        if (result == null) {
          return;
        }
        if (result.status!.isTrue) {
          AppUtil.toast(resource.otpVerifiedSuccessfully.tr);
          Navigator.of(context).pop(true);

          User? _user = result.data;
          _user!.user_password = widget.user!.user_password;
          Get.offAll(() => RequiredDetailScreen(user: _user));
        } else {
          AppUtil.toast(result.message ?? resource.somethingWentWrong.tr);
          return;
        }
      });
    } else if (widget.otpVerificationType == OTPVerificationType.FORGOT_PASS) {
      String otpStr = _otpCodeController.text.toString().trim();
      Map<String, dynamic> forgetPasswordRequestJson = {
        'user_email': widget.user!.userEmail,
        'otp_code': otpStr,
      };

      _authProvider
          .verifyForgetPasswordOtp(
              context: context,
              keyLoader: _globalKey,
              forgetPasswordRequestJson: forgetPasswordRequestJson,
              apiName: ServiceUrl.kVerifyForgetPasswordOtp)
          .then((result) {
        if (result == null) {
          return;
        }
        if (result.status.isTrue) {
          AppUtil.toast(resource.otpVerifiedSuccessfully.tr);
          Navigator.of(context).pop(otpStr);
        } else {
          AppUtil.toast(result.message);
          return;
        }
      });
    } else if (widget.otpVerificationType ==
        OTPVerificationType.DELETE_ACCOUNT) {
      String otpStr = _otpCodeController.text.toString().trim();
      Map<String, dynamic> deleteAccountRequestJson = {
        'user_email': widget.user!.userEmail,
        'otp_code': otpStr,
      };

      _authProvider
          .verifyDeleteAccountOtp(
              context: context,
              keyLoader: _globalKey,
              deleteAccountRequestJson: deleteAccountRequestJson,
              apiName: ServiceUrl.kDeleteAccountPasswordOtp)
          .then((result) {
        if (result == null) {
          return;
        }
        if (result.status.isTrue) {
          AppUtil.toast(resource.accountDeletedSuccessfully.tr);
          userDefault.clearUserDefault();
          Get.offAll(() => const UserLogin());
        } else {
          AppUtil.toast(result.message);
          return;
        }
      });
    } else {
      AppUtil.toast('developer error');
      return;
    }
  }

  void _resendCode() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
          enablesecondtext = true;
        });
      } else {
        setState(() {
          enableResend = true;
          enablesecondtext = false;
          timer.cancel();
        });
      }
    });
    setState((){
      secondsRemaining = 60;
      enableResend = false;
      enablesecondtext = false;
    });
  }

  @override
  dispose(){
    try {
      timer.cancel();
    } catch (e) {
      print(e);
    }
    super.dispose();
  }

}
