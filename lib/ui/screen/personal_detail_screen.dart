import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/document/document_data.dart';
import 'package:rate_review/model/general_response.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/service/auth.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/dialog/dialog_utils.dart';
import 'package:rate_review/ui/screen/image_preview_screen.dart';
import 'package:rate_review/ui/screen/post_detail_screen.dart';
import 'package:rate_review/util/common.dart';
import 'package:rate_review/util/string_resource.dart';
import 'package:rate_review/util/theming.dart';
import 'package:intl/intl.dart';
import '../component/border/dotted_border.dart';
import 'dashboard_screen.dart';

class PersonalDetailScreen extends StatefulWidget {
  final User user;
  final bool verifyAcc;
  final bool? isFirstTime;
  final String isFrom;

  const PersonalDetailScreen({Key? key, required this.user, required this.verifyAcc, this.isFirstTime, required this.isFrom})
      : super(key: key);

  @override
  _PersonalDetailScreenState createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
  int? groupValue = 0;
  DateTime? _selectedDate;
  String? mobileVal;
  String? firstnameVal;
  String? lastnameVal;
  String? ethnicityVal;
  String? countryVal;
  String? currencyVal;
  String? genderVal;
  String? dobVal;

  final TextEditingController _firstnameEditingController = TextEditingController();
  final TextEditingController _lastnameEditingController = TextEditingController();

  //final TextEditingController _ageEditingController = TextEditingController();
  final TextEditingController _mobileEditingController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController _ethnicityEditingController = TextEditingController();
  final TextEditingController _genderEditingController = TextEditingController();
  final TextEditingController _dateEditingController = TextEditingController();
  final TextEditingController _homeCountryEditingController = TextEditingController();

  int _selectedHomeCountryIndex = 0;
  int _selectedEthnicityIndex = 0;
  int _selectedGenderIndex = 0;
  UserDefault userDefault = Get.find();
  MethodChannelHandler methodChannelHandler = Get.find();
  User? _user;
  late int calculatedAge = 0;
  var _selectedCurrency = 'Currency';

  final AuthModel _authModel = Get.find();
  final GlobalKey<State> _globalKey = GlobalKey<State>();
  DocumentData? firstDocument, secondDocument;

