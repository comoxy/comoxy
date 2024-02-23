import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/post_controller.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/post/all_post_response.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/screen/personal_detail_screen.dart';
import 'package:rate_review/ui/screen/post_detail_screen.dart';
import 'package:rate_review/ui/screen/required_detail_screen.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';

import '../../main.dart';
import 'dashboard_screen.dart';

class PostScreen extends StatefulWidget {
  Function(int)? onback;
  PostScreen({Key? key, this.onback}) : super(key: key);

  @override
  PostScreenState createState() => PostScreenState();
}

late User _user;
final AuthModel authModel = Get.find();
final PostController postController = Get.find();
final GlobalKey<State> _globalKey = GlobalKey<State>();
bool allDataLoaded = false;
int pageCount = 0;
String? dob;
String? gender;
String? ethnicity;
String? homeCountry;
String? currency;

class PostScreenState extends State<PostScreen> with AutomaticKeepAliveClientMixin {
  UserDefault userDefault = Get.find();

  @override
  bool get wantKeepAlive => true;

  late ScrollController scrollController;

  static Future<void> filterPost(BuildContext? buildContext, String Brandid, String Categoryid, String Sorttitle) async {
    pageCount = 0;
    Map<String, dynamic> getAllPostListRequestJson = {
      RequestParam.kUserEmail: _user.userEmail,
      "page_count": pageCount,
      "sort_by": Sorttitle,
      "brand_id": Brandid,
      "category_id": Categoryid,
    };

    AllPostResponse result = await authModel.getAllPostList(
        context: buildContext,
        keyLoader: _globalKey,
        getAllPostListRequestJson: getAllPostListRequestJson,
        apiName: ServiceUrl.kGetAllPostList);
    postController.postLoadState.value = 1;
    if (pageCount == 0) {
      postController.clearPost();
    }
    if (result.data == null) {
      allDataLoaded = true;
    }
    postController.isPageLoading = false;
    if (result.data != null) {
      postController.addPosts(result.data!);
    }
  }

  static Future<void> sortPost(BuildContext? buildContext, String Sorttitle, String Brandid, String Categoryid) async {
    pageCount = 0;
    Map<String, dynamic> getAllPostListRequestJson = {
      RequestParam.kUserEmail: _user.userEmail,
      "page_count": pageCount,
      "sort_by": Sorttitle,
      "brand_id": Brandid,
      "category_id": Categoryid,
    };

    AllPostResponse result = await authModel.getAllPostList(
        context: buildContext,
        keyLoader: _globalKey,
        getAllPostListRequestJson: getAllPostListRequestJson,
        apiName: ServiceUrl.kGetAllPostList);
    postController.postLoadState.value = 1;
    if (pageCount == 0) {
      postController.clearPost();
    }
    if (result.data == null) {
      allDataLoaded = true;
    }
    postController.isPageLoading = false;
    if (result.data != null) {
      postController.addPosts(result.data!);
    }
    Navigator.pop(buildContext!);
  }

