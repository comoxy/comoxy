import 'dart:collection';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/helper/notification.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/screen/dashboard_screen.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';

import 'personal_detail_screen.dart';

class RequiredDetailScreen extends StatefulWidget {
  final User user;
  const RequiredDetailScreen({Key? key,required this.user}) : super(key: key);

  @override
  _RequiredDetailScreenState createState() => _RequiredDetailScreenState();
}

class _RequiredDetailScreenState extends State<RequiredDetailScreen> {

  //TextEditingController ageController = TextEditingController();
  final TextEditingController _ethnicityEditingController = TextEditingController();
  final TextEditingController _genderEditingController = TextEditingController();
  final TextEditingController _dateEditingController = TextEditingController();
  final TextEditingController _homeCountryEditingController = TextEditingController();
  int _selectedEthnicityIndex = 0;
  int _selectedGenderIndex = 0;
  final dobKey = GlobalKey();
  DateTime? _selectedDate;
  String? dobVal;
  bool hasPushNotification = true;
  int _selectedHomeCountryIndex = 0;
  var _selectedCurrency = 'Currency';

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  bool hasAgreeTC = false;

  MethodChannelHandler methodChannelHandler = Get.find();
  User? user;

  final AuthModel _authProvider = Get.find();
  final UserDefault userDefault = Get.find();

  final GlobalKey<State> _globalKey = GlobalKey<State>();

  //UserGender selectedGender = UserGender.MALE;

  @override
  void initState() {
    user = widget.user;
    super.initState();
  }

