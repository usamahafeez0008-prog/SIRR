import 'dart:developer';

import 'package:driver/model/referral_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ReferralController extends GetxController {
  @override
  void onInit() {
    getReferralCode();
    super.onInit();
  }

  Rx<ReferralModel> referralModel = ReferralModel().obs;
  RxBool isLoading = true.obs;

  Future<void> getReferralCode() async {
    await FireStoreUtils.getReferral().then((value) {
      if (value != null) {
        referralModel.value = value;
        log("ReferralModel :: ${referralModel.value.id}");
      }
      isLoading.value = false;
    });
  }
}
