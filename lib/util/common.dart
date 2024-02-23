import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/model/document/document_data.dart';
import 'package:rate_review/model/post/transaction.dart';
import 'package:rate_review/model/user/user.dart';
import 'package:rate_review/ui/component/app_extension.dart';
import 'package:rate_review/ui/dialog/dialog_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../model/currency/currencyModel.dart';
import 'string_resource.dart';
import 'theming.dart';

const kDefaultSidePadding = 16;

String get primaryFF => 'gotham_light_regular';
String get narrowbook => 'gothamnarrowbook';
String get narrowmedium => 'gothamnarrowmedium';
String get narrowbold => 'gothamnarrowbold';
String get narrowcondesedmedium => 'gothamcondensedmedium';

const double largeFontSize = 21;
const double normalFontSize = 20;
const double smallFontSize = 13;
const int timeoutDuration = 30;

typedef void OnParse(dynamic response);

enum UserState { NO_INTERNET, LOADING, READY }

enum OTPVerificationType { DASHBORD, FORGOT_PASS, SIGN_UP, DELETE_ACCOUNT }

enum AppLanguages { en, ar }

enum UserGender { MALE, FEMALE, OTHER }

class AppUtil {
  static var appName = resource.buzzleTitle.tr;
  static String? langcode;

  static Future<void> toast(String message, {String? title}) async {
    Get.closeAllSnackbars();
    Get.showSnackbar(GetSnackBar(
      title: title,
      message: message,
      barBlur: 100,
      duration: const Duration(milliseconds: 1500),
      isDismissible: true,
    ));
  }

//TODO 08/04/2022
  static Future<void> switchLanguage() async {
    await userDefault.getLanguageCode().then((value) {
      String? languageCode = value;
      Locale locale;
      Locale? devLocale = Get.locale;
      if (devLocale != null && languageCode == AppLanguages.en.name) {
        locale = Locale(AppLanguages.en.name, 'US');
        AppUtil.langcode = AppLanguages.en.name;
      } else {
        locale = Locale(AppLanguages.ar.name, 'US');
        AppUtil.langcode = AppLanguages.ar.name;
      }
      Get.updateLocale(locale);
    });
  }

  static Future<void> errorToast(String message, {String? title}) async {
    Get.snackbar(
      title ?? resource.invalid.tr,
      message,
      colorText: CupertinoColors.white,
      barBlur: 100,
      backgroundColor: CupertinoColors.destructiveRed.withAlpha(50),
      isDismissible: true,
    );
  }

  static Future<bool> isInternetAvailable(BuildContext context) async {
    MethodChannelHandler methodChannelHandler = Get.find();
    var connectivityResult =
        await (methodChannelHandler.isConnectedToNetwork());
    if (!connectivityResult) {
      DialogUtils.showInternetDialog(context, false);
      return false;
    } else {
      return true;
    }
  }

  static Future<bool> isInternetConnected() async {
    MethodChannelHandler methodChannelHandler = Get.find();
    var connectivityResult =
        await (methodChannelHandler.isConnectedToNetwork());
    if (!connectivityResult) {
      return false;
    } else {
      return true;
    }
  }

  static bool validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      // toast('enter_valid_email'.tr);
      return false;
    } else if (value.length > 30) {
      // toast('email_length_exceeds'.tr);
      return false;
    } else {
      return true;
    }
  }

/*bool validateMobile(String value) {
  RegExp regex = RegExp(r'^[0-9]*$');
  if (value.trim().length != 10) {
    toast('Mobile Number must be of 10 digit');
    return false;
  } else if (value.startsWith('+', 0)) {
    toast('Mobile Number should not contain +91');
    return false;
  } else if (value.trim().contains(" ")) {
    toast('Blank space is not allowed');
    return false;
  } else if (!regex.hasMatch(value)) {
    toast('Characters are not allowed');
    return false;
  } else {
    return true;
  }
}*/

  static bool passwordValidation(String value) {
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }

  static Future<void> bottomPicker(BuildContext context,
      {required List<Widget> childrens,
      int selectedIndex = 0,
      required Function(Text text) onDone,
      required Function(int index) onSelectedItemChanged}) async {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: selectedIndex);

    await showModalBottomSheet<int>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: CupertinoColors.white,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: CupertinoColors.black,
              fontSize: 22.0,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: CupertinoButton(
                        child: Text(resource.done.tr),
                        onPressed: () {
                          Navigator.of(context).pop(selectedIndex);
                          Text text = childrens[selectedIndex] as Text;
                          onDone(text);
                        }),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: scrollController,
                      itemExtent: 25,
                      backgroundColor: CupertinoColors.white,
                      onSelectedItemChanged: (int index) {
                        selectedIndex = index;
                        // TODO setState
                        onSelectedItemChanged(index);
                      },
                      children: childrens,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
