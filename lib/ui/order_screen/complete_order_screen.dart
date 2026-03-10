import 'package:clipboard/clipboard.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/complete_order_controller.dart';
import 'package:driver/model/tax_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/widget/user_order_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CompleteOrderScreen extends StatelessWidget {
  const CompleteOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX<CompleteOrderController>(
        init: CompleteOrderController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor:
                  isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FB),
              appBar: AppBar(
                backgroundColor: AppColors.moroccoRed,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  "Ride Details".tr,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700, color: Colors.white),
                ),
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              body: controller.isLoading.value
                  ? Constant.loader(isDarkTheme: isDark)
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Top Header Background
                          Container(
                            height: 60,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: AppColors.moroccoRed,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30)),
                            ),
                          ),

                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Ride ID Card
                                  _buildRideIdCard(controller, isDark),

                                  const SizedBox(height: 16),

                                  // Customer Info Card
                                  _buildSectionCard(
                                    isDark,
                                    child: UserDriverView(
                                        userId: controller
                                            .orderModel.value.userId
                                            .toString(),
                                        amount: controller
                                            .orderModel.value.finalRate
                                            .toString()),
                                  ),

                                  const SizedBox(height: 16),

                                  // Location Card
                                  _buildSectionCard(
                                    isDark,
                                    title: "Route Details".tr,
                                    child: _buildLocationStepper(
                                      controller
                                          .orderModel.value.sourceLocationName
                                          .toString(),
                                      controller.orderModel.value
                                          .destinationLocationName
                                          .toString(),
                                      isDark,
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Status Card
                                  _buildStatusCard(controller, isDark),

                                  const SizedBox(height: 16),

                                  // Booking Summary Card (The Receipt)
                                  _buildReceiptCard(controller, isDark),

                                  const SizedBox(height: 16),

                                  // Admin Commission Note
                                  if (controller.orderModel.value.ownerId ==
                                      null)
                                    _buildCommissionCard(controller, isDark),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
        });
  }

  Widget _buildSectionCard(bool isDark,
      {String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkContainerBackground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? Colors.white12 : AppColors.moroccoRed.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppColors.moroccoText,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildRideIdCard(CompleteOrderController controller, bool isDark) {
    return _buildSectionCard(
      isDark,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.moroccoRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.confirmation_number_rounded,
                color: AppColors.moroccoRed, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ride ID".tr,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Text(
                  "#${controller.orderModel.value.id!.toUpperCase()}",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              FlutterClipboard.copy(controller.orderModel.value.id.toString())
                  .then((value) {
                ShowToastDialog.showToast("OrderId copied".tr);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border:
                    Border.all(color: AppColors.moroccoRed.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Copy".tr,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.moroccoRed,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(CompleteOrderController controller, bool isDark) {
    String status = controller.orderModel.value.status.toString();
    Color statusColor = status == Constant.rideComplete
        ? AppColors.moroccoGreen
        : Colors.orange;

    return _buildSectionCard(
      isDark,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status.tr,
              style: GoogleFonts.outfit(
                color: statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const Spacer(),
          Text(
            Constant().formatTimestamp(controller.orderModel.value.createdDate),
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(CompleteOrderController controller, bool isDark) {
    return _buildSectionCard(
      isDark,
      title: "Booking Summary".tr,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Payment Method".tr,
                style: GoogleFonts.outfit(
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white : Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  controller.orderModel.value.paymentType.toString(),
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _buildReceiptRow(
              "Ride Amount".tr,
              Constant.amountShow(amount: controller.amount.value.toString()),
              isDark),
          _buildReceiptRow(
              "Minute charge".tr,
              Constant.amountShow(
                  amount: controller.totalChargeOfMinute.value.toString()),
              isDark),
          _buildReceiptRow(
              "Base Fare".tr,
              Constant.amountShow(
                  amount: controller.basicFareCharge.value.toString()),
              isDark),
          _buildReceiptRow(
              "Holding Charge".tr,
              Constant.amountShow(
                  amount: controller.holdingCharge.value.toString()),
              isDark),
          if (controller.orderModel.value.taxList != null)
            ...controller.orderModel.value.taxList!.map((taxModel) {
              return _buildReceiptRow(
                "${taxModel.title} (${taxModel.type == "fix" ? Constant.amountShow(amount: taxModel.tax) : "${taxModel.tax}%"})",
                Constant.amountShow(
                    amount: Constant()
                        .calculateTax(
                            amount: (double.parse(
                                        controller.subTotal.value.toString()) -
                                    double.parse(controller.couponAmount.value
                                        .toString()))
                                .toString(),
                            taxModel: taxModel)
                        .toString()),
                isDark,
              );
            }).toList(),
          _buildReceiptRow(
            "Discount".tr,
            "(-${controller.couponAmount.value == "0.0" ? Constant.amountShow(amount: "0.0") : Constant.amountShow(amount: controller.couponAmount.value)})",
            isDark,
            isNegative: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1),
          ),
          Row(
            children: [
              Text(
                "Payable amount".tr,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.moroccoText,
                ),
              ),
              const Spacer(),
              Text(
                Constant.amountShow(amount: controller.total.toString()),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.moroccoGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark,
      {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(label,
              style: GoogleFonts.outfit(
                  color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: isNegative
                  ? AppColors.moroccoRed
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(CompleteOrderController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.moroccoRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.moroccoRed.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.moroccoRed, size: 20),
              const SizedBox(width: 8),
              Text(
                "Admin Commission".tr,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  color: AppColors.moroccoRed,
                ),
              ),
              const Spacer(),
              Text(
                "(-${Constant.amountShow(amount: Constant.calculateAdminCommission(amount: (double.parse(controller.orderModel.value.finalRate.toString()) - double.parse(controller.couponAmount.value.toString())).toString(), adminCommission: controller.orderModel.value.adminCommission).toString())})",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800, color: AppColors.moroccoRed),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Note : Admin commission will be debited from your wallet balance. Admin commission applies on Ride Amount minus Discount."
                .tr,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: isDark ? Colors.red[200] : Colors.red[700],
              height: 1.4,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLocationStepper(String source, String destination, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.circle, size: 16, color: AppColors.moroccoGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                source,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Column(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  width: 2,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                size: 18, color: AppColors.moroccoRed),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                destination,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
