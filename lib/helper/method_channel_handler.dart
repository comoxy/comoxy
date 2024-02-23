import 'dart:developer';

import 'package:flutter/services.dart';

class MethodChannelHandler {
  static const String methodChannelName = 'RATE_REVIEW_APP_METHOD_CHANNEL';

  static late final MethodChannelHandler _instance = MethodChannelHandler._internal();
  static get instance => _instance;
  final MethodChannel platform = const MethodChannel(methodChannelName);


  MethodChannelHandler._internal() {
   log('----------------------------MethodChannelHandler--------------------------');
  }

  static MethodChannelHandler get methodChannel {
    // if (_instance == null) {
    //   _instance = MethodChannelHandler._internal()
    // }
    return _instance;
  }

  Future<bool> isConnectedToNetwork() async {
    return await platform.invokeMethod('internetConnectivity');
  }

  Future<Map<String, dynamic>?> getPlatformDetail() async {
    return await platform.invokeMapMethod<String, dynamic>('getPlatformDetail');
  }

  /*Future<String> encode(String encodeString) async {
    try {
      return await platform
          .invokeMethod('encodeString', {'string': encodeString});
    } catch (e) {
     log('encode $e');
      return "";
    }
  }

  Future<String> decode(String encodeString) async {
    try {
      return await platform
          .invokeMethod('decodeString', {'string': encodeString});
    } catch (e) {
     log('decode $e');
      return "";
    }
  }*/

  MethodChannelHandler();

  Future<String> getToken() async {
    String key = await getEncryptionKey();
    String token = await platform.invokeMethod('getToken', {"data": key});
    log('token $token');
    return token;
  }

  Future<String> getEncryptionKey() async {
    return await platform.invokeMethod('getEncryptionKey');
  }

  Future<String> getSecretKey() async {
    return await platform.invokeMethod('getSecretKey');
  }


  Future<bool> removeSharedPref(String name) async {
    try {
      return await platform
          .invokeMethod("removeSharedPref", {'sharePref': name});
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<String> readSharedPref(String name) async {
    var response;
    try {
      response = await platform.invokeMethod("readSharedPref", {'sharePref': name});
    } catch (e) {
      print(e);
    }

    return response ?? '';
  }

  Future<bool> saveSharedPref(String name, String json) async {
    try {
      var response = await platform.invokeMethod("saveSharedPref", {
        'sharePref': name,
        'json': json,
      });

      return response;
    } catch (e) {
      print(e);
    }
    return false;
  }


/*Future<String> getEncryptedPassword(password) async {
    String key = await getEncryptionKey();
    String encPass = await platform.invokeMethod('getEncryptedPassword', {"data": key, "password": password});
    log('encPass $encPass');
    return encPass;
  }*/
}
