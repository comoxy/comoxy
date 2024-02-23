import 'dart:ffi';

import '../../util/common.dart';

class UserNotification {
  String? postid;
  String? postTitle;
  String? photoName;
  String? isTargetdateAll;
  String? targetFromAge;
  String? targetToAge;
  String? targetGender;
  String? targetEthnicity;
  String? targetLocation;
  String? header;
  String? languageCode;
  int? type;
  String? notificationType;
  List<Excluded>? excluded;

  UserNotification(
      {this.postid,
      this.postTitle,
      this.photoName,
      this.isTargetdateAll,
      this.targetFromAge,
      this.targetToAge,
      this.targetGender,
      this.targetEthnicity,
      this.targetLocation,
      this.header,
      this.languageCode,
      this.type,
        this.notificationType,
      this.excluded});

  UserNotification.fromJson(Map<String, dynamic> json) {
    postid = json['postid'];
    postTitle = AppUtil.langcode == AppLanguages.en.name ? json['title'] : json['title_ar'];
    photoName = json['photo_name'];
    isTargetdateAll = json['is_targetdate_all'];
    targetFromAge = json['target_from_age'];
    targetToAge = json['target_to_age'];
    targetGender = json['target_gender'];
    targetEthnicity = json['target_ethnicity'];
    targetLocation = json['target_location'];
    header = json['header'];
    languageCode = json['languageCode'];
    type = json['type'];
    notificationType = json['notificationType'];
    //excluded = json['excluded'];
    if (json['excluded'] != null) {
      excluded = <Excluded>[];
      json['excluded'].forEach((v) {
        excluded!.add(new Excluded.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postid'] = postid;
    data['title'] = postTitle;
    data['photo_name'] = photoName;
    data['is_targetdate_all'] = isTargetdateAll;
    data['target_from_age'] = targetFromAge;
    data['target_to_age'] = targetToAge;
    data['target_gender'] = targetGender;
    data['target_ethnicity'] = targetEthnicity;
    data['target_location'] = targetLocation;
    data['header'] = header;
    data['languageCode'] = languageCode;
    data['type'] = type;
    data['notificationType'] = notificationType;
    //data['excluded'] = excluded;
    if (this.excluded != null) {
      data['excluded'] = this.excluded!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Excluded {
  String? userEmail;

  Excluded({this.userEmail});

  Excluded.fromJson(Map<String, dynamic> json) {
    userEmail = json['user_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_email'] = this.userEmail;
    return data;
  }
}
