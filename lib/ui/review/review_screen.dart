import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/rating_controller.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatelessWidget {
  // UI for rating and reviewing customers
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX<RatingController>(
        init: RatingController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor:
                isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
            appBar: AppBar(
              backgroundColor: AppColors.moroccoRed,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Rate Customer".tr,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700, color: Colors.white),
              ),
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            body: controller.isLoading.value == true
                ? Constant.loader(isDarkTheme: isDark)
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        // Decorative Top Section
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 120,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: AppColors.moroccoRed,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(40),
                                  bottomRight: Radius.circular(40),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: CachedNetworkImage(
                                    imageUrl: controller
                                        .userModel.value.profilePic
                                        .toString(),
                                    height: 110,
                                    width: 110,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Constant.loader(isDarkTheme: isDark),
                                    errorWidget: (context, url, error) =>
                                        Image.network(Constant.userPlaceHolder),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),

                        // Review Content area
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              Text(
                                controller.userModel.value.fullName ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.moroccoText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    Constant.calculateReview(
                                      reviewCount: controller
                                          .userModel.value.reviewsCount
                                          .toString(),
                                      reviewSum: controller
                                          .userModel.value.reviewsSum
                                          .toString(),
                                    ).toString(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

                              // Interactive Rating Card
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkContainerBackground
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white10
                                        : AppColors.moroccoRed
                                            .withOpacity(0.05),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 15,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "How was your trip?".tr,
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    RatingBar.builder(
                                      initialRating: controller.rating.value,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        controller.rating(rating);
                                      },
                                    ),
                                    const SizedBox(height: 24),

                                    // Review Tags
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        'Polite',
                                        'On time',
                                        'Friendly',
                                        'Easy location',
                                        'Rude',
                                        'Late',
                                        'Attempt Fraud',
                                      ].map((tag) {
                                        bool isSelected = controller.selectedTags.contains(tag);
                                        return InkWell(
                                          onTap: () {
                                            if (isSelected) {
                                              controller.selectedTags.remove(tag);
                                            } else {
                                              controller.selectedTags.add(tag);
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppColors.moroccoRed
                                                  : (isDark
                                                      ? Colors.white10
                                                      : Colors.grey[100]),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.moroccoRed
                                                    : (isDark
                                                        ? Colors.white24
                                                        : Colors.grey[200]!),
                                              ),
                                            ),
                                            child: Text(
                                              tag.tr,
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isDark
                                                        ? Colors.white70
                                                        : Colors.black54),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),

                                    const SizedBox(height: 24),
                                    TextField(
                                      controller:
                                          controller.commentController.value,
                                      maxLines: 2,
                                      style: GoogleFonts.outfit(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black87),
                                      decoration: InputDecoration(
                                        hintText: 'Share your feedback...'.tr,
                                        hintStyle: GoogleFonts.outfit(
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.grey[400]),
                                        fillColor: isDark
                                            ? Colors.white.withOpacity(0.05)
                                            : Colors.grey[50]?.withOpacity(0.5),
                                        filled: true,
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: isDark
                                                  ? Colors.white12
                                                  : Colors.grey[200]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                              color: isDark
                                                  ? Colors.white12
                                                  : Colors.grey[200]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                              color: AppColors.moroccoRed,
                                              width: 1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Submit Button
                              ButtonThem.buildButton(
                                context,
                                title: "Submit Review".tr,
                                bgColors: AppColors.moroccoGreen,
                                textColor: Colors.white,
                                onPress: () async {
                                  if (controller.rating.value > 0) {
                                    ShowToastDialog.showLoader(
                                        "Submitting Feedback...".tr);

                                    await FireStoreUtils.getCustomer(controller
                                                    .type.value ==
                                                 "orderModel"
                                            ? controller.orderModel.value.userId
                                                .toString()
                                            : controller.intercityOrderModel
                                                .value.userId
                                                .toString())
                                        .then((value) async {
                                      if (value != null) {
                                        UserModel userModel = value;

                                        if (controller.reviewModel.value.id !=
                                            null) {
                                          userModel.reviewsSum = (double.parse(
                                                      userModel.reviewsSum
                                                          .toString()) -
                                                   double.parse(controller
                                                       .reviewModel.value.rating
                                                       .toString()))
                                              .toString();
                                          userModel.reviewsCount =
                                              (double.parse(userModel
                                                           .reviewsCount
                                                           .toString()) -
                                                       1)
                                                  .toString();
                                        }
                                        userModel.reviewsSum = (double.parse(
                                                    userModel.reviewsSum
                                                        .toString()) +
                                                double.parse(controller
                                                    .rating.value
                                                    .toString()))
                                            .toString();
                                        userModel.reviewsCount = (double.parse(
                                                    userModel.reviewsCount
                                                        .toString()) +
                                                1)
                                            .toString();
                                        await FireStoreUtils.updateUser(
                                            userModel);
                                      }
                                    });

                                    controller.reviewModel.value.id =
                                        controller.type.value == "orderModel"
                                            ? controller.orderModel.value.id
                                            : controller
                                                .intercityOrderModel.value.id;
                                    
                                    String tagsText = controller.selectedTags.join(", ");
                                    controller.reviewModel.value.comment = 
                                        "${tagsText.isNotEmpty ? "[$tagsText] " : ""}${controller.commentController.value.text}";
                                    
                                    controller.reviewModel.value.rating =
                                        controller.rating.value.toString();
                                    controller.reviewModel.value.customerId =
                                        FireStoreUtils.getCurrentUid();
                                    controller.reviewModel.value.driverId =
                                        controller.type.value == "orderModel"
                                            ? controller
                                                .orderModel.value.driverId
                                            : controller.intercityOrderModel
                                                .value.driverId;
                                    controller.reviewModel.value.date =
                                        Timestamp.now();
                                    controller.reviewModel.value.type =
                                        controller.type.value == "orderModel"
                                            ? "city"
                                            : "intercity";

                                    await FireStoreUtils.setReview(
                                            controller.reviewModel.value)
                                        .then((value) {
                                      if (value != null && value == true) {
                                        ShowToastDialog.closeLoader();
                                        Get.back();
                                        ShowToastDialog.showToast(
                                            "Thank you for your feedback!".tr);
                                      }
                                    });
                                  } else {
                                    ShowToastDialog.showToast(
                                        "Please provide a rating.".tr);
                                  }
                                },
                              ),
                              const SizedBox(height: 70),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }
}
