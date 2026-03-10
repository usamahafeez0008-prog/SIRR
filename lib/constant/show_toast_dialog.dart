import 'package:driver/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ShowToastDialog {
  static void showToast(String? message) {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = AppColors.moroccoGreen
      ..textColor = Colors.white
      ..indicatorColor = Colors.white;
    EasyLoading.showToast(message ?? '');
  }

  static void showLoader(String message) {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..backgroundColor = AppColors.moroccoGreen
      ..textColor = Colors.white
      ..indicatorColor = Colors.white;
    EasyLoading.show(status: message);
  }

  static void closeLoader() {
    EasyLoading.dismiss();
  }
}
