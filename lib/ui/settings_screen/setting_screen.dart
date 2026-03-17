import 'dart:convert';

import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/services/localization_service.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/auth_screen/login_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/Preferences.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/setting_controller.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetBuilder<SettingController>(
        init: SettingController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
           /* appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.moroccoRed, size: 20),
              ),
              title: Text(
                "Settings".tr,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : AppColors.moroccoRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),*/
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: isDark)
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkContainerBackground : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  _buildSettingRow(
                                    context,
                                    icon: 'assets/icons/ic_language.svg',
                                    title: "Language".tr,
                                    isDark: isDark,
                                    trailing: SizedBox(
                                      width: 100,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField(
                                            isExpanded: true,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                            value: controller.selectedLanguage.value.id == null ? null : controller.selectedLanguage.value,
                                            onChanged: (value) {
                                              controller.selectedLanguage.value = value!;
                                              LocalizationService().changeLocale(value.code.toString());
                                              Preferences.setString(Preferences.languageCodeKey, jsonEncode(controller.selectedLanguage.value));
                                            },
                                            hint: Text("select".tr, style: GoogleFonts.outfit(fontSize: 14)),
                                            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                            items: controller.languageList.map<DropdownMenuItem>((item) {
                                              return DropdownMenuItem(
                                                value: item,
                                                child: Text(
                                                  item.name.toString(),
                                                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            }).toList()),
                                      ),
                                    ),
                                  ),
                                  _buildDivider(isDark),
                                  _buildSettingRow(
                                    context,
                                    icon: 'assets/icons/ic_light_drak.svg',
                                    title: "Theme Mode".tr,
                                    isDark: isDark,
                                    trailing: SizedBox(
                                      width: 100,
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            decoration: const InputDecoration(
                                              contentPadding: EdgeInsets.zero,
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                            value: controller.selectedMode.isEmpty ? null : controller.selectedMode.value,
                                            onChanged: (value) {
                                              controller.selectedMode.value = value!;
                                              Preferences.setString(Preferences.themKey, value.toString());
                                              if (controller.selectedMode.value == "Dark mode") {
                                                themeChange.darkTheme = 0;
                                              } else if (controller.selectedMode.value == "Light mode") {
                                                themeChange.darkTheme = 1;
                                              } else {
                                                themeChange.darkTheme = 2;
                                              }
                                            },
                                            hint: Text("select".tr, style: GoogleFonts.outfit(fontSize: 14)),
                                            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                            items: controller.modeList.map<DropdownMenuItem<String>>((item) {
                                              return DropdownMenuItem<String>(
                                                value: item,
                                                child: Text(
                                                  item.toString().tr,
                                                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              );
                                            }).toList()),
                                      ),
                                    ),
                                  ),
                                  _buildDivider(isDark),
                                  _buildSettingRow(
                                    context,
                                    icon: 'assets/icons/ic_support.svg',
                                    title: "Support".tr,
                                    isDark: isDark,
                                    onTap: () async {
                                      final Uri url = Uri.parse(Constant.supportURL.toString());
                                      if (!await launchUrl(url)) {
                                        ShowToastDialog.showToast('Could not launch support URL'.tr);
                                      }
                                    },
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                  ),
                                  _buildDivider(isDark),
                                /*  _buildSettingRow(
                                    context,
                                    icon: 'assets/icons/ic_delete.svg',
                                    title: "Delete Account".tr,
                                    isDark: isDark,
                                    titleColor: Colors.red,
                                    iconColor: Colors.red,
                                    onTap: () => showAlertDialog(context, controller),
                                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
                                  ),*/
                                ],
                              ),
                            ),
                          ),
                        /*  Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "Version ${Constant.appVersion}",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )*/
                        ],
                      ),
                    ),
                  ),
          );
        });
  }

  Widget _buildSettingRow(BuildContext context, {required String icon, required String title, required bool isDark, Widget? trailing, VoidCallback? onTap, Color? titleColor, Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? (isDark ? Colors.white : AppColors.moroccoRed)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                icon,
                width: 20,
                height: 20,
                color: iconColor ?? (isDark ? Colors.white : AppColors.moroccoRed),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: titleColor ?? (isDark ? Colors.white : AppColors.moroccoText),
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
      height: 1,
      indent: 54,
    );
  }

  void showAlertDialog(BuildContext context, SettingController controller) {
    final isDark = Provider.of<DarkThemeProvider>(context, listen: false).getThem();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.darkContainerBackground : Colors.white,
          title: Text(
            "Account delete".tr,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.moroccoText),
          ),
          content: Text(
            "Are you sure want to delete Account.".tr,
            style: GoogleFonts.outfit(color: isDark ? Colors.white70 : Colors.black87),
          ),
          actions: [
            TextButton(
              child: Text("Cancel".tr, style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.w600)),
              onPressed: () => Get.back(),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Delete".tr, style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w700)),
              onPressed: () async {
                Get.back();
                ShowToastDialog.showLoader("Please wait".tr);
                await FireStoreUtils.deleteUser().then((value) {
                  ShowToastDialog.closeLoader();
                  if (value == true) {
                    ShowToastDialog.showToast("Account delete".tr);
                    Get.offAll(const LoginScreen());
                  } else {
                    ShowToastDialog.showToast("Please contact to administrator".tr);
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }
}
