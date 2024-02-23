import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/post_controller.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/post/all_post_response.dart';
import 'package:rate_review/model/post/post_data.dart';
import 'package:rate_review/model/post/transaction.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/screen/post_detail_screen.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({Key? key}) : super(key: key);

  @override
  MailScreenState createState() => MailScreenState();
}

class MailScreenState extends State<MailScreen> with AutomaticKeepAliveClientMixin {
  UserDefault userDefault = Get.find();
  final AuthModel _authModel = Get.find();
  User? _user;
  final GlobalKey<State> _globalKey = GlobalKey<State>();

  // List<PostData>? allMail;

  final PostController postController = Get.find();

  bool allDataLoaded = false;

  @override
  bool get wantKeepAlive => true;
  String? languageCode;
  int pageCount = 0;

  // bool isPageLoading = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userDefault.getUser().then((value) {
        _user = value!;
        // getLangCode();
        generateMail(context);
      });
    });
    super.initState();
  }

  Future<void> generateMail(BuildContext? buildContext) async {
    Map<String, dynamic> getAllMailListRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail,
      RequestParam.kPageCount: pageCount,
      // "lang_code": languageCode
    };

    log('generatePost $getAllMailListRequestJson');
    AllPostResponse? result = await _authModel.getUserInterestedPostList(
        context: buildContext,
        keyLoader: _globalKey,
        getAllMailListRequestJson: getAllMailListRequestJson,
        apiName: ServiceUrl.kGetUserInterestedPostList);
    // allMail ??= [];
    postController.mailLoadState.value = 1;
    if (pageCount == 0) {
      // allMail = [];
      postController.clearMail();
    }
    // isPageLoading = false;
    postController.isPageLoading = false;
    if (result.data == null) {
      allDataLoaded = true;
    }
    if (result.data != null) {
      // allMail!.addAll(result.data!);
      postController.allMail.clear();
      postController.addMails(result.data!);
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    super.build(buildContext);
    return Material(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            //TODO 16/03/2022 remove from here to put dashboard screen
/*            ...AppToolbar(buildContext,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Image(
                          image: ImageRes.menuImg, height: 25, width: 25)),
                  Expanded(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text('mail'.tr.toUpperCase(),
                              style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontFamily: narrowmedium,
                                  fontSize: 20,
                                  letterSpacing: 4.0)))),
                  IconButton(
                      onPressed: () {},
                      icon: Image(
                          image: ImageRes.filterOutlinedImg,
                          height: 25,
                          width: 25)),
                ],
                showStatusBar: true),*/
            Expanded(
              child: Obx(() => RefreshIndicator(
                    onRefresh: () => Future.sync(
                      () {
                        onRefresh(context);
                      },
                    ),
                    child: postController.mailLoadState.value == 0
                        ? SingleChildScrollView(
                            child: Container(
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height - 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: const [CupertinoActivityIndicator(animating: true)],
                              ),
                            ),
                          )
                        : postController.allMail.isEmpty
                            ? ListView(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height - 100,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          resource.mailNotFound.tr,
                                          style: const TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.only(left: 15, right: 15),
                                child: ListView.builder(
                                    // padding: EdgeInsets.zero,
                                    controller: _scrollController,
                                    itemCount: postController.allMail.length,
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext context, int index) {
                                      var mailData = postController.allMail.elementAt(index);
                                      return InkWell(
                                        onTap: () async {
                                          PostData? postData = await Get.to(() => PostDetailScreen(
                                                data: postController.allMail[index],
                                                isFromPost: false,
                                              ));

                                          if (postData == null) {
                                            return;
                                          }
                                          postController.allMail[index] = postData;
                                        },
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                          margin: const EdgeInsets.only(bottom: 35),
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                                      child: Image.network(
                                                        mailData.photoName.toString(),
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Image(
                                                            image: ImageRes.noImageFound,
                                                          );
                                                        },
                                                        loadingBuilder: (context, child, loadingProgress) {
                                                          if (loadingProgress == null) {
                                                            return child;
                                                          }
                                                          return const SizedBox(
                                                              width: 25,
                                                              height: 50,
                                                              child: Center(child: CupertinoActivityIndicator()));
                                                        },
                                                        fit: BoxFit.fill,
                                                        height: size(context).height * 0.09,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(mailData.postTitle.toString().trim(),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    height: 1.2,
                                                                    color: lablecolor,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontFamily: narrowbook,
                                                                    fontSize: 22)),
                                                            if (mailData.transDate != null) ...[
                                                              Row(
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 10),
                                                                    child: Text(resource.deadline.tr,
                                                                        style: TextStyle(
                                                                            fontFamily: narrowbook,
                                                                            height: 1.2,
                                                                            color: desclablecolor,
                                                                            fontSize: 20)),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(top: 10),
                                                                    child: Text(' : ${mailData.endDate!.toDate.formatDate}',
                                                                        style: TextStyle(
                                                                            fontFamily: narrowbook,
                                                                            height: 1.2,
                                                                            color: desclablecolor,
                                                                            fontSize: 20)),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                  thickness: 1,
                                                  endIndent: 15.0,
                                                  indent: 15.0,
                                                  color: dividerColor,
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Theme(
                                                          data: Theme.of(context).copyWith(
                                                            unselectedWidgetColor: primaryColor,
                                                          ),
                                                          child: Checkbox(
                                                            checkColor: Colors.white,
                                                            value: false,
                                                            shape: const CircleBorder(),
                                                            onChanged: (_) {},
                                                          ),
                                                        ),
                                                        Text(resource.eligible.tr,
                                                            style: TextStyle(
                                                                color: lablecolor,
                                                                fontWeight: FontWeight.w600,
                                                                fontFamily: narrowbook,
                                                                fontSize: 18)),
                                                        Expanded(
                                                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                                              child: getIcon(mailData.transaction!.elementAt(0)),
                                                            )
                                                          ]),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Theme(
                                                          data: Theme.of(context).copyWith(
                                                            unselectedWidgetColor: primaryColor,
                                                          ),
                                                          child: Checkbox(
                                                            checkColor: Colors.white,
                                                            value: false,
                                                            shape: const CircleBorder(),
                                                            onChanged: (_) {},
                                                          ),
                                                        ),
                                                        Text(resource.purchaseReceipt.tr,
                                                            style: TextStyle(
                                                                color: lablecolor,
                                                                fontWeight: FontWeight.w600,
                                                                fontFamily: narrowbook,
                                                                fontSize: 18)),
                                                        Expanded(
                                                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                                              child: getIcon(mailData.transaction!.elementAt(1)),
                                                            )
                                                          ]),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Theme(
                                                          data: Theme.of(context).copyWith(
                                                            unselectedWidgetColor: primaryColor,
                                                          ),
                                                          child: Checkbox(
                                                            checkColor: Colors.white,
                                                            value: false,
                                                            shape: const CircleBorder(),
                                                            onChanged: (bool? value) {},
                                                          ),
                                                        ),
                                                        Text(resource.productReview.tr,
                                                            style: TextStyle(
                                                                color: lablecolor,
                                                                fontWeight: FontWeight.w600,
                                                                fontFamily: narrowbook,
                                                                fontSize: 18)),
                                                        Expanded(
                                                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                                              child: getIcon(mailData.transaction!.elementAt(2)),
                                                            )
                                                          ]),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Theme(
                                                          data: Theme.of(context).copyWith(
                                                            unselectedWidgetColor: primaryColor,
                                                          ),
                                                          child: Checkbox(
                                                            checkColor: Colors.white,
                                                            value: false,
                                                            shape: const CircleBorder(),
                                                            onChanged: (_) {},
                                                          ),
                                                        ),
                                                        Text(resource.postVerified.tr,
                                                            style: TextStyle(
                                                                color: lablecolor,
                                                                fontWeight: FontWeight.w600,
                                                                fontFamily: narrowbook,
                                                                fontSize: 18)),
                                                        Expanded(
                                                          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 15),
                                                              child: getIcon(mailData.transaction!.elementAt(3)),
                                                            )
                                                          ]),
                                                        ),
                                                      ],
                                                    ),
                                                    const Divider(
                                                      thickness: 1,
                                                      endIndent: 15.0,
                                                      indent: 15.0,
                                                      color: dividerColor,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                                                          child: Text(resource.spotAmount.tr,
                                                              style: TextStyle(
                                                                  color: lablecolor,
                                                                  fontWeight: FontWeight.w600,
                                                                  fontFamily: narrowbook,
                                                                  fontSize: 18)),
                                                        ),
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                            children: [
                                                              Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                                                child: FutureBuilder(
                                                                    future: postController.getCurrencyText(mailData.transaction!.last.paymentAmt) ??
                                                                        postController.getCurrencyText('0'),
                                                                    builder:
                                                                        (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                                      if(!snapshot.hasData){
                                                                        return const CircularProgressIndicator();
                                                                      }
                                                                      if (snapshot.hasData) {
                                                                        return Text(snapshot.data,
                                                                            style: TextStyle(
                                                                                color: lablecolor,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontFamily: narrowbook,
                                                                                fontSize: 18));
                                                                      } else {
                                                                        return Text('0',
                                                                            style: TextStyle(
                                                                                color: lablecolor,
                                                                                fontWeight: FontWeight.w600,
                                                                                fontFamily: narrowbook,
                                                                                fontSize: 18));
                                                                      }
                                                                    }),
                                                                // Text(
                                                                //     "${AppUtil.getCurrencyText(mailData.transaction!.last.paymentAmt!) ?? 0}",
                                                                //     style: TextStyle(
                                                                //         color:
                                                                //             lablecolor,
                                                                //         fontWeight:
                                                                //             FontWeight
                                                                //                 .w600,
                                                                //         fontFamily:
                                                                //             narrowbook,
                                                                //         fontSize:
                                                                //             18)),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                      );
                                    }),
                              ),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget getIcon(Transaction transaction) {
    // pendingSVG
    // verifiedSVG
    // unverifiedSVG
    if (transaction.isApproved == null) {
      return SvgPicture.asset(
        ImageRes.unverifiedSVG,
        height: 20,
      );
    } else if (transaction.isApproved == '0') {
      return SvgPicture.asset(
        ImageRes.unverifiedSVG,
        height: 20,
      );
    } else if (transaction.isApproved == '1') {
      return SvgPicture.asset(
        ImageRes.verifiedSVG,
        height: 20,
      );
    }
    return Container();
  }

  _scrollListener() async {
    ScrollDirection scrollDirection = _scrollController.position.userScrollDirection;
    if (_scrollController.position.pixels >= (_scrollController.position.maxScrollExtent - 50) &&
        postController.isPageLoading == false &&
        scrollDirection == ScrollDirection.reverse &&
        !allDataLoaded) {
      //isPageLoading = true;
      // postController.isPageLoading = true;
      // pageCount++;
      // fetchPage(context, pageCount);
    }
  }

  Future<void> fetchPage(BuildContext? context, int pageKe) async {
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
          log('Hey something went wrong with SnackBar$e');
        }
      }
      await generateMail(context);
      if (context != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (error) {
      if (context != null) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  void onRefresh(BuildContext context) async {
    pageCount = 0;
    allDataLoaded = false;
    postController.isPageLoading = true;
    //  await getLangCode();
    await generateMail(context);
  }

/*  Future<void> getLangCode() async {
    await userDefault.getLanguageCode().then((value) {
      languageCode = value;
    });
  }*/
}
