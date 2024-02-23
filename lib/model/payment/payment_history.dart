import 'payment_detail.dart';

class PaymentHistory {
  String? status;
  int? responseCode;
  int? code;
  String? codemessage;
  String? iosCodemessage;
  String? message;
  List<PaymentDetail>? data;

  PaymentHistory(
      {this.status,
        this.responseCode,
        this.code,
        this.codemessage,
        this.iosCodemessage,
        this.message,
        this.data});

  PaymentHistory.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    responseCode = json['response_code'];
    code = json['code'];
    codemessage = json['codemessage'];
    iosCodemessage = json['ios_codemessage'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PaymentDetail>[];
      json['data'].forEach((v) {
        data!.add(PaymentDetail.fromJson(v));
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