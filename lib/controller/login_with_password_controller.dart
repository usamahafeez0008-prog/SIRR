import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/ui/dashboard_screen.dart';
import 'package:driver/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:driver/utils/Preferences.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginWithPasswordController extends GetxController {
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  RxString countryCode = "+212".obs;

  Future<void> loginWithPassword(String password) async {
    if (phoneNumberController.value.text.isEmpty || password.isEmpty) {
      ShowToastDialog.showToast(
          "Please enter both phone number and password".tr);
      return;
    }

    ShowToastDialog.showLoader("Logging in...".tr);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionName.driverUsers)
          .where('countryCode', isEqualTo: countryCode.value)
          .where('phoneNumber', isEqualTo: phoneNumberController.value.text)
          .where('password', isEqualTo: password)
          .get();

      ShowToastDialog.closeLoader();

      if (querySnapshot.docs.isNotEmpty) {
        ShowToastDialog.showToast("Login Successful".tr);

        var docData = querySnapshot.docs.first.data();
        DriverUserModel userModel = DriverUserModel.fromJson(docData);

        // Save UID to preferences so that FireStoreUtils can access it
        Preferences.setString('userId', querySnapshot.docs.first.id);

        bool isPlanExpire = false;
        if (userModel.subscriptionPlan?.id != null) {
          if (userModel.subscriptionExpiryDate == null) {
            isPlanExpire = (userModel.subscriptionPlan?.expiryDay != '-1');
          } else {
            DateTime expiryDate = userModel.subscriptionExpiryDate!.toDate();
            isPlanExpire = expiryDate.isBefore(DateTime.now());
          }
        } else {
          isPlanExpire = true;
        }

        if ((userModel.subscriptionPlanId == null || isPlanExpire == true) &&
            userModel.ownerId == null) {
          if (Constant.adminCommission?.isEnabled == false &&
              Constant.isSubscriptionModelApplied == false) {
            Get.offAll(() => const DashBoardScreen());
          } else {
            Get.offAll(() => const SubscriptionListScreen(),
                arguments: {"isShow": true});
          }
        } else {
          if (userModel.ownerId != null && userModel.isEnabled == false) {
            Get.back();
            ShowToastDialog.showToast(
                'This account has been disabled. Please reach out to the owner'
                    .tr);
          } else {
            Get.offAll(() => const DashBoardScreen());
          }
        }
      } else {
        ShowToastDialog.showToast(
            "Incorrect credentials or account not found".tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
    }
  }
}
