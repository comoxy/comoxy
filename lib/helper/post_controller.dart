import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rate_review/helper/userdefault.dart';

import 'package:rate_review/model/payment/payment_detail.dart';
import 'package:rate_review/model/post/post_data.dart';
import 'package:rate_review/model/post/transaction.dart';
import 'package:rate_review/util/common.dart';

class PostController extends GetxController{

  // post screen
  RxInt postLoadState = 0.obs;
  var allPost = <PostData>[].obs;
  bool isPageLoading = false;

  // mail screen
  RxInt mailLoadState = 0.obs;
  var allMail = <PostData>[].obs;
  bool isMailLoading = false;

  // wallet screen
  RxInt paymentLoadState = 0.obs;
  var allPayment = <PaymentDetail>[].obs;
  bool isPaymentLoading = false;
  RxString totalAmount = '0'.obs;
  RxString paymentAmount = '0'.obs;
  String? isApprove;

  String getTotalAmount() {
    return paymentAmount.value;
  }

  void setTotalAmount(String totalAmt) {
    paymentAmount.value = totalAmt;
    update();
  }

  void clearPost() {
    allPost.clear();
    update();
  }

  void addPosts(List<PostData> postList) {
    allPost.addAll(postList);

    // allPost.add(postList.first);
    // allPost.add(postList.elementAt(1));
    update();
  }

  void clearMail() {
    allMail.clear();
    update();
  }

  void addMails(List<PostData> mailList) {
    allMail.addAll(mailList);
    update();
  }

  void modifyPostData(PostData postData, bool isForPost) {
    if (allPost.isEmpty || allMail.isEmpty) {
      return;
    }
    if (isForPost) {
      var postInd = allPost.indexWhere((element) => postData.postid == element.postid);
      if (postInd != -1) {
        allPost[postInd]=postData;
        var mailInd = allMail.indexWhere((element) => postData.postid == element.postid);
        if (mailInd != -1) {
          allMail[mailInd] =  postData;
          update();
        }
      }
    }
    else {
      var postInd = allMail.indexWhere((element) => postData.postid == element.postid);
      if (postInd != -1) {
        allMail[postInd] =  postData;
        var mailInd = allPost.indexWhere((element) => postData.postid == element.postid);
        if (mailInd != -1) {
          allPost[mailInd] = postData;
          update();
        }
      }
    }
  }

  void changeIsApprove(value){
    isApprove = value;
    update();
  }

  ///TODO Phase2
  Future<String?> getCurrencyText(String? currency)  async {
    String? curr;
    await UserDefault().getUser().then((value) {
      int index = AppUtil.Currencydata.indexWhere((element) => element.currency == value!.currency);
      if (index != -1) {
        curr = '${AppUtil.Currencydata[index].currencySymbol}' + ' $currency';
      }
    });
    update();
    return curr;
  }

  ///TODO  Phase2

  removeNotInterestedPostFromList(String id) {
    int index = allPost.indexWhere((element) => element.postid == id);
    if (index != -1) {
      allPost.removeAt(index);
    }
    update();
  }

  ///TODO Phase 2
  void removePostFromList(PostData postData, bool isForPost) {
    var postInd = allPost.indexWhere((element) => postData.postid == element.postid);
    if (allPost.isEmpty || allMail.isEmpty) {
      return;
    }
    if (isForPost) {
      var postInd = allPost.indexWhere((element) => postData.postid == element.postid);

      if (postInd != -1) {
        //allPost.removeAt(postInd);
        var mailInd = allPost.indexWhere((element) => postData.postid == element.postid);
        if (mailInd != -1) {
          allMail.removeWhere((element) => postData.postid == element.postid);
          if(!isForPost)
          {
            allPost.removeWhere((element) => postData.postid == element.postid);
            // allMail[mailInd] =  postData;
            update();
          }
        }
      }
    }
    else {
      var postInd = allMail.indexWhere((element) => postData.postid == element.postid);
      if (postInd != -1) {
        var mailInd = allMail.indexWhere((element) => postData.postid == element.postid);
        if (mailInd != -1) {
          allMail.removeWhere((element) => postData.postid == element.postid);
          // allPost[postInd] = postData;
          update();
        }
      }
    }
    allPost[postInd].transaction![0].isApproved = null;
    update();
  }

  void deletePostData(PostData postData, bool isForPost) {
    if (allPost.isEmpty || allMail.isEmpty) {
      return;
    }
    if (isForPost) {
      var postInd = allPost.indexWhere((element) => postData.postid == element.postid);

      if (postInd != -1) {
      //allPost.removeAt(postInd);
        var mailInd = allPost.indexWhere((element) => postData.postid == element.postid);
        if (mailInd != -1) {
          allMail[mailInd] =  postData;
          update();
        }
      }
    }
    else {
      var postInd = allMail.indexWhere((element) => postData.postid == element.postid);
      if (postInd != -1) {
        var mailInd = allMail.indexWhere((element) => postData.postid == element.postid);
        if (mailInd != -1) {
          allPost[postInd] = postData;
          update();
        }
      }
    }
  }

  void onlyModifyPostData(PostData postData) {
    if (allPost.isEmpty) {
      return;
    }
    var postInd = allPost.indexWhere((element) => postData.postid == element.postid);
    if (postInd != -1) {
      allPost[postInd] = postData;
      update();
    }
  }

  void addPostData(PostData postData) {
    var postInd = allMail.indexWhere((element) => postData.postid == element.postid);
    var postInd1 = allPost.indexWhere((element) => postData.postid == element.postid);
    if (postInd1 != -1) {
      allPost[postInd1] =  postData;
    }
    if (postInd != -1) {
      allMail[postInd] =  postData;
    }else{
      allMail.insert(0, postData);
    }

    update();
  }

  void resetMailData(PostData postData, bool isFromPost,String doctype) {
    for (int i = 0; i < postData.transaction!.length; i++) {
      if(postData.transaction!.elementAt(i).docType==doctype) {
        postData.transaction!.elementAt(i).createdDate = null;
        postData.transaction!.elementAt(i).docPhoto = null;
        postData.transaction!.elementAt(i).isApproved = '0';
        postData.transaction!.elementAt(i).paymentAmt = '0';
      }
    }
    modifyPostData(postData, isFromPost);
  }

  void clearPayment() {
    allPayment.clear();
    update();
  }

  void addPayments(List<PaymentDetail> paymentList) {
    allPayment.addAll(paymentList);
    update();
  }

  String getBalance() {
    return totalAmount.value;
  }

  void setBalance(String totalAmt) {
    totalAmount.value = totalAmt;
    update();
  }

  double getPaymentTotal(){
    try{
      return ( double.parse(paymentAmount.value)) +( double.parse(totalAmount.value));
    }catch(e){
      return 0;
    }

  }

}