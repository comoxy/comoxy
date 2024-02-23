import '../../model/user/user.dart';

class UserLogInResponse {
  String? status;
  String? message;
  String? codemessage;
  String? ios_codemessage;
  late int response_code;
  late int code;
  User? data;

  UserLogInResponse(
      {this.status,
      this.message,
      this.codemessage,
      this.ios_codemessage,
      required this.response_code,
      required this.code,
      this.data});

  UserLogInResponse.fromJson(dynamic json) {
    status = json["status"];
    message = json["message"];
    codemessage = json["codemessage"];
    ios_codemessage = json["ios_codemessage"];
    response_code = json["response_code"];
    code = json["code"];
    data = json["data"] != null ? User.fromJson(json["data"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["status"] = status;
    map["message"] = message;
    map["codemessage"] = codemessage;
    map["ios_codemessage"] = ios_codemessage;
    map["response_code"] = response_code;
    map["code"] = code;
    if (data != null) {
      map["data"] = data!.toJson();
    }
    return map;
  }
}
