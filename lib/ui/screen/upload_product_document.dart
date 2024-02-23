import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rate_review/ui/component/app_extension.dart';

import '../../helper/post_controller.dart';
import '../../helper/userdefault.dart';
import '../../model/general_response.dart';
import '../../model/post/all_transaction_response.dart';
import '../../model/post/post_data.dart';
import '../../model/post/transaction.dart';
import '../../model/user/user.dart';
import '../../service/auth.dart';
import '../../util/common.dart';
import '../../util/string_resource.dart';
import '../../util/theming.dart';
import '../component/border/dotted_border.dart';
import '../dialog/dialog_utils.dart';
import 'image_preview_screen.dart';
import 'mail_screen.dart';

class UploadProductDocument extends StatefulWidget {
  UploadProductDocument({Key? key,required this.data,required this.isFromPost,}) : super(key: key);
  final PostData data;
  final bool isFromPost;
  @override
  _UploadProductDocumentState createState() => _UploadProductDocumentState();
}

class _UploadProductDocumentState extends State<UploadProductDocument> {
  UserDefault userDefault = Get.find();
  PostController postController = Get.find();
  final AuthModel _authModel = Get.find();
  final GlobalKey<State> _globalKey = GlobalKey<State>();
  late PostData postData;
  late bool isFromPost;
  Transaction? firstDocument, secondDocument;
  User? _user;

