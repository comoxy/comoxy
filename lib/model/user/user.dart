import 'package:rate_review/model/document/document_data.dart';
import 'package:rate_review/model/payment/payment_detail.dart';

class User {
  String? userEmail;
  String? userName;
  String? languageCode;
  String? age;
  String? gender;
  String? pushNotification;
  String? createdDate;
  String? lastLoginDate;
  String? otpCode;
  String? otpTimestamp;
  String? mobile;
  String? ethnicity;
  String? dateOfBirth;
  String? homeCountry;
  String? currency;
  String? isActive;
  String? isDeleted;
  String? loginFrom;
  String? token;
  String? tokenExpireTime;
  String? user_id;
  String? user_password;
  List<DocumentData>? documents;
  List<PaymentDetail>? payment;

  User(
      {this.userEmail,
      this.userName,
      this.languageCode,
      this.age,
      this.gender,
      this.pushNotification,
      this.createdDate,
      this.lastLoginDate,
      this.otpCode,
      this.otpTimestamp,
      this.mobile,
      this.ethnicity,
      this.dateOfBirth,
      this.homeCountry,
      this.currency,
      this.isActive,
      this.isDeleted,
      this.loginFrom,
      this.token,
      this.tokenExpireTime,
      this.user_id,
      this.user_password,
      this.documents,
      this.payment});

  User.fromJson(dynamic json) {
    userEmail = json["user_email"];
    userName = json["full_name"];
    languageCode = json["language_code"];
    age = json["age"];
    gender = json["gender"];
    pushNotification = json["push_notification"];
    createdDate = json["created_date"];
    lastLoginDate = json["lastlogin_date"];
    otpCode = json["otp_code"];
    otpTimestamp = json["otp_timestamp"];
    mobile = json["mobile"];
    ethnicity = json["ethnicity"];
    dateOfBirth = json["dateof_birth"];
    homeCountry = json["home_country"];
    currency = json["currency_code"];
    isActive = json["is_active"];
    isDeleted = json["is_deleted"];
    loginFrom = json["login_from"];
    token = json["token"];
    tokenExpireTime = json["token_expire_time"];
    user_id = json["user_id"];
    user_password = json["user_password"];
    if (json['documents'] != null) {
      documents = <DocumentData>[];
      json['documents'].forEach((v) {
        documents!.add(DocumentData.fromJson(v));
      });
    }

    if (json['payment'] != null) {
      payment = <PaymentDetail>[];
      json['payment'].forEach((v) {
        payment!.add(PaymentDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["user_email"] = userEmail;
    map["full_name"] = userName;
    map["language_code"] = languageCode;
    map["age"] = age;
    map["gender"] = gender;
    map["push_notification"] = pushNotification;
    map["created_date"] = createdDate;
    map["lastlogin_date"] = lastLoginDate;
    map["otp_code"] = otpCode;
    map["otp_timestamp"] = otpTimestamp;
    map["mobile"] = mobile;
    map["ethnicity"] = ethnicity;
    map["dateof_birth"] = dateOfBirth;
    map["home_country"] = homeCountry;
    map["currency_code"] = currency;
    map["is_active"] = isActive;
    map["is_deleted"] = isDeleted;
    map["login_from"] = loginFrom;
    map["token"] = token;
    map["token_expire_time"] = tokenExpireTime;
    map["user_id"] = user_id;
    map["user_password"] = user_password;
    if (documents != null) {
      map['documents'] = documents!.map((v) => v.toJson()).toList();
    }
    if (payment != null) {
      map['payment'] = payment!.map((v) => v.toJson()).toList();
    }
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && runtimeType == other.runtimeType && userEmail == other.userEmail;

  @override
  int get hashCode => userEmail.hashCode;
}
