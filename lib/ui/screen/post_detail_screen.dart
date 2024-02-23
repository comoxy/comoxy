import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rate_review/helper/post_controller.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/document/document_data.dart';
import 'package:rate_review/model/general_response.dart';
import 'package:rate_review/model/post/all_transaction_response.dart';
import 'package:rate_review/model/post/post_data.dart';
import 'package:rate_review/model/post/transaction.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/component/border/dotted_border.dart';
import 'package:rate_review/ui/dialog/dialog_utils.dart';
import 'package:rate_review/ui/screen/personal_detail_screen.dart';
import 'package:rate_review/ui/screen/terms_and_conditions_screen.dart';
import 'package:rate_review/ui/screen/upload_product_document.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/post/all_post_response.dart';
import '../../util/DashedLineVerticalPainter.dart';
import '../dialog/dialog_utils.dart';
import 'dashboard_screen.dart';
import 'image_preview_screen.dart';
import 'webview_screen.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({Key? key, required this.data, required this.isFromPost, this.isFromNotification = false})
      : super(key: key);
  final PostData data;
  final bool isFromPost;
  final bool isFromNotification;

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

bool? isCheck;

class _PostDetailScreenState extends State<PostDetailScreen> {
  int? maxline;
  int? tcMaxLine;
  final AuthModel _authModel = Get.find();
  final GlobalKey<State> _globalKey = GlobalKey<State>();
  Transaction? firstDocument, secondDocument;
  UserDefault userDefault = Get.find();
  PostController postController = Get.find();
  User? _user;
  late PostData postData;
  late bool isFromPost;
  late bool isBlur = true;
  late bool isBlurWithoutButton = true;
  late bool shareIconVisibility = false;
  Locale? devLocale = Get.locale;



  @override
  void initState() {
    postData = widget.data;
    isFromPost = widget.isFromPost;
    isCheck = widget.isFromNotification;
    postController.isApprove = postData.transaction!.elementAt(0).isApproved;
    print('isApp: ${postController.isApprove}');

    userDefault.getUser().then((value) {
      _user = value!;
      var nullDocument = _user?.documents?.toList().where((element) => element.documentId != null).toList();
      var verifiedDocuments = _user?.documents?.toList().where((element) => element.isVerified == '1').toList();
      if (nullDocument == null) {
        Dailog(context, resource.verifyAccount.tr, resource.verify.tr, true);
      } else if (verifiedDocuments != null && verifiedDocuments.isEmpty) {
        Dailog(context, resource.pendingverifyAccount.tr, resource.checkstatus.tr, false);
        shareIconVisibility = false;
      } else {
        isBlur = false;
        shareIconVisibility = false;
      }
      if (postData.transaction!.elementAt(0).isApproved != 1.toString() ||
          postData.transaction!.elementAt(0).isApproved == null) {
        isBlurWithoutButton = true;
      } else {
        isBlurWithoutButton = false;
        shareIconVisibility = true;
      }
      if (mounted) {
        setState(() {});
      }
    });
    setExiestingData();
    super.initState();
  }

  void setExiestingData() {
    Transaction? fTransaction;
    Transaction? sTransaction;
    try {
      postData.transaction ??= [];
      fTransaction = postData.transaction!.firstWhere((element) => element.docType == '1' && element.docPhoto != null);
    } catch (e) {
      log('exc $e');
    }
    firstDocument = fTransaction;

    try {
      sTransaction = postData.transaction!.firstWhere((element) => element.docType == '2' && element.docPhoto != null);
    } catch (e) {
      log('exc $e');
    }
    secondDocument = sTransaction;
  }

  bool isVisible = false;

