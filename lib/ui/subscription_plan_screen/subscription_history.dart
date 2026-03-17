import 'package:driver/constant/constant.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../controller/subscrription_history_controller.dart';
import '../../utils/network_image_widget.dart';

class SubscriptionHistory extends StatelessWidget {
  const SubscriptionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX(
        init: SubscriptionHistoryController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
         /*   appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.moroccoRed, size: 20),
              ),
              title: Text(
                "Subscription History".tr,
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
                      padding: const EdgeInsets.only(top: 8),
                      child: controller.subscriptionHistoryList.isEmpty
                          ? Center(child: Constant.showEmptyView(message: "Subscription History Not Found.".tr))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                              itemCount: controller.subscriptionHistoryList.length,
                              itemBuilder: (context, index) {
                                final subscriptionHistoryModel = controller.subscriptionHistoryList[index];
                                bool isActive = index == 0; // Assuming first one is active based on original logic

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF252525) : AppColors.moroccoBackground,
                                    borderRadius: BorderRadius.circular(24),
                                    border: isActive ? Border.all(color: AppColors.moroccoRed.withOpacity(0.3), width: 1) : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(color: AppColors.moroccoRed.withOpacity(0.2)),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(30),
                                                child: NetworkImageWidget(
                                                  imageUrl: subscriptionHistoryModel.subscriptionPlan?.image ?? '',
                                                  fit: BoxFit.cover,
                                                  width: 50,
                                                  height: 50,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    subscriptionHistoryModel.subscriptionPlan?.name ?? '',
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 18,
                                                      color: isDark ? Colors.white : AppColors.moroccoText,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${'Payment:'.tr} ${(subscriptionHistoryModel.paymentType ?? '').capitalizeString()}",
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isActive)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.12),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.verified, color: Colors.green, size: 14),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Active'.tr,
                                                      style: GoogleFonts.outfit(
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 12,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Divider(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05), height: 1),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          children: [
                                            _buildHistoryRow('Price'.tr, Constant.amountShow(amount: subscriptionHistoryModel.subscriptionPlan?.price ?? '0'), isDark, isBold: true, valueColor: AppColors.moroccoRed),
                                            const SizedBox(height: 12),
                                            _buildHistoryRow('Validity'.tr, subscriptionHistoryModel.subscriptionPlan?.expiryDay == '-1' ? "Unlimited".tr : '${subscriptionHistoryModel.subscriptionPlan?.expiryDay ?? '0'} ${'Days'.tr}', isDark),
                                            const SizedBox(height: 12),
                                            _buildHistoryRow('Purchase Date'.tr, Constant.timestampToDateTime(subscriptionHistoryModel.subscriptionPlan!.createdAt!), isDark),
                                            const SizedBox(height: 12),
                                            _buildHistoryRow('Expiry Date'.tr, subscriptionHistoryModel.expiryDate == null ? "Unlimited".tr : Constant.timestampToDateTime(subscriptionHistoryModel.expiryDate!), isDark),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                    ),
                  ),
          );
        });
  }

  Widget _buildHistoryRow(String label, String value, bool isDark, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? (isDark ? Colors.white.withOpacity(0.9) : AppColors.moroccoText),
          ),
        ),
      ],
    );
  }
}

