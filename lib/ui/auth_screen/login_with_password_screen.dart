import 'package:country_code_picker/country_code_picker.dart';
import 'package:driver/controller/login_with_password_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/auth_screen/login_screen.dart'; // To use ModernMoroccanPainter
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LoginWithPasswordScreen extends StatefulWidget {
  const LoginWithPasswordScreen({Key? key}) : super(key: key);

  @override
  State<LoginWithPasswordScreen> createState() =>
      _LoginWithPasswordScreenState();
}

class _LoginWithPasswordScreenState extends State<LoginWithPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

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
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX<LoginWithPasswordController>(
        init: LoginWithPasswordController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: !isDark
                ? AppColors.darkBackground
                : AppColors.moroccoBackground,
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

                // Back Button
                // SafeArea(
                //   child: Positioned(
                //     top: 10,
                //     left: 20,
                //     child: Align(
                //       alignment: Alignment.topLeft,
                //       child: Padding(
                //         padding: const EdgeInsets.only(left: 24.0, top: 10),
                //         child: InkWell(
                //           onTap: () => Get.back(),
                //           borderRadius: BorderRadius.circular(12),
                //           child: Container(
                //             padding: const EdgeInsets.all(10),
                //             decoration: BoxDecoration(
                //               color: !isDark
                //                   ? Colors.white.withOpacity(0.08)
                //                   : Colors.white.withOpacity(0.7),
                //               borderRadius: BorderRadius.circular(12),
                //               border: Border.all(
                //                 color: !isDark ? Colors.white12 : Colors.white,
                //               ),
                //             ),
                //             child: Icon(
                //               Icons.arrow_back_ios_new,
                //               size: 18,
                //               color: !isDark ? Colors.white : Colors.black87,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
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
                          _buildModernTerms(!isDark),
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

  Widget _buildGlassCard(BuildContext context, bool isDark,
      LoginWithPasswordController controller) {
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
            "Login with Password".tr,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.moroccoText,
            ),
          ),
          const SizedBox(height: 20),
          _buildModernTextField(controller, isDark),
          const SizedBox(height: 16),
          _buildPasswordField(isDark),
          const SizedBox(height: 24),
          _buildPrimaryButton(context, controller),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Get.to(() => const LoginScreen());
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  textAlign: TextAlign.right,
                  "Don't have an account! SignUp".tr,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.moroccoGreen,
                    //decoration: TextDecoration.underline,
                    decorationColor: AppColors.moroccoRed,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField(
      LoginWithPasswordController controller, bool isDark) {
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

  Widget _buildPasswordField(bool isDark) {
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
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppColors.moroccoGreen),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: InputBorder.none,
          hintText: "Enter your password".tr,
          hintStyle: GoogleFonts.outfit(
              color: isDark ? Colors.white30 : Colors.black26),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: isDark
                  ? Colors.white30
                  : AppColors.moroccoGreen.withOpacity(0.6),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
      BuildContext context, LoginWithPasswordController controller) {
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
        // boxShadow: [
        //   BoxShadow(
        //     color: AppColors.moroccoGreen.withOpacity(0.3),
        //     blurRadius: 15,
        //     offset: const Offset(0, 8),
        //   ),
        // ],
      ),
      child: ElevatedButton(
        onPressed: () {
          controller.loginWithPassword(_passwordController.text.trim());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          "Login".tr,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
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
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        children: [
          TextSpan(
            recognizer: TapGestureRecognizer()..onTap = () {},
            text: 'Terms'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.moroccoRed),
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            recognizer: TapGestureRecognizer()..onTap = () {},
            text: 'Privacy'.tr,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.moroccoGreen),
          ),
        ],
      ),
    );
  }
}
