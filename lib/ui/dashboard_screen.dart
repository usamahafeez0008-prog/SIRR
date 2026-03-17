import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/dash_board_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/ui/online_registration/online_registartion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX<DashBoardController>(
        init: DashBoardController(),
        builder: (controller) {
          return Scaffold(
            drawerEnableOpenDragGesture: false,
            backgroundColor:
                isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
            appBar: AppBar(
              toolbarHeight: 70,
              elevation: 0,
              backgroundColor: AppColors.moroccoRed,
              centerTitle: true,
              leading: Builder(builder: (context) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    onPressed: () => Scaffold.of(context).openDrawer(), //_showLogoutDialog(context, controller),
                    icon: SvgPicture.asset(
                      'assets/icons/ic_humber.svg',
                      color: Colors.white,
                      width: 20,
                    ),
                  ),
                );
              }),
              title: controller.selectedDrawerIndex.value == 0
                  ? StreamBuilder(
                      stream: FireStoreUtils.fireStore
                          .collection(CollectionName.driverUsers)
                          .doc(FireStoreUtils.getCurrentUid())
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return Text('Error'.tr);
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Constant.loader(isDarkTheme: isDark);
                        }

                        DriverUserModel driverModel =
                            DriverUserModel.fromJson(snapshot.data!.data()!);

                        // Custom Premium Toggle Button
                        return Container(
                          width: Responsive.width(52, context),
                          height: 42,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Sliding active background
                              AnimatedAlign(
                                alignment: Alignment(
                                    driverModel.isOnline == true ? -1 : 1, 0),
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                                child: Container(
                                  width: Responsive.width(24.5, context),
                                  height: 36,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: driverModel.isOnline == true
                                          ? [
                                              AppColors.moroccoGreen,
                                              const Color(0xFF2A9D5B)
                                            ]
                                          : [
                                              const Color(0xFFE5E5E5),
                                              Colors.white
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: driverModel.isOnline == true
                                            ? AppColors.moroccoGreen
                                                .withOpacity(0.4)
                                            : Colors.black12,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Interactive buttons
                              Row(
                                children: [
                                  // Online Option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        ShowToastDialog.showLoader(
                                            "Please wait".tr);
                                        if (driverModel.documentVerification ==
                                            false) {
                                          ShowToastDialog.closeLoader();
                                          _showAlertDialog(context, "document");
                                        } else if (driverModel
                                                    .vehicleInformation ==
                                                null ||
                                            driverModel.serviceId == null) {
                                          ShowToastDialog.closeLoader();
                                          _showAlertDialog(
                                              context, "vehicleInformation");
                                        } else {
                                          driverModel.isOnline = true;
                                          await FireStoreUtils.updateDriverUser(
                                              driverModel);
                                          ShowToastDialog.closeLoader();
                                        }
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Online'.tr,
                                          style: GoogleFonts.outfit(
                                            color: driverModel.isOnline == true
                                                ? Colors.white
                                                : Colors.white60,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Offline Option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        ShowToastDialog.showLoader(
                                            "Updating...".tr);
                                        driverModel.isOnline = false;
                                        await FireStoreUtils.updateDriverUser(
                                            driverModel);
                                        ShowToastDialog.closeLoader();
                                      },
                                      child: Container(
                                        color: Colors.transparent,
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Offline'.tr,
                                          style: GoogleFonts.outfit(
                                            color: driverModel.isOnline == false
                                                ? AppColors.moroccoRed
                                                : Colors.white60,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      })
                  : Text(
                      controller
                          .drawerItems[controller.selectedDrawerIndex.value]
                          .title
                          .tr,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                      ),
                    ),
            ),
            drawer: buildAppDrawer(context, controller),
            body: WillPopScope(
              onWillPop: controller.onWillPop,
              child: controller
                  .getDrawerItemWidget(controller.selectedDrawerIndex.value),
            ),
          );
        });
  }

  Future<void> _showAlertDialog(BuildContext context, String type) async {
    final controllerDashBoard = Get.put(DashBoardController());
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final bool isDark = themeChange.getThem();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : AppColors.moroccoGreen.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.moroccoRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.moroccoRed,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Information'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'To start earning with SIRR you need to fill in your personal information'
                      .tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'No'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (type == "document") {
                            Get.back(); // close dialog
                            Get.to(() => const OnlineRegistrationScreen());
                          } else {
                            if (Constant.isVerifyDocument == true) {
                              controllerDashBoard.onSelectItem(9);
                            } else {
                              controllerDashBoard.onSelectItem(8);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.moroccoGreen,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Yes'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLogoutDialog(
      BuildContext context, DashBoardController controller) async {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final bool isDark = themeChange.getThem();

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white12
                    : AppColors.moroccoRed.withOpacity(0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.moroccoRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.moroccoRed,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sign Out'.tr,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to sign out ?'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: isDark ? Colors.white38 : Colors.black26,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Cancel'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // close dialog
                          controller.signOut();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.moroccoRed,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Log Out'.tr,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Drawer buildAppDrawer(BuildContext context, DashBoardController controller) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    var drawerOptions = <Widget>[];
    for (var i = 0; i < controller.drawerItems.length; i++) {
      var d = controller.drawerItems[i];
      bool isSelected = i == controller.selectedDrawerIndex.value;

      if (d.isHeader) {
        drawerOptions.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
            child: Text(
              d.title.tr,
              style: GoogleFonts.outfit(
                color: AppColors.moroccoRed,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
        continue;
      }

      drawerOptions.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: InkWell(
            onTap: () => controller.onSelectItem(i),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.moroccoRed.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(
                        color: AppColors.moroccoRed.withOpacity(0.1), width: 1)
                    : null,
              ),
              child: Row(
                children: [
                   SvgPicture.asset(
                    d.icon,
                    width: 18,
                    color: isSelected
                        ? AppColors.moroccoRed
                        : (isDark ? Colors.white54 : Colors.black45),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    d.title.tr,
                    style: GoogleFonts.outfit(
                      color: isSelected
                          ? AppColors.moroccoRed
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          // ── Premium Header ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius:
                  const BorderRadius.only(topRight: Radius.circular(35)),
            ),
            child: SafeArea(
              bottom: false,
              child: FutureBuilder<DriverUserModel?>(
                future: FireStoreUtils.getDriverProfile(
                    FireStoreUtils.getCurrentUid()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  DriverUserModel driverModel = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                    child: Row(
                      children: [
                        // Profile Circle
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.moroccoRed.withOpacity(0.1),
                                width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: CachedNetworkImage(
                              height: 75,
                              width: 75,
                              imageUrl: driverModel.profilePic.toString(),
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Constant.loader(isDarkTheme: isDark),
                              errorWidget: (context, url, error) =>
                                  Image.network(Constant.userPlaceHolder),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driverModel.fullName.toString(),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.moroccoRed,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              StreamBuilder<QuerySnapshot>(
                                stream: FireStoreUtils.fireStore
                                    .collection('review_driver')
                                    .where('driverId', isEqualTo: driverModel.id)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  double rating = 0.0;
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    double total = 0;
                                    for (var doc in snapshot.data!.docs) {
                                      total += double.tryParse(
                                              doc['rating'].toString()) ??
                                          0.0;
                                    }
                                    rating = total / snapshot.data!.docs.length;
                                  }
                                  return Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating
                                            .toStringAsFixed(1)
                                            .replaceAll('.', ','),
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Verified account".tr,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Menu Items ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 0),
              children: drawerOptions,
            ),
          ),

          // ── Version App Info (Bottom) ──
         /* Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "App Version v 1.0".tr,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: isDark ? Colors.white24 : Colors.black26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),*/
          SizedBox(height: 40,)
        ],
      ),
    );
  }
}

// ─── Custom Painters for Styling ──────────────────────────────────────────────
// _DrawerHeaderPainter was removed as it is no longer used in the new drawer design.
