import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/post_controller.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/payment/payment_detail.dart';
import 'package:rate_review/model/payment/payment_history.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with AutomaticKeepAliveClientMixin {
  final PostController postController = Get.find();
  final AuthModel _authProvider = Get.find();
  final UserDefault userDefault = Get.find();
  final GlobalKey<State> _globalKey = GlobalKey<State>();
  int pageCount = 0;
  late ScrollController _scrollController;
  late User _user;

  bool allDataLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      userDefault.getUser().then((value) {
        _user = value!;
        if (mounted) {
          setState(() {});
        }
        getUserWalletHistory(context);
        generatePaymentHistory(context);
      });
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    return Material(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            //TODO 16/03/2022 remove from here to put dashboard screen
/*            ... AppToolbar(buildContext,
                children: [
                  Expanded(child: Align( alignment: Alignment.center,child: Text('wallet'.tr.toUpperCase(),
                    style: TextStyle(
                        color: CupertinoColors.white,
                        fontFamily: narrowmedium,
                        fontSize: 20,
                        letterSpacing: 4.0)))),

                ],
                showStatusBar: true),*/
            Expanded(
              child: Column(
                children: [
                  //TODO 15/04/2022 Replace Two Container
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
                    child: Card(
                      color: Colors.orangeAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            children: [
                              //TODO 25.03.2022 change to Your total earnings till date
                              Text(resource.totalBalanceTitle.tr,
                                  style: normalTextStyle.copyWith(
                                    fontSize: 25,
                                    color: lablecolor,
                                    fontFamily: narrowbook,
                                  )),
                              GetBuilder<PostController>(
                                builder: (postController) {
                                  return Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: FutureBuilder(  ///TODO Phase2
                                            future: postController.getCurrencyText((double.parse(postController.getTotalAmount()).toStringAsFixed(2))),
                                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                              if(!snapshot.hasData){
                                                return const CircularProgressIndicator();
                                              }
                                              if (snapshot.hasData) {
                                                return Text(snapshot.data,
                                                    style: normalTextStyle.copyWith(
                                                      fontSize: 20,
                                                      color: lablecolor,
                                                      fontFamily: narrowbold,
                                                    ));
                                              } else {
                                                return Text('0',
                                                    style: normalTextStyle.copyWith(
                                                      fontSize: 20,
                                                      color: lablecolor,
                                                      fontFamily: narrowbold,
                                                    ));
                                              }
                                            }),
                                        //
                                        // Text(
                                        //   '\$${double.parse(postController.getTotalAmount()).toStringAsFixed(2)}',
                                        //   style: normalTextStyle.copyWith(
                                        //     fontSize: 20,
                                        //     color: lablecolor,
                                        //     fontFamily: narrowbold,
                                        //   ),
                                        // ),
                                      );
                                }
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                    child: Card(
                      color: CupertinoColors.systemGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Column(
                            children: [
                              //TODO 25.03.2022 change to Your total earnings till date
                              Text(resource.totalPendingBalanceTitle.tr,
                                  style: normalTextStyle.copyWith(
                                    fontSize: 25,
                                    color: lablecolor,
                                    fontFamily: narrowbook,
                                  )),
                              GetBuilder<PostController>(
                                builder: (postController) {
                                  return Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: FutureBuilder(  ///TODO Phase2
                                            future: postController.getCurrencyText(
                                                    double.parse(postController.getBalance()).toStringAsFixed(2)),
                                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                              if(!snapshot.hasData){
                                                return const CircularProgressIndicator();
                                              }
                                              if (snapshot.hasData) {
                                                return Text(snapshot.data,
                                                    style: normalTextStyle.copyWith(
                                                      fontSize: 20,
                                                      color: lablecolor,
                                                      fontFamily: narrowbold,
                                                    ));
                                              } else {
                                                return Text(snapshot.data,
                                                    style: normalTextStyle.copyWith(
                                                      fontSize: 20,
                                                      color: lablecolor,
                                                      fontFamily: narrowbold,
                                                    ));
                                              }
                                            }),

                                        // Text(
                                        //   '\$${double.parse(postController.getBalance()).toStringAsFixed(2)}',
                                        //   style: normalTextStyle.copyWith(
                                        //     fontSize: 20,
                                        //     color: lablecolor,
                                        //     fontFamily: narrowbold,
                                        //   ),
                                        // ),
                                      );
                                }
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() => RefreshIndicator(
                          onRefresh: () => Future.sync(
                            () {
                              onRefresh(buildContext);
                            },
                          ),
                          child: postController.paymentLoadState.value == 0
                              ? SingleChildScrollView(
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [CupertinoActivityIndicator(animating: true)],
                                    ),
                                  ),
                                )
                              : postController.allPayment.isEmpty
                                  ? SingleChildScrollView(
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: size(buildContext).height * .72,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              resource.historyNotFound.tr,
                                              style: const TextStyle(
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      height: size(buildContext).height * .72,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                  child: Text(resource.paymentHistory.tr,
                                                      style: TextStyle(
                                                          fontFamily: narrowbook,
                                                          //TODO 15/04/2022
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 24,
                                                          color: desclablecolor)),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                                  child: Text(
                                                    '',
                                                    style: TextStyle(fontFamily: narrowbook, fontSize: 20, color: desclablecolor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(bottom: 100),
                                              child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  controller: _scrollController,
                                                  shrinkWrap: true,
                                                  physics: const AlwaysScrollableScrollPhysics(),
                                                  itemCount: postController.allPayment.length,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    PaymentDetail paymentData = postController.allPayment.elementAt(index);
                                                    return Card(
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(0),
                                                      ),
                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  Container(
                                                                    padding:
                                                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                                                    child: Text(
                                                                      paymentData.paymentDate!.toDate.formatDate,
                                                                      style: TextStyle(
                                                                          fontFamily: narrowbook,
                                                                          fontSize: normalFontSize,
                                                                          color: lablecolor),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              padding: const EdgeInsets.all(5),
                                                              child: Text(
                                                                '\$${double.parse(paymentData.paymentAmount.toString()).toStringAsFixed(2)}',
                                                                style: TextStyle(
                                                                    fontFamily: narrowbook, fontSize: 24, color: lablecolor),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _scrollListener() async {
    ScrollDirection scrollDirection = _scrollController.position.userScrollDirection;
    if (_scrollController.position.pixels >= (_scrollController.position.maxScrollExtent - 50) &&
        postController.isPaymentLoading == false &&
        scrollDirection == ScrollDirection.reverse &&
        !allDataLoaded) {
      postController.isPaymentLoading = true;
      pageCount++;
      fetchPage(context, pageCount);
    }
  }

  Future<void> fetchPage(BuildContext? context, int pageCount) async {
    try {
      if (pageCount > 0) {
        try {
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.transparent,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        )),
                  ],
                )));
          }
        } catch (e) {
          log('Hey something went wrong with SnackBar $e');
        }
      }
      await generatePaymentHistory(context);
      if (context != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (error) {
      if (context != null) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  void onRefresh(BuildContext context) {
    pageCount = 0;
    allDataLoaded = false;
    postController.isPageLoading = true;
    getUserWalletHistory(context);
    generatePaymentHistory(context);
  }

  void getUserWalletHistory(BuildContext context) {
    Map<String, dynamic> getUserWalletHistoryRequestJson = {RequestParam.kUserEmail: _user.userEmail.toString().trim()};
    _authProvider
        .getUserWalletHistory(
            context: context,
            keyLoader: _globalKey,
            apiName: ServiceUrl.kGetUserWalletHistory,
            getUserWalletHistoryRequestJson: getUserWalletHistoryRequestJson)
        .then((value) {
      if (value == null && value!.data!.isEmpty) {
        return;
      }
      //TODO 15/04/2022
      postController.setBalance(value.data!.first.pendingAmount);
      postController.setTotalAmount(value.data!.first.paymentAmount);
    });
  }

  Future<void> generatePaymentHistory(BuildContext? buildContext) async {
    Map<String, dynamic> getPaymentHistoryListRequestJson = {
      RequestParam.kUserEmail: _user.userEmail,
      RequestParam.kPageCount: pageCount
    };

    PaymentHistory? result = await _authProvider.getPaymentHistory(
        context: buildContext,
        keyLoader: _globalKey,
        getPaymentHistoryListRequestJson: getPaymentHistoryListRequestJson,
        apiName: ServiceUrl.kGetAllPaymentHistoryList);
    postController.paymentLoadState.value = 1;
    if (pageCount == 0) {
      postController.clearPayment();
    }
    postController.isPaymentLoading = false;

    if (result.responseCode == 1020) {
      allDataLoaded = true;
    }
    if (result.data != null) {
      postController.addPayments(result.data!);
    }
  }
}
