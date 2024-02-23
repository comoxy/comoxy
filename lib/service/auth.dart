import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/brandFilter/brand.dart';
import 'package:rate_review/model/document/all_document_response.dart';
import 'package:rate_review/model/general_response.dart';
import 'package:rate_review/model/payment/payment_history.dart';
import 'package:rate_review/model/post/all_post_response.dart';
import 'package:rate_review/model/post/all_transaction_response.dart';
import 'package:rate_review/model/post/post_data.dart';
import 'package:rate_review/model/post/transaction.dart';
import 'package:rate_review/model/user/user_login_response.dart';
import 'package:rate_review/model/wallet/wallet_balance_response.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/dialog/dialog_utils.dart';
import 'package:rate_review/ui/screen/user_login.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';

import '../model/brandFilter/AllBrandResponse.dart';
import '../model/brandCategory/brandCategory.dart';
import '../model/user/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_exception.dart';

class AuthModel extends ChangeNotifier {
  String errorMessage = "";

  User? _user;
  Transaction? _transaction;

  UserDefault userDefault = Get.find();
  final MethodChannelHandler _methodChannelHandler = Get.find();

  /// WARN
  Future<dynamic> get({BuildContext? context, keyLoader, required String api, bool? showDialog}) async {
    if (context != null) {
      DialogUtils.showLoadingDialog(context, keyLoader);
    }
    try {
      // String publicUrl = await _methodChannelHandler.getPublicUrl();
      String token = user!.token!;
      String publicUrl = ServiceUrl.SERVER_URL;
      final response = await http.get(Uri.parse(publicUrl + api), headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: token,
        
      }).timeout(Duration(seconds: timeoutDuration), onTimeout: () {
        //loge(resource.connectionTimeout);
        AppUtil.toast(resource.connectionTimeout.tr);
        throw TimeoutException(resource.connectionTimeout.tr);
      });
      if (context != null) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (response.statusCode != 200) {
        AppUtil.toast(resource.somethingWentWrong.tr);
      }
      return _returnResponse(response);
    } on SocketException {
      AppUtil.toast(resource.socketException.tr);
    } on Exception {
      if (context != null) Navigator.of(context, rootNavigator: true).pop();
      AppUtil.toast(resource.somethingWentWrong.tr);
      return null;
    }
  }

  /// WARN
  Future<dynamic> post(
      {BuildContext? context,
      keyLoader,
      required String api,
      required dynamic body,
      int? timeoutSec,
      int? pageCount,
      bool showInternetDialog = true,
      bool showDialog = true}) async {
    if (context != null) {
      var internetConnectivity =
      await (showInternetDialog ? AppUtil.isInternetAvailable(context) : AppUtil.isInternetConnected());
      if (!internetConnectivity) {
        return null;
      }
    }
    if ((context != null && (pageCount == null) || (context != null && pageCount == 0)) && showDialog) {
      DialogUtils.showLoadingDialog(context, keyLoader);
    }
    try {

      String publicUrl = ServiceUrl.SERVER_URL;
      var _body = jsonEncode(body);
      log('request body $_body');

      Map<String, String> headers = <String, String>{
        HttpHeaders.contentTypeHeader: "application/json; charset=UTF-8",
        HttpHeaders.acceptHeader: 'application/json',
      };

      _user = await userDefault.getUser();
      if (_user != null && api != ServiceUrl.simpleLoginCheck) {

        String token = user!.token!;
        log('header token $token');
        headers.addAll({HttpHeaders.authorizationHeader: token});
      }

      final response = await http
          .post(
        Uri.parse(publicUrl + api),
        headers: headers,
        body: _body,
      )
          .timeout(Duration(seconds: timeoutSec ?? timeoutDuration), onTimeout: () {
        //loge(resource.connectionTimeout);
        AppUtil.toast(resource.connectionTimeout.tr);
        throw TimeoutException(resource.connectionTimeout.tr);
      });
      if ((context != null && (pageCount == null) || (context != null && pageCount == 0)) && showDialog) {
        var canPop = Navigator.of(context, rootNavigator: true).canPop();
        if (canPop) Navigator.of(context, rootNavigator: true).pop();
      }
      // if (response.statusCode != 200) {
      //   AppUtil.toast(resource.somethingWentWrong);
      // }
      //logd(api + ' - Body', response.body, level: LL.API_LOG);
      return _returnResponse(response);
    } on SocketException {
      // loge(resource.socketException);
      AppUtil.toast(resource.socketException.tr);
      if (context != null) {
        var canPop = Navigator.of(context, rootNavigator: true).canPop();
        if (canPop) Navigator.of(context, rootNavigator: true).pop();
      }
    } on TimeoutException {
      if (context != null) {
        var canPop = Navigator.of(context, rootNavigator: true).canPop();
        if (canPop) Navigator.of(context, rootNavigator: true).pop();
      }
      return null;
    } on Exception {
      if (context != null) {
        var canPop = Navigator.of(context, rootNavigator: true).canPop();
        if (canPop) Navigator.of(context, rootNavigator: true).pop();
      }
      AppUtil.toast(resource.somethingWentWrong.tr);
      return null;
    }
  }

  /// WARN
  Future<dynamic> callMultipartWithProgress(BuildContext context, GlobalKey<State> keyLoader, String api,
      Map<String, dynamic> businessRequestJson, http.MultipartRequest request,
      {bool showInternetDialog = true}) async {
    var internetConnectivity =
        await (showInternetDialog ? AppUtil.isInternetAvailable(context) : AppUtil.isInternetConnected());
    if (!internetConnectivity) {
      return null;
    }
    DialogUtils.showLoadingDialog(context, keyLoader);

    var response;
    try {
      // request.headers = {};
      response = await request.send().timeout(const Duration(seconds: 10), onTimeout: () {
        AppUtil.toast(response.connectionTimeout);
        throw TimeoutException(resource.connectionTimeout.tr);

      });
    } on SocketException {
      AppUtil.toast(response.socketException);
      if (context != null) {
        var canPop = Navigator.of(context, rootNavigator: true).canPop();
        if (canPop) Navigator.of(context, rootNavigator: true).pop();
      }
    } on TimeoutException {
      if (context != null) {
        var canPop = Navigator.of(context, rootNavigator: true).canPop();
        if (canPop) Navigator.of(context, rootNavigator: true).pop();
      }
      return null;
    } on Exception {
      if (context != null) {
        var canPop = Navigator.of(context, rootNavigator: true).canPop();
        if (canPop) Navigator.of(context, rootNavigator: true).pop();
      }
      AppUtil.toast(resource.somethingWentWrong.tr);
      return null;
    }

    if (response.statusCode != 200) {
      return null;
    }

    final respStr = await response.stream.bytesToString();
    return json.decode(respStr);
  }

  User? get user => _user;

  void navigateToMain(BuildContext? context) {
    Get.offAll(const UserLogin());
    // Navigator.of(context).pushAndRemoveUntil(
    //     MaterialPageRoute(
    //       builder: (context) => const UserLogin(),
    //     ),
    //     (Route<dynamic> route) => false);
  }

  /// WARN
  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          var responseJson = json.decode(response.body);
          return responseJson;
        } catch (e) {
          print(e);
          return {
            resource.status: false,
            resource.message: response.body,
            'body': response.body,
          };
        }
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      case 404:
        throw NotFoundException(resource.notFound.tr);
      case 500:
      default:
        throw FetchDataException('${resource.server_error.tr} ${response.statusCode}');
    }
  }

  /// WARN
  Future<bool> handleResponseNew(BuildContext? context, response, {OnParse? onParse, bool showSnackBar = true}) async {
    if (response == null) return false;
    log('response $response');
    String status = response[resource.status.tr];
    String message = response[resource.message.tr];

    int responseCode = response[resource.responseCode.tr];

    if (status.isTrue) {
      if (responseCode == 1001 ||
          responseCode == 1004 ||
          responseCode == 1007) {
        // AppUtil.toast('email_not_active'.tr);
        handleStatus(message, context, requiredLogout: true, showSnackBar: showSnackBar);
        return false;
      }
      else {
        if (responseCode == 1000 ||
            responseCode == 1003 ||
            responseCode == 1004 ||
            responseCode == 1005 ||
            responseCode == 1006 ||
            responseCode == 1007 ||
            responseCode == 1008 ||
            responseCode == 1009 ||
            responseCode == 1011 ||
            responseCode == 1012) {
          if (showSnackBar) {
            AppUtil.toast(message);
          }
        }
        onParse!.call(response);
        return true;
      }
    }
    else {
      if (responseCode == 1001 ||
          responseCode == 1004 ||
          responseCode == 1007) {
        handleStatus(message, context, requiredLogout: true, showSnackBar: showSnackBar);
        return false;
      }
      else {
        handleStatus(message, context, requiredLogout: false, showSnackBar: (showSnackBar || (responseCode != 1020)));
        return false;
      }
    }
  }


  /// WARN
  Future<AuthStatus> handleResponse(context, response, {OnParse? onParse}) async {
    if (response == null) return AuthStatus.server_error;
    log('response $response');
    String status = response[resource.status.tr];
    String message = response[resource.message.tr];

    if (status.isTrue) {
      int responseCode = response[resource.responseCode.tr];
      if (responseCode == 1001 ||
          responseCode == 1004 ||
          responseCode == 1007) {
        AppUtil.toast(resource.emailNotActive.tr);
        handleStatus(message, context, requiredLogout: true);
        return AuthStatus.invalid;
      } else {
        if (responseCode == 1000 ||
            responseCode == 1003 ||
            responseCode == 1004 ||
            responseCode == 1005 ||
            responseCode == 1006 ||
            responseCode == 1007 ||
            responseCode == 1008 ||
            responseCode == 1009 ||
            responseCode == 1011 ||
            responseCode == 1012) {
          AppUtil.toast(message);
        }
        onParse!.call(response);
        return AuthStatus.success;
      }
    } else {
      handleStatus(message, context, requiredLogout: false);// TODO handle response for login API
      return AuthStatus.error;
    }
  }

  /// WARN
  Future<void> handleStatus(String message, BuildContext? context, {bool requiredLogout = false, bool showSnackBar = true}) async {
    // Map<String, dynamic>? platform = await _methodChannelHandler.getPlatformDetail();
    await Future.delayed(const Duration(milliseconds: 100));
    if (showSnackBar) {
      AppUtil.toast(message);
    }
    if (requiredLogout) {
      userDefault.clearUserDefault();
      navigateToMain(context);
    }
  }


  Future<void> saveTokenOnServer(String newToken) async {
    userDefault.saveString(UserDefault.kFirebaseToken, newToken);
    User? _user = await userDefault.getUser();

    if (_user == null) {
      return;
    }
    // _user = User.fromJson(userMap);

    bool _hasInternet = await AppUtil.isInternetConnected();
    if (!_hasInternet) {
      return;
    }
    Map<String, dynamic> saveNewTokenRequestJson = {
      RequestParam.kUserEmail : _user.userEmail,
      RequestParam.kFirebaseToken : newToken
    };

    saveNewToken(
        saveNewTokenRequestJson: saveNewTokenRequestJson,
        apiName: ServiceUrl.kUpdateFirebaseToken)
        .then((result) async {
      if (result == null) {
        return;
      }
      if(result.status.isTrue){
        // userDefault.saveBool(UserDefault.kFTokenRef, true);
      }
    });
  }

  Future<UserLogInResponse?> getSimpleLoginRegister({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> userLoginSignUpRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: userLoginSignUpRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: userLoginSignUpRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return UserLogInResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<AllPostResponse?> getPostById({
    BuildContext? context,
    GlobalKey<State>? keyLoader,
    required String apiName,
    required Map<String, dynamic> getPostByIdRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getPostByIdRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: getPostByIdRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return AllPostResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<UserLogInResponse?> newProfileUpdate({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> userLoginSignUpRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: userLoginSignUpRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: userLoginSignUpRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return UserLogInResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> forgetPassword({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> forgetPasswordRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: forgetPasswordRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: forgetPasswordRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  //TODO 08/04/2022
  Future<GeneralResponse?> signUpResendOTP({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> resendOTPRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: resendOTPRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: resendOTPRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }


  Future<GeneralResponse?> saveNewToken({
    required String apiName,
    required Map<String, dynamic> saveNewTokenRequestJson,
  }) async {
    var response = await post(api: apiName, body: saveNewTokenRequestJson, showDialog: false, showInternetDialog: false);

    bool res = await handleResponseNew(
      null,
      response,
      onParse: (response) {},
      showSnackBar: false
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> verifyForgetPasswordOtp({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> forgetPasswordRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: forgetPasswordRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: forgetPasswordRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> verifyDeleteAccountOtp({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> deleteAccountRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: deleteAccountRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: deleteAccountRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> deleteAccount({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> deleteAccountRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: deleteAccountRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: deleteAccountRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> resetPassword({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> resetPasswordRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: resetPasswordRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: resetPasswordRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> userProfileUpdate({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> userProfileRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: userProfileRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: userProfileRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<Map<AuthStatus, dynamic>> getSimpleLoginCheck({
    BuildContext? context,
    GlobalKey<State>? keyLoader,
    required String apiName,
    required Map<String, dynamic> userLoginSignUpRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: userLoginSignUpRequestJson);
    } else {
      response = await post(context: context, keyLoader: keyLoader, api: apiName, body: userLoginSignUpRequestJson);
    }

    AuthStatus res = await handleResponse(
      context,
      response,
      onParse: (response) {},
    );
    if (res != null) {
      if (res == AuthStatus.success) {
        UserLogInResponse userLogInResponse = UserLogInResponse.fromJson(response);
        if (userLogInResponse.data != null) {
          _user = userLogInResponse.data;
        }
        return {AuthStatus.success: userLogInResponse};
      }
      else {
        if (res == AuthStatus.server_error) {
          return {res: resource.serverError.tr};
        }
        else {
          return {AuthStatus.error: response[resource.message.tr]};
        }
      }

    } else {
      return {AuthStatus.error: response[resource.message.tr]};
    }
  }

  Future<UserLogInResponse?> generateVerifyOtp({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> generateVerifyOtpRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: generateVerifyOtpRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: generateVerifyOtpRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return UserLogInResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<AllDocumentResponse?> getUserDocumentList({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> userDocumentListRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: userDocumentListRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: userDocumentListRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return AllDocumentResponse.fromJson(response);
    } else {
      return AllDocumentResponse.fromJson(response);
    }
  }

  Future<AllPostResponse> getAllPostList({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> getAllPostListRequestJson


  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getAllPostListRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: getAllPostListRequestJson, showDialog: true);
    }

    bool res = await handleResponseNew(
        context,
        response,
        onParse: (response) {},
        showSnackBar: false
    );
    if (res) {
      return AllPostResponse.fromJson(response);
    } else {
      return AllPostResponse.fromJson(response);
    }
  }


  Future<User> userProfile({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> getUserProfileRequestJson


  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getUserProfileRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: getUserProfileRequestJson, showDialog: true);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
      showSnackBar: false
    );
    if (res) {
      return User.fromJson(response['data']);
    } else {
      return User.fromJson(response);
    }
  }

  Future<AllBrandResponse> getAllFilterBrandList({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> getAllFilterBrandRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getAllFilterBrandRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: getAllFilterBrandRequestJson, showDialog: false);
    }

    bool res = await handleResponseNew(
        context,
        response,
        onParse: (response) {},
        showSnackBar: false
    );
    if (res) {
      return AllBrandResponse.fromJson(response);
    } else {
      return AllBrandResponse.fromJson(response);
    }
  }

  Future<brandCategory> getCategoryList({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> getAllCategoryRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getAllCategoryRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: getAllCategoryRequestJson, showDialog: false);
    }

    bool res = await handleResponseNew(
        context,
        response,
        onParse: (response) {},
        showSnackBar: false
    );
    if (res) {
      return brandCategory.fromJson(response);
    } else {
      return brandCategory.fromJson(response);
    }
  }

  Future<AllPostResponse> getFollowStatus({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> getAllFollowUnfollowRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getAllFollowUnfollowRequestJson);
    } else {
      // TODO 14/03/2022 TO SHOW showDialog : FALSE TO TRUE
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: getAllFollowUnfollowRequestJson, showDialog: true);
    }

    bool res = await handleResponseNew(
        context,
        response,
        onParse: (response) {},
        showSnackBar: false
    );
    if (res) {
      return AllPostResponse.fromJson(response);
    } else {
      return AllPostResponse.fromJson(response);
    }
  }

  Future<AllPostResponse> getUserInterestedPostList({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> getAllMailListRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getAllMailListRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: getAllMailListRequestJson, showDialog: false);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
        showSnackBar: false
    );
    if (res) {
      return AllPostResponse.fromJson(response);
    } else {
      return AllPostResponse.fromJson(response);
    }
  }

  Future<WalletBalanceResponse?> getUserWalletHistory({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> getUserWalletHistoryRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getUserWalletHistoryRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: getUserWalletHistoryRequestJson, showDialog: false);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
      showSnackBar: true
    );
    if (res) {
      return WalletBalanceResponse.fromJson(response);
    } else {
      return WalletBalanceResponse.fromJson(response);
    }
  }

  Future<PaymentHistory> getPaymentHistory({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> getPaymentHistoryListRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: getPaymentHistoryListRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: getPaymentHistoryListRequestJson, showDialog: false);
    }

    bool res = await handleResponseNew(
        context,
        response,
        onParse: (response) {},
        showSnackBar: false
    );
      if (res) {
        return PaymentHistory.fromJson(response);
      }else{
        return PaymentHistory.fromJson(response);
      }
  }

  Future<GeneralResponse?> deleteUserDocument({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> deleteDocumentRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: deleteDocumentRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: deleteDocumentRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> setupPaymentMethod({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> setupPaymentMethodRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: setupPaymentMethodRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: setupPaymentMethodRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> deleteProdcutTransactionDocument({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> deleteProductTransactionRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: deleteProductTransactionRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: deleteProductTransactionRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }


  Future<GeneralResponse?> notInterestedPost({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> notInterestedPostRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: notInterestedPostRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: notInterestedPostRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }

  Future<GeneralResponse?> cancelPost({
    required BuildContext? context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> notInterestedPostRequestJson,
  }) async {
    var response;
    if (context == null) {
      response = await post(api: apiName, body: notInterestedPostRequestJson);
    } else {
      response = await post(
          context: context, keyLoader: keyLoader, api: apiName, body: notInterestedPostRequestJson);
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return GeneralResponse.fromJson(response);
    } else {
      return null;
    }
  }


  Future<AllDocumentResponse?> uploadDocumentResponse({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String apiName,
    required Map<String, dynamic> uploadDocumentRequestJson,
  }) async {

    String publicUrl = ServiceUrl.SERVER_URL;
    var request = http.MultipartRequest(
        'POST', Uri.parse(publicUrl +  apiName))
      ..fields[RequestParam.kUserEmail] = uploadDocumentRequestJson[RequestParam.kUserEmail]
      ..fields[RequestParam.kDocOrd] = uploadDocumentRequestJson[RequestParam.kDocOrd].toString();


    _user = await userDefault.getUser();
    if (_user != null) {
      // _user = User.fromJson(userMap);

      String token = user!.token!;

      request.headers[HttpHeaders.authorizationHeader] = token;
    }

    String filePath = uploadDocumentRequestJson[RequestParam.kUserDocument];
    log('uploadDocumentRequestJson: $uploadDocumentRequestJson');
    if (filePath.isNotEmpty) {
      var pic = await http.MultipartFile.fromPath(RequestParam.kUserDocument, filePath);
      //add multipart to request
      request.files.add(pic);
    /*final bytes = pic.length;
      final kb = bytes / 1024;

      if (kb > 50) {
        AppUtil.toast('file size is too large');
        return null;
      }*/
    }

    var response = await callMultipartWithProgress(
        context, keyLoader, apiName, uploadDocumentRequestJson, request);

    if (context != null) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return AllDocumentResponse.fromJson(response);
    } else {
      return null;
    }
  }


  Future<AllTransactionResponse?> uploadTransactionResponse({
    required BuildContext context,
    required GlobalKey<State> keyLoader,
    required String? apiName,
    required Map<String, dynamic> uploadDocumentRequestJson,
  }) async {

    String publicUrl = ServiceUrl.SERVER_URL;
    var request = http.MultipartRequest(
        'POST', Uri.parse(publicUrl +  apiName!))
      ..fields[RequestTransaction.kUserEmail] = uploadDocumentRequestJson[RequestTransaction.kUserEmail]
      ..fields[RequestTransaction.kPostId] = uploadDocumentRequestJson[RequestTransaction.kPostId].toString()
      ..fields[RequestTransaction.kUserDocument] = uploadDocumentRequestJson[RequestTransaction.kUserDocument].toString()
      ..fields[RequestTransaction.kUserDocumentType] = uploadDocumentRequestJson[RequestTransaction.kUserDocumentType].toString();


    _user = await userDefault.getUser();
    if (_user != null) {
     // _user = User.fromJson(userMap);
      String token = user!.token!;

      request.headers[HttpHeaders.authorizationHeader] = token;
    }

    String filePath = uploadDocumentRequestJson[RequestTransaction.kUserDocument];
    if (filePath.isNotEmpty) {
      var pic = await http.MultipartFile.fromPath(RequestTransaction.kUserDocument, filePath);
      //add multipart to request
      request.files.add(pic);
      /*final bytes = pic.length;
      final kb = bytes / 1024;

      if (kb > 50) {
        AppUtil.toast('file size is too large');
        return null;
      }*/
    }

    var response = await callMultipartWithProgress(
        context, keyLoader, apiName, uploadDocumentRequestJson, request);

    if (context != null) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    bool res = await handleResponseNew(
      context,
      response,
      onParse: (response) {},
    );
    if (res) {
      return AllTransactionResponse.fromJson(response);
    } else {
      return null;
    }
  }
}




enum AuthStatus {
  error,
  success,
  server_error,
  invalid
}