//TODO 14/04/2022 put all country here

  static List<Widget> allCountries = [
    const Text('Algeria'),
    const Text('Angola'),
    const Text('Anguilla'),
    const Text('Antigua and Barbuda'),
    const Text('Argentina'),
    const Text('Armenia'),
    const Text('Australia'),
    const Text('Austria'),
    const Text('Azerbaijan'),
    const Text('Bahamas'),
    const Text('Bahrain'),
    const Text('Barbados'),
    const Text('Belarus'),
    const Text('Belgium'),
    const Text('Belize'),
    const Text('Bermuda'),
    const Text('Bolivia'),
    const Text('Botswana'),
    const Text('Brazil'),
    const Text('Brunei Darussalam'),
    const Text('Bulgaria'),
    const Text('Canada'),
    const Text('Cayman Islands'),
    const Text('Chile'),
    const Text('China'),
    const Text('Colombia'),
    const Text('Costa Rica'),
    const Text('Croatia'),
    const Text('Cyprus'),
    const Text('Czech Republic'),
    const Text('Denmark'),
    const Text('Dominica'),
    const Text('Dominican Republic'),
    const Text('Ecuador'),
    const Text('Egypt'),
    const Text('El Salvador'),
    const Text('Estonia'),
    const Text('Finland'),
    const Text('France'),
    const Text('Germany'),
    const Text('Ghana'),
    const Text('Greece'),
    const Text('Grenada'),
    const Text('Guatemala'),
    const Text('Guyana'),
    const Text('Honduras'),
    const Text('Hong Kong'),
    const Text('Hungary'),
    const Text('Iceland'),
    const Text('India'),
    const Text('Indonesia'),
    const Text('Ireland'),
    const Text('Israel'),
    const Text('Italy'),
    const Text('Jamaica'),
    const Text('Japan'),
    const Text('Jordan'),
    const Text('Kazakstan'),
    const Text('Kenya'),
    const Text('Korea, Republic Of'),
    const Text('Kuwait'),
    const Text('Latvia'),
    const Text('Lebanon'),
    const Text('Lithuania'),
    const Text('Luxembourg'),
    const Text('Macau'),
    const Text('Macedonia, The Former Yugoslav Republic Of'),
    const Text('Madagascar'),
    const Text('Malaysia'),
    const Text('Mali'),
    const Text('Malta'),
    const Text('Mauritius'),
    const Text('Mexico'),
    const Text('Moldova, Republic Of'),
    const Text('Montserrat'),
    const Text('Netherlands'),
    const Text('New Zealand'),
    const Text('Nicaragua'),
    const Text('Niger'),
    const Text('Nigeria'),
    const Text('Norway'),
    const Text('Oman'),
    const Text('Pakistan'),
    const Text('Panama'),
    const Text('Paraguay'),
    const Text('Peru'),
    const Text('Philippines'),
    const Text('Poland'),
    const Text('Portugal'),
    const Text('Qatar'),
    const Text('Romania'),
    const Text('Russia'),
    const Text('Saint Kitts and Nevis'),
    const Text('Saint Lucia'),
    const Text('Saint Vincent and The Grenadines'),
    const Text('Saudi Arabia'),
    const Text('Senegal'),
    const Text('Singapore'),
    const Text('Slovakia'),
    const Text('Slovenia'),
    const Text('South Africa'),
    const Text('Spain'),
    const Text('Sri Lanka'),
    const Text('Suriname'),
    const Text('Sweden'),
    const Text('Switzerland'),
    const Text('Taiwan'),
    const Text('Tanzania, United Republic Of'),
    const Text('Thailand'),
    const Text('Trinidad and Tobago'),
    const Text('Tunisia'),
    const Text('Turkey'),
    const Text('Turks and Caicos Islands'),
    const Text('Uganda'),
    const Text('United Arab Emirates'),
    const Text('United Kingdom'),
    const Text('United States'),
    const Text('Uruguay'),
    const Text('Uzbekistan'),
    const Text('Venezuela'),
    const Text('Vietnam'),
    const Text('Virgin Islands, British'),
    const Text('Yemen'),
  ];

  static List<Widget> allEthinicity = [
    const Text('South Asian'),
    const Text('South East Asian'),
    const Text('African'),
    const Text('Middle Eastern'),
    const Text('European'),
    const Text('White'),
    const Text('Hispanic'),
    const Text('Latino'),
    const Text('Other'),
  ];

  static List<Widget> gender = [
    const Text('Male'),
    const Text('Female'),
    const Text('I prefer not to say'),
    // const Text('Other'),
  ];

  static List<String>  countryList= ['Netherlands','Spain','Ireland','Italy','France','Germany','Belgium','Finland'];

  static List<DropdownMenuItem<String>> get currencyList {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(value: "Currency", child: Center(child: Text("Currency",style: mDropDownFieldTS))),
      DropdownMenuItem(value: "AED", child: Center(child: Text("د.إ - Emirati Dirham",style: mDropDownFieldTS))),
      DropdownMenuItem(value: "USD", child: Center(child: Text("\$ - US Dollar",style: mDropDownFieldTS))),
      DropdownMenuItem(value: "GBP", child: Center(child: Text("£ - United Kingdom Pound",style: mDropDownFieldTS))),
      DropdownMenuItem(value: "SAR", child: Center(child: Text("﷼ - Saudi Arabia Riyal",style: mDropDownFieldTS))),
      DropdownMenuItem(value: "EGP", child: Center(child: Text("E£ - Egyptian Pound",style: mDropDownFieldTS))),
      DropdownMenuItem(value: "EUR", child: Center(child: Text("€ - Euro",style: mDropDownFieldTS))),
    ];
    return menuItems;
  }

  ///TODO Phase2
  static List<CurrencyModel> Currencydata = <CurrencyModel>[
    const CurrencyModel(currency: 'AED', currencySymbol: 'د.إ', currencyName: 'United Arab Emirates', isSelect: false),
    CurrencyModel(currency: "EUR", currencySymbol: "€", currencyName: countryList[0], isSelect: false),
    CurrencyModel(currency: "EUR", currencySymbol: "€", currencyName: countryList[1], isSelect: false),
    CurrencyModel(currency: "EUR", currencySymbol: "€", currencyName: countryList[2], isSelect: false),
    CurrencyModel(currency: "EUR", currencySymbol: "€", currencyName: countryList[3], isSelect: false),
    CurrencyModel(currency: "EUR", currencySymbol: "€", currencyName: countryList[4], isSelect: false),
    CurrencyModel(currency: "EUR", currencySymbol: "€", currencyName: countryList[5], isSelect: false),
    CurrencyModel(currency: "EUR", currencySymbol: "€", currencyName: countryList[6], isSelect: false),
    const CurrencyModel(currency: "GBP", currencySymbol: "£", currencyName: "United Kingdom", isSelect: false),
    const CurrencyModel(currency: "SAR", currencySymbol: "﷼", currencyName: "Saudi Arabia", isSelect: false),
    const CurrencyModel(currency: "USD", currencySymbol: "\$", currencyName: "United States", isSelect: false),
    const CurrencyModel(currency: "EGP", currencySymbol: "E£", currencyName: "Egypt", isSelect: false)
  ].obs;

  ///TODO Phase2
   static getCurrency(String currency)  {
    String? curr;
    int index = AppUtil.Currencydata.indexWhere((element) => element.currencyName == currency);
    if (index != -1) {
      curr = AppUtil.Currencydata[index].currency!;
    }
    return curr;
  }




  static final Map<String, Widget> gendersSlidingTab = <String, Widget>{
    'male': Text(
      'male'.tr,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    ),
    'female': Text(
      'female'.tr,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    ),
    'other': Text(
      'other'.tr,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    )
  };

  static String getDocumentUrl(DocumentData doc) {
    return doc.documentName!;
    if (doc.documentName!.isStartWithHTTP) {
      return doc.documentName!;
    } else {
      return ServiceUrl.DOC_IMAGE_DIR_URL + doc.documentName!;
    }
  }

  static String getTransactionUrl(Transaction tra) {
    return tra.docPhoto!;
  }

  static Future<String> getEncrptedString(String decodedStr) async {
    MethodChannelHandler methodChannelHandler = MethodChannelHandler();
    String key = await methodChannelHandler.getEncryptionKey();
    List<int> plaintext = utf8.encode("${decodedStr}${key}");
    List<int> iv = AesGcm.with128bits().newNonce();
    String secretStr = await methodChannelHandler.getSecretKey();
    List<int> passphrase = utf8.encode(secretStr);
    SecretKey secretKey = SecretKey(passphrase);

    SecretBox secretBox = await AesGcm.with128bits()
        .encrypt(plaintext, nonce: iv, secretKey: secretKey);
    String ivCiphertextMacB64 = base64.encode(
        secretBox.concatenation()); // Base64 encoding of: IV | ciphertext | MAC
    log('encrypted- $ivCiphertextMacB64');
    return ivCiphertextMacB64;
  }
}

