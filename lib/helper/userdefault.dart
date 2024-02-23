import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/util/common.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification.dart';

class UserDefault extends GetxController{

  static const String kLoggedInUser = 'LoggedInUser';
  static const String kImagePermissionDenied = 'ImagePermissionDenied';
  static const String kFirebaseToken = 'FirebaseToken';

  static const String UDKey = 'UserDefault';
  static const String language = 'language';
  static final UserDefault _instance = UserDefault._internal();
  final MethodChannelHandler methodChannelHandler = MethodChannelHandler();

  static get instance => _instance;

  UserDefault._internal(){
    log('----------------------------UserDefault--------------------------');
  }
  Rx<User> user = User().obs;

  void setUser(User value) {
    user.value = value;
    update();
    update(['user']);
  }

  void saveString(String name, String value) async {
    SharedPreferences sharedPreferences = await _pref();
    sharedPreferences.setString(name, value);
    // await methodChannelHandler.saveSharedPref(name, json.encode(value));
  }

  void saveInt(String name, int value) async {
    SharedPreferences sharedPreferences = await _pref();
    sharedPreferences.setInt(name, value);
    // await methodChannelHandler.saveSharedPref(name, json.encode(value));
  }

  void saveBool(String name, bool value) async {
    SharedPreferences sharedPreferences = await _pref();
    sharedPreferences.setBool(name, value);

    // await methodChannelHandler.saveSharedPref(name, json.encode(value));
  }

  Future<String?> readString(String value) async {
    // var result = await methodChannelHandler.readSharedPref(value);
    // if (result.isEmpty) {
    //   return null;
    // }
    // return result;
    // Map map = json.decode(result);
    // return map[value];
    SharedPreferences sharedPreferences = await _pref();
    return sharedPreferences.getString(value);
  }


  Future<bool> readBool(String value) async {
    // var res = await methodChannelHandler.readSharedPref(value);
    // return res.isTrue;
    SharedPreferences sharedPreferences = await _pref();
    return sharedPreferences.getBool(value)??false;
  }

  void clearUserDefault() async {
    FCM().fcmUnSubscribe();
    // await methodChannelHandler.removeSharedPref(kLoggedInUser);
    // await methodChannelHandler.removeSharedPref(kImagePermissionDenied);
    // await methodChannelHandler.removeSharedPref(kFirebaseToken);
    // await methodChannelHandler.removeSharedPref(kFTokenRef);

    String? language=await getLanguageCode();
    SharedPreferences preferences = await _pref();
    await preferences.clear();
    await setLanguageCode(language!);
  }

  Future<dynamic> _pref() async {
    // SharedPreferences.setMockInitialValues({});
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences;
  }
//TODO 07/04/2022
  Future<String?> getLanguageCode() async {
    SharedPreferences sharedPreferences = await _pref();
    String? languageCode = sharedPreferences.getString(language);
    languageCode ??= AppLanguages.en.name;
    return languageCode;
  }

//TODO 07/04/2022
  Future<void> setLanguageCode(String languageCode) async {
    SharedPreferences sharedPreferences = await _pref();
    sharedPreferences.setString(language,languageCode);
  }


  Future<User?> getUser() async {
    SharedPreferences prefs = await _pref();
    String? strLoggedInUser = prefs.getString(kLoggedInUser);
    // String? strLoggedInUser = await readString(kLoggedInUser);
    if (strLoggedInUser == null) {
      return null;
    }
    return User.fromJson(json.decode(strLoggedInUser));
  }

  Future<void> saveUser(User _user) async {
    // saveString(kLoggedInUser, json.encode(_user.toJson()));
    SharedPreferences prefs = await _pref();
    await prefs.setString(kLoggedInUser, json.encode(_user.toJson()));
  }

  /*dynamic read(String key) {
    if (_prefs != null) {

    }
    var value =  otherBox.call().read(key);
    return value;
  }

  bool readBool(String key) {
    var value =  otherBox.call().read(key);
    return value?? false;
  }

  String readString(String key) {
    return otherBox.call().read(key);
  }

  save(String key, value) {
    otherBox.call().write(key, value);
  }

  Future remove(String key) async {
    await (otherBox.call() as GetStorage).remove(key);
  }*/


  /*void clearUserDefault() {
    remove(UserDefault.kLoggedInUser);
    // remove(UserDefault.kFirebaseToken);
    remove(UserDefault.kFTokenRef);
  }*/

  UserDefault(){
    /*var userMap = read(UserDefault.kLoggedInUser);
    if (userMap != null) {
      User _user = User.fromJson(userMap);
      user.value = _user;
      update();
    }
    else {
      user.value = User();
      update();
    }*/
  }

}
