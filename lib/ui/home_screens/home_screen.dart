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
    final bool isDark = false; // Forced Light Mode as requested
    return GetX<HomeController>(
        init: HomeController(),
        dispose: (state) {
          FireStoreUtils().closeStream();
        },
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.moroccoBackground,
            body: controller.isLoading.value ||
                    controller.driverModel.value.id == null
                ? Constant.loader(isDarkTheme: false)
                : Column(
                    children: [
                      if (controller.driverModel.value.ownerId == null)
                        double.parse(
                                    controller.driverModel.value.walletAmount ??
                                        '0.0') >=
                                double.parse(
                                    Constant.minimumDepositToRideAccept)
                            ? SizedBox(
                                height: Responsive.width(8, context),
                                width: Responsive.width(100, context),
                              )
                            : SizedBox(
                                height: Responsive.width(18, context),
                                width: Responsive.width(100, context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: Text(
                                      "You have to minimum ${Constant.amountShow(amount: Constant.minimumDepositToRideAccept.toString())} wallet amount to Accept Order and place a bid"
                                          .tr,
                                      style: GoogleFonts.poppins(
                                          color: Colors.white)),
                                ),
                              ),
                      Expanded(
                        child: Container(
                          height: Responsive.height(100, context),
                          width: Responsive.width(100, context),
                          decoration: BoxDecoration(
                              color: AppColors.moroccoBackground,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(35),
                                  topRight: Radius.circular(35))),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Animated-like Static Icon with Gradient
                                  Container(
                                    padding: const EdgeInsets.all(28),
                                    decoration: BoxDecoration(
                                      color: AppColors.moroccoRed
                                          .withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.moroccoRed,
                                            const Color(0xFFE53935)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.moroccoRed
                                                .withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          )
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 45,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Title
                                  Text(
                                    'Coming Soon'.tr,
                                    style: GoogleFonts.outfit(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Description
                                  Text(
                                    "We're crafting something amazing for you.\nThis feature will be live soon!"
                                        .tr,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // Visual placeholder for a button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.moroccoRed
                                              .withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      "Stay Tuned".tr,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.moroccoRed,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            // Expanded(
            //         child: Container( height: Responsive.height(100, context),
            //                           width: Responsive.width(100, context),
            //                           decoration: BoxDecoration(
            //                               color: AppColors.moroccoBackground,
            //                               borderRadius: const BorderRadius.only(
            //                                   topLeft: Radius.circular(25),
            //                                   topRight: Radius.circular(25))),
            //                           child: Padding(
            //                             padding: const EdgeInsets.all(8.0),
            //                             child: controller.widgetOptions
            //                                  .elementAt(controller.selectedIndex.value),
            //                           ),
            //                         ),
            //                       ),
            //
            //
            //
            //
            // bottomNavigationBar: BottomNavigationBar(
            //     items: <BottomNavigationBarItem>[
            //       BottomNavigationBarItem(
            //         icon: Padding(
            //           padding: const EdgeInsets.all(6.0),
            //           child: Image.asset("assets/icons/ic_new.png",
            //               width: 18,
            //               color: controller.selectedIndex.value == 0
            //                   ? themeChange.getThem()
            //                       ? AppColors.darksecondprimary
            //                       : AppColors.lightsecondprimary
            //                   : Colors.white),
            //         ),
            //         label: 'New'.tr,
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Padding(
            //           padding: const EdgeInsets.all(6.0),
            //           child: Image.asset("assets/icons/ic_accepted.png",
            //               width: 18,
            //               color: controller.selectedIndex.value == 1
            //                   ? themeChange.getThem()
            //                       ? AppColors.darksecondprimary
            //                       : AppColors.lightsecondprimary
            //                   : Colors.white),
            //         ),
            //         label: 'Accepted'.tr,
            //       ),
            //       BottomNavigationBarItem(
            //         icon: badges.Badge(
            //           badgeContent: Text(controller.isActiveValue.value.toString()),
            //           child: Padding(
            //             padding: const EdgeInsets.all(6.0),
            //             child: Image.asset("assets/icons/ic_active.png",
            //                 width: 18,
            //                 color: controller.selectedIndex.value == 2
            //                     ? themeChange.getThem()
            //                         ? AppColors.darksecondprimary
            //                         : AppColors.lightsecondprimary
            //                     : Colors.white),
            //           ),
            //         ),
            //         label: 'Active'.tr,
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Padding(
            //           padding: const EdgeInsets.all(6.0),
            //           child: Image.asset("assets/icons/ic_completed.png",
            //               width: 18,
            //               color: controller.selectedIndex.value == 3
            //                   ? themeChange.getThem()
            //                       ? AppColors.darksecondprimary
            //                       : AppColors.lightsecondprimary
            //                   : Colors.white),
            //         ),
            //         label: 'Completed'.tr,
            //       ),
            //     ],
            //     backgroundColor: AppColors.lightprimary,
            //     type: BottomNavigationBarType.fixed,
            //     currentIndex: controller.selectedIndex.value,
            //     selectedItemColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
            //     unselectedItemColor: Colors.white,
            //     selectedFontSize: 12,
            //     unselectedFontSize: 12,
            //     onTap: controller.onItemTapped),
          );
        });
  }
}
