import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:rate_review/ui/component/icon_outline_button.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import '../screen/dashboard_screen.dart';
import '../screen/post_detail_screen.dart';
import 'error_dialog.dart';

class DialogUtils {

  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black26,
        builder: (BuildContext context) {
          return Center(
            widthFactor: 70,
            heightFactor: 70,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Colors.black,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      backgroundColor: Colors.black,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(resource.pleaseWaitMessage.tr,
                          style: TextStyle(
                              fontFamily: primaryFF,
                              color: Colors.white,
                              fontSize: normalFontSize)),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  static CupertinoActionSheetAction InfoList(context, ttl, index, title) {
    return CupertinoActionSheetAction(
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Text(title,
                  style: TextStyle(
                      fontSize: smallFontSize,
                      color: headingTextColor,
                      fontFamily: primaryFF),
                  textAlign: TextAlign.start),
            ),
          ],
        ),
      ),
      onPressed: () async {
        Navigator.pop(context);
      },
    );
  }


  static Future<void> showLoadingDialogbottom(BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(key: key, children: <Widget>[
                Center(
                  child: Column(children: [
                    const CircularProgressIndicator(
                        backgroundColor: primaryColor,
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white70)),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(resource.pleaseWaitMessage.tr,
                      style: const TextStyle(color: primaryColor),
                    )
                  ]),
                )
              ]));
        });
  }

  static void showDailogForUser(BuildContext context, String title,String dailogokbutton, Function(bool action) action, {bool? islatterbutton, bool? isDailogeCancle } ) {
    Text titleText = Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold,height: 1.4),
      textAlign: TextAlign.center,
    );

    // show the dialog
    showDialog(

      barrierDismissible: (isDailogeCancle ?? false),
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: titleText,
          actions: [
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: !(islatterbutton ?? false),
                  child: Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        action(false);
                        Navigator.pop(ctx);
                        //TODO 07/04/2022
                        if(isCheck == true){
                        Get.offAll(() => DashboardScreen());
                        }
                      },
                      child: Container(
                          margin: const EdgeInsets.only(
                              left: 10,right: 10,bottom: 15),
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 1),
                              child:  Text(
                                resource.laterBtnText.tr.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 18,
                                    letterSpacing: 2,
                                    fontFamily: narrowbold,
                                    fontWeight: FontWeight.w600,
                                    color: CupertinoColors.white),
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      action(true);
                    },
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 0,right: 10,bottom: 15),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 1),
                            child:
                            Text(dailogokbutton.toUpperCase(), textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18,
                                  letterSpacing: 2,
                                  fontFamily: narrowbold,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static void showDeleteDailogForUser(BuildContext context, String title,String subTitle,String? btnText, Function(bool action) action ) {
    Text titleText = Text(
      title,
      style:  TextStyle(fontFamily: narrowbold,height: 1.2),
      textAlign: TextAlign.center,
    );
    Text subTitleText = Text(
      subTitle,
      style:  const TextStyle(fontWeight: FontWeight.bold,height: 1.4),
      textAlign: TextAlign.center,
    );

    // show the dialog
    showDialog(

      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: titleText,
          content: subTitleText,
          actions: [
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await Future.delayed(const Duration(milliseconds: 500));
                      action(false);
                    },
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 10,right: 10,bottom: 15),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 1),
                            child:  Text(
                              resource.cancel.tr.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 4,
                                  fontFamily: narrowbold,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white),
                            ),
                          ),
                        )),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(ctx);
                      await Future.delayed(const Duration(milliseconds: 500));
                      action(true);
                    },
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 0,right: 10,bottom: 15),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 1),
                            child:
                            Text(btnText!.toUpperCase(), textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 4,
                                  fontFamily: narrowbold,
                                  fontWeight: FontWeight.w600,
                                  color: CupertinoColors.white),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static Future<String> showInputAlertDialog(BuildContext context, String title,
      String positive, String negative, hintText, username, userEmail) async {
    TextEditingController _textFieldController = TextEditingController();
    _textFieldController.text = username.toString().trim();

    var changedValue;
    Platform.isIOS
        ? changedValue = await showCupertinoDialog<String>(
            barrierDismissible: false,
            context: context,
            builder: (_) => CupertinoAlertDialog(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              fontFamily: primaryFF,
                              color: headingTextColor,
                              fontSize: normalFontSize,
                              fontWeight: FontWeight.w600)),
                      Text(userEmail,
                          style: TextStyle(
                              fontFamily: primaryFF,
                              color: greyTextColor,
                              fontSize: normalFontSize,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      placeholder: '${resource.enter.tr} $hintText',
                      controller: _textFieldController,
                      autofocus: false,
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(negative,
                            style: TextStyle(
                                fontFamily: primaryFF,
                                color: Colors.red,
                                fontSize: normalFontSize,
                                fontWeight: FontWeight.w700))),
                    TextButton(
                        onPressed: () {
                          if (_textFieldController.text.isEmpty) {
                            AppUtil.toast('$hintText ${resource.isRequired.tr}');
                            return;
                          }
                          Navigator.of(context).pop(_textFieldController.text);
                        },
                        child: Text(positive,
                            style: TextStyle(
                                fontFamily: primaryFF,
                                color: buttonBackColor,
                                fontSize: normalFontSize,
                                fontWeight: FontWeight.w700)))
                  ],
                ))
        : changedValue = await showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AlertDialog(
                titlePadding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                backgroundColor: Colors.white,
                title: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(title,
                            style: TextStyle(
                                fontFamily: primaryFF,
                                color: yesFont,
                                fontSize: largeFontSize,
                                fontWeight: FontWeight.w700)),
                      ),
                      Container(
                        height: 1,
                        color: Colors.grey[300],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(userEmail,
                                style: TextStyle(
                                    fontFamily: primaryFF,
                                    color: dialogFont,
                                    fontSize: smallFontSize,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Material(
                            color: bottomBg,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                controller: _textFieldController,
                                autofocus: false,
                                decoration: InputDecoration(
                                  hintText: '${resource.enter.tr} $hintText',
                                  border: InputBorder.none,
                                  fillColor: backgroundColor,
                                  hintStyle:
                                      const TextStyle(color: Colors.black26),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 110,
                                    margin: const EdgeInsets.only(right: 5),
                                    child: IconsOutlineButton(
                                      color: Colors.white,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      text: negative,
                                      textStyle: const TextStyle(
                                          color: noFont,
                                          fontWeight: FontWeight.w600,
                                          fontSize: normalFontSize),
                                      iconColor: Colors.grey,
                                    ),
                                  ),
                                  Container(
                                    width: 110,
                                    margin: const EdgeInsets.only(left: 5),
                                    child: IconsOutlineButton(
                                      color: bgYes,
                                      onPressed: () {
                                        if (_textFieldController.text.isEmpty) {
                                          AppUtil.toast(
                                              '$hintText ${resource.isRequired.tr}');
                                          return;
                                        }
                                        Navigator.of(context)
                                            .pop(_textFieldController.text);
                                      },
                                      text: positive,
                                      textStyle: const TextStyle(
                                          color: yesFont,
                                          fontWeight: FontWeight.w600,
                                          fontSize: normalFontSize),
                                      iconColor: yesBorder,
                                    ),
                                  ),
                                ]),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
    return changedValue;
  }

  static Future<bool?> displayDialog(
      BuildContext context, String title, String content) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
          ),
        );
      },
    );
  }

  static void closeButtonDialog(
      BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(resource.close.tr))
              ]);
        });
  }

  static void callbackDialog(
      BuildContext context, String title, String content, onPressed) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                TextButton(onPressed: onPressed, child: Text(resource.close.tr))
              ]);
        });
  }

  static void showProgressDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: const Color(0x01000000),
        builder: (BuildContext context) {
          return Center(
            child: Container(
              width: 50.0,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(.15),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: CupertinoActivityIndicator(animating: true),
              ),
            ),
          );
        });
  }

  static void hideProgressDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static void okDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message,
            style: TextStyle(fontFamily: primaryFF, fontSize: 20)),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(resource.ok.tr.toUpperCase(),
                style: TextStyle(fontFamily: primaryFF, fontSize: 20)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

/*  static void showInternetDialog(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: Text(resource.unableToConnect),
            content: Text(resource.noInternetMessage),
            actions: [
              CupertinoButton(
                child: Text(
                  resource.ok.tr.toUpperCase(),
                  style: const TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (context != null)
                    Navigator.of(context, rootNavigator: true).pop();
                },
              )
            ],
          );
        },
      );
    } else {
      Widget continueButton = TextButton(
        child: Text(resource.ok.tr.toUpperCase()),
        onPressed: () {
          if (context != null) Navigator.of(context, rootNavigator: true).pop();
        },
      );

      AlertDialog alert = AlertDialog(
        title: Text(resource.unableToConnect),
        content: Text(resource.noInternetMessage),
        actions: [
          continueButton,
        ],
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }*/

  static void showInternetDialog(BuildContext context, bool internet, {Function? onCloseTap}) {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text( internet == true ? '' : resource.unableToConnect.tr),
          content: Text(internet == true ? resource.socketException.tr : resource.noInternetMessage.tr),
          actions: [
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      if (onCloseTap != null) onCloseTap();
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    child: Container(
                        margin: const EdgeInsets.only(
                            left: 70,right: 70,bottom: 15),
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
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 1),
                            child:
                            Text(internet == true ? resource.tryAgain.tr.toUpperCase() :  resource.ok.tr.toUpperCase(), textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.bold,
                                  color: CupertinoColors.white),
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  static const TextStyle titleStyle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

  static const Color bcgColor = Color(0xfffefefe);

  static const Widget holder = SizedBox(
    height: 0,
  );

  static const ShapeBorder dialogShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)));

  static void showActionAlert(BuildContext context,
      {required String title,
      required String message,
      required Function(bool action) action}) {
    Text titleText = Text(title);
    Text content = Text(message);

    if (Platform.isIOS) {
      // show the dialog
      showCupertinoDialog(
        context: context,
        builder: (BuildContext ctx) {
          return CupertinoAlertDialog(
            title: titleText,
            content: content,
            actions: [
              CupertinoButton(
                  child: Text(resource.cancel.tr.toUpperCase(),
                      style: const TextStyle(color: CupertinoColors.systemRed)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Future.delayed(const Duration(milliseconds: 500));
                    action(false);
                  }),
              CupertinoButton(
                child: Text(
                  resource.ok.tr.toUpperCase(),
                  style: const TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Future.delayed(const Duration(milliseconds: 500));
                  action(true);
                },
              )
            ],
          );
        },
      );
    } else {
      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: titleText,
            content: content,
            actions: [
              TextButton(
                  child: Text(resource.cancel.tr.toUpperCase()),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Future.delayed(const Duration(milliseconds: 500));
                    action(false);
                  }),
              TextButton(
                child: Text(resource.ok.tr.toUpperCase()),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await Future.delayed(const Duration(milliseconds: 500));
                  action(true);
                },
              ),
            ],
          );
        },
      );
    }
  }

  /// show loading Dialog
  static void loadingDialog(BuildContext context, {Function()? onCloseTap}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: const Color(0x01000000),
        builder: (BuildContext context) {
          return Center(
            child: Container(
              width: 40,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(.50),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const CircularProgressIndicator(color: Colors.white),
            ),
          );
        });
  }

  /// hide loading Dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Error Dialog with message
  static void showErrorDialog(BuildContext context, String errorString, String btnName,
      {String? titleString, Function? onCloseTap}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(
            onCloseTap: onCloseTap,
            message: errorString,
            title: titleString ?? resource.error.tr,
            btnName: btnName);
      },
      barrierDismissible: false,
    );
  }

  /// No Internet Dialog with message
/*  static void noInternetDialog(BuildContext context, {Function()? onCloseTap}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NoInternetDialog(onCloseTap: onCloseTap);
      },
      barrierDismissible: false,
    );
  }*/

  static void showAlertDialog(BuildContext context, String title,
      String content, String positive, String negative, onItemClick) {
    showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: Column(
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(content,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              actions: [
                // Close the dialog
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(negative,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w700))),
                TextButton(
                    onPressed: onItemClick,
                    child: Text(positive,
                        style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)))
              ],
            ));
  }
}
