class GeneralResponse {
  late String status;
  late String message;
  late int response_code;
  dynamic code;
  String? codemessage;
  String? ios_codemessage;
  dynamic data;

  GeneralResponse({
    required this.status,
    required this.message,
    required this.response_code,
    this.code,
    required this.codemessage,
    required this.ios_codemessage,
    this.data,
  });

  GeneralResponse.fromJson(dynamic json) {
    status = json["status"];
    message = json["message"];
    response_code = json["response_code"];
    code = json["code"];
    codemessage = json["codemessage"];
    ios_codemessage = json["ios_codemessage"];
    data = json["data"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["status"] = status;
    map["message"] = message;
    map["response_code"] = response_code;
    map["code"] = code;
    map["codemessage"] = codemessage;
    map["ios_codemessage"] = ios_codemessage;
    map["data"] = data;
    return map;
  }
}