  @override
  Widget build(BuildContext buildContext) {
    //TODO 15/04/2022 remove uper to put here
    List title = [
      postData.step1_title,
      postData.step2_title,
      postData.step3_title,
      postData.step4_title,
      /* resource.buyTheProduct.tr,
    resource.uploadProofPurchase.tr,
    resource.writeReview.tr,
    resource.getPaid.tr*/
    ];
    List desc = [
      postData.step1_desc,
      postData.step2_desc,
      postData.step3_desc,
      postData.step4_desc,
/*      resource.buyTheProductDesc.tr,
      resource.uploadProofPurchaseDesc.tr,
      resource.writeReviewDesc.tr,
      resource.getPaidDesc.tr*/
    ];

    return Material(
      child: WillPopScope(
        onWillPop: () async {
          if (widget.isFromNotification) {
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: Column(children: [
            ...AppToolbar(buildContext,
                children: [
                  IconButton(
                      onPressed: () {
                        if (widget.isFromNotification) {
                          Get.offAll(() => DashboardScreen());
                        } else {
                          Get.back();
                        }
                      },
                      icon: Image(image: ImageRes.backIcon, height: 25, width: 25)),
                  Expanded(
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '${postData.postTitle?.toUpperCase()}'.trim(),
                            style: TextStyle(
                                color: CupertinoColors.white, fontFamily: narrowmedium, fontSize: 20, letterSpacing: 4.0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ))),
                  Visibility(
                    visible: shareIconVisibility,
                    child: IconButton(
                      onPressed: () async {
                        await _onShareData(buildContext);
                      },
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Image(image: ImageRes.shareIcon, height: 25, width: 25),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ],
                showStatusBar: true),
            GetBuilder<PostController>(
              builder: (postController) {
                return Expanded(
                  child: Stack(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 0, bottom: 15, left: 15, right: 15),
                              child: Container(
                                  // height: double.maxFinite,
                                  //width: double.maxFinite,
                                  /*  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: ExactAssetImage("assets/images/blur.png"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),*/
                                  color: Colors.white,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Stack(
                                      children: [
                                        Container(
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(() => ImagePreviewScreen(imageUrl: imageUrl));
                                                },
                                                child: Container(
                                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                                  decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.vertical(top: Radius.circular(5))),
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
                                                          width: 50, height: 50, child: Center(child: CupertinoActivityIndicator()));
                                                    },
                                                  ),
                                                ) /*Image.network(
                                            imageUrl,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Image(
                                                image: ImageRes.noImageFound,
                                                height: size(buildContext).height / 2.0,
                                                width: size(buildContext).width,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                            */ /*height: size(buildContext).height / 2.0,
                                            width: size(buildContext).width,*/ /*
                                            loadingBuilder:
                                                (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: Center(
                                                    child:
                                                        CupertinoActivityIndicator()));
                                            },
                                            fit: BoxFit.cover,
                                      )*/
                                                ,
                                              ),
                                              const Divider(
                                                thickness: 0.5,
                                                endIndent: 15,
                                                indent: 15,
                                                color: dividerColor,
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0, top: 10),
                                                    child: Text(postData.postTitle.toString().trim(),
                                                        style: TextStyle(
                                                            fontSize: 22,
                                                            height: 1.2,
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily: narrowbook,
                                                            color: lablecolor)),
                                                  ),
                                                  Visibility(
                                                    visible: postController.isApprove == '1' ? true : false,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            //TODO 30/03/2022
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Padding(
                                                                //TODO 30/03/2022
                                                                padding: const EdgeInsets.only(top: 13),
                                                                child: Image(image: ImageRes.discontImg, height: 20, width: 20),
                                                              ),
                                                              Expanded(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.all(5),
                                                                  child: Text(String.fromCharCodes(Runes(postData.post_brief.toString())),
                                                                      style: TextStyle(
                                                                          fontFamily: narrowbook,
                                                                          fontSize: 22,
                                                                          height: 1.5,
                                                                          color: lablecolor)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 0),
                                                          child: Text(
                                                            '${postData.postDesc}'.trim(),
                                                            style: TextStyle(
                                                                color: desclablecolor, fontSize: 19, height: 1.3, fontFamily: narrowbook),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Visibility(
                                                visible: postController.isApprove == '1' ? true : false,
                                                child: Column(
                                                  children: [
                                                    const Divider(
                                                      thickness: 0.5,
                                                      endIndent: 15,
                                                      indent: 15,
                                                      color: dividerColor,
                                                    ),
                                                    //TODO 14/03/2022 BRAND SECTION
                                                    Visibility(
                                                      visible: showBrandContent(),
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(top: 10),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: <Widget>[
                                                                Padding(
                                                                  //TODO 15/04/2022
                                                                  padding: devLocale?.languageCode == AppLanguages.en.name
                                                                      ? const EdgeInsets.only(left: 15)
                                                                      : const EdgeInsets.only(right: 15),
                                                                  child: SizedBox(
                                                                    height: 80,
                                                                    width: 80,
                                                                    child: CircleAvatar(
                                                                      backgroundColor: Colors.transparent,
                                                                      child: ClipOval(
                                                                        child: Image.network(
                                                                          postData.brand_photo_name.toString(),
                                                                          width: 100,
                                                                          height: 100,
                                                                          fit: BoxFit.cover,
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
                                                                ),
                                                                Expanded(
                                                                  child: Padding(
                                                                    //TODO 15/04/2022
                                                                    padding: devLocale?.languageCode == AppLanguages.en.name
                                                                        ? const EdgeInsets.only(left: 10)
                                                                        : const EdgeInsets.only(right: 10),
                                                                    child: Text(
                                                                      '${postData.brand_name}'.trim(),
                                                                      style: TextStyle(
                                                                        fontSize: 18,
                                                                        letterSpacing: 1,
                                                                        fontFamily: narrowbold,
                                                                        color: lablecolor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () async {
                                                                    brandFollowUnfollowStatus(context);
                                                                  },
                                                                  child: postData.isFollowed == 0.toString()
                                                                      ? Align(
                                                                          child: Container(
                                                                              height: 50,
                                                                              width: size(context).width * 0.3,
                                                                              //TODO 05/04/2022
                                                                              margin: devLocale?.languageCode == AppLanguages.en.name
                                                                                  ? const EdgeInsets.only(right: 15)
                                                                                  : const EdgeInsets.only(left: 15),
                                                                              decoration: BoxDecoration(
                                                                                gradient: const LinearGradient(
                                                                                  begin: Alignment.centerLeft,
                                                                                  end: Alignment.centerRight,
                                                                                  colors: [
                                                                                    btnEndColor,
                                                                                    btnStartColor,
                                                                                  ],
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(40),
                                                                              ),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  resource.followTitle.tr.toUpperCase(),
                                                                                  style: TextStyle(
                                                                                      fontSize: 18,
                                                                                      fontFamily: narrowbold,
                                                                                      letterSpacing: 3,
                                                                                      color: CupertinoColors.white),
                                                                                ),
                                                                              )),
                                                                        )
                                                                      : Align(
                                                                          child: Container(
                                                                              height: 50,
                                                                              width: size(context).width * 0.3,
                                                                              //TODO 05/04/2022
                                                                              margin: devLocale?.languageCode == AppLanguages.en.name
                                                                                  ? const EdgeInsets.only(right: 15)
                                                                                  : const EdgeInsets.only(left: 15),
                                                                              decoration: BoxDecoration(
                                                                                color: backgroundColor,
                                                                                borderRadius: BorderRadius.circular(40),
                                                                              ),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  resource.followedTitle.tr.toUpperCase(),
                                                                                  style: TextStyle(
                                                                                      fontSize: 18,
                                                                                      fontFamily: narrowbold,
                                                                                      letterSpacing: 3,
                                                                                      color: primaryColor),
                                                                                ),
                                                                              )),
                                                                        ),
                                                                ),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 10.0),
                                                              child: Stack(
                                                                children: [
                                                                  Positioned(
                                                                    //the diamond behind the content
                                                                    top: 0,
                                                                    right: 65,
                                                                    child: Container(),
                                                                    /*child: Transform.rotate(
                                                                          angle: 3 / 4,
                                                                          //rotating the container to turn it into a diamond
                                                                          child: Container(
                                                                            width: 40,
                                                                            height: 40,
                                                                            decoration:
                                                                                const BoxDecoration(
                                                                              color: Colors
                                                                                  .white,
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: Colors
                                                                                      .grey,
                                                                                  blurRadius:
                                                                                      0.2,
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),*/
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                        const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 15),
                                                                    child: Center(
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          boxShadow: const [
                                                                            BoxShadow(
                                                                              color: Colors.grey,
                                                                              blurRadius: 0.2,
                                                                            ),
                                                                          ],
                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(30.0),
                                                                          child: Text(
                                                                            resource.followDesc.tr,
                                                                            style: TextStyle(
                                                                                fontSize: 18,
                                                                                fontFamily: primaryFF,
                                                                                fontWeight: FontWeight.w300),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const Divider(
                                                              thickness: 0.5,
                                                              endIndent: 15,
                                                              indent: 15,
                                                              color: dividerColor,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    // TODO OVER
                                                    /*  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                            top: 20, left: 15),
                                                        child: Text(
                                                          "Follow the below steps:",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              color: lablecolor,
                                                              fontFamily: narrowbook),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 20,
                                                      ),
                                                      ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemCount: 4,
                                                          itemBuilder: (context, index) {
                                                            return Stack(
                                                              children: [
                                                                Positioned(
                                                                  left: 60,
                                                                  top: 0,
                                                                  bottom: 0,
                                                                  width: 2,
                                                                  child: index == 3 ? Container() : Container(color: Colors.grey), // replace with your image
                                                                ),
                                                                Container(
                                                                  padding : EdgeInsets.only(left: 15),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment.start,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment.start,
                                                                    children: [
                                                                      // VerticalDivider(
                                                                      //   color: Colors.black,
                                                                      //   thickness: 3, //thickness of divier line
                                                                      // ),
                                                                      Column(children: [
                                                                        index == 0
                                                                            ? Container()
                                                                            : Container(),
                                                                        Container(
                                                                          padding: const EdgeInsets.only(
                                                                                  top: 10,
                                                                                  left: 25,
                                                                                  right: 25),
                                                                          decoration: BoxDecoration(
                                                                            color: Colors.white,
                                                                              border: Border.all(
                                                                                  color: btnEndColor,
                                                                                  width: 3),
                                                                              shape:
                                                                                  BoxShape.circle),
                                                                          child: Column(
                                                                            children: [
                                                                              Text(
                                                                                'STEP',
                                                                                style: TextStyle(
                                                                                    letterSpacing:
                                                                                        1,
                                                                                    fontFamily:
                                                                                        narrowmedium,
                                                                                    color:
                                                                                        desclablecolor),
                                                                              ),
                                                                              Text('${index + 1}',
                                                                                  style: TextStyle(
                                                                                      fontFamily:
                                                                                          narrowbold,
                                                                                      fontSize: 50,
                                                                                      color:
                                                                                          btnEndColor)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        // index == 3
                                                                        //     ? Container()
                                                                        //     : CustomPaint(
                                                                        //         size: const Size(
                                                                        //             1, 25),
                                                                        //         painter:
                                                                        //             DashedLineVerticalPainter())
                                                                      ]),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Theme(
                                                                          data: Theme.of(context)
                                                                              .copyWith(
                                                                                  dividerColor: Colors
                                                                                      .transparent),
                                                                          child: Container(
                                                                            padding:
                                                                                const EdgeInsets
                                                                                    .only(top: 20),
                                                                            child: ExpansionTile(
                                                                              title: Text(
                                                                                title[index],
                                                                                style: TextStyle(
                                                                                    fontFamily:
                                                                                        narrowbold,
                                                                                    color:
                                                                                        lablecolor,
                                                                                    fontSize: 18),
                                                                              ),
                                                                              children: <Widget>[
                                                                                ListTile(
                                                                                    visualDensity:
                                                                                        const VisualDensity(
                                                                                            horizontal:
                                                                                                0,
                                                                                            vertical:
                                                                                                -4),
                                                                                    title: Text(
                                                                                        desc[index],
                                                                                        style: TextStyle(
                                                                                            color:
                                                                                                desclablecolor,
                                                                                            fontSize:
                                                                                                20,
                                                                                            height:
                                                                                                1.3,
                                                                                            fontFamily:
                                                                                                narrowbook))),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            );
                                                          })
                                                    ],
                                            ),*/
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          //TODO 05/04/2022
                                                          padding: devLocale?.languageCode == AppLanguages.en.name
                                                              ? const EdgeInsets.only(top: 20, left: 15)
                                                              : const EdgeInsets.only(top: 20, right: 15),
                                                          child: Text(
                                                            resource.followSteps.tr,
                                                            style: TextStyle(fontSize: 20, color: lablecolor, fontFamily: narrowbook),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                        ),
                                                        ListView.builder(
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemCount: 4,
                                                            itemBuilder: (context, index) {
                                                              return Stack(
                                                                children: [
                                                                  //TODO 05/04/2022
                                                                  devLocale?.languageCode == AppLanguages.en.name
                                                                      ? Positioned(
                                                                          left: 60,
                                                                          top: 0,
                                                                          bottom: 0,
                                                                          width: 2,
                                                                          child: index == 3
                                                                              ? Container()
                                                                              : CustomPaint(
                                                                                  size: const Size(1, 0),
                                                                                  painter:
                                                                                      DashedLineVerticalPainter()), // replace with your image
                                                                        )
                                                                      : Positioned(
                                                                          //TODO 06/04/2022
                                                                          right: 60,
                                                                          top: 0,
                                                                          bottom: 0,
                                                                          width: 2,
                                                                          child: index == 3
                                                                              ? Container()
                                                                              : CustomPaint(
                                                                                  size: const Size(1, 0),
                                                                                  painter:
                                                                                      DashedLineVerticalPainter()), // replace with your image
                                                                        ),
                                                                  Container(
                                                                    //TODO 05/04/2022
                                                                    padding: devLocale?.languageCode == AppLanguages.en.name
                                                                        ? const EdgeInsets.only(left: 12)
                                                                        : const EdgeInsets.only(right: 12),
                                                                    child: Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      children: [
                                                                        // VerticalDivider(
                                                                        //   color: Colors.black,
                                                                        //   thickness: 3, //thickness of divier line
                                                                        // ),
                                                                        Column(children: [
                                                                          index == 0 ? Container() : Container(),
                                                                          Container(
                                                                            padding: const EdgeInsets.only(top: 10, left: 25, right: 25),
                                                                            decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                border: Border.all(color: btnEndColor, width: 3),
                                                                                shape: BoxShape.circle),
                                                                            child: Column(
                                                                              children: [
                                                                                Text(
                                                                                  resource.step.tr,
                                                                                  style: TextStyle(
                                                                                      letterSpacing: 1,
                                                                                      fontFamily: narrowmedium,
                                                                                      color: desclablecolor),
                                                                                ),
                                                                                Text('${index + 1}',
                                                                                    style: TextStyle(
                                                                                        fontFamily: narrowbold,
                                                                                        fontSize: 50,
                                                                                        color: btnEndColor)),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                        Expanded(
                                                                          flex: 1,
                                                                          child: Theme(
                                                                            data: Theme.of(context)
                                                                                .copyWith(dividerColor: Colors.transparent),
                                                                            child: Container(
                                                                              padding: const EdgeInsets.only(top: 20, bottom: 40),
                                                                              child: ExpansionTile(
                                                                                //TODO 15/04/2022
                                                                                title: Text(
                                                                                  title[index].toString().toUpperCase(),
                                                                                  style: TextStyle(
                                                                                      fontFamily: narrowbold,
                                                                                      color: lablecolor,
                                                                                      fontSize: 18),
                                                                                ),
                                                                                children: <Widget>[
                                                                                  ListTile(
                                                                                      visualDensity:
                                                                                          const VisualDensity(horizontal: 0, vertical: -4),
                                                                                      //TODO 15/04/2022
                                                                                      title: Text(desc[index],
                                                                                          style: TextStyle(
                                                                                              color: desclablecolor,
                                                                                              fontSize: 20,
                                                                                              height: 1.3,
                                                                                              fontFamily: narrowbook))),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            })
                                                      ],
                                                    ),
                                                    const Divider(
                                                      thickness: 0.5,
                                                      endIndent: 15,
                                                      indent: 15,
                                                      color: dividerColor,
                                                    ),
                                                    Visibility(
                                                      visible: showProductLink(),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              if (postData.postUrl == null) {
                                                                return;
                                                              }
                                                              Get.to(() => WebViewScreen(webUrl: postData.postUrl!));
                                                            },
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
                                                                  child: Text(resource.getProductTitle.tr,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight.bold, fontSize: 20, color: lablecolor)),
                                                                ),
                                                                InkWell(
                                                                  onTap: () async {
                                                                    if (!await launch(postData.postUrl ?? '-')) {
                                                                      throw 'Could not launch ${postData.postUrl}';
                                                                    }
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
                                                                    child: Text(
                                                                      postData.postUrl ?? '-',
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                      style: TextStyle(
                                                                          color: CupertinoColors.activeBlue,
                                                                          fontSize: 20,
                                                                          fontFamily: primaryFF,
                                                                          fontWeight: FontWeight.w100),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: showProductLink(),
                                                      child: const Divider(
                                                        thickness: 0.5,
                                                        endIndent: 15,
                                                        indent: 15,
                                                        color: dividerColor,
                                                      ),
                                                    ),
                                                    //TODO 05/04/2022
                                                    Align(
                                                      alignment: devLocale?.languageCode == AppLanguages.en.name
                                                          ? Alignment.centerLeft
                                                          : Alignment.centerRight,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: devLocale?.languageCode == AppLanguages.en.name
                                                                ? const EdgeInsets.only(top: 10, left: 15)
                                                                : const EdgeInsets.only(top: 10, right: 15),
                                                            child: Text(resource.deadline.tr,
                                                                style: const TextStyle(
                                                                    fontWeight: FontWeight.bold, fontSize: 20, color: lablecolor)),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 10, top: 10),
                                                            child: Text(
                                                              getDate(),
                                                              style: TextStyle(
                                                                  color: CupertinoColors.systemRed, fontSize: 20, fontFamily: narrowbook),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Divider(
                                                thickness: 0.5,
                                                endIndent: 15,
                                                indent: 15,
                                                color: dividerColor,
                                              ),
                                              Container(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(20),
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      await Navigator.push(context,
                                                          MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()));
                                                      /*  DialogUtils.showDailogForUser(
                                                        context,
                                                        '${postData.postTerms}',
                                                        resource.ok,
                                                        (action) => null,
                                                        islatterbutton: true);*/
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          resource.termsAndConditionTitle.tr.toUpperCase(),
                                                          style: TextStyle(fontSize: 15, fontFamily: narrowbold, letterSpacing: 2
                                                              //fontWeight: FontWeight.bold
                                                              ),
                                                        ),
                                                        const Padding(
                                                          padding: EdgeInsets.only(left: 3),
                                                          child: Icon(
                                                            CupertinoIcons.forward,
                                                            color: Colors.black,
                                                            size: 15,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        ///TODO 7nov
                                        // Visibility(
                                        //   visible: isBlurWithoutButton,
                                        //   child: Positioned(
                                        //     top: 0,
                                        //     bottom: 0,
                                        //     left: 0,
                                        //     right: 0,
                                        //     child: ClipRect(
                                        //       child: BackdropFilter(
                                        //         filter: ImageFilter.blur(
                                        //             sigmaX: 10.0, sigmaY: 10.0),
                                        //         child: Container(
                                        //           color: Colors.transparent,
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Visibility(
                                            visible: postController.isApprove == null || postController.isApprove == '0' || postController.isApprove == '1' ? true : false,
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (postData.transaction?.elementAt(0).isApproved == null) {
                                                  uploadMyDocument("", 0, onuploadsuccess: (List<Transaction>? data) {
                                                    if (data == null) {
                                                      return;
                                                    }
                                                    postData.transaction ??= [];
                                                    try {
                                                      var imEligible = data.firstWhereOrNull((element) => element.docType == '0');
                                                      if (imEligible != null) {
                                                        postData.transId ??= imEligible.transId;
                                                        postData.transaction![0] = imEligible;
                                                      }
                                                      postController.addPostData(postData);
                                                      Dailog1(context, resource.elegibleContent.tr, resource.checkstatus.tr);
                                                    } catch (e) {
                                                      print(e);
                                                      // log('openFilePicker $docNum $e');
                                                    }
                                                    postController.changeIsApprove('0');
                                                    setState((){});
                                                  });
                                                } else if (postData.transaction!.elementAt(0).isApproved == 0.toString()) {
                                                  Dailog1(context, resource.elegibleContent.tr, resource.checkstatus.tr);
                                                } else {
                                                  var postDataBackResponse = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UploadProductDocument(data: postData, isFromPost: isFromPost)));

                                                  if (postDataBackResponse != null && postDataBackResponse is PostData) {
                                                    postData = postDataBackResponse;
                                                  } else if (postDataBackResponse != null && postDataBackResponse is bool) {
                                                    //TODO 16/03/2022 put pop line
                                                    if (isFromPost) {
                                                      Navigator.of(context).pop(currentSelected);
                                                    } else {
                                                      Navigator.of(context).pop();
                                                    }
                                                  }
                                                }
                                                //iAmInterested(buildContext);
                                              },
                                              child: Container(
                                                  height: 80,
                                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.centerLeft,
                                                      end: Alignment.centerRight,
                                                      colors: [
                                                        btnEndColor,
                                                        btnStartColor,
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(40),
                                                  ),
                                                  child: Center(
                                                    child: SizedBox(
                                                      child: Text(
                                                        postController.isApprove == '1' ? resource.uploadUserDocTitle.tr.toUpperCase() : resource.interestedBtnTitle.tr.toUpperCase(),
                                                        style: boldBtnStyle,
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          Visibility(
                                            visible: postController.isApprove == null ? true : false,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                  height: 80,
                                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.centerLeft,
                                                      end: Alignment.centerRight,
                                                      colors: [
                                                        yellowStartColor,
                                                        yellowEndColor,
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(40),
                                                  ),
                                                  child: Center(
                                                    child: SizedBox(
                                                      child: CupertinoButton(
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(50.0),
                                                        ),
                                                        //TODO 30/03/2022
                                                        onPressed: () async {
                                                          if (widget.isFromNotification) {
                                                            Get.offAll(() => DashboardScreen());
                                                          } else {
                                                            DialogUtils.showLoadingDialog(context,_globalKey);
                                                            await notInterested();
                                                            DialogUtils.hideLoadingDialog(context);
                                                            Navigator.of(context).pop();
                                                          }
                                                        },
                                                        //TODO Over
                                                        child: Text(
                                                          resource.notInterestedBtnTitle.tr.toUpperCase(),
                                                          style: boldBtnStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          Visibility(
                                            visible:  postController.isApprove == '0' ? true :false,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Container(
                                                  height: 80,
                                                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                  decoration: BoxDecoration(
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.centerLeft,
                                                      end: Alignment.centerRight,
                                                      colors: [
                                                        yellowStartColor,
                                                        yellowEndColor,
                                                      ],
                                                    ),
                                                    borderRadius: BorderRadius.circular(40),
                                                  ),
                                                  child: Center(
                                                    child: SizedBox(
                                                      child: CupertinoButton(
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(50.0),
                                                        ),
                                                        //todo phase2
                                                        onPressed: () async {
                                                          DialogUtils.showLoadingDialog(context,_globalKey);
                                                          await cancelApiCall();
                                                          DialogUtils.hideLoadingDialog(context);
                                                          Navigator.of(context).pop();
                                                        },
                                                        //TODO Over
                                                        child: Text(
                                                          resource.cancelBtnTitle.tr.toUpperCase(),
                                                          style: boldBtnStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ])))
                        ],
                      ),
                      Visibility(
                        visible: isBlur,
                        child: Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                // the size where the blurring starts
                                //height: MediaQuery.of(context).size.height,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            )
          ]),
        ),
      ),
    );
  }

  /* void iAmInterested(BuildContext buildContext) {
    if (_user == null) {
      // return;

      DialogUtils.okDialog(buildContext,
          'Please contact administrator to verify your document.');
      return;
    }
    if (_user!.documents == null) {
      DialogUtils.okDialog(buildContext,
          'Please contact administrator to verify your document.');
      return;
    } else {
      _user!.documents ??= [];
      List<DocumentData>? verifiedDocuments;
      try {
        verifiedDocuments = _user!.documents!
            .toList()
            .where((element) => element.isVerified == '1')
            .toList();
      } catch (e) {
        verifiedDocuments = [];
      }
      if (verifiedDocuments.isNotEmpty) {
        if ((postData.noSpots != null && postData.availableSpots != null) &&
            (postData.availableSpots!.toInt > 0)) {
          hoverPostDocumentUploader(buildContext);
        } else {
          DialogUtils.okDialog(buildContext, 'Spot completed!');
        }
      } else {
        DialogUtils.okDialog(buildContext,
            'Please contact administrator to verify your document.');
      }
      return;
    }
  }*/

  void Dailog(BuildContext buildContext, String verifyAccount, String okButton, bool isfirsttime) {
    return DialogUtils.showDailogForUser(buildContext, verifyAccount, okButton, (bool action) async {
      if (action) {
        var result =
            await Get.to(() => PersonalDetailScreen(user: _user!, verifyAcc: true, isFirstTime: isfirsttime, isFrom: "fromPost"));
        Navigator.of(context).pop(result);
        setState(() {});
      } else {
        Navigator.pop(context);
      }
    });
  }

  int currentSelected = 1;

  void Dailog1(BuildContext buildContext, String verifyAccount, String okButton) {
    return DialogUtils.showDailogForUser(
      buildContext,
      verifyAccount,
      okButton,
      (bool action) {
        if (action) {
          if (isFromPost) {
            Navigator.of(context).pop(currentSelected);
          } else {
            Navigator.of(context).pop(); //todo change
          }
          if (widget.isFromNotification) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => DashboardScreen(
                    initialPage: 1,
                  ),
                ),
                (Route<dynamic> route) => false);
          }
        }
      },
      islatterbutton: true,
      isDailogeCancle: true,
    );
  }

  Widget DocumentsWidget(BuildContext buildContext, StateSetter setState) {
    return Column(
      children: [
        ...AppToolbar(context,
            children: [
              Expanded(
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        resource.upload.tr.toUpperCase(),
                        style: const TextStyle(
                            color: CupertinoColors.white, fontWeight: FontWeight.bold, fontSize: 17.0, letterSpacing: 4.0),
                      ))),
            ],
            showStatusBar: false),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: size(buildContext).height * 0.35,
            width: size(buildContext).width,
            child: InkWell(
              onTap: () {
                if (firstDocument != null) {
                  openImagePreview(firstDocument);
                } else {
                  openFilePick(1, setState);
                }
              },
              child: Card(
                color: backgroundColor,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: backgroundColor, width: 1),
                  // borderRadius: BorderRadius.circular(10),
                ),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Expanded(child: getDocUrl(firstDocument, isFirstDoc: true)),
                                if (firstDocument?.docPhoto != null) ...[
                                  Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      getDocName(firstDocument, true),
                                      style: TextStyle(letterSpacing: 3.0, fontFamily: primaryFF, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Column(
                              children: [
                                if (firstDocument != null) ...[
                                  Row(
                                    children: [
                                      if (firstDocument!.isApproved == '1') ...[
                                        SizedBox(width: 100, child: SvgPicture.asset(ImageRes.verifiedSVG)),
                                      ] else ...[
                                        SizedBox(width: 100, child: SvgPicture.asset(ImageRes.unverifiedSVG)),
                                        IconButton(
                                          // padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          onPressed: () async {
                                            DialogUtils.showActionAlert(buildContext,
                                                title: resource.deleteUserDocTitle.tr,
                                                message: resource.deleteUserDocContent.tr, action: (bool action) {
                                              if (action) {
                                                deleteMyDocument(firstDocument!, 1, onDeleteSuccess: () {
                                                  firstDocument = null;

                                                  setState(() {});
                                                });
                                              }
                                            });
                                          },
                                          icon: const Icon(
                                            CupertinoIcons.delete,
                                            color: CupertinoColors.systemRed,
                                            size: 25,
                                          ),
                                        )
                                      ]
                                    ],
                                  )
                                ],
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: size(buildContext).height * 0.35,
            width: size(buildContext).width,
            child: InkWell(
              onTap: () {
                if (firstDocument?.isApproved == '1') {
                  if (secondDocument != null) {
                    openImagePreview(secondDocument);
                  } else {
                    openFilePick(2, setState);
                  }
                } else {
                  if (secondDocument != null && secondDocument?.isApproved != '1') {
                    openImagePreview(secondDocument);
                  } else {
                    AppUtil.toast(resource.documentForVerification.tr);
                  }
                }
              },
              child: Card(
                color: backgroundColor,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(color: backgroundColor, width: 1),
                  // borderRadius: BorderRadius.circular(10),
                ),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  padding: const EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Expanded(child: getDocUrl(secondDocument, isFirstDoc: false)),
                                if (secondDocument?.docPhoto != null) ...[
                                  Container(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Text(
                                      getDocName(secondDocument, false),
                                      style: TextStyle(letterSpacing: 3.0, fontFamily: primaryFF, fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Column(
                              children: [
                                if (secondDocument != null) ...[
                                  Row(
                                    children: [
                                      if (secondDocument!.isApproved == '1') ...[
                                        SizedBox(width: 100, child: SvgPicture.asset(ImageRes.verifiedSVG)),
                                      ] else ...[
                                        SizedBox(width: 100, child: SvgPicture.asset(ImageRes.unverifiedSVG)),
                                        IconButton(
                                          // padding: EdgeInsets.symmetric(horizontal: 10.0),
                                          onPressed: () async {
                                            bool _hasInternet = await AppUtil.isInternetAvailable(buildContext);
                                            if (!_hasInternet) {
                                              return;
                                            }

                                            DialogUtils.showActionAlert(buildContext,
                                                title: resource.deleteUserDocTitle.tr,
                                                message: resource.deleteUserDocContent.tr, action: (bool action) {
                                              if (action) {
                                                deleteMyDocument(secondDocument!, 2, onDeleteSuccess: () {
                                                  // postData.transaction!
                                                  //     .removeWhere((element) => element == secondDocument);
                                                  secondDocument = null;
                                                  updateSimilarRecord();
                                                  setState(() {});
                                                });
                                                setState(() {});
                                              }
                                            });
                                          },
                                          icon: const Icon(
                                            CupertinoIcons.delete,
                                            color: CupertinoColors.systemRed,
                                            size: 30,
                                          ),
                                        )
                                      ]
                                    ],
                                  )
                                ],
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
          ),
        ),
      ],
    );
  }

  Icon getTrailingIcon(Transaction? transaction, [bool isReviewDoc = false]) {
    if (transaction == null) {
      return const Icon(
        CupertinoIcons.cloud_upload,
        size: 30,
        color: CupertinoColors.systemTeal,
      );
    } else {
      return Icon(
        (transaction.isApproved != '1' ? CupertinoIcons.delete : CupertinoIcons.cloud_upload),
        size: 30,
        color: (transaction.isApproved != '1' ? CupertinoColors.systemRed : CupertinoColors.systemTeal),
      );
    }
  }

  void openImagePreview(Transaction? data) {
    if (data != null && data.docPhoto != null) {
      if (data.docPhoto!.isNotEmpty) {
        String docImageUrl = data.docPhoto!;
        Get.to(() => ImagePreviewScreen(imageUrl: docImageUrl));
      } else {
        AppUtil.toast(resource.somethingWentWrong.tr);
      }
    }
  }

  String getDocName(Transaction? doc, [bool isFirstDoc = true]) {
    /* if (doc == null) {
      return '${'document'.tr} ${isFirstDoc ? 'Product' : 'Review'}';
    } else {
      if (doc.docPhoto == null) {
        return '${'document'.tr} ${isFirstDoc ? 'Product' : 'Review'}';
      } else {
        return doc.docPhoto!.split('/').last;
      }
    } */
    if (doc!.docPhoto != null) {
      return resource.userDocTitleForUploading.tr + (isFirstDoc ? resource.purchase.tr : resource.review.tr);
    } else {
      return resource.userDocTitleForUploading.tr + (isFirstDoc ? resource.purchase.tr : resource.review.tr);
    }
  }

  /*String getDocName(Transaction? doc, [bool isFirstDoc = true]) {
    if (doc == null) {
      return '${'document'.tr} ${isFirstDoc ? 'Product' : 'Review'}';
    } else {
      if (doc.docPhoto == null) {
        return '${'document'.tr} ${isFirstDoc ? 'Product' : 'Review'}';
      } else {
        return doc.docPhoto!.split('/').last;
      }
    }
  }*/

  Widget getDocUrl(Transaction? doc, {bool isFirstDoc = true}) {
    if (doc == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            color: Colors.tealAccent,
            size: 50,
          ),
          Text(
            isFirstDoc ? resource.uploadPurchase.tr : resource.uploadReview.tr,
            style: TextStyle(letterSpacing: 3.0, fontFamily: primaryFF, fontWeight: FontWeight.w400),
          )
        ],
      );
    }
    if (doc != null && doc.docPhoto != null) {
      return Center(
          child: Image.network(
        doc.docPhoto.toString(),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return const SizedBox(width: 50, height: 50, child: Center(child: CupertinoActivityIndicator()));
        },
        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Image(
            image: ImageRes.noImageFound,
            fit: BoxFit.cover,
          );
        },
      ));
    } else {
      return SizedBox(
        width: size(context).width * 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Image(
            image: ImageRes.noImageFound,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  String get imageUrl => postData.photoName.toString();

  String getDate() {
    int dateInt = int.tryParse(postData.endDate.toString()) ?? 0;
    DateTime datetime = DateTime.fromMillisecondsSinceEpoch(dateInt);
    final DateFormat formatter = DateFormat.yMMMd();
    return formatter.format(datetime);
  }

/*  Widget? getDocStatus(Transaction? doc) {
    String status = (doc != null && doc.isApproved != null)
        ? (doc.isApproved == '1' ? 'verified'.tr : 'not_verified'.tr)
        : '';

    if (status.isEmpty) {
      return null;
    }
    return Text(
      status,
      style: TextStyle(color: getDocStatusColor(doc), fontSize: 15),
      maxLines: 1,
    );
  }*/

/*  Color getDocStatusColor(Transaction? doc) {
    return (doc != null && doc.isApproved != null)
        ? (doc.isApproved == '1'
            ? CupertinoColors.systemGreen
            : CupertinoColors.systemRed)
        : CupertinoColors.white;
  }*/

  void hoverPostDocumentUploader(BuildContext ctx, {Function(String? data)? onImagePic}) {
    showModalBottomSheet<dynamic>(
      context: ctx,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, setState) {
          return Wrap(children: <Widget>[DocumentsWidget(ctx, setState)]);
        });
      },
    );
  }

  bool getCountMeInVis() {
    if (_user == null) {
      return false;
    }
    if (_user!.documents == null) {
      return false;
    } else {
      _user!.documents ??= [];
      List<DocumentData>? verifiedDocuments;
      try {
        verifiedDocuments = _user!.documents!.toList().where((element) => element.isVerified == '1').toList();
      } catch (e) {
        verifiedDocuments = [];
      }
      return verifiedDocuments.isNotEmpty;
    }
  }

  void openFilePick(int docNum, StateSetter setState) async {
    XFile? pickedFile;

    var isPermisssion = await userDefault.readBool(UserDefault.kImagePermissionDenied);

    if (isPermisssion) {
      try {
        pickedFile = await pickImages(pickedFile, context);
      } catch (e) {
        if ((e as PlatformException).message == resource.photoPermission) {
          userDefault.saveBool(UserDefault.kImagePermissionDenied, true);
          opnDialog(context);
        }
        print(e);
      }
    } else {
      try {
        pickedFile = await pickImages(pickedFile, context);
      } catch (e) {
        if ((e as PlatformException).message == resource.photoPermission) {
          userDefault.saveBool(UserDefault.kImagePermissionDenied, true);
        }
      }
    }

    if (pickedFile != null) {
      String name = pickedFile.path;

      bool _hasInternet = await AppUtil.isInternetAvailable(context);
      if (!_hasInternet) {
        return;
      }
      DialogUtils.showActionAlert(context, title: resource.uploadUserDocTitle.tr, message: resource.uploadUserDocContent.tr,
          action: (bool action) {
        if (action) {
          uploadMyDocument(name, docNum, onuploadsuccess: (List<Transaction>? data) {
            if (data == null) {
              return;
            }

            postData.transaction ??= [];
            try {
              if (docNum == 1) {
                var firstData = data.firstWhereOrNull((element) => element.docType == '1');
                if (firstData != null) {
                  postData.transId ??= firstData.transId;
                  firstDocument = firstData;
                  postData.transaction!.add(firstData);
                }
                postController.addPostData(postData);
              } else {
                var secondData = data.firstWhereOrNull((element) => element.docType == '2');
                if (secondData != null) {
                  secondDocument = secondData;
                  postData.transaction!.add(secondData);
                }
                updateSimilarRecord();
              }
            } catch (e) {
              log('openFilePicker $docNum $e');
            }

            setState(() {});
          });
        }
      });
    }
  }

  Future<XFile?> pickImages(XFile? pickedFile, BuildContext context) async {
    try {
      pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 768, imageQuality: 100);
    } catch (e) {
      if ((e as PlatformException).message == resource.photoPermission.tr) {
        userDefault.saveBool(UserDefault.kImagePermissionDenied, true);
        opnDialog(context);
      }
    }
    return pickedFile;
  }

  void uploadMyDocument(String name, int docNum, {required Function(List<Transaction>? data) onuploadsuccess}) {
    postData.transaction ??= [];
    Map<String, dynamic> uploadDocumentRequestJson = {
      RequestTransaction.kUserDocument: name,
      RequestTransaction.kUserEmail: _user!.userEmail,
      RequestTransaction.kUserDocumentType: docNum,
      RequestTransaction.kPostId: postData.postid,
      RequestTransaction.kPostTitle: postData.postTitle,
    };

    log('uploadDocumentRequestJson $uploadDocumentRequestJson');
    uploadDocument(uploadDocumentRequestJson, onUpload: (List<Transaction>? data) {
      if (data != null) {
        onuploadsuccess(data);

        // if (docNum == 1) {
        //   Dailog1(context, resource.productpurchaseuploadscreenshot,
        //       resource.checkstatus);
        // } else {
        //   Dailog1(context, resource.productreviewuploadscreenshot,
        //       resource.checkstatus);
        // }
      }
    });
  }

  void uploadDocument(Map<String, dynamic> uploadDocumentRequestJson, {Function(List<Transaction>? data)? onUpload}) {
    _authModel
        .uploadTransactionResponse(
            context: context,
            keyLoader: _globalKey,
            apiName: ServiceUrl.kUploadTransactionDocuments,
            uploadDocumentRequestJson: uploadDocumentRequestJson)
        .then((AllTransactionResponse? response) {
      if (response != null) {
        if (onUpload != null && response.data != null) {
          onUpload(response.data!);
        }
      }
    });
  }

  void updateSimilarRecord() {
    postController.modifyPostData(postData, isFromPost);
  }

  void deleteSimilarRecord() {
    postController.modifyPostData(postData, isFromPost);
  }

  bool getProductReviewVisibility() {
    return firstDocument != null && firstDocument!.isApproved == '1';
  }

  bool getTrailingIconVisibility(Transaction? transaction, [bool isReviewDoc = false]) {
    if (transaction == null) {
      if (isReviewDoc) {
        return true;
      } else {
        return true;
      }
    } else {
      return transaction.isApproved != '1';
    }
  }

  void deleteMyDocument(Transaction tra, int docNum, {required Function()? onDeleteSuccess}) {
    Map<String, dynamic> deleteProductTransactionRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail,
      RequestParam.kTranDocId: tra.trandocId,
      RequestParam.kTranId: tra.transId,
      RequestParam.kPostId: postData.postid,
      RequestParam.kDocType: docNum,
    };
    log('deleteProductTransactionRequestJson $deleteProductTransactionRequestJson');
    deleteDocument(deleteProductTransactionRequestJson, (genResponse) {
      if (genResponse != null && genResponse.status.isTrue) {
        if (onDeleteSuccess != null) onDeleteSuccess();
        setState(() {});
      }
    });
  }

  void deleteDocument(Map<String, dynamic> deleteProductTransactionJson, Function(GeneralResponse genResponse) onResponse) {
    _authModel
        .deleteProdcutTransactionDocument(
            context: context,
            keyLoader: _globalKey,
            deleteProductTransactionRequestJson: deleteProductTransactionJson,
            apiName: ServiceUrl.kProductTransactionDelete)
        .then((GeneralResponse? result) {
      if (result == null) {
        return;
      }
      onResponse(result);
    });
  }

  ///TODO Phase2
  Future<void> notInterested() async {
    Map<String, dynamic> notInterestedPostRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail,
      RequestParam.kPostId: postData.postid,
    };

    GeneralResponse? result = await _authModel.notInterestedPost(
        context: null,
        keyLoader: _globalKey,
        notInterestedPostRequestJson: notInterestedPostRequestJson,
        apiName: ServiceUrl.kNotInterestedPost);

    if(result!.status.isTrue){
      postController.removeNotInterestedPostFromList(postData.postid!);
    }
  }

  ///TODO Phase2
  Future<void> cancelApiCall() async {
    Map<String, dynamic> cancelPostRequestJson = {
      RequestParam.kTransId: postData.transId,
    };

    GeneralResponse? result = await _authModel.cancelPost(
        context: null,
        keyLoader: _globalKey,
        notInterestedPostRequestJson: cancelPostRequestJson,
        apiName: ServiceUrl.kCancelPost);

    if(result!.status.isTrue){
      postController.removePostFromList(postData,isFromPost);
      //postController.changeIsApprove(null);
    }
  }

  void opnDialog(BuildContext context) {
    DialogUtils.showAlertDialog(context, resource.pickImagePermission.tr, resource.accessPhotoPermission.tr, 'App Settings', 'No',
        () async {
      Navigator.of(context).pop();
      openAppSettings();
    });
  }

//TODO 28/03/2022 _onShareData
  Future<void> _onShareData(BuildContext buildContext) async {
    var documentDirectory;
    Directory? newDirectory;
    File imgFile;
    var url = Uri.parse(postData.photoName.toString());
    var response = await get(url);

    if (Platform.isAndroid) {
      documentDirectory = await getExternalStorageDirectory();
      newDirectory = Directory('${documentDirectory.path}/temp/');
    } else if (Platform.isIOS) {
      documentDirectory = await getApplicationDocumentsDirectory();
      newDirectory = Directory('${documentDirectory.path}/temp/');
    }

    if (await newDirectory!.exists()) {
      imgFile = File('${newDirectory.path}${postData.photoName.toString().split('/').last}');
      imgFile.writeAsBytesSync(response.bodyBytes);
    } else {
      final Directory appNewDirectory = await newDirectory.create(recursive: true);
      imgFile = File('${appNewDirectory.path}${postData.photoName.toString().split('/').last}');
      imgFile.writeAsBytesSync(response.bodyBytes);
    }

    await Share.shareFiles(
      [imgFile.path],
      subject: postData.postTitle.toString(),
      text: '${postData.postTitle}\n\n${postData.postDesc}\n\n To Get Product : ${postData.postUrl}\n\n Deadline : ${getDate()}',
    );
  }

  showProductLink() {
    if (postData.postUrl != null && postData.postUrl!.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

// TODO 14/03/2022 FOR BRAND SHOW & HIDE
  showBrandContent() {
    if (postData.brand_id == null || postData.brand_id == 0.toString()) {
      return false;
    } else {
      return true;
    }
  }

  /*Future<void> checkEligibleuser(BuildContext buildContext) async {
    Map<String, dynamic> userEligibleRequestJson = {

      RequestParam.kUserEmail: _user?.userEmail.toString().trim(),
      "doc_type": 0,
      "post_id": postData.postid,
      "user_document" : '',
    };

    AllPostResponse result = await _authModel.userEligibleStatus(
        context: buildContext,
        keyLoader: _globalKey,
        userEligibleRequestJson: userEligibleRequestJson,
        apiName: ServiceUrl.kUploadTransactionDocuments);

    if (result.data != null) {
      DialogUtils.showDailogForUser(context, resource.elegibleContent, resource.checkstatus, (action) {
        if(action){
          Navigator.of(context)
              .pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    DashboardScreen(
                      intialPage: 1,
                    ),
              ),
                  (Route<dynamic> route) =>
              false);
        }
      } ,islatterbutton: true
      );
      postData = result.data![0];
      postController.onlyModifyPostData(postData);
      setState(() {});
    }
  }*/

//TODO 14/03/2022 UPDATE FOLLOW/UNFOLLOW SECTION
  Future<void> brandFollowUnfollowStatus(BuildContext buildContext) async {
    Map<String, dynamic> getAllFollowUnfollowListRequestJson = {
      RequestParam.kUserEmail: _user?.userEmail.toString().trim(),
      "brand_id": postData.brand_id,
      "post_id": postData.postid
    };

    AllPostResponse result = await _authModel.getFollowStatus(
        context: buildContext,
        keyLoader: _globalKey,
        getAllFollowUnfollowRequestJson: getAllFollowUnfollowListRequestJson,
        apiName: ServiceUrl.kGetAllFollowUnfollowList);

    if (result.data != null) {
      var resultData = result.data![0];
      postData.isFollowed = resultData.isFollowed;
      postController.onlyModifyPostData(postData);
      setState(() {});
    }
  }
}
