import 'dart:math' as math;
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/information_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/referral_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/dashboard_screen.dart';
import 'package:driver/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX<InformationController>(
        init: InformationController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: !isDark
                ? AppColors.darkBackground
                : AppColors.moroccoBackground,
            body: Stack(
              children: [
                // // 1. Immersive Animated Background
                // Positioned.fill(
                //   child: AnimatedBuilder(
                //     animation: _backgroundController,
                //     builder: (context, child) {
                //       return CustomPaint(
                //         painter: ModernMoroccanPainter(
                //           scrollOffset: _backgroundController.value,
                //           isDark: !isDark,
                //         ),
                //       );
                //     },
                //   ),
                // ),

                // 2. Main Content
                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),

                          // Logo Section
                          _buildModernLogo(),

                          const SizedBox(height: 14),

                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                AppColors.moroccoRed,
                                AppColors.moroccoGreen
                              ],
                            ).createShader(bounds),
                            child: Text(
                              "Sign up".tr,
                              style: GoogleFonts.outfit(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Create your account to start using SIIR".tr,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: !isDark ? Colors.white60 : Colors.black45,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // 3. Form Card
                          _buildGlassCard(context, !isDark, controller),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildModernLogo() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: Center(
        child: Image.asset(
          "assets/images/splash_image.png",
          width: 170,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildGlassCard(
      BuildContext context, bool isDark, InformationController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color:
              isDark ? Colors.white12 : AppColors.moroccoGreen.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            hintText: 'Full name'.tr,
            controller: controller.fullNameController.value,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildPhoneField(controller, isDark),
          const SizedBox(height: 16),
          _buildTextField(
            hintText: 'Email'.tr,
            controller: controller.emailController.value,
            isDark: isDark,
            enable: controller.loginType.value != Constant.googleLoginType,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            hintText: 'Referral Code (Optional)'.tr,
            controller: controller.referralCodeController.value,
            isDark: isDark,
          ),
          const SizedBox(height: 32),
          _buildPrimaryButton(controller),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    required bool isDark,
    bool enable = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? Colors.white10 : AppColors.moroccoGreen.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enable,
        style: GoogleFonts.outfit(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            color: isDark ? Colors.white30 : Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField(InformationController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? Colors.white10 : AppColors.moroccoGreen.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: controller.phoneNumberController.value,
        enabled: controller.loginType.value != Constant.phoneLoginType,
        style: GoogleFonts.outfit(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: CountryCodePicker(
            onChanged: (value) {
              controller.countryCode.value = value.dialCode.toString();
            },
            dialogBackgroundColor:
                isDark ? AppColors.darkBackground : AppColors.background,
            initialSelection: controller.countryCode.value,
            textStyle: GoogleFonts.outfit(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            showFlagMain: true,
            flagDecoration:
                BoxDecoration(borderRadius: BorderRadius.circular(4)),
          ),
          border: InputBorder.none,
          hintText: "Phone number".tr,
          hintStyle: GoogleFonts.outfit(
            color: isDark ? Colors.white30 : Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(InformationController controller) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.moroccoRed.withOpacity(0.9),
            AppColors.moroccoRed.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.moroccoGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (controller.fullNameController.value.text.isEmpty) {
            ShowToastDialog.showToast("Please enter full name".tr);
          } else if (controller.emailController.value.text.isEmpty) {
            ShowToastDialog.showToast("Please enter email".tr);
          } else if (controller.phoneNumberController.value.text.isEmpty) {
            ShowToastDialog.showToast("Please enter phone number".tr);
          } else if (Constant.validateEmail(
                  controller.emailController.value.text) ==
              false) {
            ShowToastDialog.showToast("Please enter valid email".tr);
          } else {
            if (controller.referralCodeController.value.text.isNotEmpty) {
              FireStoreUtils.checkReferralCodeValidOrNot(
                      controller.referralCodeController.value.text)
                  .then((value) async {
                if (value == true) {
                  ShowToastDialog.showLoader("Please wait".tr);
                  DriverUserModel userModel = controller.userModel.value;
                  userModel.fullName = controller.fullNameController.value.text;
                  userModel.email = controller.emailController.value.text;
                  userModel.countryCode = controller.countryCode.value;
                  userModel.phoneNumber =
                      controller.phoneNumberController.value.text;
                  userModel.documentVerification = false;
                  userModel.isOnline = false;
                  userModel.isEnabled = true;
                  userModel.createdAt = Timestamp.now();
                  String token = await NotificationService.getToken();
                  userModel.fcmToken = token;
                  await FireStoreUtils.getReferralUserByCode(
                          controller.referralCodeController.value.text)
                      .then((value) async {
                    if (value != null) {
                      ReferralModel ownReferralModel = ReferralModel(
                        id: FireStoreUtils.getCurrentUid(),
                        referralBy: value.id,
                        referralCode: Constant.getReferralCode(),
                      );
                      await FireStoreUtils.referralAdd(ownReferralModel);
                    } else {
                      ReferralModel referralModel = ReferralModel(
                          id: FireStoreUtils.getCurrentUid(),
                          referralBy: "",
                          referralCode: Constant.getReferralCode());
                      await FireStoreUtils.referralAdd(referralModel);
                    }
                  });
                  await FireStoreUtils.updateDriverUser(userModel)
                      .then((value) {
                    ShowToastDialog.closeLoader();
                    if (value == true) {
                      bool isPlanExpire = false;
                      if (userModel.subscriptionPlan?.id != null) {
                        if (userModel.subscriptionExpiryDate == null) {
                          if (userModel.subscriptionPlan?.expiryDay == '-1') {
                            isPlanExpire = false;
                          } else {
                            isPlanExpire = true;
                          }
                        } else {
                          DateTime expiryDate =
                              userModel.subscriptionExpiryDate!.toDate();
                          isPlanExpire = expiryDate.isBefore(DateTime.now());
                        }
                      } else {
                        isPlanExpire = true;
                      }

                      if (userModel.subscriptionPlanId == null ||
                          isPlanExpire == true) {
                        if (Constant.adminCommission?.isEnabled == false &&
                            Constant.isSubscriptionModelApplied == false) {
                          Get.offAll(const DashBoardScreen());
                        } else {
                          Get.offAll(const SubscriptionListScreen(),
                              arguments: {"isShow": true});
                        }
                      } else {
                        Get.offAll(const DashBoardScreen());
                      }
                    }
                  });
                } else {
                  ShowToastDialog.showToast("Referral code Invalid".tr);
                }
              });
            } else {
              ShowToastDialog.showLoader("Please wait".tr);
              DriverUserModel userModel = controller.userModel.value;
              userModel.fullName = controller.fullNameController.value.text;
              userModel.email = controller.emailController.value.text;
              userModel.countryCode = controller.countryCode.value;
              userModel.phoneNumber =
                  controller.phoneNumberController.value.text;
              userModel.documentVerification = false;
              userModel.isOnline = false;
              userModel.isEnabled = true;
              userModel.createdAt = Timestamp.now();
              String token = await NotificationService.getToken();
              userModel.fcmToken = token;

              ReferralModel referralModel = ReferralModel(
                id: FireStoreUtils.getCurrentUid(),
                referralBy: "",
                referralCode: Constant.getReferralCode(),
              );
              await FireStoreUtils.referralAdd(referralModel);

              await FireStoreUtils.updateDriverUser(userModel).then((value) {
                ShowToastDialog.closeLoader();
                if (value == true) {
                  bool isPlanExpire = false;
                  if (userModel.subscriptionPlan?.id != null) {
                    if (userModel.subscriptionExpiryDate == null) {
                      if (userModel.subscriptionPlan?.expiryDay == '-1') {
                        isPlanExpire = false;
                      } else {
                        isPlanExpire = true;
                      }
                    } else {
                      DateTime expiryDate =
                          userModel.subscriptionExpiryDate!.toDate();
                      isPlanExpire = expiryDate.isBefore(DateTime.now());
                    }
                  } else {
                    isPlanExpire = true;
                  }

                  if (userModel.subscriptionPlanId == null ||
                      isPlanExpire == true) {
                    if (Constant.adminCommission?.isEnabled == false &&
                        Constant.isSubscriptionModelApplied == false) {
                      Get.offAll(const DashBoardScreen());
                    } else {
                      Get.offAll(const SubscriptionListScreen(),
                          arguments: {"isShow": true});
                    }
                  } else {
                    Get.offAll(const DashBoardScreen());
                  }
                }
              });
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          "Create account".tr,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class ModernMoroccanPainter extends CustomPainter {
  final double scrollOffset;
  final bool isDark;

  ModernMoroccanPainter({required this.scrollOffset, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paintRed = Paint()
      ..color = AppColors.moroccoRed.withOpacity(isDark ? 0.01 : 0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintGreen = Paint()
      ..color = AppColors.moroccoGreen.withOpacity(isDark ? 0.01 : 0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double patternSize = 140.0;
    final double offset = scrollOffset * patternSize;

    for (double x = -patternSize;
        x < size.width + patternSize;
        x += patternSize) {
      for (double y = -patternSize;
          y < size.height + patternSize;
          y += patternSize) {
        bool isEvenRow = (y / patternSize).round().isEven;
        bool isEvenCol = (x / patternSize).round().isEven;
        Paint activePaint = (isEvenRow ^ isEvenCol) ? paintRed : paintGreen;
        _drawEightPointStar(canvas, Offset(x + offset, y + offset),
            patternSize * 0.35, activePaint);
      }
    }
  }

  void _drawEightPointStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    Path path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
      double midAngle = (i + 0.5) * math.pi / 4;
      double midX = center.dx + (radius * 0.6) * math.cos(midAngle);
      double midY = center.dy + (radius * 0.6) * math.sin(midAngle);
      path.lineTo(midX, midY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ModernMoroccanPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset || oldDelegate.isDark != isDark;
}
