import 'dart:math';

import 'package:driver/constant/constant.dart';
import 'package:driver/controller/online_registration_controller.dart';
import 'package:driver/model/document_model.dart';
import 'package:driver/model/driver_document_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/online_registration/details_upload_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OnlineRegistrationScreen extends StatefulWidget {
  const OnlineRegistrationScreen({super.key});

  @override
  State<OnlineRegistrationScreen> createState() =>
      _OnlineRegistrationScreenState();
}

class _OnlineRegistrationScreenState extends State<OnlineRegistrationScreen>
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

    return GetBuilder<OnlineRegistrationController>(
      init: OnlineRegistrationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor:
              !isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
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
                child: controller.isLoading.value
                    ? Center(
                        child: Constant.loader(isDarkTheme: isDark),
                      )
                    : Column(
                        children: [
                          _buildHeader(context, isDark),
                          Expanded(
                            child: controller.documentList.isEmpty
                                ? Constant.showEmptyView(
                                    message: "No documents found.".tr)
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 8, 20, 30),
                                    itemCount: controller.documentList.length,
                                    itemBuilder: (context, index) {
                                      DocumentModel documentModel =
                                          controller.documentList[index];
                                      Documents documents = Documents();

                                      var contain = controller
                                          .driverDocumentList
                                          .where((element) =>
                                              element.documentId ==
                                              documentModel.id);
                                      if (contain.isNotEmpty) {
                                        documents = controller
                                            .driverDocumentList
                                            .firstWhere((itemToCheck) =>
                                                itemToCheck.documentId ==
                                                documentModel.id);
                                      }

                                      return _buildDocumentCard(
                                        context,
                                        !isDark,
                                        documentModel,
                                        documents,
                                      );
                                    },
                                  ),
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

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          // Top bar with back button and logo
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
                      color: !isDark ? Colors.white12 : Colors.white,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: !isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const Spacer(),
              Image.asset(
                "assets/images/splash_image.png",
                width: 170,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              // Placeholder to balance layout
            ],
          ),

          // Gradient title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.moroccoRed, AppColors.moroccoGreen],
            ).createShader(bounds),
            child: Text(
              "Document Verification".tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Upload and verify your required documents".tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    bool isDark,
    DocumentModel documentModel,
    Documents documents,
  ) {
    final bool isVerified = documents.verified == true;
    final bool isUploaded =
        documents.documentId != null && documents.documentId!.isNotEmpty;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (isVerified) {
      statusColor = AppColors.moroccoGreen;
      statusLabel = "Verified".tr;
      statusIcon = Icons.verified_rounded;
    } else if (isUploaded) {
      statusColor = Colors.orange;
      statusLabel = "Under Review".tr;
      statusIcon = Icons.hourglass_top_rounded;
    } else {
      statusColor = AppColors.moroccoRed;
      statusLabel = "Unverified".tr;
      statusIcon = Icons.upload_file_rounded;
    }

    return GestureDetector(
      onTap: () {
        Get.to(const DetailsUploadScreen(),
            arguments: {'documentModel': documentModel});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isVerified
                ? AppColors.moroccoGreen.withOpacity(0.4)
                : (isDark ? Colors.white12 : Colors.grey.withOpacity(0.15)),
            width: isVerified ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isVerified
                  ? AppColors.moroccoGreen.withOpacity(0.08)
                  : Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Document icon container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),

              // Title & status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Constant.localizationTitle(documentModel.title),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(statusIcon, size: 13, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
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
