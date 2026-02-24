import 'package:driver/controller/freight_controller.dart';
import 'package:driver/controller/home_intercity_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ActiveInterCityOrderController extends GetxController {
  HomeIntercityController homeController = Get.put(HomeIntercityController());
  FreightController frightController = Get.put(FreightController());
  Rx<TextEditingController> otpController = TextEditingController().obs;
  Rx<DriverUserModel?> driverUserModel = DriverUserModel().obs;

  @override
  void onInit() {
    getDriverData();
    super.onInit();
  }

  void getDriverData() async {
    driverUserModel.value = await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid());
  }
}
