import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/login_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/auth_screen/information_screen.dart';
import 'package:driver/ui/dashboard_screen.dart';
import 'package:driver/ui/subscription_plan_screen/subscription_list_screen.dart';
import 'package:driver/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
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

    return GetX<LoginController>(
        init: LoginController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: !isDark
                ? AppColors.darkBackground
                : AppColors.moroccoBackground,
            body: Stack(
              children: [
                // 1. Immersive Animated Background (Minimalist version like SplashScreen)
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
                              "Welcome Back".tr,
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
                            "Ready to drive with SIIR!".tr,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: !isDark ? Colors.white60 : Colors.black45,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // 3. Clean Card (Light Glassmversion)
                          _buildGlassCard(context, !isDark, controller),

                          const SizedBox(height: 32),

                          // Terms & Privacy
                          _buildModernTerms(isDark),
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
      BuildContext context, bool isDark, LoginController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
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
          Text(
            "Phone Login".tr,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.moroccoText,
            ),
          ),
          const SizedBox(height: 20),
          _buildModernTextField(controller, isDark),
          const SizedBox(height: 24),
          _buildPrimaryButton(controller),
          const SizedBox(height: 32),
          _buildDivider(isDark),
          const SizedBox(height: 32),
          _buildSocialLoginRow(controller, isDark),
        ],
      ),
    );
  }

  Widget _buildModernTextField(LoginController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? Colors.white10 : AppColors.moroccoGreen.withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        validator: (value) =>
            value != null && value.isNotEmpty ? null : 'Required'.tr,
        keyboardType: TextInputType.number,
        controller: controller.phoneNumberController.value,
        style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppColors.moroccoGreen),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: CountryCodePicker(
            onChanged: (value) {
              controller.countryCode.value = value.dialCode.toString();
            },
            dialogBackgroundColor: !isDark
                ? AppColors.moroccoGreen.withOpacity(0.6)
                : AppColors.background,
            initialSelection: controller.countryCode.value,
            textStyle: GoogleFonts.outfit(
              color: isDark ? Colors.white70 : AppColors.moroccoGreen,
              fontWeight: FontWeight.w600,
            ),
            showFlagMain: true,
            flagDecoration:
                BoxDecoration(borderRadius: BorderRadius.circular(4)),
          ),
          border: InputBorder.none,
          hintText: "6/7 XX XX XX XX".tr,
          hintStyle: GoogleFonts.outfit(
              color: isDark ? Colors.white30 : Colors.black26),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(LoginController controller) {
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
        onPressed: () => controller.sendCode(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          "Get OTP".tr,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
            child: Divider(
                color: isDark
                    ? Colors.white10
                    : AppColors.moroccoGreen.withOpacity(0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Quick Login".tr,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.moroccoGreen.withOpacity(0.6),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Expanded(
            child: Divider(
                color: isDark
                    ? Colors.white10
                    : AppColors.moroccoGreen.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildSocialLoginRow(LoginController controller, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircularSocialButton(
          icon: 'assets/icons/ic_google.png',
          isDark: isDark,
          onTap: () async {
            ShowToastDialog.showLoader("Connecting...".tr);
            await controller.signInWithGoogle().then((value) async {
              ShowToastDialog.closeLoader();
              if (value != null) _handleSocialLogin(value, "google");
            });
          },
        ),
        const SizedBox(width: 20),
        _buildCircularSocialButton(
          icon: Icons.facebook,
          isDark: isDark,
          onTap: () async {
            await controller.signInWithFacebook();
          },
        ),
        if (Platform.isIOS) ...[
          const SizedBox(width: 20),
          _buildCircularSocialButton(
            icon: 'assets/icons/ic_apple.png',
            isDark: isDark,
            isApple: true,
            onTap: () async {
              ShowToastDialog.showLoader("Connecting...".tr);
              await controller.signInWithApple().then((value) {
                ShowToastDialog.closeLoader();
                if (value != null) _handleSocialLogin(value, "apple");
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCircularSocialButton({
    required dynamic icon,
    required bool isDark,
    required VoidCallback onTap,
    bool isApple = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? Colors.white12
                : AppColors.moroccoGreen.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: icon is String
            ? Image.asset(
                icon,
                color: isApple && isDark ? Colors.white : null,
              )
            : Icon(
                icon as IconData,
                color: icon == Icons.facebook
                    ? const Color(0xFF1877F2)
                    : (isDark ? Colors.white : Colors.black87),
                size: 28,
              ),
      ),
    );
  }

  Widget _buildModernTerms(bool isDark) {
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        text: 'Agreement on '.tr,
        style: GoogleFonts.outfit(
          fontSize: 12,
          color: !isDark ? Colors.white38 : Colors.black38,
        ),
        children: [
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap =
                  () => Get.to(const TermsAndConditionScreen(type: "terms")),
            text: 'Terms'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.moroccoRed),
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            recognizer: TapGestureRecognizer()
              ..onTap =
                  () => Get.to(const TermsAndConditionScreen(type: "privacy")),
            text: 'Privacy'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.moroccoGreen),
          ),
        ],
      ),
    );
  }

  void _handleSocialLogin(dynamic value, String type) async {
    UserCredential? userCredential;
    Map<String, dynamic>? appleData;

    if (type == "google") {
      userCredential = value as UserCredential;
    } else {
      appleData = value as Map<String, dynamic>;
      userCredential = appleData['userCredential'];
    }

    if (userCredential?.additionalUserInfo?.isNewUser == true) {
      DriverUserModel userModel = DriverUserModel(
        id: userCredential!.user!.uid,
        email: userCredential.user!.email,
        fullName: type == "google"
            ? userCredential.user!.displayName
            : "${appleData!['appleCredential'].givenName} ${appleData['appleCredential'].familyName}",
        profilePic: userCredential.user!.photoURL,
        loginType: type == "google"
            ? Constant.googleLoginType
            : Constant.appleLoginType,
      );
      Get.to(const InformationScreen(), arguments: {"userModel": userModel});
    } else if (userCredential?.user != null) {
      FireStoreUtils.userExitCustomerOrDriverRole(userCredential!.user!.uid)
          .then((userExit) async {
        if (userExit == '') {
          DriverUserModel userModel = DriverUserModel(
            id: userCredential!.user!.uid,
            email: userCredential.user!.email,
            loginType: type == "google"
                ? Constant.googleLoginType
                : Constant.appleLoginType,
          );
          Get.to(const InformationScreen(),
              arguments: {"userModel": userModel});
        } else if (userExit == Constant.currentUserType) {
          _handleOldUserLogin(userCredential!.user!.uid);
        } else {
          await FirebaseAuth.instance.signOut();
          ShowToastDialog.showToast('Account conflict.'.tr);
        }
      });
    }
  }

  void _handleOldUserLogin(String uid) async {
    ShowToastDialog.showLoader("Checking profile...".tr);
    await FireStoreUtils.getDriverProfile(uid).then((value) async {
      ShowToastDialog.closeLoader();
      if (value != null) {
        DriverUserModel userModel = value;
        bool isExpired = false;
        if (userModel.subscriptionPlan?.id != null) {
          isExpired = userModel.subscriptionExpiryDate
                  ?.toDate()
                  .isBefore(DateTime.now()) ??
              true;
        } else {
          isExpired = true;
        }

        if ((userModel.subscriptionPlanId == null || isExpired) &&
            userModel.ownerId == null) {
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

class ModernMoroccanPainter extends CustomPainter {
  final double scrollOffset;
  final bool isDark;

  ModernMoroccanPainter({required this.scrollOffset, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle Red stars
    final paintRed = Paint()
      ..color = AppColors.moroccoRed.withOpacity(isDark ? 0.05 : 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Subtle Green stars
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
        // Alternate colors in a grid
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
