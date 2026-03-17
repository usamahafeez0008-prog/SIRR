import 'package:driver/constant/constant.dart';
import 'package:driver/model/withdraw_model.dart';
import 'package:driver/themes/app_colors.dart';
// import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WithDrawHistoryScreen extends StatelessWidget {
  const WithDrawHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.moroccoRed, size: 20),
        ),
        title: Text(
          "Withdrawal History".tr,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppColors.moroccoRed,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: FutureBuilder<List<WithdrawModel>?>(
        future: FireStoreUtils.getWithDrawRequest(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Constant.loader(isDarkTheme: isDark);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_outlined, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "No transactions yet".tr,
                    style: GoogleFonts.outfit(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                WithdrawModel withdrawModel = snapshot.data![index];
                bool isApproved = withdrawModel.paymentStatus?.toLowerCase() == "approved";
                bool isPending = withdrawModel.paymentStatus?.toLowerCase() == "pending";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252525) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.moroccoRed.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.moroccoRed,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "- ${Constant.amountShow(amount: withdrawModel.amount.toString())}",
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isApproved
                                        ? Colors.green.withOpacity(0.1)
                                        : isPending
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    withdrawModel.paymentStatus!.tr.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      color: isApproved
                                          ? Colors.green
                                          : isPending
                                              ? Colors.orange
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              withdrawModel.note ?? "Withdrawal Request".tr,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: isDark ? Colors.white70 : AppColors.moroccoText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              Constant.dateAndTimeFormatTimestamp(withdrawModel.createdDate),
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: Colors.grey,
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
        },
      ),
    );
  }
}