  @override
  void initState() {
    postData = widget.data;
    isFromPost = widget.isFromPost;
    userDefault.getUser().then((value) {
      _user = value!;
    }
    );
    setExiestingData();
    super.initState();

  }
  void setExiestingData() {
    Transaction? fTransaction;
    Transaction? sTransaction;
    try {
      postData.transaction ??= [];
      fTransaction = postData.transaction!.firstWhere(
              (element) => element.docType == '1' && element.docPhoto != null);
    } catch (e) {
      log('exc $e');
    }
    firstDocument = fTransaction;

    try {
      sTransaction = postData.transaction!.firstWhere(
              (element) => element.docType == '2' && element.docPhoto != null);
    } catch (e) {
      log('exc $e');
    }
    secondDocument = sTransaction;
  }
  @override
  Widget build(BuildContext buildContext) {
    return Material(
      child: Column(
        children: [
          ...AppToolbar(context,
              children: [
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Image(
                        image: ImageRes.backIcon, height: 25, width: 25)),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            resource.upload.tr.toUpperCase(),
                            style: TextStyle(
                                color: CupertinoColors.white,
                                fontFamily: narrowmedium,
                                fontSize: 20,
                                letterSpacing: 4.0),
                          )),
                    )),
              ],
              showStatusBar: true),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10,top: 20),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30,horizontal: 10),
                      child: SizedBox(
                        height: size(buildContext).height * 0.35,
                        width: size(buildContext).width,
                        child: Card(
                          color: boxcolor,
                          elevation: 0,
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: backgroundColor, width: 1),
                            // borderRadius: BorderRadius.circular(10),
                          ),
                          child: DottedBorder(
                            color: inputbor1dercolor,
                            borderType: BorderType.RRect,
                            padding: const EdgeInsets.all(6),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        //TODO 06/04/2022
                                          child: SizedBox(
                                            width: size(context).width,
                                            child: InkWell(
                                              onTap: (){
                                                if (firstDocument != null) {
                                                  openImagePreview(firstDocument);
                                                } else {
                                                  openFilePick(1, setState);
                                                }
                                              },
                                              child: getDocUrl(
                                                  firstDocument, isFirstDoc: true),
                                            ),
                                          )),
                                      if (firstDocument != null) ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (firstDocument?.isApproved == '1') ...[
                                              SizedBox(
                                                  width: 100,
                                                  child: SvgPicture.asset(
                                                      ImageRes.verifiedSVG)),
                                            ] else ...[
                                              SizedBox(
                                                  width: 100,
                                                  child: SvgPicture.asset(
                                                      ImageRes.unverifiedSVG)),
                                              GestureDetector(
                                                onTap: () {
                                                  DialogUtils.showDeleteDailogForUser(context,resource.deleteUserDocTitle.tr,resource.deleteUserDocContent.tr,resource.ok.tr,(bool action) {
                                                    if (action) {
                                                      deleteMyDocument(
                                                          firstDocument!, 1,
                                                          onDeleteSuccess: () {
                                                            postController.resetMailData(
                                                                postData, isFromPost,firstDocument!.docType ?? '');
                                                            firstDocument = null;
                                                            setState(() {});
                                                          });
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.only(top: 8,bottom: 8,left: 15,right: 15),
                                                  child: Visibility(
                                                    visible: firstDocument != null &&
                                                        firstDocument!.isApproved != '1',
                                                    child: const Icon(
                                                      CupertinoIcons.delete,
                                                      color: CupertinoColors.systemRed,
                                                      size: 25,
                                                      //Icons.delete,color: CupertinoColors.systemRed,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ]
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
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: SizedBox(
                        height: size(buildContext).height * 0.35,
                        width: size(buildContext).width,
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          color: boxcolor,
                          child: DottedBorder(
                            color: inputbor1dercolor,
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
                                          Expanded(
                                            //TODO 06/04/2022
                                              child: SizedBox(
                                                width: size(context).width,
                                                child: InkWell(
                                                  onTap: (){
                                                    if (firstDocument?.isApproved == '1') {
                                                      if (secondDocument != null) {
                                                        openImagePreview(secondDocument);
                                                      } else {
                                                        openFilePick(2, setState);
                                                      }
                                                    } else {
                                                      if (secondDocument != null &&
                                                          secondDocument?.isApproved != '1') {
                                                        openImagePreview(secondDocument);
                                                      } else {
                                                        AppUtil.toast(
                                                            resource.documentForVerification.tr);
                                                      }
                                                    }
                                                  },
                                                  child: getDocUrl(
                                                      secondDocument, isFirstDoc: false),
                                                ),
                                              )),
                                          if (secondDocument != null) ...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                if (secondDocument?.isApproved == '1') ...[
                                                  SizedBox(
                                                      width: 100,
                                                      child: SvgPicture.asset(
                                                          ImageRes.verifiedSVG)),
                                                ] else ...[
                                                  SizedBox(
                                                      width: 100,
                                                      child: SvgPicture.asset(
                                                          ImageRes.unverifiedSVG)),
                                                  GestureDetector(
                                                    onTap: () {
                                                      DialogUtils.showDeleteDailogForUser(context,resource.deleteUserDocTitle.tr,resource.deleteUserDocContent.tr,resource.ok.tr,(bool action) {
                                                        if (action) {
                                                          deleteMyDocument(
                                                              secondDocument!, 2,
                                                              onDeleteSuccess: () {
                                                                postController.resetMailData(postData, isFromPost,secondDocument!.docType??'');
                                                                secondDocument = null;
                                                                setState(() {});
                                                              });
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.only(top: 8,bottom: 8,left: 15,right: 15),
                                                      child: Visibility(
                                                        visible: secondDocument != null &&
                                                            secondDocument!.isApproved != '1',
                                                        child: const Icon(
                                                          CupertinoIcons.delete,
                                                          color: CupertinoColors.systemRed,
                                                          size: 25,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ]
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
                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
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

  void deleteMyDocument(Transaction tra, int docNum,
      {required Function()? onDeleteSuccess}) {
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
      }
    });
  }
  void deleteDocument(Map<String, dynamic> deleteProductTransactionJson,
      Function(GeneralResponse genResponse) onResponse) {
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
  void openFilePick(int docNum, StateSetter setState) async {
    XFile? pickedFile;

    var isPermisssion =
    await userDefault.readBool(UserDefault.kImagePermissionDenied);

    if (isPermisssion) {
      try {
        pickedFile = await pickImages(pickedFile, context);
      } catch (e) {
        if ((e as PlatformException).message ==
            resource.photoPermission) {
          userDefault.saveBool(UserDefault.kImagePermissionDenied, true);
          opnDialog(context);
        }
        print(e);
      }
    } else {
      try {
        pickedFile = await pickImages(pickedFile, context);
      } catch (e) {
        if ((e as PlatformException).message ==
            resource.photoPermission) {
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
      DialogUtils.showDeleteDailogForUser(context,resource.uploadUserDocTitle.tr,resource.uploadUserDocContent.tr,resource.ok.tr,(bool action) {
        if (action) {
          uploadMyDocument(name, docNum,
              onuploadsuccess: (List<Transaction>? data) {
                if (data == null) {
                  return;
                }

                postData.transaction ??= [];
                try {
                  // postData.transaction!.clear();
                  // postData.transaction!.addAll(data);

                  if (docNum == 1) {
                    var firstData =
                    data.firstWhereOrNull((element) => element.docType == '1');
                    if (firstData != null) {
                      postData.transId ??= firstData.transId;
                      firstDocument = firstData;
                      postData.transaction!.add(firstData);
                    }
                    postController.addPostData(postData);
                  } else {
                    var secondData =
                    data.firstWhereOrNull((element) => element.docType == '2');
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

  void updateSimilarRecord() {
    postController.modifyPostData(postData, isFromPost);
  }

  void uploadMyDocument(String name, int docNum,
      {required Function(List<Transaction>? data) onuploadsuccess}) {
    postData.transaction ??= [];
    Map<String, dynamic> uploadDocumentRequestJson = {
      RequestTransaction.kUserDocument: name,
      RequestTransaction.kUserEmail: _user!.userEmail,
      RequestTransaction.kUserDocumentType: docNum,
      RequestTransaction.kPostId: postData.postid,
      RequestTransaction.kPostTitle: postData.postTitle,
    };

    log('uploadDocumentRequestJson $uploadDocumentRequestJson');
    uploadDocument(uploadDocumentRequestJson,
        onUpload: (List<Transaction>? data) {
          if (data != null) {
            onuploadsuccess(data);
            if(docNum == 1){
              Dailog1(context, resource.productpurchaseuploadscreenshot.tr, resource.checkstatus.tr);
            }else{
              Dailog1(context, resource.productreviewuploadscreenshot.tr, resource.checkstatus.tr);
            }
          }
        });
  }

/*  String getDocName(Transaction? doc, [bool isFirstDoc = true]) {
    *//* if (doc == null) {
      return '${'document'.tr} ${isFirstDoc ? 'Product' : 'Review'}';
    } else {
      if (doc.docPhoto == null) {
        return '${'document'.tr} ${isFirstDoc ? 'Product' : 'Review'}';
      } else {
        return doc.docPhoto!.split('/').last;
      }
    } *//*
    if (doc!.docPhoto != null) {
      return resource.userDocTitleForUploading + (isFirstDoc ? resource.purchase : resource.review);
    } else {
      return resource.userDocTitleForUploading + (isFirstDoc ? resource.purchase : resource.review);
    }
  }*/

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
          Image(image: ImageRes.uploadimage,height: 60),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              isFirstDoc
                  ? resource.uploadPurchase.tr.toUpperCase()
                  : resource.uploadReview.tr.toUpperCase(),
              style: TextStyle(
                  letterSpacing: 1.2,
                  color: lablecolor,
                  fontFamily: narrowbold),
            ),
          )
        ],
      );
    }
    if (doc != null && doc.docPhoto != null) {
      return Center(
          child: SizedBox(
            width: size(context).width,
            child: Image.network(
              doc.docPhoto.toString(),
             // fit: BoxFit.fill,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                }
                return const SizedBox(
                    width: 50,
                    height: 50,
                    child: Center(child: CupertinoActivityIndicator()));
              },
              errorBuilder:
                  (BuildContext context, Object exception, StackTrace? stackTrace) {
                return Image(
                  image: ImageRes.noImageFound,
                  fit: BoxFit.fill,
                );
              },
            ),
          ));
    } else {
      return SizedBox(
        width: size(context).width * 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Image(
            image: ImageRes.noImageFound,
            fit: BoxFit.fill,
          ),
        ),
      );
    }
  }

  void Dailog1(BuildContext buildContext, String verifyAccount,String okButton) {
    return DialogUtils.showDailogForUser(buildContext, verifyAccount,okButton, (bool action) {
      if (action) {
      /*  Get.to(() =>
        const MailScreen());*/
      Navigator.of(context).pop(true);
      }
    });
  }

  void uploadDocument(Map<String, dynamic> uploadDocumentRequestJson,
      {Function(List<Transaction>? data)? onUpload}) {
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

  Future<XFile?> pickImages(XFile? pickedFile, BuildContext context) async {
    try {
      pickedFile = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 768,
          imageQuality: 100);
    } catch (e) {
      if ((e as PlatformException).message ==
          resource.photoPermission.tr) {
        userDefault.saveBool(UserDefault.kImagePermissionDenied, true);
        opnDialog(context);
      }
    }
    return pickedFile;
  }

  void opnDialog(BuildContext context) {
    DialogUtils.showAlertDialog(
        context,
        resource.pickImagePermission.tr,
        resource.accessPhotoPermission.tr,
        'App Settings',
        'No', () async {
      Navigator.of(context).pop();
      openAppSettings();
    });
  }

}
