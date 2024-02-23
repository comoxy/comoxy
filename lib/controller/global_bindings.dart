import 'package:get/get.dart';
import 'package:rate_review/helper/method_channel_handler.dart';
import 'package:rate_review/helper/post_controller.dart';
import 'package:rate_review/helper/userdefault.dart';
import 'package:rate_review/service/auth.dart';

class GlobalBindings extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => UserDefault(), fenix: true);
    Get.lazyPut(() => PostController(), fenix: true);
    Get.lazyPut(() => MethodChannelHandler(), fenix: true);
    Get.lazyPut(() => AuthModel(), fenix: true);
  }
}