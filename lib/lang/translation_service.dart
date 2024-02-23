import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rate_review/util/common.dart';

import 'en_us.dart';
import 'ar_us.dart';

class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static final fallbackLocale = Locale(AppLanguages.en.name, 'US');
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': en_US,
    'ar_US': ar_US,
  };
}