  final fNameKey = GlobalKey();
  final lNameKey = GlobalKey();
  final ageKey = GlobalKey();
  final mobileKey = GlobalKey();
  final dobKey = GlobalKey();
  final genderKey = GlobalKey();
  final ethnicityKey = GlobalKey();
  final countryKey = GlobalKey();
  final currencyKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  UserGender selectedGender = UserGender.MALE;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    userDefault.getUser().then((value) {
      _user = value!;
      if (widget.isFirstTime ?? false) {
        Dailog(context, resource.uploaddocumentsizetoast.tr, resource.ok.tr);
      }
    });
    checkVerifyDocument();
    setupUserData();
  }

  Future<void> checkVerifyDocument() async {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (widget.verifyAcc) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 50), curve: Curves.easeOut);
      }
    });
  }

  var verifiedDocuments;
  Future<void> setupUserData() async {
    if (_user == null) {
      _user = widget.user;
    } else {
      _user = (await userDefault.getUser())!;
    }

    if (_user!.documents != null) {
      if (_user!.documents!.isNotEmpty) {
        firstDocument = _user!.documents!.first;
        if (_user!.documents!.length > 1) {
          secondDocument = _user!.documents![1];
        }
      }
    }

    verifiedDocuments = _user?.documents?.toList().where((element) => element.isVerified == '1').toList();

    emailController.text = _user!.userEmail!;
    var fullName = _user!.userName!.split(' ');
    _firstnameEditingController.text = fullName.first.trim();
    fullName.removeAt(0);
    _lastnameEditingController.text = fullName.join(' ').trim();
    //_ageEditingController.text = _user!.age.toString();
    _mobileEditingController.text = _user!.mobile!;
    /*String gender = _user!.gender!.toUpperCase();
    if (gender == UserGender.OTHER.toString().toUpperCase().split('.').last) {
      selectedGender = UserGender.OTHER;
    } else if (gender == UserGender.FEMALE.toString().toUpperCase().split('.').last) {
      selectedGender = UserGender.FEMALE;
    } else {
      selectedGender = UserGender.MALE;
    }*/
    _ethnicityEditingController.text = _user!.ethnicity!;
    _genderEditingController.text = _user!.gender!;
    _homeCountryEditingController.text = _user!.homeCountry!;

    if (_user!.dateOfBirth != null) {
      _selectedDate = DateTime.fromMillisecondsSinceEpoch(int.tryParse(_user!.dateOfBirth!) ?? 0);
      if (_selectedDate != null) {
        setupSelectedDate();
      }
    }
    _selectedCurrency = _user!.currency! == '' ? 'AED' : _user!.currency!;
  }

  @override
  Widget build(BuildContext buildContext) {
    double height = size(context).height;
    return WillPopScope(
      onWillPop: () async {
        if (widget.isFrom == 'fromProfile') {
          Navigator.pop(context);
        } else {
          Navigator.of(context).pop(0);
        }
        return false;
      },
      child: Scaffold(
        body: Material(
          color: backgroundColor,
          child: Column(
            children: [
              ...AppToolbar(context,
                  children: [
                    IconButton(
                        onPressed: () {
                          //TODO 07/04/2022
                          if (widget.isFrom == 'fromProfile') {
                            Navigator.pop(context);
                          } else if (isCheck == true) {
                            Get.offAll(() => DashboardScreen());
                          } else {
                            Navigator.of(context).pop(0);
                          }
                        },
                        icon: Image(image: ImageRes.backIcon, height: 25, width: 25)),
                    Expanded(
                        child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              resource.personalDetails.tr.toUpperCase(),
                              style: TextStyle(
                                  color: CupertinoColors.white, fontFamily: narrowmedium, fontSize: 20, letterSpacing: 4.0),
                            ))),
                    IconButton(
                        onPressed: () {
                          handleSignIn(context);
                        },
                        icon: const Icon(
                          CupertinoIcons.refresh,
                          color: CupertinoColors.white,
                        )),
                  ],
                  showStatusBar: true),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  controller: _scrollController,
                  shrinkWrap: true,
                  children: [
                    GestureDetector(
                      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 10),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                      key: fNameKey,
                                      textAlign: TextAlign.center,
                                      controller: _firstnameEditingController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      decoration: inputInputDecoration(
                                          placeholder: resource.firstNamePlaceholder.tr)
                                          .copyWith(errorText: firstnameVal),
                                      style: mTextFieldTS,
                                      keyboardType: TextInputType.text,
                                      onChanged: (value) {
                                        if (firstnameVal != null) {
                                          firstnameVal = null;
                                          setState(() {});
                                        }
                                      },
                                      validator: (val){
                                        if(val!.isEmpty){
                                          return firstnameVal = resource.firstNameValidation.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                      key: lNameKey,
                                      textAlign: TextAlign.center,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      decoration: inputInputDecoration(placeholder: resource.lastNamePlaceholder.tr)
                                          .copyWith(errorText: lastnameVal),
                                      style: mTextFieldTS,
                                      controller: _lastnameEditingController,
                                      keyboardType: TextInputType.text,
                                      onChanged: (value) {
                                        if (lastnameVal != null) {
                                          lastnameVal = null;
                                          setState(() {});
                                        }
                                      },
                                      validator: (val){
                                        if(val!.isEmpty){
                                          return lastnameVal = resource.lastNameValidation.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  // TODO 14/03/2022 COMMENT AGE SECTION
                                  /* Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                      key: ageKey,
                                      textAlign: TextAlign.center,
                                      controller: _ageEditingController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[0123456789]"))
                                      ],
                                      keyboardType: TextInputType.phone,
                                      decoration:
                                      inputInputDecoration(placeholder: 'age'.tr)
                                              .copyWith(errorText: ageVal),
                                      style: mTextFieldTS,
                                      onChanged: (value) {
                                        if (ageVal != null) {
                                          ageVal = null;
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height* 0.02,
                                  ),*/
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                      key: mobileKey,
                                      textAlign: TextAlign.center,
                                      controller: _mobileEditingController,
                                      keyboardType: TextInputType.phone,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[+-0123456789() ]"))],
                                      decoration: inputInputDecoration(placeholder: resource.mobilePlaceholder.tr)
                                          .copyWith(errorText: mobileVal),
                                      style: mTextFieldTS,
                                      onChanged: (value) {
                                        if (mobileVal != null) {
                                          mobileVal = null;
                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      controller: emailController,
                                      decoration: inputInputDecoration(placeholder: resource.emailPlaceholder.tr),
                                      style: mTextFieldTS,
                                      enableInteractiveSelection: false,
                                      onTap: () {
                                        FocusScope.of(context).requestFocus(FocusNode());
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                      key: genderKey,
                                      focusNode: AlwaysDisabledFocusNode(),
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _genderEditingController,
                                      textAlign: TextAlign.center,
                                      decoration: inputInputDecoration(placeholder: resource.genderPlaceholder.tr)
                                          .copyWith(errorText: genderVal),
                                      style: mTextFieldTS,
                                      keyboardType: TextInputType.text,
                                      onTap: () async {
                                        AppUtil.bottomPicker(buildContext,
                                            childrens: AppUtil.gender, selectedIndex: _selectedGenderIndex, onDone: (Text text) {
                                          _genderEditingController.text = text.data.toString();
                                          if (genderVal != null) {
                                            genderVal = null;
                                            setState(() {});
                                          }
                                        }, onSelectedItemChanged: (int index) {
                                          setState(() {
                                            _selectedGenderIndex = index;
                                          });
                                        });
                                      },
                                      validator: (val){
                                        if(val!.isEmpty){
                                          return genderVal = resource.genderValidation.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                      key: ethnicityKey,
                                      focusNode: AlwaysDisabledFocusNode(),
                                      controller: _ethnicityEditingController,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      textAlign: TextAlign.center,
                                      decoration: inputInputDecoration(placeholder: resource.ethnicityPlaceholder.tr)
                                          .copyWith(errorText: ethnicityVal),
                                      style: mTextFieldTS,
                                      keyboardType: TextInputType.text,
                                      onTap: () async {
                                        AppUtil.bottomPicker(buildContext,
                                            childrens: AppUtil.allEthinicity,
                                            selectedIndex: _selectedEthnicityIndex, onDone: (Text text) {
                                          _ethnicityEditingController.text = text.data.toString();
                                          if (ethnicityVal != null) {
                                            ethnicityVal = null;
                                            setState(() {});
                                          }
                                        }, onSelectedItemChanged: (int index) {
                                          setState(() {
                                            _selectedEthnicityIndex = index;
                                          });
                                        });
                                      },
                                      validator: (val){
                                        if(val!.isEmpty){
                                          return ethnicityVal = resource.ethinicityValidation.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                      key: dobKey,
                                      focusNode: AlwaysDisabledFocusNode(),
                                      controller: _dateEditingController,
                                      textAlign: TextAlign.center,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      decoration: inputInputDecoration(placeholder: resource.dateOfBirthPlaceholder.tr)
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
                                      validator: (val){
                                        if(val!.isEmpty){
                                          return dobVal = resource.dateOfBirthValidation.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.02,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: TextFormField(
                                      key: countryKey,
                                      focusNode: AlwaysDisabledFocusNode(),
                                      textAlign: TextAlign.center,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      decoration: inputInputDecoration(placeholder: resource.homeCountryPlaceholder.tr)
                                          .copyWith(errorText: countryVal),
                                      style: mTextFieldTS,
                                      controller: _homeCountryEditingController,
                                      onTap: () async {
                                        AppUtil.bottomPicker(buildContext,
                                            childrens: AppUtil.allCountries,
                                            selectedIndex: _selectedHomeCountryIndex, onDone: (Text text) {
                                          setState(() {
                                            _homeCountryEditingController.text = text.data.toString();

                                            ///TODO Phase 2
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
                                            if (countryVal != null) {
                                              countryVal = null;
                                              setState(() {});
                                            }
                                          });
                                        }, onSelectedItemChanged: (int index) {
                                          _selectedHomeCountryIndex = index;
                                        });
                                      },
                                      validator: (val){
                                        if(val!.isEmpty){
                                          return countryVal = resource.homeCountryValidation.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: height * 0.01,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: IgnorePointer(
                                      ignoring: true,
                                      child: InputDecorator(
                                        textAlign: TextAlign.center,
                                        decoration: inputInputDecoration(placeholder: resource.homeCountryPlaceholder.tr),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton(
                                            key: currencyKey,
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
                                                if (currencyVal != null) {
                                                  currencyVal = null;
                                                  setState(() {});
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                                    child: GestureDetector(
                                      onTap: () async {
                                        // bool isValid = _isValid();
                                        if (_formKey.currentState!.validate()) {
                                          bool _hasInternet = await AppUtil.isInternetAvailable(context);
                                          if (!_hasInternet) {
                                            return;
                                          }
                                          // String ageStr = _ageEditingController.text.trim();
                                          String fName = _firstnameEditingController.text.trim();
                                          String lName = _lastnameEditingController.text.trim();
                                          String mobile = _mobileEditingController.text.trim();
                                          String ethnicity = _ethnicityEditingController.text.trim();
                                          String gender = _genderEditingController.text.trim();
                                          String homeCountry = _homeCountryEditingController.text.trim();
                                          String currency = _selectedCurrency == "Currency" ? "AED" : _selectedCurrency;

                                          Map<String, dynamic> userProfileRequestJson = {
                                            RequestParam.kUserEmail: _user!.userEmail,
                                            RequestParam.kFullName: '$fName $lName',
                                            RequestParam.kMobile: mobile,
                                            // RequestParam.kAge : int.tryParse(ageStr) ?? 0,
                                            RequestParam.kGender: gender,
                                            RequestParam.kEthnicity: ethnicity,
                                            RequestParam.kDateOfBirth: _selectedDate!.millisecondsSinceEpoch,
                                            RequestParam.kHomeCountry: homeCountry,
                                            RequestParam.kCurrency: currency,
                                          };
                                          var userUpdate = await _authModel.userProfileUpdate(
                                            context: buildContext,
                                            keyLoader: _globalKey,
                                            userProfileRequestJson: userProfileRequestJson,
                                            apiName: ServiceUrl.kUserProfileUpdate,
                                          );

                                          if (userUpdate != null) {
                                            if (userUpdate.status.isTrue) {
                                              _user!.userName = '$fName $lName';
                                              _user!.age = calculatedAge.toString();
                                              _user!.gender = gender;
                                              _user!.mobile = mobile;
                                              _user!.ethnicity = ethnicity;
                                              _user!.dateOfBirth = _selectedDate!.millisecondsSinceEpoch.toString();
                                              _user!.homeCountry = homeCountry;
                                              _user!.currency = currency;
                                              userDefault.saveUser(_user!);
                                              userDefault.setUser(_user!);
                                            }
                                          }
                                          Navigator.pop(buildContext);
                                        }
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(50.0),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              btnEndColor,
                                              btnStartColor,
                                            ],
                                          ),
                                        ),
                                        height: 80,
                                        width: MediaQuery.of(context).size.width,
                                        child: Center(
                                          child: Text(
                                            resource.submit.tr.toUpperCase(),
                                            style: boldBtnStyle,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: (verifiedDocuments == null || verifiedDocuments.isEmpty) ? true : false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10, left: 10),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      resource.userDocumentTitle.tr,
                                      style: TextStyle(fontSize: 20, letterSpacing: 1, fontFamily: narrowbook),
                                    )),
                              ),
                              documentsWidget(buildContext),
                              Visibility(
                                visible: uploadButtonVisibility(),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                                  child: GestureDetector(
                                    onTap: () {
                                      openFilePick(setState);
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(50.0),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            btnEndColor,
                                            btnStartColor,
                                          ],
                                        ),
                                      ),
                                      height: 80,
                                      width: MediaQuery.of(buildContext).size.width,
                                      child: Center(
                                        child: Text(
                                          resource.upload.tr,
                                          style: boldBtnStyle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
                                child: Text(
                                  resource.askToDocument.tr,
                                  style: mHelperTextFieldTS,
                                  //textAlign: TextAlign.center,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    /*   SizedBox(height: bottomViewPad(context),)*/
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void openFilePick(StateSetter setState) async {
    XFile? pickedFile;

    var isPermission = await userDefault.readBool(UserDefault.kImagePermissionDenied);

    if (isPermission) {
      try {
        pickedFile = await pickImages(pickedFile, context);
      } catch (e) {
        if ((e as PlatformException).message == resource.photoPermission) {
          userDefault.saveBool(UserDefault.kImagePermissionDenied, true);
          opnDialog(context);
        }
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
      DialogUtils.showDeleteDailogForUser(
          context, resource.uploadUserDocTitle.tr, resource.uploadUserDocContent.tr, resource.ok.tr, (bool action) {
        if (action) {
          uploadMyDocument(name);
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

  void uploadMyDocument(String name) {
    _user!.documents ??= [];
    Map<String, dynamic> uploadDocumentRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail,
      RequestParam.kDocOrd: _user!.documents!.isEmpty ? 1 : 2,
      RequestParam.kUserDocument: name
    };

    uploadDocument(uploadDocumentRequestJson, onUpload: (DocumentData? data) {
      if (data != null) {
        _user!.documents ??= [];
        if (_user!.documents!.isEmpty) {
          firstDocument = data;
        } else {
          secondDocument = data;
        }
        DialogUtils.showDailogForUser(context, resource.pendingverifyAccount.tr, resource.ok.tr, (action) => null,
            islatterbutton: true);
        setState(() {
          _user!.documents!.insert(_user!.documents!.isEmpty ? 0 : 1, data);

          userDefault.saveUser(_user!);
        });
      }
    });
  }

  bool uploadButtonVisibility() {
    if (_user!.documents == null) {
      return true;
    } else {
      if (_user!.documents!.isEmpty) {
        return true;
      }
      return _user!.documents!.length <= 1;
    }
  }

  Column documentsWidget(BuildContext buildContext) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: size(buildContext).height * 0.35,
            width: size(buildContext).width,
            child: Card(
              elevation: 0,
              color: boxcolor,
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
                              onTap: () {
                                openImagePreview(firstDocument);
                              },
                              child: getDocUrl(firstDocument, isFirstDoc: true),
                            ),
                          )),
                          if (firstDocument != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (firstDocument!.isVerified == '1') ...[
                                  SizedBox(width: 100, child: SvgPicture.asset(ImageRes.verifiedSVG)),
                                ] else ...[
                                  SizedBox(width: 100, child: SvgPicture.asset(ImageRes.unverifiedSVG)),
                                  GestureDetector(
                                    onTap: () {
                                      DialogUtils.showDeleteDailogForUser(context, resource.deleteUserDocTitle.tr,
                                          resource.deleteUserDocContent.tr, resource.ok.tr, (bool action) {
                                        if (action) {
                                          deleteFirstDocImage(buildContext);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                                      child: Visibility(
                                        visible: firstDocument != null && firstDocument!.isVerified != '1',
                                        child: const Icon(
                                          CupertinoIcons.delete,
                                          color: CupertinoColors.systemRed,
                                          size: 25,
                                          //Icons.delete,color: CupertinoColors.systemRed,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
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
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: size(buildContext).height * 0.35,
            width: size(buildContext).width,
            child: Card(
              elevation: 0,
              color: boxcolor,
              shape: const RoundedRectangleBorder(
                side: BorderSide(color: backgroundColor, width: 1),
              ),
              child: DottedBorder(
                borderType: BorderType.RRect,
                color: inputbor1dercolor,
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
                              onTap: () {
                                openImagePreview(secondDocument);
                              },
                              child: getDocUrl(secondDocument, isFirstDoc: false),
                            ),
                          )),
                          if (secondDocument != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (secondDocument?.isVerified == '1') ...[
                                  SizedBox(width: 100, child: SvgPicture.asset(ImageRes.verifiedSVG)),
                                ] else ...[
                                  SizedBox(width: 100, child: SvgPicture.asset(ImageRes.unverifiedSVG)),
                                  GestureDetector(
                                    onTap: () {
                                      DialogUtils.showDeleteDailogForUser(context, resource.deleteUserDocTitle.tr,
                                          resource.deleteUserDocContent.tr, resource.ok.tr, (bool action) {
                                        if (action) {
                                          deleteSecondDocImage(buildContext);
                                        }
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
                                      child: Visibility(
                                        visible: secondDocument != null && secondDocument!.isVerified != '1',
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
      ],
    );
  }

  void deleteSecondDocImage(BuildContext buildContext) {
    Map<String, dynamic> deleteDocumentRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail,
      RequestParam.kDocumentId: secondDocument!.documentId,
    };
    deleteDocument(buildContext, deleteDocumentRequestJson, (genResponse) {
      if (genResponse != null && genResponse.status.isTrue) {
        _user!.documents!.removeWhere((element) => element.documentId == secondDocument!.documentId);
        userDefault.saveUser(_user!);
        secondDocument = null;
        setState(() {});
      }
    });
  }

  void deleteFirstDocImage(BuildContext buildContext) {
    Map<String, dynamic> deleteDocumentRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail,
      RequestParam.kDocumentId: firstDocument!.documentId,
    };
    deleteDocument(buildContext, deleteDocumentRequestJson, (genResponse) {
      if (genResponse != null && genResponse.status.isTrue) {
        _user!.documents!.removeWhere((element) => element.documentId == firstDocument!.documentId);
        userDefault.saveUser(_user!);
        firstDocument = null;
        firstDocument = secondDocument;
        secondDocument = null;
        setState(() {});
      }
    });
  }

  void openImagePreview(DocumentData? data) {
    if (data != null && data.documentName != null) {
      if (data.documentName!.isNotEmpty) {
        String docImageUrl = AppUtil.getDocumentUrl(data);
        Get.to(() => ImagePreviewScreen(imageUrl: docImageUrl));
      } else {
        AppUtil.toast(resource.somethingWentWrong.tr);
      }
    }
  }

  void uploadDocument(Map<String, dynamic> uploadDocumentRequestJson, {Function(DocumentData? data)? onUpload}) {
    _authModel
        .uploadDocumentResponse(
            context: context,
            keyLoader: _globalKey,
            apiName: ServiceUrl.kUploadUserDocuments,
            uploadDocumentRequestJson: uploadDocumentRequestJson)
        .then((response) {
      if (onUpload != null) onUpload(response!.data!.first);
    });
  }

  void deleteDocument(
      BuildContext buildContext, Map<String, dynamic> deleteDocumentRequestJson, Function(GeneralResponse? gr) onResponse) {
    _authModel
        .deleteUserDocument(
            context: buildContext,
            keyLoader: _globalKey,
            deleteDocumentRequestJson: deleteDocumentRequestJson,
            apiName: ServiceUrl.kDeleteUserDocument)
        .then((result) {
      onResponse(result);
    });
  }

  String getDocName(DocumentData? doc, [bool isFirstDoc = true]) {
    if (isFirstDoc) {
      return resource.uploadGovernmentDocument.tr;
    } else {
      return resource.optionalDocument.tr.toUpperCase();
    }
  }

  Widget getDocUrl(DocumentData? doc, {Function()? onDelete, bool isFirstDoc = true}) {
    if (doc != null && doc.documentName != null) {
      String imageUrl = AppUtil.getDocumentUrl(doc);
      return SizedBox(
        width: size(context).width,
        child: Image.network(
          imageUrl,
          //fit: BoxFit.fill,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return const SizedBox(width: 50, height: 50, child: Center(child: CupertinoActivityIndicator()));
          },
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Image(
              image: ImageRes.noImageFound,
              fit: BoxFit.fill,
            );
          },
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(image: ImageRes.uploadimage, height: 60),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              getDocName(secondDocument, isFirstDoc),
              textAlign: TextAlign.center,
              style: TextStyle(letterSpacing: 1.2, color: lablecolor, fontFamily: narrowbold),
            ),
          ),
        ],
      );
    }
  }

/*  Widget getDocStatus(DocumentData? doc) {
    String status = (doc != null && doc.isVerified != null)
        ? (doc.isVerified == '1' ? 'verified'.tr : 'not_verified'.tr)
        : '';

    return Text(
      status,
      style: TextStyle(
          color: getDocStatusColor(doc), fontSize: 15, fontFamily: primaryFF),
      maxLines: 1,
    );
  }*/

/*  Color getDocStatusColor(DocumentData? doc) {
    return (doc != null && doc.isVerified != null)
        ? (doc.isVerified == '1'
            ? CupertinoColors.systemGreen
            : CupertinoColors.systemRed)
        : CupertinoColors.white;
  }*/

  // TODO 14/03/2022 DATE FUNCTION REPLACE
  void _selectDate(BuildContext context) async {
    DateTime date = DateTime.now();
    var newDate = DateTime(date.year - 21, date.month, date.day);

    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day),
      firstDate: DateTime(1950),
      lastDate: DateTime(newDate.year, newDate.month, newDate.day),
    );

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      calculateAge(_selectedDate!);
      setupSelectedDate();
    }
  }

  void setupSelectedDate() {
    _dateEditingController
      ..text = DateFormat.yMMMd().format(_selectedDate!)
      ..selection =
          TextSelection.fromPosition(TextPosition(offset: _dateEditingController.text.length, affinity: TextAffinity.upstream));
  }

  bool _isValid() {
    if (_firstnameEditingController.text.isEmpty) {
      firstnameVal = resource.firstNameValidation.tr;
      Scrollable.ensureVisible(fNameKey.currentContext!);
      setState(() {});
      return false;
    } else if (_lastnameEditingController.text.isEmpty) {
      lastnameVal = resource.lastNameValidation.tr;
      Scrollable.ensureVisible(lNameKey.currentContext!);
      setState(() {});
      return false;
    } else if (_genderEditingController.text.isEmpty) {
      genderVal = resource.genderValidation.tr;
      Scrollable.ensureVisible(genderKey.currentContext!);
      setState(() {});
      return false;
    } else if (_ethnicityEditingController.text.isEmpty) {
      ethnicityVal = resource.ethinicityValidation.tr;
      Scrollable.ensureVisible(ethnicityKey.currentContext!);
      setState(() {});
      return false;
    }
    // TODO 14/03/2022 COMMENT AGE VALIDATION

    /*else if (_ageEditingController.text.isEmpty) {
      ageVal = '${'please_enter'.tr} ${'age'.tr}';
      Scrollable.ensureVisible(ageKey.currentContext!);
      setState(() {});
      return false;
    }*/
    else if (_selectedDate == null) {
      dobVal = resource.birthDateValidation.tr;
      Scrollable.ensureVisible(dobKey.currentContext!);
      AppUtil.toast(resource.birthDateValidation.tr);
      return false;
    } else if (_homeCountryEditingController.text.isEmpty) {
      countryVal = resource.homeCountryValidation.tr;
      Scrollable.ensureVisible(countryKey.currentContext!);
      setState(() {});
      return false;
    }else {
      return true;
    }
  }

  Future handleSignIn(BuildContext context) async {
    String pwd = _user!.user_password!.trim();

    Map<String, dynamic> userLoginSignUpRequestJson = {
      RequestParam.kUserEmail: _user!.userEmail!,
      "password": pwd.trim(),
    };
    Map<AuthStatus, dynamic> userLogin = await _authModel.getSimpleLoginCheck(
        context: context,
        keyLoader: _globalKey,
        userLoginSignUpRequestJson: userLoginSignUpRequestJson,
        apiName: ServiceUrl.simpleLoginCheck);
    if (userLogin.isNotEmpty) {
      switch (userLogin.keys.first) {
        case AuthStatus.error:
          DialogUtils.showErrorDialog(context, userLogin.values.first, resource.close.tr);
          break;
        case AuthStatus.success:
          User _usr = userLogin.values.first.data;
          _usr.user_password = pwd.trim();
          await userDefault.saveUser(_usr);
          _user = _usr;
          setupUserData();
          setState(() {});
          break;
        case AuthStatus.server_error:
          DialogUtils.showErrorDialog(context, resource.serverError.tr, resource.close.tr);
          break;
        case AuthStatus.invalid:
          break;
      }
    }
  }

  void opnDialog(BuildContext context) {
    DialogUtils.showAlertDialog(context, resource.pickImagePermission.tr, resource.accessPhotoPermission.tr, 'App Settings', 'No',
        () async {
      Navigator.of(context).pop();
      openAppSettings();
    });
  }

  TextStyle selectionStyle(UserGender sGen) {
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
  }

  void Dailog(BuildContext buildContext, String verifyAccount, String okButton) {
    return DialogUtils.showDailogForUser(buildContext, verifyAccount, okButton, (bool action) {
      if (action) {
        //Get.to(() => PersonalDetailScreen(user: _user!, verifyacc: true));
        //setState(() {});
      }
    });
  }

  calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    calculatedAge = age;
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
