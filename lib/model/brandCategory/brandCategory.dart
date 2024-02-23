import 'category.dart';

class brandCategory {
  String? status;
  int? responseCode;
  int? code;
  String? codemessage;
  String? iosCodemessage;
  String? message;
  List<Category>? data;

  brandCategory(
      {this.status,
        this.responseCode,
        this.code,
        this.codemessage,
        this.iosCodemessage,
        this.message,
        this.data});

  brandCategory.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    responseCode = json['response_code'];
    code = json['code'];
    codemessage = json['codemessage'];
    iosCodemessage = json['ios_codemessage'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Category>[];
      json['data'].forEach((v) {
        data!.add(new Category.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['response_code'] = this.responseCode;
    data['code'] = this.code;
    data['codemessage'] = this.codemessage;
    data['ios_codemessage'] = this.iosCodemessage;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? categoryId;
  String? categoryName;

  Data({this.categoryId, this.categoryName});

  Data.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    return data;
  }
}