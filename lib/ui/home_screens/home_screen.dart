import 'package:driver/constant/constant.dart';
import 'package:driver/controller/home_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
        init: HomeController(),
        dispose: (state) {
          FireStoreUtils().closeStream();
        },
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.lightprimary,
            body: controller.isLoading.value || controller.driverModel.value.id == null
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : Column(
                    children: [
                      if (controller.driverModel.value.ownerId == null)
                        double.parse(controller.driverModel.value.walletAmount ?? '0.0') >= double.parse(Constant.minimumDepositToRideAccept)
                            ? SizedBox(
                                height: Responsive.width(8, context),
                                width: Responsive.width(100, context),
                              )
                            : SizedBox(
                                height: Responsive.width(18, context),
                                width: Responsive.width(100, context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Text("You have to minimum ${Constant.amountShow(amount: Constant.minimumDepositToRideAccept.toString())} wallet amount to Accept Order and place a bid".tr,
                                      style: GoogleFonts.poppins(color: Colors.white)),
                                ),
                              ),
                      Expanded(
                        child: Container(
                          height: Responsive.height(100, context),
                          width: Responsive.width(100, context),
                          decoration:
                              BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: controller.widgetOptions.elementAt(controller.selectedIndex.value),
                          ),
                        ),
                      ),
                    ],
                  ),
            bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset("assets/icons/ic_new.png",
                          width: 18,
                          color: controller.selectedIndex.value == 0
                              ? themeChange.getThem()
                                  ? AppColors.darksecondprimary
                                  : AppColors.lightsecondprimary
                              : Colors.white),
                    ),
                    label: 'New'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset("assets/icons/ic_accepted.png",
                          width: 18,
                          color: controller.selectedIndex.value == 1
                              ? themeChange.getThem()
                                  ? AppColors.darksecondprimary
                                  : AppColors.lightsecondprimary
                              : Colors.white),
                    ),
                    label: 'Accepted'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: badges.Badge(
                      badgeContent: Text(controller.isActiveValue.value.toString()),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Image.asset("assets/icons/ic_active.png",
                            width: 18,
                            color: controller.selectedIndex.value == 2
                                ? themeChange.getThem()
                                    ? AppColors.darksecondprimary
                                    : AppColors.lightsecondprimary
                                : Colors.white),
                      ),
                    ),
                    label: 'Active'.tr,
                  ),
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset("assets/icons/ic_completed.png",
                          width: 18,
                          color: controller.selectedIndex.value == 3
                              ? themeChange.getThem()
                                  ? AppColors.darksecondprimary
                                  : AppColors.lightsecondprimary
                              : Colors.white),
                    ),
                    label: 'Completed'.tr,
                  ),
                ],
                backgroundColor: AppColors.lightprimary,
                type: BottomNavigationBarType.fixed,
                currentIndex: controller.selectedIndex.value,
                selectedItemColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                unselectedItemColor: Colors.white,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                onTap: controller.onItemTapped),
          );
        });
  }
}
