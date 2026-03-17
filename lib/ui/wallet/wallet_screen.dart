import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/wallet_controller.dart';
// import 'package:driver/model/intercity_order_model.dart';
// import 'package:driver/model/order_model.dart';
import 'package:driver/model/wallet_transaction_model.dart';
import 'package:driver/model/withdraw_model.dart';
import 'package:driver/payment/createRazorPayOrderModel.dart';
import 'package:driver/payment/rozorpayConroller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
// import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/ui/order_intercity_screen/complete_intecity_order_screen.dart';
import 'package:driver/ui/order_screen/complete_order_screen.dart';
import 'package:driver/ui/withdraw_history/withdraw_history_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX<WalletController>(
        init: WalletController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
/*            appBar: AppBar(
              backgroundColor: isDark ? AppColors.darkBackground : AppColors.moroccoBackground,
              elevation: 0,
              centerTitle: true,
              leading: InkWell(
                onTap: () => Get.back(),
                child: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.moroccoRed, size: 20),
              ),
              title: Text(
                "My Wallet".tr,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white : AppColors.moroccoRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ),*/
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: isDark)
                : Column(
                    children: [
                      // ── Premium Balance Card ──
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.moroccoRed, AppColors.moroccoRed.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.moroccoRed.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Balance".tr,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    'assets/icons/ic_wallet.svg',
                                    width: 24,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Constant.amountShow(amount: controller.driverUserModel.value.walletAmount.toString()),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 24),
                              MaterialButton(
                                onPressed: () => ShowToastDialog.showToast("Payment Method Coming Soon"), //paymentMethodDialog(context, controller),
                                height: 48,
                                minWidth: double.infinity,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.white,
                                elevation: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline, color: AppColors.moroccoRed, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Topup Wallet".tr,
                                      style: GoogleFonts.outfit(
                                        color: AppColors.moroccoRed,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Transaction Header ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Transactions".tr,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.moroccoText,
                              ),
                            ),
                            Text(
                              "View All".tr,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.moroccoRed,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Transaction List ──
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkContainerBackground : Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: controller.transactionList.isEmpty
                              ? Center(
                                  child: Text(
                                    "No transaction found".tr,
                                    style: GoogleFonts.outfit(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                                  itemCount: controller.transactionList.length,
                                  itemBuilder: (context, index) {
                                    WalletTransactionModel walletTransactionModel = controller.transactionList[index];
                                    bool isNegative = Constant.IsNegative(double.parse(walletTransactionModel.amount.toString()));

                                    return InkWell(
                                      onTap: () async {
                                        if (walletTransactionModel.note != 'Referral Amount') {
                                          if (walletTransactionModel.orderType == "city") {
                                            await FireStoreUtils.getOrder(walletTransactionModel.transactionId.toString()).then((value) {
                                              if (value != null) {
                                                Get.to(const CompleteOrderScreen(), arguments: {"orderModel": value});
                                              }
                                            });
                                          } else if (walletTransactionModel.orderType == "intercity") {
                                            await FireStoreUtils.getInterCityOrder(walletTransactionModel.transactionId.toString()).then((value) {
                                              if (value != null) {
                                                Get.to(const CompleteIntercityOrderScreen(), arguments: {"orderModel": value});
                                              }
                                            });
                                          } else {
                                            showTransactionDetails(context: context, walletTransactionModel: walletTransactionModel);
                                          }
                                        }
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFF252525) : AppColors.moroccoBackground,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: isNegative
                                                    ? Colors.red.withOpacity(0.1)
                                                    : Colors.green.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isNegative ? Icons.arrow_upward : Icons.arrow_downward,
                                                color: isNegative ? Colors.red : Colors.green,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    walletTransactionModel.note.toString(),
                                                    style: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 15,
                                                      color: isDark ? Colors.white : AppColors.moroccoText,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    Constant.dateAndTimeFormatTimestamp(walletTransactionModel.createdDate),
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "${isNegative ? "-" : "+"}${Constant.amountShow(amount: walletTransactionModel.amount.toString().replaceAll("-", ""))}",
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: isNegative ? Colors.red : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: MaterialButton(
                      onPressed: () async {
                        if (double.parse(controller.driverUserModel.value.walletAmount.toString()) <= 0) {
                          ShowToastDialog.showToast("Insufficient balance".tr);
                        } else {
                          ShowToastDialog.showLoader("Please wait".tr);
                          await FireStoreUtils.bankDetailsIsAvailable().then((value) {
                            ShowToastDialog.closeLoader();
                            if (value == true) {
                              withdrawAmountBottomSheet(context, controller);
                            } else {
                              ShowToastDialog.showToast("Your bank details is not available. Please add bank details".tr);
                            }
                          });
                        }
                      },
                      height: 56,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: AppColors.moroccoRed.withOpacity(0.5)),
                      ),
                      color: isDark ? Colors.white10 : Colors.white,
                      elevation: 0,
                      child: Text(
                        "Withdraw".tr,
                        style: GoogleFonts.outfit(
                          color: AppColors.moroccoRed,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MaterialButton(
                      onPressed: () => Get.to(const WithDrawHistoryScreen()),
                      height: 56,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      color: AppColors.moroccoRed,
                      elevation: 4,
                      child: Text(
                        "History".tr,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  paymentMethodDialog(BuildContext context, WalletController controller) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30))),
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        builder: (context1) {
          final themeChange = Provider.of<DarkThemeProvider>(context1);

          return FractionallySizedBox(
            heightFactor: 0.9,
            child: StatefulBuilder(builder: (context1, setState) {
              return Obx(
                () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: const Icon(Icons.arrow_back_ios)),
                            Expanded(
                                child: Center(
                                    child: Text(
                              "Topup Wallet".tr,
                              style: GoogleFonts.poppins(),
                            ))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Add Topup Amount".tr,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextFieldThem.buildTextFiled(
                                  context,
                                  hintText: 'Enter Amount'.tr,
                                  controller: controller.amountController.value,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(RegExp(r'[0-9*]')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Select Payment Option".tr,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                ),

                              /*  Visibility(
                                  visible: controller.paymentModel.value.strip!.enable == true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller.selectedPaymentMethod.value == controller.paymentModel.value.strip!.name.toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors.darksecondprimary
                                                          : AppColors.lightsecondprimary
                                                      : AppColors.textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Image.asset('assets/images/stripe.png'),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel.value.strip!.name.toString(),
                                                      style: GoogleFonts.poppins(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller.paymentModel.value.strip!.name.toString(),
                                                    groupValue: controller.selectedPaymentMethod.value,
                                                    activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                    onChanged: (value) {
                                                      controller.selectedPaymentMethod.value = controller.paymentModel.value.strip!.name.toString();
                                                    },
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.paypal!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paypal!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paypal.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.paypal!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.paypal!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.paypal!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.payStack!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payStack!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paystack.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payStack!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.payStack!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.payStack!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.mercadoPago!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.mercadoPago!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/mercadopago.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.mercadoPago!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.mercadoPago!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.mercadoPago!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.flutterWave!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.flutterWave!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/flutterwave.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.flutterWave!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.flutterWave!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.flutterWave!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.payfast!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.payfast!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/payfast.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.payfast!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.payfast!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.payfast!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.paytm!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.paytm!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/paytam.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.paytm!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.paytm!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.paytm!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: controller.paymentModel.value.razorpay!.enable == true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                                color: controller.selectedPaymentMethod.value == controller.paymentModel.value.razorpay!.name.toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors.darksecondprimary
                                                        : AppColors.lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Image.asset('assets/images/razorpay.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel.value.razorpay!.name.toString(),
                                                    style: GoogleFonts.poppins(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel.value.razorpay!.name.toString(),
                                                  groupValue: controller.selectedPaymentMethod.value,
                                                  activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller.selectedPaymentMethod.value = controller.paymentModel.value.razorpay!.name.toString();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                controller.paymentModel.value.midtrans != null && controller.paymentModel.value.midtrans!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.midtrans!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.midtrans!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/midtrans.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.midtrans!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.midtrans!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.midtrans!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                controller.paymentModel.value.xendit != null && controller.paymentModel.value.xendit!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.xendit!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/xendit.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.xendit!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.xendit!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.xendit!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),
                                controller.paymentModel.value.orangePay != null && controller.paymentModel.value.orangePay!.enable == true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod.value = controller.paymentModel.value.orangePay!.name.toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller.selectedPaymentMethod.value == controller.paymentModel.value.orangePay!.name.toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors.darksecondprimary
                                                            : AppColors.lightsecondprimary
                                                        : AppColors.textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(color: AppColors.lightGray, borderRadius: BorderRadius.all(Radius.circular(5))),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset('assets/images/orange_money.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel.value.orangePay!.name.toString(),
                                                        style: GoogleFonts.poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller.paymentModel.value.orangePay!.name.toString(),
                                                      groupValue: controller.selectedPaymentMethod.value,
                                                      activeColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller.selectedPaymentMethod.value = controller.paymentModel.value.orangePay!.name.toString();
                                                      },
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox(),*/
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonThem.buildButton(context, title: "Topup".tr, onPress: () {
                        if (controller.amountController.value.text.isNotEmpty) {
                          if (controller.selectedPaymentMethod.value == controller.paymentModel.value.strip!.name) {
                            controller.stripeMakePayment(amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.paypal!.name) {
                            controller.paypalPaymentSheet(controller.amountController.value.text, context1);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.payStack!.name) {
                            controller.payStackPayment(controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.mercadoPago!.name) {
                            controller.mercadoPagoMakePayment(context: context, amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.flutterWave!.name) {
                            controller.flutterWaveInitiatePayment(context: context, amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.payfast!.name) {
                            controller.payFastPayment(context: context, amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.paytm!.name) {
                            controller.getPaytmCheckSum(context, amount: double.parse(controller.amountController.value.text));
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.razorpay!.name) {
                            RazorPayController().createOrderRazorPay(amount: int.parse(controller.amountController.value.text), razorpayModel: controller.paymentModel.value.razorpay).then((value) {
                              if (value == null) {
                                Get.back();
                                ShowToastDialog.showToast("Something went wrong, please contact admin.".tr);
                              } else {
                                CreateRazorPayOrderModel result = value;
                                controller.openCheckout(amount: controller.amountController.value.text, orderId: result.id);
                              }
                            });
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.midtrans!.name) {
                            controller.midtransMakePayment(context: context, amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.orangePay!.name) {
                            controller.orangeMakePayment(context: context, amount: controller.amountController.value.text);
                          } else if (controller.selectedPaymentMethod.value == controller.paymentModel.value.xendit!.name) {
                            controller.xenditPayment(context, controller.amountController.value.text);
                          } else {
                            ShowToastDialog.showToast("Please select payment method".tr);
                          }
                        } else {
                          ShowToastDialog.showToast("Please enter amount".tr);
                        }
                      }),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  showTransactionDetails({required BuildContext context, required WalletTransactionModel walletTransactionModel}) {
    return showModalBottomSheet(
        elevation: 5,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            final themeChange = Provider.of<DarkThemeProvider>(context);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "Transaction Details".tr,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                        boxShadow: themeChange.getThem()
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 5,
                                  offset: const Offset(0, 4), // changes position of shadow
                                ),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Transaction ID".tr,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "#${walletTransactionModel.transactionId!.toUpperCase()}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                        boxShadow: themeChange.getThem()
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.10),
                                  blurRadius: 5,
                                  offset: const Offset(0, 4), // changes position of shadow
                                ),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Payment Details".tr,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Opacity(
                                          opacity: 0.7,
                                          child: Text(
                                            "Pay Via".tr,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          " ${walletTransactionModel.paymentType}",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Divider(),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date in UTC Format".tr,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Opacity(
                                        opacity: 0.7,
                                        child: Text(
                                          DateFormat('KK:mm:ss a, dd MMM yyyy').format(walletTransactionModel.createdDate!.toDate()).toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            );
          });
        });
  }

  withdrawAmountBottomSheet(BuildContext context, WalletController controller) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        builder: (context) {
          final themeChange = Provider.of<DarkThemeProvider>(context);

          return StatefulBuilder(builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                      child: Text(
                        "Withdraw".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                        decoration: BoxDecoration(
                          color: themeChange.getThem() ? AppColors.darkContainerBackground : AppColors.containerBackground,
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          border: Border.all(color: themeChange.getThem() ? AppColors.darkContainerBorder : AppColors.containerBorder, width: 0.5),
                          boxShadow: themeChange.getThem()
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.bankDetailsModel.value.bankName.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.account_balance,
                                    size: 40,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                controller.bankDetailsModel.value.accountNumber.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                controller.bankDetailsModel.value.holderName.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                controller.bankDetailsModel.value.branchName.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                controller.bankDetailsModel.value.otherInformation.toString(),
                                style: GoogleFonts.poppins(),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(
                      height: 20,
                    ),
                    RichText(
                      text: TextSpan(
                        text: "Amount to Withdraw".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: themeChange.getThem() ? AppColors.containerBackground : AppColors.darkContainerBackground,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldThem.buildTextFiled(context, hintText: 'Enter Amount'.tr, controller: controller.withdrawalAmountController.value),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldThem.buildTextFiled(context, hintText: 'Notes'.tr, maxLine: 3, controller: controller.noteController.value),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ButtonThem.buildButton(
                          context,
                          title: "Withdrawal".tr,
                          onPress: () async {
                            if (double.parse(controller.driverUserModel.value.walletAmount.toString()) < double.parse(controller.withdrawalAmountController.value.text)) {
                              ShowToastDialog.showToast("Insufficient balance".tr);
                            } else if (double.parse(Constant.minimumAmountToWithdrawal) > double.parse(controller.withdrawalAmountController.value.text)) {
                              ShowToastDialog.showToast("Withdraw amount must be greater or equal to ${Constant.amountShow(amount: Constant.minimumAmountToWithdrawal.toString())}".tr);
                            } else {
                              ShowToastDialog.showLoader("Please wait".tr);
                              WithdrawModel withdrawModel = WithdrawModel();
                              withdrawModel.id = Constant.getUuid();
                              withdrawModel.userId = FireStoreUtils.getCurrentUid();
                              withdrawModel.paymentStatus = "pending";
                              withdrawModel.amount = controller.withdrawalAmountController.value.text;
                              withdrawModel.note = controller.noteController.value.text;
                              withdrawModel.createdDate = Timestamp.now();

                              await FireStoreUtils.updatedDriverWallet(amount: "-${controller.withdrawalAmountController.value.text}");

                              await FireStoreUtils.setWithdrawRequest(withdrawModel).then((value) {
                                controller.getUser();
                                ShowToastDialog.closeLoader();
                                ShowToastDialog.showToast("Request sent to admin".tr);
                                Get.back();
                              });
                            }
                          },
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}