Size size(BuildContext context) => MediaQuery.of(context).size;
// Size size(BuildContext context) => context.mediaQuerySize;

double bottomViewPad(BuildContext context) =>
    MediaQuery.of(context).viewPadding.bottom;
double topViewPad(BuildContext context) =>
    MediaQuery.of(context).viewPadding.top;
double get statusBarViewPad => AppBar().preferredSize.height;

Widget _statusBarGradient(BuildContext buildContext) {
  return Container(
    height: MediaQuery.of(buildContext).viewPadding.top,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          headerStartColor,
          headerEndColor,
        ],
      ),
    ),
  );
}

TextStyle get mTextFieldTS {
  return TextStyle(
      fontFamily: primaryFF,
      fontSize: 20,
      color: CupertinoColors.black,
      fontWeight: FontWeight.w300);
}

TextStyle get mDropDownFieldTS {
  return TextStyle(
      fontFamily: primaryFF,
      fontSize: 20,
      color: Colors.black38,
      fontWeight: FontWeight.w300);
}

TextStyle get mHelperTextFieldTS {
  return TextStyle(
      fontFamily: primaryFF,
      fontSize: 15,
      color: CupertinoColors.systemRed.withAlpha(200));
}

TextStyle get boldBtnStyle {
  return TextStyle(
      fontSize: 28,
      letterSpacing: 6,
      fontFamily: narrowbold,
      fontWeight: FontWeight.w600,
      color: CupertinoColors.white);
}

