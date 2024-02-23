import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common.dart';

const Color primaryColor = Color(0xff14bed4);
const Color greyTextColor = Color(0xFF8696a1);
const Color borderColor = Color(0xFFdcdcdc);
const Color orangeColor = Color(0xFFf1885a);
const Color kViewDownloadsTemplateColor = Color(0xFFf4ffdc);
const Color kDownloadsButtonColor = Color(0xFF8ea164);
const Color kBlackButtonColor = Color(0xFF3a3a3a);
const Color editFieldBackClr = Color(0XFFe5f4ff);
const Color eyeColor = Color(0xFF06306a);
const Color buttonBackColor = Color(0xFF43acfb);
const Color pinkColor = Color(0xFFf66daa);
const Color headingTextColor = Color(0xFF073a61);

const Color btnStartColor = Color(0xFF92e4f1);
const Color btnEndColor = Color(0xFF6ac2ce);

const Color headerStartColor = Color(0xFF44b0c4);
const Color headerEndColor = Color(0xFF49d5ea);

const Color yellowStartColor = Color(0xFFfcc87b);
const Color yellowEndColor = Color(0xFFffbc5a);

const Color bgYes = Color(0xFFffe3e2);
const Color yesFont = Color(0xFFde7573);
const Color yesBorder = Color(0xFFffc0be);
const Color msgFontColor = Color(0XFFA55A61);
const Color noFont = Color(0xFF838c9d);
const Color bottomBg = Color(0xFFf8f8f8);
const Color dialogFont = Color(0xFF5b5b5b);

const Color backgroundColor = Color(0xFFf3f4f5);
const Color dividerColor = Color(0xFFb3bdc2);

const Color inputbordercolor = Color(0xFF957444);
const Color inputbor1dercolor = Color(0xFFcdcdcd);
const Color inputlablecolor = Color(0xFFcccccc);
const Color lablecolor = Color(0xFF333333);
const Color desclablecolor = Color(0xFF888888);
const Color tablablecolor = Color(0xFF434443);
const Color boxcolor = Color(0xFFfafafa);
const Color tabshadowcolor = Color(0xFF343434);
const Color splashBuzzelcolor = Color(0xFF434343);
const Color splashtextcolor = Color(0xFF6ac2ce);

ThemeData lightThemeData(BuildContext context) {
  return ThemeData.light().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      platform: TargetPlatform.iOS,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: appBarTheme,
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              primary: primaryColor, textStyle: TextStyle(fontFamily: primaryFF, fontSize: normalFontSize))),
      iconTheme: const IconThemeData(color: primaryColor),
      textTheme: Theme.of(context).textTheme.apply(
          bodyColor: CupertinoColors.black,
          displayColor: CupertinoColors.black,
          fontFamily: primaryFF
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      hintColor: CupertinoColors.systemGrey,
      colorScheme:const ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        error: CupertinoColors.systemRed,
      ));
}

ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
      primaryColor: Colors.black38,
      scaffoldBackgroundColor: Colors.black87,
      appBarTheme: appBarTheme,
      iconTheme: const IconThemeData(color: primaryColor),
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
            fontFamily: primaryFF,
          ),
      // textButtonTheme: Theme.of(context).textButtonTheme.apply(
      //   bodyColor: Colors.white,
      //   displayColor: Colors.white,
      //   fontFamily: primaryFF,
      // ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.dark().copyWith(
        primary: primaryColor,
        secondary: primaryColor,
        error: CupertinoColors.systemRed,
      ));
}

AppBarTheme appBarTheme = AppBarTheme(
  titleTextStyle: TextStyle(fontSize: normalFontSize, fontFamily: primaryFF),
  toolbarTextStyle: TextStyle(fontSize: normalFontSize, fontFamily: primaryFF),
  centerTitle: true, elevation: 0, color: primaryColor, systemOverlayStyle: SystemUiOverlayStyle.light, );

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      // '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