  @override
  Widget build(BuildContext buildContext) {
    double height = size(context).height;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ... AppToolbar(context,
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(
                          CupertinoIcons.back,
                          color: CupertinoColors.white,
                            size: 37
                        )),
                    Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              resource.detailTitle.tr.toUpperCase(),
                              style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17.0,
                                  letterSpacing: 4.0),
                            ))),
                  ],
                  showStatusBar: true),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: height* 0.02,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                focusNode: AlwaysDisabledFocusNode(),
                                controller: _genderEditingController,
                                textAlign: TextAlign.center,
                                style: mTextFieldTS,
                                decoration: inputInputDecoration(placeholder: resource.genderPlaceholder.tr),
                                keyboardType: TextInputType.text,
                                onTap: () async {
                                  AppUtil.bottomPicker(buildContext,
                                      childrens: AppUtil.gender,
                                      selectedIndex: _selectedGenderIndex, onDone: (Text text) {
                                        _genderEditingController.text = text.data.toString();
                                      },
                                      onSelectedItemChanged: (int index) {
                                        setState(() {
                                          _selectedGenderIndex = index;
                                        });
                                      }
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: height* 0.02,
                            ),
/*                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                controller: ageController,
                                autofocus: false,
                                maxLines: 1,
                                maxLength: 3,
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0123456789]"))],
                                keyboardType: TextInputType.phone,
                                style: mTextFieldTS,
                                decoration: inputInputDecoration(placeholder: 'age'.tr).copyWith(
                                  hintText: '${'enter'.tr} ${'age'.tr}',
                                  counterText: '',
                                ),
                              ),
                            ),*/
                            // TODO 14/03/2022 REMOVE AGE FIELD AND ADD DATE FIELD
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: TextFormField(
                                key: dobKey,
                                focusNode: AlwaysDisabledFocusNode(),
                                controller: _dateEditingController,
                                textAlign: TextAlign.center,
                                decoration: inputInputDecoration(
                                    placeholder: resource.dateOfBirthPlaceholder.tr)
                                    .copyWith(errorText: dobVal),
                                style: mTextFieldTS,
                                onChanged: (value) {
                                  if (dobVal != null) {
                                    dobVal = null;
                                    setState(() {});
                                  }
                                },
                                onTap: () {
                                  _selectDate(context);
                                },
                              ),
                            ),
                            //OVER
                            SizedBox(
                              height: height* 0.02,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TextField(
                                focusNode: AlwaysDisabledFocusNode(),
                                controller: _ethnicityEditingController,
                                style: mTextFieldTS,
                                textAlign: TextAlign.center,
                                decoration: inputInputDecoration(placeholder: resource.ethnicityPlaceholder.tr),
                                keyboardType: TextInputType.text,
                                onTap: () async {
                                  AppUtil.bottomPicker(buildContext,
                                      childrens: AppUtil.allEthinicity,
                                      selectedIndex: _selectedEthnicityIndex, onDone: (Text text) {
                                        _ethnicityEditingController.text = text.data.toString();
                                      },
                                      onSelectedItemChanged: (int index) {
                                        setState(() {
                                          _selectedEthnicityIndex = index;
                                        });
                                      }
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: height* 0.02,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10),
                              child: TextFormField(
                                focusNode: AlwaysDisabledFocusNode(),
                                textAlign: TextAlign.center,
                                decoration: inputInputDecoration(
                                    placeholder:
                                    resource.homeCountryPlaceholder.tr),
                                style: mTextFieldTS,
                                controller: _homeCountryEditingController,
                                onTap: () async {
                                  AppUtil.bottomPicker(buildContext,
                                      childrens: AppUtil.allCountries,
                                      selectedIndex:
                                      _selectedHomeCountryIndex,
                                      onDone: (Text text) {
                                        setState(() {
                                          _homeCountryEditingController.text = text.data.toString();

                                          if (text.data.toString() == 'United Kingdom') {
                                            _selectedCurrency = AppUtil.getCurrency(text.data.toString());
                                          } else if (text.data.toString() == 'United States') {
                                            _selectedCurrency = AppUtil.getCurrency(text.data.toString());
                                          } else if (text.data.toString() == 'Egypt') {
                                            _selectedCurrency = AppUtil.getCurrency(text.data.toString());
                                          } else if (text.data.toString() == 'United Arab Emirates') {
                                            _selectedCurrency = AppUtil.getCurrency(text.data.toString());
                                          } else if (text.data.toString() == 'Saudi Arabia') {
                                            _selectedCurrency = AppUtil.getCurrency(text.data.toString());
                                          } else if (AppUtil.countryList.contains(text.data.toString())) {
                                            _selectedCurrency = AppUtil.getCurrency(text.data.toString());
                                          } else {
                                            _selectedCurrency = AppUtil.Currencydata[0].currency!;
                                          }
                                        });
                                      }, onSelectedItemChanged: (int index) {
                                        _selectedHomeCountryIndex = index;
                                      });
                                },
                              ),
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: IgnorePointer(
                                ignoring: true,
                                child: InputDecorator(
                                  textAlign: TextAlign.center,
                                  decoration: inputInputDecoration(
                                      placeholder:
                                      resource.homeCountryPlaceholder.tr),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      isDense: true,
                                      value: _selectedCurrency,
                                      style: mTextFieldTS,
                                      icon: const Icon(
                                        Icons.arrow_drop_down,
                                        size: 0,
                                      ),
                                      items: AppUtil.currencyList,
                                      onChanged: (String? val) {
                                        setState(() {
                                          _selectedCurrency = val!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(resource.pushNotification.tr,
                                      style: const TextStyle(
                                        color: lablecolor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Switch.adaptive(
                                      value: hasPushNotification,
                                      onChanged: (_value) {
                                        if (hasPushNotification != _value) {
                                          setState(() {
                                            hasPushNotification = _value;
                                          });
                                        }
                                      },
                                    activeColor: CupertinoColors.activeGreen,
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  color: CupertinoColors.white
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Visibility(
                                visible: false,// TODO unhide and set tc url
                                child: InAppWebView(
                                  key: webViewKey,
                                  initialUrlRequest: URLRequest(url: Uri.parse("https://github.com/flutter")),
                                  initialUserScripts: UnmodifiableListView<UserScript>([]),
                                  initialOptions: options,
                                  onWebViewCreated: (controller) {
                                    webViewController = controller;
                                  },
                                  onLoadStart: (controller, url) {
                                    /*setState(() {
                                          this.url = url.toString();
                                          urlController.text = this.url;
                                        });*/
                                  },
                                  androidOnPermissionRequest: (controller, origin, resources) async {
                                    return PermissionRequestResponse(
                                        resources: resources, action: PermissionRequestResponseAction.GRANT);
                                  },
                                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                                    return NavigationActionPolicy.ALLOW;
                                  },
                                  onLoadStop: (controller, url) async {
                                    /*pullToRefreshController.endRefreshing();
                                        setState(() {
                                          this.url = url.toString();
                                          urlController.text = this.url;
                                        });*/
                                  },
                                  onLoadError: (controller, url, code, message) {
                                    /*pullToRefreshController.endRefreshing();*/
                                  },
                                  onProgressChanged: (controller, progress) {
                                    /*if (progress == 100) {
                                          pullToRefreshController.endRefreshing();
                                        }
                                        setState(() {
                                          this.progress = progress / 100;
                                          urlController.text = this.url;
                                        });*/
                                  },
                                  onUpdateVisitedHistory: (controller, url, androidIsReload) {
                                    /*setState(() {
                                          this.url = url.toString();
                                          urlController.text = this.url;
                                        });*/
                                  },
                                  onConsoleMessage: (controller, consoleMessage) {
                                    log('consoleMessage $consoleMessage');
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: size(context).height * 0.5,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    heightFactor: 9,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          checkColor: Colors.white,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          fillColor: MaterialStateProperty.all(primaryColor),
                                          value: hasAgreeTC,
                                          shape: const CircleBorder(),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              hasAgreeTC = value!;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          child: Text(resource.agreeTermsCondition.tr,
                                            style: const TextStyle(
                                              color: greyTextColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: GestureDetector(
                                      onTap: () async {
                                        String ageStr = _dateEditingController.text.trim();
                                        if (_genderEditingController.text.isEmpty) {
                                          Get.closeAllSnackbars();
                                          Get.showSnackbar(GetSnackBar(
                                            title: resource.missingTitle.tr,
                                            message: resource.genderValidation.tr,
                                            barBlur: 100,
                                            duration: const Duration(milliseconds: 1500),
                                            isDismissible: true,
                                            snackPosition: SnackPosition.BOTTOM,
                                          ));
                                          return;
                                        }
                                        if (ageStr.isEmpty) {
                                          Get.closeAllSnackbars();
                                          Get.showSnackbar(GetSnackBar(
                                            title: resource.missingTitle.tr,
                                            message: resource.dateOfBirthValidation.tr,
                                            barBlur: 100,
                                            duration: const Duration(milliseconds: 1500),
                                            isDismissible: true,
                                            snackPosition: SnackPosition.BOTTOM,
                                          ));
                                          return;
                                        }
                                        if (_ethnicityEditingController.text.isEmpty) {
                                          Get.closeAllSnackbars();
                                          Get.showSnackbar(GetSnackBar(
                                            title: resource.missingTitle.tr,
                                            message: resource.ethinicityValidation.tr,
                                            barBlur: 100,
                                            duration: const Duration(milliseconds: 1500),
                                            isDismissible: true,
                                            snackPosition: SnackPosition.BOTTOM,
                                          ));
                                          return;
                                        }
                                        if (_homeCountryEditingController.text.isEmpty) {
                                          Get.closeAllSnackbars();
                                          Get.showSnackbar(GetSnackBar(
                                            title: resource.missingTitle.tr,
                                            message: resource.homeCountryValidation.tr,
                                            barBlur: 100,
                                            duration: const Duration(milliseconds: 1500),
                                            isDismissible: true,
                                            snackPosition: SnackPosition.BOTTOM,
                                          ));
                                          return;
                                        }
                                        if (!hasAgreeTC) {
                                          Get.closeAllSnackbars();
                                          Get.showSnackbar(GetSnackBar(
                                            title: resource.agreementTitle.tr,
                                            message: resource.termsAndConditionValidation.tr,
                                            barBlur: 100,
                                            duration: const Duration(milliseconds: 1500),
                                            isDismissible: true,
                                            snackPosition: SnackPosition.BOTTOM,
                                          ));
                                          return;
                                        }

                                        bool _hasInternet = await AppUtil.isInternetAvailable(context);
                                        if (!_hasInternet) {
                                          return;
                                        }
                                        handleNewProfile(buildContext);
                                      },
                                      child: Container(
                                        height: 70,
                                        width: size(context).width * 0.8,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [btnEndColor, btnStartColor],
                                            begin: Alignment.topLeft,
                                            end: Alignment.topRight,
                                          ),
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        child: Center(
                                          child: Text(
                                            resource.submit.tr.toUpperCase(),
                                            style: const TextStyle(
                                                color:Colors.white,
                                                fontSize: 28,
                                                letterSpacing: 3
                                            ),
                                          ),
                                        ),
                                      ),
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
              SizedBox(height: bottomViewPad(context),)
            ]),
      ),
    );
  }


  Future handleNewProfile(BuildContext context) async {

    //String ageStr = _dateEditingController.text.trim();
    String ethnicity = _ethnicityEditingController.text.trim();
    String gender = _genderEditingController.text.trim();
    String country = _homeCountryEditingController.text.trim();
    //int? age = int.tryParse(ageStr);

    Map<String, dynamic> userLoginSignUpRequestJson = {
      "user_email" : user!.userEmail,
      "gender" : gender,
      //"age" : age??0,
      "dateof_birth": _selectedDate!.millisecondsSinceEpoch,
      "push_notification" : hasPushNotification,
      "ethnicity" : ethnicity,
      "home_country" : country,
      "currency_code" : _selectedCurrency
    };

    var userSignUp = await _authProvider.newProfileUpdate(
      context: context,
      keyLoader: _globalKey,
      userLoginSignUpRequestJson: userLoginSignUpRequestJson,
      apiName: ServiceUrl.kNewProfileUpdate,
    );
    if (userSignUp != null) {
      if (userSignUp.status!.isTrue) {
        User _user = userSignUp.data??user!;
        _user.user_password = user!.user_password;
        userDefault.saveUser(_user);
        userDefault.setUser(_user);
        // userDefault.setUser = user;
        var fToken = await UserDefault().readString(UserDefault.kFirebaseToken);
        if (fToken != null) {
          await _authProvider.saveTokenOnServer(fToken);
          FCM().fcmSubscribe();
        }
        Get.offAll(() =>  DashboardScreen());
      }
    }
  }
// TODO 14/03/2022 DATE FUNCTION
  void _selectDate(BuildContext context) async {
    DateTime date = DateTime.now();
    var newDate = DateTime(date.year - 21, date.month, date.day);
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(newDate.year - 1),
      firstDate: DateTime(1950),
      lastDate: DateTime(newDate.year,newDate.month,newDate.day),
    );

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      setupSelectedDate();
    }
  }

  void setupSelectedDate() {
    _dateEditingController
      ..text = DateFormat.yMMMd().format(_selectedDate!)
      ..selection = TextSelection.fromPosition(TextPosition(
          offset: _dateEditingController.text.length,
          affinity: TextAffinity.upstream));
  }
//OVER

/*  TextStyle selectionStyle(UserGender sGen) {
    return TextStyle(
        color: selectedGender == sGen ? const Color(0xfffbfbfb) : const Color(0xff888888),
        fontFamily: primaryFF,
        fontWeight: FontWeight.bold,
        fontSize: 15,
        letterSpacing: 1);
  }

  BoxDecoration selectionDecoration(UserGender sLang) {
    return (selectedGender == sLang)
        ? BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xff2d9bd3), Color(0xff47d8ee)]),
        borderRadius: BorderRadius.circular(50))
        : BoxDecoration(color: CupertinoColors.white, borderRadius: BorderRadius.circular(50));
  }*/

}
