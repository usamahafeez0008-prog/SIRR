import 'dart:developer';

import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/ui/auth_screen/login_screen.dart';
import 'package:driver/ui/bank_details/bank_details_screen.dart';
import 'package:driver/ui/chat_screen/inbox_screen.dart';
import 'package:driver/ui/freight/freight_screen.dart';
import 'package:driver/ui/help_support_screen/help_support_screen.dart';
import 'package:driver/ui/home_screens/home_screen.dart';
import 'package:driver/ui/intercity_screen/home_intercity_screen.dart';
import 'package:driver/ui/online_registration/online_registartion_screen.dart';
import 'package:driver/ui/profile_screen/profile_screen.dart';
import 'package:driver/ui/refer_and_earn/refer_and_earn_screen.dart';
import 'package:driver/ui/settings_screen/setting_screen.dart';
import 'package:driver/ui/subscription_plan_screen/subscription_history.dart';
import 'package:driver/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:driver/ui/vehicle_information/vehicle_information_screen.dart';
import 'package:driver/ui/wallet/wallet_screen.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashBoardController extends GetxController {
  RxList<DrawerItem> drawerItems = <DrawerItem>[].obs;

  Widget getDrawerItemWidget(int pos) {
    log("driverUser.value.ownerId :::: ${driverUser.value.ownerId}");
    if (driverUser.value.ownerId == null) {
      if (Constant.isSubscriptionModelApplied == true) {
        switch (pos) {
          case 0:
            return const HomeScreen();
          case 1:
            return const HomeIntercityScreen();
          case 2:
            return const FreightScreen();
          case 3:
            return const WalletScreen();
          case 4:
            return const BankDetailsScreen();
          case 5:
            return const InboxScreen();
          case 6:
            return const ProfileScreen();
          case 7:
            return const ReferralScreen();
          case 8:
            // yahan change kea ha
            if (Constant.isVerifyDocument == true) {
              return const OnlineRegistrationScreen();
            } else {
              return const VehicleInformationScreen();
            }
          case 9:
            return Constant.isVerifyDocument == true ? const VehicleInformationScreen() : const SettingScreen();
          case 10:
            return Constant.isVerifyDocument == true ? const SettingScreen() : const SubscriptionListScreen();
          case 11:
            return Constant.isVerifyDocument == true ? const SubscriptionListScreen() : const SubscriptionHistory();
          case 12:
            return Constant.isVerifyDocument == true
                ? const SubscriptionHistory()
                : HelpSupportScreen(
                    userId: driverUser.value.id,
                    userName: driverUser.value.fullName,
                    userProfileImage: driverUser.value.profilePic,
                    token: driverUser.value.fcmToken,
                    isShowAppbar: false,
                  );
          case 13:
            return HelpSupportScreen(
              userId: driverUser.value.id,
              userName: driverUser.value.fullName,
              userProfileImage: driverUser.value.profilePic,
              token: driverUser.value.fcmToken,
              isShowAppbar: false,
            );
          default:
            return const Text("Error");
        }
      } else {
        switch (pos) {
          case 0:
            return const HomeScreen();
          case 1:
            return const HomeIntercityScreen();
          case 2:
            return const FreightScreen();
          case 3:
            return const WalletScreen();
          case 4:
            return const BankDetailsScreen();
          case 5:
            return const InboxScreen();
          case 6:
            return const ProfileScreen();
          case 7:
            return const ReferralScreen();
          /// Check Here doucment Verification Screen
            case 8:
              // yahan change kea ha
            if (Constant.isVerifyDocument == true) {
              return const OnlineRegistrationScreen();
            } else {
              return const VehicleInformationScreen();
            }
          case 9:
            return Constant.isVerifyDocument == true ? const VehicleInformationScreen() : const SettingScreen();
          case 10:
            return Constant.isVerifyDocument == true ? const SettingScreen() : const SubscriptionHistory();

          case 11:
            return Constant.isVerifyDocument == true
                ? const SubscriptionHistory()
                : HelpSupportScreen(
                    userId: driverUser.value.id,
                    userName: driverUser.value.fullName,
                    userProfileImage: driverUser.value.profilePic,
                    token: driverUser.value.fcmToken,
                    isShowAppbar: false,
                  );
          case 12:
            return HelpSupportScreen(
              userId: driverUser.value.id,
              userName: driverUser.value.fullName,
              userProfileImage: driverUser.value.profilePic,
              token: driverUser.value.fcmToken,
              isShowAppbar: false,
            );
          default:
            return const Text("Error");
        }
      }
    } else {
      switch (pos) {
        case 0:
          return const HomeScreen();
        case 1:
          return const HomeIntercityScreen();
        case 2:
          return const FreightScreen();
        case 3:
          return const InboxScreen();
        case 4:
          return const ProfileScreen();
        case 5:
          return const VehicleInformationScreen();
        case 6:
          return const SettingScreen();
        case 7:
          return HelpSupportScreen(
            userId: driverUser.value.id,
            userName: driverUser.value.fullName,
            userProfileImage: driverUser.value.profilePic,
            token: driverUser.value.fcmToken,
            isShowAppbar: false,
          );
        default:
          return const Text("Error");
      }
    }
  }

  Future<void> onSelectItem(int index) async {
    if (driverUser.value.ownerId == null) {
      if (Constant.isSubscriptionModelApplied == true) {
        if (Constant.isVerifyDocument == true ? index == 14 : index == 13) {
          await FirebaseAuth.instance.signOut();
          Get.offAll(const LoginScreen());
        } else {
          selectedDrawerIndex.value = index;
        }
      } else {
        if (Constant.isVerifyDocument == true ? index == 13 : index == 12) {
          await FirebaseAuth.instance.signOut();
          Get.offAll(const LoginScreen());
        } else {
          selectedDrawerIndex.value = index;
        }
      }
    } else {
      if (index == 8) {
        await FirebaseAuth.instance.signOut();
        Get.offAll(const LoginScreen());
      } else {
        selectedDrawerIndex.value = index;
      }
    }

    Get.back();
  }

  void setDrawerList() {
    if (driverUser.value.ownerId == null) {
      if (Constant.isSubscriptionModelApplied == true) {
        drawerItems.value = [
          DrawerItem('City', "assets/icons/ic_city.svg"),
          // DrawerItem('Rides'.tr, "assets/icons/ic_order.svg"),
          DrawerItem('OutStation', "assets/icons/ic_intercity.svg"),
          // DrawerItem('OutStation Rides'.tr, "assets/icons/ic_order.svg"),
          DrawerItem('Freight', "assets/icons/ic_freight.svg"),
          DrawerItem('My Wallet', "assets/icons/ic_wallet.svg"),
          DrawerItem('Bank Details', "assets/icons/ic_profile.svg"),
          DrawerItem('Inbox', "assets/icons/ic_inbox.svg"),
          DrawerItem('Profile', "assets/icons/ic_profile.svg"),
          DrawerItem('Referral a friends', "assets/icons/ic_referral.svg"),
          if (Constant.isVerifyDocument == true) DrawerItem('Online Registration', "assets/icons/ic_document.svg"),
          DrawerItem('Vehicle Information', "assets/icons/ic_city.svg"),
          DrawerItem('Settings', "assets/icons/ic_settings.svg"),
          DrawerItem('Subscription', "assets/icons/ic_subscription.svg"),
          DrawerItem('Subscription History', "assets/icons/ic_subscription_history.svg"),
          DrawerItem('Help & Support', "assets/icons/ic_help_support.svg"),
          DrawerItem('Log out', "assets/icons/ic_logout.svg"),
        ];
      } else {
        drawerItems.value = [
          DrawerItem('City', "assets/icons/ic_city.svg"),
          // DrawerItem('Rides'.tr, "assets/icons/ic_order.svg"),
          DrawerItem('OutStation', "assets/icons/ic_intercity.svg"),
          // DrawerItem('OutStation Rides'.tr, "assets/icons/ic_order.svg"),
          DrawerItem('Freight', "assets/icons/ic_freight.svg"),
          DrawerItem('My Wallet', "assets/icons/ic_wallet.svg"),
          DrawerItem('Bank Details', "assets/icons/ic_profile.svg"),
          DrawerItem('Inbox', "assets/icons/ic_inbox.svg"),
          DrawerItem('Profile', "assets/icons/ic_profile.svg"),
          DrawerItem('Referral a friends', "assets/icons/ic_referral.svg"),
          if (Constant.isVerifyDocument == true) DrawerItem('Online Registration', "assets/icons/ic_document.svg"),
          DrawerItem('Vehicle Information', "assets/icons/ic_city.svg"),
          DrawerItem('Settings', "assets/icons/ic_settings.svg"),
          DrawerItem('Subscription History', "assets/icons/ic_subscription_history.svg"),
          DrawerItem('Help & Support', "assets/icons/ic_help_support.svg"),
          DrawerItem('Log out', "assets/icons/ic_logout.svg"),
        ];
      }
    } else {
      drawerItems.value = [
        DrawerItem('City', "assets/icons/ic_city.svg"),
        DrawerItem('OutStation', "assets/icons/ic_intercity.svg"),
        DrawerItem('Freight', "assets/icons/ic_freight.svg"),
        DrawerItem('Inbox', "assets/icons/ic_inbox.svg"),
        DrawerItem('Profile', "assets/icons/ic_profile.svg"),
        DrawerItem('Vehicle Information', "assets/icons/ic_city.svg"),
        DrawerItem('Settings', "assets/icons/ic_settings.svg"),
        DrawerItem('Help & Support', "assets/icons/ic_help_support.svg"),
        DrawerItem('Log out', "assets/icons/ic_logout.svg"),
      ];
    }
  }

  RxInt selectedDrawerIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getDriver();
    getLocation();
    super.onInit();
  }

  Rx<DriverUserModel> driverUser = DriverUserModel().obs;
  Future<void> getDriver() async {
    await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((driver) {
      if (driver?.id != null) {
        driverUser.value = driver!;
      }
    });
    setDrawerList();
  }

  getLocation() async {
    await Utils.determinePosition();
  }

  Rx<DateTime> currentBackPressTime = DateTime.now().obs;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime.value) > const Duration(seconds: 2)) {
      currentBackPressTime.value = now;
      ShowToastDialog.showToast(
        "Double press to exit",
      );
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class DrawerItem {
  String title;
  String icon;

  DrawerItem(this.title, this.icon);
}
