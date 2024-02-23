import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/helper/notification.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/dialog/dialog_utils.dart';
import 'package:rate_review/ui/screen/required_detail_screen.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import '../../ui/screen/user_signup.dart';
import 'dashboard_screen.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({Key? key}) : super(key: key);

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {

  final AuthModel _authProvider = Get.find();
  final MethodChannelHandler methodChannelHandler = Get.find();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordObscure = true;

  final GlobalKey<State> _globalKey = GlobalKey<State>();

  UserDefault userDefault = Get.find();

  @override
  Widget build(BuildContext context) {
    double height = size(context).height;
    double width = size(context).width;

    return Stack(
      children: [
        backgroundImage,
        Scaffold(
            backgroundColor: Colors.transparent,
            body: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SizedBox(
                height: height,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: height *.94,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              resource.login.tr,
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
                              height: height* 0.09,
                            ),
                            TextFormField(
                              decoration: mInputDecoration(placeholder: resource.emailPlacholder.tr),
                              // decoration: InputDecoration(
                              //   hintText: 'erfhgde'
                              // ),
                              style: mTextFieldTS,
                              textAlign: TextAlign.center,
                              controller: _emailController,
                            ),
                            SizedBox(
                              height: height* 0.02,
                            ),
                            TextField(
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: _passwordObscure,
                              textAlign: TextAlign.center,
                              // focusNode: textFieldFocusNode,
                              decoration: mInputDecoration(placeholder: resource.passwordPlacholder.tr).copyWith(
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _passwordObscure = !_passwordObscure;
                                      });
                                    },
                                    child: Icon(Icons.remove_red_eye,
                                        color: _passwordObscure
                                            ? eyeColor
                                            : eyeColor.withAlpha(50).withAlpha(75))),
                              ),
                              style: mTextFieldTS,
                              controller: _passwordController,
                            ),
                            SizedBox(
                              height: height* 0.04,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap:(){
                                    Get.to(() => const UserSignUp(isForgetPassword: true));
                                  },
                                  child: Text(resource.forgotPasswordLinkTitle.tr,style: TextStyle(
                                      color: lablecolor,
                                      decoration: TextDecoration.underline,
                                      fontFamily: narrowbold,
                                      fontSize: 18),),
                                ),

                              ],
                            ),
                            SizedBox(
                              height: height*0.04,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (!isValid()) {
                                  return;
                                }
                                bool _hasInternet = await AppUtil.isInternetAvailable(context);
                                if (!_hasInternet) {
                                  return;
                                }
                                await handleSignIn(context);
                              } ,
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
                                        resource.login.tr.toUpperCase(),
                                        style:  normalBtnStyle,
                                      ),
                                    ),
                                  )),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            resource.newAccountLinkTitle.tr,
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: narrowbook,
                                fontSize: 22),
                          ),
                          GestureDetector(
                              onTap: () {
                                Get.to(() => const UserSignUp(isForgetPassword: false));
                              }, child: Text(
                                resource.signup.tr.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: narrowbold,
                                    fontSize: 22),
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ], //<Widget>[]
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Future handleSignIn(BuildContext context) async {
    String pwd = _passwordController.text.trim();

    String encryptedPassword = await AppUtil.getEncrptedString(pwd);

    log('encryptedPassword $encryptedPassword');
    Map<String, dynamic> userLoginSignUpRequestJson = {
      "user_email": _emailController.text,
      "password": encryptedPassword.trim(),
    };

    Map<AuthStatus, dynamic> userLogin = await _authProvider.getSimpleLoginCheck(
        context: context,
        keyLoader: _globalKey,
        userLoginSignUpRequestJson: userLoginSignUpRequestJson,
        apiName: ServiceUrl.simpleLoginCheck);
    if (userLogin != null && userLogin.isNotEmpty) {
      // TODO password

      switch (userLogin.keys.first) {
        case AuthStatus.error:
          DialogUtils.showErrorDialog(context, userLogin.values.first,resource.close.tr);
          break;
        case AuthStatus.success:
          User _user = userLogin.values.first.data;
          _user.user_password = encryptedPassword.trim();
          userDefault.saveUser(_user);
          // userDefault.setUser = loginResp.data!;
          ///TODO Phase2
          if(_user.gender == '' || _user.dateOfBirth == null || _user.dateOfBirth == '0' || _user.ethnicity == '' || _user.homeCountry == ''){
            Get.offAll(()=> RequiredDetailScreen(user: _user));
          }else{
            var fToken = await UserDefault().readString(UserDefault.kFirebaseToken);
            if (fToken != null) {
              await _authProvider.saveTokenOnServer(fToken);
              FCM().fcmSubscribe();
            }
            FCM().fcmSubscribe();
            Get.offAll(()=> DashboardScreen(isFirstTime: true,));
          }

          break;
        case AuthStatus.server_error:
          DialogUtils.showErrorDialog(context, resource.serverError.tr,resource.close.tr);
          break;
        case AuthStatus.invalid:
          break;
      }
    }
  }

  bool isValid() {
    if (_emailController.text.isEmpty) {
      AppUtil.toast(resource.emailValidation.tr);
      return false;
    }
    else if (!AppUtil.validateEmail(_emailController.text.trim())) {
      AppUtil.toast(resource.emailValidValidation.tr);
      return false;
    }
    else if (_passwordController.text.isEmpty) {
      AppUtil.toast(resource.passwordValidation.tr);
      return false;
    }
    else {
      return true;
    }
  }
}