TextStyle get headerStyle {
  return TextStyle(
      color: CupertinoColors.white,
      fontFamily: narrowmedium,
      fontSize: 20,
      letterSpacing: 4.0);
}

TextStyle get normalBtnStyle {
  return TextStyle(
      fontSize: 28,
      letterSpacing: 6,
      fontFamily: narrowbold,
      fontWeight: FontWeight.w600,
      color: primaryColor);
}

TextStyle get normalTextStyle => TextStyle(
    fontSize: normalFontSize,
    color: CupertinoColors.black,
    fontFamily: primaryFF,
    fontWeight: FontWeight.w300);

InputDecoration mInputDecoration({required String placeholder}) =>
    InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: TextStyle(
          fontFamily: primaryFF,
          fontSize: 22,
          fontWeight: FontWeight.w300,
          color: inputlablecolor),
      floatingLabelStyle: TextStyle(
          fontFamily: primaryFF,
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: CupertinoColors.black),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(color: inputbordercolor, width: 0.5),
      ),
      filled: true,
      fillColor: CupertinoColors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(color: inputbordercolor, width: 0.5),
      ),
      hintText: placeholder,
      hintStyle: TextStyle(color: inputlablecolor, fontFamily: primaryFF),
      border: const OutlineInputBorder(
        //borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: inputbordercolor, width: 0.5),
      ),
    );

/*InputDecoration  mInputDecoration({required String placeholder})=> InputDecoration(
    labelText: placeholder,
    labelStyle: TextStyle(
        fontFamily: primaryFF,
        fontSize: 22,
        fontWeight: FontWeight.w300,
      color: CupertinoColors.black.withAlpha(150)
    ),
    floatingLabelStyle: TextStyle(
        fontFamily: primaryFF,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: CupertinoColors.black
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
          color: CupertinoColors.systemGrey2, width: 2),
    ),
    filled: true,
    fillColor: CupertinoColors.white,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
          color: CupertinoColors.systemGrey, width: 1),
    ),
    hintText: placeholder,
    hintStyle: const TextStyle(color: CupertinoColors.systemGrey3, fontWeight: FontWeight.w400),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(7),
      borderSide: const BorderSide(
          color: CupertinoColors.systemGrey2, width: 1),
    ),
  );*/

InputDecoration inputInputDecoration({required String placeholder}) =>
    InputDecoration(
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: TextStyle(
          fontFamily: primaryFF,
          fontSize: 22,
          fontWeight: FontWeight.w300,
          color: inputlablecolor),
      floatingLabelStyle: TextStyle(
          fontFamily: primaryFF,
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: CupertinoColors.black),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(color: inputbor1dercolor, width: 0.5),
      ),
      filled: true,
      fillColor: CupertinoColors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: const BorderSide(color: inputbor1dercolor, width: 0.5),
      ),
      hintText: placeholder,
      hintStyle: TextStyle(color: inputlablecolor, fontFamily: primaryFF),
      border: const OutlineInputBorder(
        //borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: inputbor1dercolor, width: 0.5),
      ),
    );
List<Widget> AppToolbar(BuildContext buildContext,
    {required List<Widget> children, bool showStatusBar = false}) {
  return [
    if (showStatusBar) _statusBarGradient(buildContext),
    Container(
      height: AppBar().preferredSize.height,
      transform: Matrix4.translationValues(0.0, -0.3, 0.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            headerStartColor,
            headerEndColor,
          ],
        ),
      ),
      child: Row(
        children: children,
      ),
    ),
  ];
}

var backgroundImage = Container(
  decoration: BoxDecoration(
      image: DecorationImage(image: ImageRes.coloredBGImg, fit: BoxFit.fill)),
);
