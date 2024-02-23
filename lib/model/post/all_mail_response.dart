import 'package:rate_review/model/post/post_data.dart';

class AllMailResponse {
  String? status;
  int? responseCode;
  int? code;
  String? codemessage;
  String? iosCodemessage;
  String? message;
  List<PostData>? data;

  AllMailResponse(
      {this.status,
        this.responseCode,
        this.code,
        this.codemessage,
        this.iosCodemessage,
        this.message,
        this.data});

  AllMailResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    responseCode = json['response_code'];
    code = json['code'];
    codemessage = json['codemessage'];
    iosCodemessage = json['ios_codemessage'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PostData>[];
      json['data'].forEach((v) {
        data!.add(PostData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['response_code'] = responseCode;
    data['code'] = code;
    data['codemessage'] = codemessage;
    data['ios_codemessage'] = iosCodemessage;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
