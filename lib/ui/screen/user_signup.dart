import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'dashboard_screen.dart';
import 'verify_otp_screen.dart';

class UserSignUp extends StatefulWidget {
  final bool isForgetPassword;

  const UserSignUp({Key? key, this.isForgetPassword = false}) : super(key: key);

  @override
  _UserSignUpState createState() => _UserSignUpState();
}

class _UserSignUpState extends State<UserSignUp> {
  final AuthModel _authProvider = Get.find();
  final MethodChannelHandler methodChannelHandler = Get.find();
  final GlobalKey<State> _globalKey = GlobalKey<State>();
  String otpCode = '';
  bool otpVerified = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordObscure = true, _confirmPasswordObscure = true;
  String? selectedLanguage = AppLanguages.en.name;

  @override
  void initState() {
    checkLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = size(context).height;
    return Stack(
      children: [
        backgroundImage,
        Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    if (!widget.isForgetPassword) ...[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                        if (!widget.isForgetPassword) ...[
                          //TODO 08/04/2022
                          Padding(
                            padding: selectedLanguage == AppLanguages.en.name ? const EdgeInsets.only(right: 5, bottom: 30) : const EdgeInsets.only(right: 5, top: 30),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  onPrimary: Colors.transparent,
                                  elevation: 0,

                                  primary: Colors.transparent,
                                  ),

                              // splashColor: Colors.transparent,
                              // highlightColor: Colors.transparent,
                              child: selectedLanguage == AppLanguages.en.name
                                  ? Text("ENG",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: primaryFF,
                                          fontSize: 18))
                                  : Text("عربى",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: primaryFF,
                                          fontSize: 22)),
                              onPressed: () async {
                                //TODO 06/04/2022 Remove bool to string
                                if (selectedLanguage != AppLanguages.en.name) {
                                  selectedLanguage = AppLanguages.en.name;
                                } else {
                                  selectedLanguage = AppLanguages.ar.name;
                                }
                                setState(() {});
                                //TODO 07/04/2022
                                await userDefault.setLanguageCode(selectedLanguage!);
                                await AppUtil.switchLanguage();
                              },
                            ),
                          ),
                        ],
                      ])
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (!widget.isForgetPassword) ...[
                              Text(
                                resource.signup.tr,
                                style: TextStyle(
                                    fontSize: 48,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                    fontFamily: narrowbook),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      resource.loginScreenTitle1.tr,
                                      style: TextStyle(
                                          fontSize: 24,
                                          letterSpacing: -0.5,
                                          color: Colors.white,
                                          fontFamily: narrowbook),
                                    ),
                                    Text(
                                      resource.buzzleTitle.tr.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 24,
                                          letterSpacing: -0.5,
                                          color: Colors.white,
                                          fontFamily: narrowbold),
                                    ),
                                    Text(
                                      resource.family.tr,
                                      style: TextStyle(
                                          fontSize: 24,
                                          letterSpacing: -0.5,
                                          color: Colors.white,
                                          fontFamily: narrowbook),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: height * 0.09,
                              ),
                              TextField(
                                decoration: mInputDecoration(
                                    placeholder: resource.namePlacholder.tr),
                                style: mTextFieldTS,
                                textAlign: TextAlign.center,
                                controller: _nameController,
                              ),
                              SizedBox(
                                height: height * 0.02,
                              )
                            ] else ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      (widget.isForgetPassword && !otpVerified)
                                          ? resource.forgotPassword.tr
                                          : resource.changePassword.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 48,
                                          color: Colors.white,
                                          letterSpacing: -1,
                                          fontFamily: narrowbook),
                                    ),
                                    if (widget.isForgetPassword &&
                                        !otpVerified) ...[
                                      Text(
                                        resource.recoverPassword.tr,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 24,
                                            letterSpacing: -0.5,
                                            color: Colors.white,
                                            fontFamily: narrowbook),
                                      )
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: height * 0.09,
                              ),
                            ],
                            Visibility(
                              visible: !otpVerified,
                              child: TextFormField(
                                  cursorColor: Colors.blue,
                                  keyboardType: TextInputType.emailAddress,
                                  textAlign: TextAlign.center,
                                  decoration: mInputDecoration(
                                      placeholder: resource.emailPlacholder.tr),
                                  style: mTextFieldTS,
                                  // onSaved: (val) => text = val,
                                  obscureText: false,
                                  controller: _emailController,
                                  autocorrect: false),
                            ),
                            if (!widget.isForgetPassword || otpVerified) ...[
                              SizedBox(
                                height: height * 0.02,
                              ),
                              TextField(
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _passwordObscure,
                                textAlign: TextAlign.center,
                                decoration: mInputDecoration(
                                        placeholder:
                                            resource.passwordPlacholder.tr)
                                    .copyWith(
                                  suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _passwordObscure = !_passwordObscure;
                                        });
                                      },
                                      child: Icon(Icons.remove_red_eye,
                                          color: _passwordObscure
                                              ? eyeColor
                                              : eyeColor
                                                  .withAlpha(50)
                                                  .withAlpha(75))),
                                ),
                                style: mTextFieldTS,
                                controller: _passwordController,
                              )
                            ],
                            if (!widget.isForgetPassword || otpVerified) ...[
                              SizedBox(
                                height: height * 0.02,
                              ),
                              TextField(
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _confirmPasswordObscure,
                                textAlign: TextAlign.center,
                                decoration: mInputDecoration(
                                        placeholder:
                                            resource.confirmPassword.tr)
                                    .copyWith(
                                  suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _confirmPasswordObscure =
                                              !_confirmPasswordObscure;
                                        });
                                      },
                                      child: Icon(Icons.remove_red_eye,
                                          color: _confirmPasswordObscure
                                              ? eyeColor
                                              : eyeColor
                                                  .withAlpha(50)
                                                  .withAlpha(75))),
                                  helperText: resource.passwordContain.tr,
                                  helperStyle: mHelperTextFieldTS,
                                  helperMaxLines: 4,
                                ),
                                style: mTextFieldTS,
                                controller: _confirmPasswordController,
                              )
                            ],
                            /*if (!widget.isForgetPassword) ...[
                              SizedBox(
                                height: height * 0.02,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "language_".tr,
                                    style: TextStyle(
                                        color: lablecolor,
                                        fontFamily: narrowbook,
                                        fontSize: 18),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white, borderRadius: BorderRadius.circular(45)),
                                    child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            if (selectedLanguage != AppLanguages.EN) {
                                              setState(() {
                                                selectedLanguage = AppLanguages.EN;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            decoration: selectionDecoration(AppLanguages.EN),
                                            child: Center(
                                                child: Text(
                                                  "english".toUpperCase(),
                                                  style: selectionStyle(AppLanguages.EN),
                                                )),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (selectedLanguage != AppLanguages.ARB) {
                                              setState(() {
                                                selectedLanguage = AppLanguages.ARB;
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            decoration: selectionDecoration(AppLanguages.ARB),
                                            child: Center(
                                                child: Text(
                                                  "arabic".toUpperCase(),
                                                  style: selectionStyle(AppLanguages.ARB),
                                                )),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],*/
                            SizedBox(
                              height: height * 0.04,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (widget.isForgetPassword && !otpVerified) {
                                  if (!onlyEmailIsValid()) return;
                                  bool _hasInternet =
                                      await AppUtil.isInternetAvailable(
                                          context);
                                  if (!_hasInternet) {
                                    return;
                                  }
                                  await verifyOTP(context);
                                } else if (otpVerified) {
                                  if (!isValidResetPassword()) return;

                                  bool _hasInternet =
                                      await AppUtil.isInternetAvailable(
                                          context);
                                  if (!_hasInternet) {
                                    return;
                                  }
                                  await resetPassword(context);
                                } else {
                                  if (!isValid()) return;

                                  bool _hasInternet =
                                      await AppUtil.isInternetAvailable(
                                          context);
                                  if (!_hasInternet) {
                                    return;
                                  }
                                  await handleSignUp(context);
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
                                        Colors.white,
                                        Colors.white,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      child: Text(
                                        widget.isForgetPassword
                                            ? otpVerified
                                                ? resource.apply.tr
                                                    .toUpperCase()
                                                : resource.otp.tr.toUpperCase()
                                            : resource.signup.tr.toUpperCase(),
                                        style: normalBtnStyle,
                                      ),
                                    ),
                                  )),
                            )
                            /*SizedBox(
                              width: width,
                              height: 80,

                             // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    shape: const StadiumBorder(), primary: const Color(0xfffbfbfb)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    widget.isForgetPassword
                                        ? otpVerified
                                        ? 'apply'.tr.toUpperCase()
                                        : 'send_otp'.tr
                                        : 'sign_up'.tr.toUpperCase(),
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 3),
                                  ),
                                ),
                                onPressed: () async {
                                  if (widget.isForgetPassword && !otpVerified) {
                                    if (!onlyEmailIsValid()) return;
                                    bool _hasInternet = await AppUtil.isInternetAvailable(context);
                                    if (!_hasInternet) {
                                      return;
                                    }
                                    await verifyOTP(context);
                                  }
                                  else if (otpVerified) {
                                    if (!isValidResetPassword()) return;

                                    bool _hasInternet = await AppUtil.isInternetAvailable(context);
                                    if (!_hasInternet) {
                                      return;
                                    }
                                    await resetPassword(context);
                                  }
                                  else {
                                    if (!isValid()) return;

                                    bool _hasInternet = await AppUtil.isInternetAvailable(context);
                                    if (!_hasInternet) {
                                      return;
                                    }
                                    await handleSignUp(context);
                                  }
                                },
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ),
                    if (!widget.isForgetPassword) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              resource.signInLink.tr,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: narrowbook,
                                  fontSize: 22),
                            ),
                            GestureDetector(
                                onTap: () {
                                  // Get.to(() => const UserLogin());
                                  Get.back();
                                },
                                child: Text(
                                  resource.signIn.tr.toUpperCase(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: narrowbold,
                                      fontSize: 22),
                                )),
                          ],
                        ),

                      )
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future handleSignUp(BuildContext context) async {
    String pwd = _passwordController.text.trim();
    String encryptedPassword = await pwd.getEncrptedString;

    Map<String, dynamic> userLoginSignUpRequestJson = {
      RequestParam.kUserEmail: _emailController.text.trim(),
      'full_name': _nameController.text.trim(),
      'password': encryptedPassword.trim(),
      'login_from': Platform.isAndroid ? 'Google' : 'iCloud',
      "language_code": selectedLanguage!,
    };

    var userSignUp = await _authProvider.getSimpleLoginRegister(
      context: context,
      keyLoader: _globalKey,
      userLoginSignUpRequestJson: userLoginSignUpRequestJson,
      apiName: ServiceUrl.simpleLoginRegister,
    );
    if (userSignUp != null) {
      if (userSignUp.status!.isTrue) {
        User? user = userSignUp.data;
        user!.user_password = encryptedPassword.trim();
        await Get.to(() => VerifyOtpScreen(OTPVerificationType.SIGN_UP, user: user));
      }
    }
  }

  resetPassword(context) async {
    String pwd = _passwordController.text.trim();
    String encryptedPassword = await pwd.getEncrptedString;

    Map<String, dynamic> resetPasswordRequestJson = {
      'user_email': _emailController.text.toString().trim(),
      'password': encryptedPassword.trim(),
      'otp_code': otpCode,
    };

    _authProvider
        .resetPassword(
            context: context,
            keyLoader: _globalKey,
            resetPasswordRequestJson: resetPasswordRequestJson,
            apiName: ServiceUrl.kResetPassword)
        .then((result) async {
      if (result == null) {
        return;
      }
      if (result.status.isTrue) {
        Navigator.of(context).pop();
        AppUtil.toast(resource.resetPassword.tr);
      } else {
        AppUtil.toast(result.message);
        return;
      }
    });
  }

  verifyOTP(context) async {
    Map<String, dynamic> forgetPasswordRequestJson = {
      'user_email': _emailController.text.toString().trim(),
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
        User user = User(userEmail: _emailController.text.toString().trim());

        var result = await Get.to(
            () => VerifyOtpScreen(OTPVerificationType.FORGOT_PASS, user: user));

        String otp = '';
        if (result != null) {
          otp = result as String;
        }

        if (otp.isNotEmpty) {
          otpCode = otp;
          otpVerified = true;
          setState(() {});
        }
      } else {
        AppUtil.toast(result.message);
        return;
      }
    });
  }

  bool onlyEmailIsValid() {
    if (_emailController.text.isEmpty) {
      AppUtil.toast(resource.emailValidation.tr);
      return false;
    } else if (!AppUtil.validateEmail(_emailController.text.trim())) {
      AppUtil.toast(resource.emailValidValidation.tr);
      return false;
    } else {
      return true;
    }
  }

  bool isValidResetPassword() {
    if (_passwordController.text.isEmpty) {
      AppUtil.toast(resource.passwordValidation.tr);
      return false;
    } else if (_confirmPasswordController.text.isEmpty) {
      AppUtil.toast(resource.confirmPasswordValidation.tr);
      return false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      AppUtil.toast(resource.passwordMismatch.tr);
      return false;
    } else if (!AppUtil.passwordValidation(_passwordController.text)) {
      AppUtil.toast(resource.passwordValidValidation.tr);
      return false;
    } else {
      return true;
    }
  }

  bool isValid() {
    if (_nameController.text.trim().isEmpty) {
      AppUtil.toast(resource.nameValidation.tr);
      return false;
    } else if (_emailController.text.trim().isEmpty) {
      AppUtil.toast(resource.emailValidation.tr);
      return false;
    } else if (!AppUtil.validateEmail(_emailController.text.trim())) {
      AppUtil.toast(resource.emailValidValidation.tr);
      return false;
    } else if (_passwordController.text.isEmpty) {
      AppUtil.toast(resource.passwordValidation.tr);
      return false;
    } else if (_confirmPasswordController.text.isEmpty) {
      AppUtil.toast(resource.confirmPasswordValidation.tr);
      return false;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      AppUtil.toast(resource.passwordMismatch.tr);
      return false;
    } else if (!AppUtil.passwordValidation(_passwordController.text)) {
      AppUtil.toast(resource.passwordValidValidation.tr);
      return false;
    } else {
      return true;
    }
  }

  //TODO 07/04/2022
  Future<void> checkLanguage() async {
    userDefault.getLanguageCode().then((value) {
      if (value == null) {
        selectedLanguage = AppLanguages.en.name;
      } else {
        selectedLanguage =
        value == AppLanguages.en.name
            ? AppLanguages.en.name
            : AppLanguages.ar.name;
      }
      setState(() {});
    });
  }
}
