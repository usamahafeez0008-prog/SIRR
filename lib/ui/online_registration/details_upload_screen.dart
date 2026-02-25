import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/details_upload_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailsUploadScreen extends StatefulWidget {
  const DetailsUploadScreen({super.key});

  @override
  State<DetailsUploadScreen> createState() => _DetailsUploadScreenState();
}

class _DetailsUploadScreenState extends State<DetailsUploadScreen>
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
    final bool isDark = !themeChange.getThem();

    return GetX<DetailsUploadController>(
      init: DetailsUploadController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
          body: Stack(
            children: [
              // Animated Moroccan background
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _MoroccanPainter(
                        scrollOffset: _backgroundController.value,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, controller, isDark),
                    Expanded(
                      child: controller.isLoading.value
                          ? Center(
                              child: Constant.loader(isDarkTheme: isDark),
                            )
                          : _buildBody(context, controller, isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context, DetailsUploadController controller, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                "assets/images/splash_image.png",
                width: 110,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              const SizedBox(width: 42),
            ],
          ),
          const SizedBox(height: 16),

          // Gradient title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.moroccoRed, AppColors.moroccoGreen],
            ).createShader(bounds),
            child: Text(
              Constant.localizationTitle(controller.documentModel.value.title),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Upload Your ${Constant.localizationTitle(controller.documentModel.value.title)} Details "
                .tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody(
      BuildContext context, DetailsUploadController controller, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document number input
          _buildSectionLabel(
            "${Constant.localizationTitle(controller.documentModel.value.title)} Number"
                .tr,
            Icons.badge_rounded,
            isDark,
          ),
          const SizedBox(height: 8),
          _buildStyledTextField(
            context,
            controller: controller.documentNumberController.value,
            hintText: "Number".tr,
            isDark: isDark,
          ),

          // Expiry date
          Visibility(
            visible: controller.documentModel.value.expireAt == true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSectionLabel(
                  "Expiry Date".tr,
                  Icons.calendar_month_rounded,
                  isDark,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    await Constant.selectFetureDate(context).then((value) {
                      if (value != null) {
                        controller.selectedDate.value = value;
                        controller.expireAtController.value.text =
                            DateFormat("dd-MM-yyyy").format(value);
                      }
                    });
                  },
                  child: _buildStyledTextField(
                    context,
                    controller: controller.expireAtController.value,
                    hintText: "Select Expire date".tr,
                    isDark: isDark,
                    enabled: false,
                    suffixIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.moroccoRed,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Front side image
          Visibility(
            visible: controller.documentModel.value.frontSide == true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSectionLabel(
                  "Front Side of ${Constant.localizationTitle(controller.documentModel.value.title)}"
                      .tr,
                  Icons.flip_to_front_rounded,
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildImageUploadArea(
                  context,
                  controller: controller,
                  isDark: isDark,
                  imageUrl: controller.frontImage.value,
                  type: "front",
                  themeChange:
                      Provider.of<DarkThemeProvider>(context, listen: false),
                ),
              ],
            ),
          ),

          // Back side image
          Visibility(
            visible: controller.documentModel.value.backSide == true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildSectionLabel(
                  "Back Side of ${Constant.localizationTitle(controller.documentModel.value.title)}"
                      .tr,
                  Icons.flip_to_back_rounded,
                  isDark,
                ),
                const SizedBox(height: 8),
                _buildImageUploadArea(
                  context,
                  controller: controller,
                  isDark: isDark,
                  imageUrl: controller.backImage.value,
                  type: "back",
                  themeChange:
                      Provider.of<DarkThemeProvider>(context, listen: false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Done button
          Visibility(
            visible: controller.documents.value.verified != true,
            child: _buildDoneButton(context, controller, isDark),
          ),
        ],
      ),
    );
  }

  // ─── Section Label ────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.moroccoRed),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // ─── Styled Text Field ────────────────────────────────────────────────────

  Widget _buildStyledTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    bool enabled = true,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.outfit(
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.moroccoRed, width: 1.5),
          ),
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  // ─── Image Upload Area ────────────────────────────────────────────────────

  Widget _buildImageUploadArea(
    BuildContext context, {
    required DetailsUploadController controller,
    required bool isDark,
    required String imageUrl,
    required String type,
    required DarkThemeProvider themeChange,
  }) {
    final bool hasImage = imageUrl.isNotEmpty;
    final bool isVerified = controller.documents.value.verified == true;

    if (hasImage) {
      return GestureDetector(
        onTap: () {
          if (!isVerified) {
            buildBottomSheet(context, controller, type);
          }
        },
        child: Container(
          height: Responsive.height(22, context),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isVerified
                  ? AppColors.moroccoGreen.withOpacity(0.5)
                  : AppColors.moroccoRed.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Constant().hasValidUrl(imageUrl) == false
                    ? Image.file(
                        File(imageUrl),
                        height: Responsive.height(22, context),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        height: Responsive.height(22, context),
                        width: double.infinity,
                        placeholder: (context, url) =>
                            Center(child: Constant.loader(isDarkTheme: isDark)),
                        errorWidget: (context, url, error) => Image.network(
                            'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                      ),
              ),
              // Edit overlay (only if not verified)
              if (!isVerified)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.moroccoRed,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.moroccoRed.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              // Verified badge
              if (isVerified)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.moroccoGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded,
                            color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          "Verified".tr,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Empty upload placeholder
    return GestureDetector(
      onTap: () => buildBottomSheet(context, controller, type),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(20),
          dashPattern: const [8, 6],
          color: AppColors.moroccoRed.withOpacity(0.4),
          strokeWidth: 1.5,
        ),
        child: Container(
          height: Responsive.height(20, context),
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.moroccoRed.withOpacity(0.04)
                : AppColors.moroccoRed.withOpacity(0.02),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.moroccoRed.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_rounded,
                  color: AppColors.moroccoRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Tap to upload photo".tr,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Camera or Gallery".tr,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Done Button ──────────────────────────────────────────────────────────

  Widget _buildDoneButton(
      BuildContext context, DetailsUploadController controller, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (controller.documentNumberController.value.text.isEmpty) {
            ShowToastDialog.showToast("Please enter document number".tr);
          } else {
            if (controller.documentModel.value.frontSide == true &&
                controller.frontImage.value.isEmpty) {
              ShowToastDialog.showToast(
                  "Please upload front side of document.".tr);
            } else if (controller.documentModel.value.backSide == true &&
                controller.backImage.value.isEmpty) {
              ShowToastDialog.showToast(
                  "Please upload back side of document.".tr);
            } else {
              ShowToastDialog.showLoader("Please wait..".tr);
              controller.uploadDocument();
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.moroccoRed,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: AppColors.moroccoRed.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              "Done".tr,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Sheet ─────────────────────────────────────────────────────────

  buildBottomSheet(
      BuildContext context, DetailsUploadController controller, String type) {
    final bool isDark =
        !Provider.of<DarkThemeProvider>(context, listen: false).getThem();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return Container(
            height: Responsive.height(26, context),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Select Source".tr,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      context,
                      isDark,
                      icon: Icons.camera_alt_rounded,
                      label: "Camera".tr,
                      onTap: () => controller.pickFile(
                          source: ImageSource.camera, type: type),
                    ),
                    Container(
                      height: 60,
                      width: 1,
                      color: isDark ? Colors.white12 : Colors.black87,
                    ),
                    _buildSourceOption(
                      context,
                      isDark,
                      icon: Icons.photo_library_rounded,
                      label: "Gallery".tr,
                      onTap: () => controller.pickFile(
                          source: ImageSource.gallery, type: type),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildSourceOption(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.moroccoRed.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.moroccoRed, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Moroccan Background Painter ─────────────────────────────────────────────

class _MoroccanPainter extends CustomPainter {
  final double scrollOffset;
  final bool isDark;

  const _MoroccanPainter({required this.scrollOffset, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paintRed = Paint()
      ..color = AppColors.moroccoRed.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintGreen = Paint()
      ..color = AppColors.moroccoGreen.withOpacity(0.03)
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
        _drawEightPointStar(
          canvas,
          Offset(x + offset, y + offset),
          patternSize * 0.35,
          activePaint,
        );
      }
    }
  }

  void _drawEightPointStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    const int points = 8;
    final double innerRadius = radius * 0.45;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? radius : innerRadius;
      final double angle = (pi * i) / points - pi / 2;
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MoroccanPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset;
}
