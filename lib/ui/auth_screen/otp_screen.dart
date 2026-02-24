import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/otp_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/auth_screen/information_screen.dart';
import 'package:driver/ui/dashboard_screen.dart';
import 'package:driver/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
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

    return GetX<OtpController>(
      init: OtpController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              !isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
          body: Stack(
            children: [
              // 1. Immersive Animated Background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ModernMoroccanPainter(
                        scrollOffset: _backgroundController.value,
                        isDark: !isDark,
                      ),
                    );
                  },
                ),
              ),

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

                        const SizedBox(height: 28),

                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.moroccoRed,
                              AppColors.moroccoGreen
                            ],
                          ).createShader(bounds),
                          child: Text(
                            "Verify OTP".tr,
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
                          "Enter the code sent to".tr,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: !isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                        Text(
                          "${controller.countryCode.value} ${controller.phoneNumber.value}",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.moroccoRed,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // 3. Clean Card
                        _buildGlassCard(context, !isDark, controller),

                        const SizedBox(height: 32),

                        // Resend Section
                        _buildResendSection(!isDark),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
      BuildContext context, bool isDark, OtpController controller) {
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
        children: [
          PinCodeTextField(
            length: 6,
            appContext: context,
            keyboardType: TextInputType.number,
            controller: controller.otpController.value,
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.box,
              borderRadius: BorderRadius.circular(15),
              fieldHeight: 50,
              fieldWidth: 40,
              inactiveColor:
                  isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
              selectedColor: AppColors.moroccoRed,
              activeColor: AppColors.moroccoGreen,
              inactiveFillColor:
                  isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
              selectedFillColor: isDark ? Colors.white10 : Colors.white,
              activeFillColor: isDark ? Colors.white10 : Colors.white,
            ),
            enableActiveFill: true,
            cursorColor: AppColors.moroccoRed,
            textStyle: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onChanged: (value) {},
          ),
          const SizedBox(height: 32),
          _buildPrimaryButton(controller),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(OtpController controller) {
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
          if (controller.otpController.value.text.length == 6) {
            ShowToastDialog.showLoader("Verify OTP".tr);

            PhoneAuthCredential credential = PhoneAuthProvider.credential(
              verificationId: controller.verificationId.value,
              smsCode: controller.otpController.value.text,
            );

            await FirebaseAuth.instance
                .signInWithCredential(credential)
                .then((value) async {
              if (value.additionalUserInfo!.isNewUser) {
                log("----->new user");
                DriverUserModel userModel = DriverUserModel();
                userModel.id = value.user!.uid;
                userModel.countryCode = controller.countryCode.value;
                userModel.phoneNumber = controller.phoneNumber.value;
                userModel.loginType = Constant.phoneLoginType;

                ShowToastDialog.closeLoader();
                Get.off(const InformationScreen(), arguments: {
                  "userModel": userModel,
                });
              } else {
                log("----->old user");
                await FireStoreUtils.userExitCustomerOrDriverRole(
                        value.user!.uid)
                    .then((userExit) async {
                  ShowToastDialog.closeLoader();
                  if (userExit == '') {
                    DriverUserModel userModel = DriverUserModel();
                    userModel.id = value.user!.uid;
                    userModel.countryCode = controller.countryCode.value;
                    userModel.phoneNumber = controller.phoneNumber.value;
                    userModel.loginType = Constant.phoneLoginType;

                    Get.off(const InformationScreen(), arguments: {
                      "userModel": userModel,
                    });
                  } else if (userExit == Constant.currentUserType) {
                    await FireStoreUtils.getDriverProfile(value.user!.uid)
                        .then((driverData) async {
                      if (driverData != null) {
                        DriverUserModel userModel = driverData;
                        bool isPlanExpire = false;
                        if (userModel.subscriptionPlan?.id != null) {
                          if (userModel.subscriptionExpiryDate == null) {
                            isPlanExpire =
                                (userModel.subscriptionPlan?.expiryDay != '-1');
                          } else {
                            DateTime expiryDate =
                                userModel.subscriptionExpiryDate!.toDate();
                            isPlanExpire = expiryDate.isBefore(DateTime.now());
                          }
                        } else {
                          isPlanExpire = true;
                        }

                        if ((userModel.subscriptionPlanId == null ||
                                isPlanExpire == true) &&
                            userModel.ownerId == null) {
                          if (Constant.adminCommission?.isEnabled == false &&
                              Constant.isSubscriptionModelApplied == false) {
                            Get.offAll(const DashBoardScreen());
                          } else {
                            Get.offAll(const SubscriptionListScreen(),
                                arguments: {"isShow": true});
                          }
                        } else {
                          if (userModel.ownerId != null &&
                              userModel.isEnabled == false) {
                            await FirebaseAuth.instance.signOut();
                            Get.back();
                            ShowToastDialog.showToast(
                                'This account has been disabled. Please reach out to the owner'
                                    .tr);
                          } else {
                            Get.offAll(const DashBoardScreen());
                          }
                        }
                      }
                    });
                  } else {
                    await FirebaseAuth.instance.signOut();
                    ShowToastDialog.showToast(
                        'This mobile number is already registered with a different role.'
                            .tr);
                  }
                });
              }
            }).catchError((error) {
              ShowToastDialog.closeLoader();
              ShowToastDialog.showToast("Code is Invalid".tr);
            });
          } else {
            ShowToastDialog.showToast("Please Enter Valid OTP".tr);
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
          "Verify OTP".tr,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResendSection(bool isDark) {
    return Column(
      children: [
        Text(
          "Didn't receive code?".tr,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        TextButton(
          onPressed: () {
            // Controller handles resend logic if available
          },
          child: Text(
            "Resend OTP".tr,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: AppColors.moroccoGreen,
            ),
          ),
        ),
      ],
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
      ..color = AppColors.moroccoRed.withOpacity(isDark ? 0.05 : 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintGreen = Paint()
      ..color = AppColors.moroccoGreen.withOpacity(isDark ? 0.05 : 0.03)
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
