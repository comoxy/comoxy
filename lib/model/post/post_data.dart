import 'package:rate_review/model/post/transaction.dart';
import '../../util/common.dart';


class PostData {
  String? postid;
  String? postTitle;
  String? postDesc;
  String? postTerms;
  String? photoName;
  String? postUrl;
  String? noSpots;
  String? isManually;
  String? startDate;
  String? endDate;
  String? transId;
  String? availableSpots;
  String? post_brief;
  String? transDate;

  // TODO 14/03/2022
  String? brand_id;
  String? isFollowed;
  String? brand_photo_name;
  String? brand_name;

  // TODO 15/04/2022
  String? step1_title;
  String? step1_desc;
  String? step2_title;
  String? step2_desc;
  String? step3_title;
  String? step3_desc;
  String? step4_title;
  String? step4_desc;

  List<Transaction>? transaction;

  PostData({
    this.postid,
    this.postTitle,
    this.postDesc,
    this.postTerms,
    this.photoName,
    this.postUrl,
    this.noSpots,
    this.isManually,
    this.startDate,
    this.endDate,
    this.post_brief,
    this.transaction,
    // TODO 14/03/2022
    this.brand_id,
    this.isFollowed,
    this.brand_photo_name,
    this.brand_name,
    // TODO 15/04/2022
    this.step1_title,
    this.step1_desc,
    this.step2_title,
    this.step2_desc,
    this.step3_title,
    this.step3_desc,
    this.step4_title,
    this.step4_desc,
  });

  PostData.fromJson(Map<String, dynamic> json) {
    // TODO 31/05/2022 add this
    postid = json['postid'];
    postTitle = AppUtil.langcode == AppLanguages.en.name ? json['post_title'] : json['post_title_ar'];
    postDesc = AppUtil.langcode == AppLanguages.en.name ? json['post_desc'] : json['post_desc_ar'];
    postTerms = AppUtil.langcode == AppLanguages.en.name ? json['post_terms'] : json['post_terms_ar'];
    photoName = json['photo_name'];
    postUrl = json['post_url'];
    noSpots = json['no_spots'];
    isManually = json['is_manually'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    transId = json['trans_id'];
    availableSpots = json['availableSpots'];
    post_brief = AppUtil.langcode == AppLanguages.en.name ? json['post_brief'] : json['post_brief_ar'];
    transDate = json['trans_date'];
    // TODO 14/03/2022
    brand_id = json['brand_id'];
    isFollowed = json['isFollowed'];
    brand_photo_name = json['brand_photo_name'];
    brand_name = json['brand_name'];
    // TODO 15/04/2022
    step1_title = AppUtil.langcode == AppLanguages.en.name ? json['step1_title'] : json['step1_title_ar'];
    step1_desc = AppUtil.langcode == AppLanguages.en.name ? json['step1_desc'] : json['step1_desc_ar'];
    step2_title = AppUtil.langcode == AppLanguages.en.name ? json['step2_title'] : json['step2_title_ar'];
    step2_desc = AppUtil.langcode == AppLanguages.en.name ? json['step2_desc'] : json['step2_desc_ar'];
    step3_title = AppUtil.langcode == AppLanguages.en.name ? json['step3_title'] : json['step3_title_ar'];
    step3_desc = AppUtil.langcode == AppLanguages.en.name ? json['step3_desc'] : json['step3_desc_ar'];
    step4_title = AppUtil.langcode == AppLanguages.en.name ? json['step4_title'] : json['step4_title_ar'];
    step4_desc = AppUtil.langcode == AppLanguages.en.name ? json['step4_desc'] : json['step4_desc_ar'];

    if (json['transaction'] != null) {
      transaction = <Transaction>[];
      json['transaction'].forEach((v) {
        transaction!.add(Transaction.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['postid'] = postid;
    data['post_title'] = postTitle;
    data['post_desc'] = postDesc;
    data['post_terms'] = postTerms;
    data['photo_name'] = photoName;
    data['post_url'] = postUrl;
    data['no_spots'] = noSpots;
    data['is_manually'] = isManually;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['trans_id'] = transId;
    data['availableSpots'] = availableSpots;
    data['post_brief'] = post_brief;
    data['trans_date'] = transDate;
    // TODO 14/03/2022
    data['brand_id'] = brand_id;
    data['isFollowed'] = isFollowed;
    data['brand_photo_name'] = brand_photo_name;
    data['brand_name'] = brand_name;
    // TODO 15/04/2022
    data['step1_title'] = step1_title;
    data['step1_desc'] = step1_desc;
    data['step2_title'] = step2_title;
    data['step2_desc'] = step2_desc;
    data['step3_title'] = step3_title;
    data['step3_desc'] = step3_desc;
    data['step4_title'] = step4_title;
    data['step4_desc'] = step4_desc;

    if (transaction != null) {
      data['transaction'] = transaction!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostData &&
          runtimeType == other.runtimeType &&
          postid == other.postid;

  @override
  int get hashCode => postid.hashCode;

}
