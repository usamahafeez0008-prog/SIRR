import 'package:driver/themes/app_colors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ShowToastDialog {
  static void showToast(String? message) {
    EasyLoading.instance.backgroundColor = Get.isDarkMode ? AppColors.moroccoGreen : AppColors.lightsecondprimary;
    EasyLoading.showToast(message!);
  }

  static void showLoader(String message) {
    EasyLoading.instance.backgroundColor = Get.isDarkMode ? AppColors.moroccoGreen : AppColors.lightsecondprimary;
    EasyLoading.show(status: message);
  }

  static void closeLoader() {
    EasyLoading.dismiss();
  }
}