  @override
  void initState() {
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      userDefault.getUser().then((value) {
        _user = value!;

        generatePost(context);
        getUserProfile(context);
        setState(() {});
      });
    });
    super.initState();
  }

  Future<void> generatePost(BuildContext? buildContext) async {
    await getLangCode();
    Map<String, dynamic> getAllPostListRequestJson = {
      RequestParam.kUserEmail: _user.userEmail,
      RequestParam.kPageCount: pageCount,
      "lang_code": languageCode
    };

    AllPostResponse result = await authModel.getAllPostList(
        context: null,
        keyLoader: _globalKey,
        getAllPostListRequestJson: getAllPostListRequestJson,
        apiName: ServiceUrl.kGetAllPostList);
    postController.postLoadState.value = 1;
    if (pageCount == 0) {
      postController.clearPost();
    }
    if (result.data == null) {
      allDataLoaded = true;
    }
    postController.isPageLoading = false;
    if (result.data != null) {
      postController.addPosts(result.data!);
    }
  }

  Future<void> getUserProfile(BuildContext? buildContext) async {
    Map<String, dynamic> getUserProfileRequestJson = {
      RequestParam.kUserEmail: _user.userEmail,
    };

    User result = await authModel.userProfile(
        context: null,
        keyLoader: _globalKey,
        getUserProfileRequestJson: getUserProfileRequestJson,
        apiName: ServiceUrl.kGetUserProfile);

    if (result != null) {
      dob = result.dateOfBirth;
      gender = result.gender;
      ethnicity = result.ethnicity;
      homeCountry = result.homeCountry;
      currency = result.currency;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Material(
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            //TODO 16/03/2022 remove from here to put dashboard screen
/*            ...AppToolbar(context,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Image(
                          image: ImageRes.menuImg, height: 25, width: 25)),
                  Expanded(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            'MISSIONS'.tr.toUpperCase(),
                            style: headerStyle,
                          ))),
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
                        // child:  allPost == null
                        child: postController.postLoadState.value == 0
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
                            : postController.allPost.isEmpty
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
                                              resource.postNotFound.tr,
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
                                    child: SizedBox(
                                      child: ListView.builder(
                                          //padding: EdgeInsets.zero,
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemCount: postController.allPost.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            var postData = postController.allPost.elementAt(index);
                                            return Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(0),
                                              ),
                                              elevation: 2,
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              margin: const EdgeInsets.only(bottom: 35),
                                              child: Stack(
                                                children: [
                                                  Positioned(
                                                    child: Padding(
                                                      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
                                                      child: SizedBox(
                                                        height: size(context).height * 0.35,
                                                        child: Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () async {
                                                              var postData = await Get.to(() => PostDetailScreen(
                                                                  data: postController.allPost.elementAt(index),
                                                                  isFromPost: true));

                                                              if (postData == null) {
                                                                return;
                                                              }
                                                              if (postData is int) {
                                                                widget.onback!(postData);
                                                              } else {
                                                                postController.allPost[index] = postData;
                                                              }
                                                            },
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Expanded(
                                                                  child: Center(
                                                                    child: Container(
                                                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                      decoration: const BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.vertical(top: Radius.circular(5))),
                                                                      child: Image.network(
                                                                        postData.photoName.toString(),
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
                                                                              width: 50,
                                                                              height: 50,
                                                                              child: Center(child: CupertinoActivityIndicator()));
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Divider(
                                                                  thickness: 0.5,
                                                                  endIndent: 15.0,
                                                                  indent: 15.0,
                                                                  color: dividerColor,
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(
                                                                      top: 5, bottom: 10, right: 5, left: 5),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Container(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 10, right: 10, bottom: 0),
                                                                          child: Text(postData.postTitle.toString().trim(),
                                                                              maxLines: 2,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(
                                                                                  height: 1.2,
                                                                                  color: lablecolor,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  fontFamily: narrowbook,
                                                                                  fontSize: 22))),
                                                                      Container(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 10, right: 10, bottom: 8),
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              //TODO 30/03/2022
                                                                              padding: const EdgeInsets.only(top: 13),
                                                                              child: Image(
                                                                                  image: ImageRes.discontImg,
                                                                                  height: 20,
                                                                                  width: 20),
                                                                            ),
                                                                            Expanded(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(
                                                                                    top: 10, right: 5, left: 5),
                                                                                child: Text(
                                                                                  postData.post_brief.toString().trim(),
                                                                                  maxLines: 3,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: TextStyle(
                                                                                      fontFamily: narrowbook,
                                                                                      height: 1.2,
                                                                                      color: desclablecolor,
                                                                                      fontSize: 22),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                      left: 0,
                                                      top: 0,
                                                      child: Container(
                                                        // margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                                        decoration: const BoxDecoration(
                                                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10)),
                                                          gradient: LinearGradient(
                                                            begin: Alignment.centerLeft,
                                                            end: Alignment.centerRight,
                                                            colors: [
                                                              orangeColor,
                                                              orangeColor,
                                                            ],
                                                          ),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                        // margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            //TODO 16/03/2022 change available spots to Products left
                                                            Text(
                                                              resource.productsLeft.tr,
                                                              style: TextStyle(
                                                                  fontFamily: narrowbook,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: CupertinoColors.white),
                                                            ),
                                                            Text(
                                                              ' ${postData.availableSpots}',
                                                              style: TextStyle(
                                                                  fontFamily: narrowbook,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: CupertinoColors.white),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                  Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: Container(
                                                        // margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                        // margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              resource.deadline.tr,
                                                              style: TextStyle(
                                                                  fontFamily: narrowbook,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: lablecolor),
                                                            ),
                                                            Text(
                                                              postData.endDate!.toDate.formatDate,
                                                              style: TextStyle(
                                                                  fontFamily: narrowbook,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: lablecolor),
                                                            ),
                                                          ],
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                      )),
            ),
          ],
        ),
      ),
    );
  }

  scrollListener() async {
    ScrollDirection scrollDirection = scrollController.position.userScrollDirection;
    if (scrollController.position.pixels >= (scrollController.position.maxScrollExtent - 50) &&
        postController.isPageLoading == false &&
        scrollDirection == ScrollDirection.reverse &&
        !allDataLoaded) {
      postController.isPageLoading = true;
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
          log('Hey something went wrong with SnackBar$e');
        }
      }
      await generatePost(context);
      if (context != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (error) {
      if (context != null) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
  }

  //TODO 15/04/2022
  void onRefresh(BuildContext context) async {
    pageCount = 0;
    allDataLoaded = false;
    postController.isPageLoading = true;
    isLanguageSwitch = false;
    //await getUserProfile(context);
    await generatePost(context);
  }

//TODO 15/04/2022
  Future<void> getLangCode() async {
    await userDefault.getLanguageCode().then((value) {
      languageCode = value;
    });
  }
}
