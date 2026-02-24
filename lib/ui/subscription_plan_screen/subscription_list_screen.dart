import 'dart:math' as math;
import 'dart:ui';

import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/subscription_controller.dart';
import 'package:driver/model/subscription_plan_model.dart';
import 'package:driver/payment/createRazorPayOrderModel.dart';
import 'package:driver/payment/rozorpayConroller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen>
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

    return GetX<SubscriptionController>(
        init: SubscriptionController(),
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

                // 2. Main Content
                Column(
                  children: [
                    // Premium Custom Header
                    _buildHeader(context, controller, !isDark),

                    Expanded(
                      child: controller.isLoading.value
                          ? Center(child: Constant.loader(isDarkTheme: !isDark))
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: controller.subscriptionPlanList.isEmpty
                                  ? Constant.showEmptyView(
                                      message:
                                          "Subscription Plan Not Found.".tr)
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(
                                          top: 10, bottom: 30),
                                      itemCount: controller
                                          .subscriptionPlanList.length,
                                      itemBuilder: (context, index) {
                                        final subscriptionPlanModel = controller
                                            .subscriptionPlanList[index];
                                        return SubscriptionPlanWidget(
                                          onContainClick: () {
                                            controller.selectedSubscriptionPlan
                                                .value = subscriptionPlanModel;
                                            controller.totalAmount.value =
                                                double.parse(
                                                    subscriptionPlanModel
                                                            .price ??
                                                        '0.0');
                                            controller.update();
                                          },
                                          onClick: () {
                                            if (controller
                                                    .selectedSubscriptionPlan
                                                    .value
                                                    .id ==
                                                subscriptionPlanModel.id) {
                                              if (controller
                                                          .selectedSubscriptionPlan
                                                          .value
                                                          .type ==
                                                      'free' ||
                                                  controller
                                                          .selectedSubscriptionPlan
                                                          .value
                                                          .id ==
                                                      Constant
                                                          .commissionSubscriptionID) {
                                                controller.selectedPaymentMethod
                                                    .value = 'free';
                                                controller.placeOrder();
                                              } else {
                                                paymentMethodDialog(
                                                    context, controller);
                                              }
                                            }
                                          },
                                          subscriptionPlanModel:
                                              subscriptionPlanModel,
                                        );
                                      },
                                    ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  Widget _buildHeader(
      BuildContext context, SubscriptionController controller, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (controller.isShowing.value)
                IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white : Colors.black87,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              const Spacer(),
              _buildModernLogo(),
              const Spacer(),
              if (controller.isShowing.value) const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 20),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.moroccoRed, AppColors.moroccoGreen],
            ).createShader(bounds),
            child: Text(
              "Subscription Plans".tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Choose a plan that fits your business needs".tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white60 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernLogo() {
    return Image.asset(
      "assets/images/splash_image.png",
      width: 80,
      fit: BoxFit.contain,
    );
  }

  paymentMethodDialog(BuildContext context, SubscriptionController controller) {
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(30), topLeft: Radius.circular(30))),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
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
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  size: 20,
                                  color: themeChange.getThem()
                                      ? Colors.white
                                      : Colors.black87,
                                )),
                            Expanded(
                                child: Center(
                                    child: Text(
                              "Payment Selection".tr,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeChange.getThem()
                                    ? Colors.white
                                    : Colors.black87,
                              ),
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
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Select Payment Option".tr,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600),
                                ),
                                Visibility(
                                  visible: controller
                                          .paymentModel.value.wallet!.enable ==
                                      true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod
                                                    .value =
                                                controller.paymentModel.value
                                                    .wallet!.name
                                                    .toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller
                                                              .selectedPaymentMethod
                                                              .value ==
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .wallet!
                                                              .name
                                                              .toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors
                                                              .darksecondprimary
                                                          : AppColors
                                                              .lightsecondprimary
                                                      : AppColors
                                                          .textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: AppColors
                                                                .lightGray,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: SvgPicture.asset(
                                                          'assets/icons/ic_wallet.svg',
                                                          color: AppColors
                                                              .lightprimary),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel
                                                          .value.wallet!.name
                                                          .toString(),
                                                      style:
                                                          GoogleFonts.outfit(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller
                                                        .paymentModel
                                                        .value
                                                        .wallet!
                                                        .name
                                                        .toString(),
                                                    groupValue: controller
                                                        .selectedPaymentMethod
                                                        .value,
                                                    activeColor: themeChange
                                                            .getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary,
                                                    onChanged: (value) {
                                                      controller
                                                              .selectedPaymentMethod
                                                              .value =
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .wallet!
                                                              .name
                                                              .toString();
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
                                  visible: controller
                                          .paymentModel.value.strip!.enable ==
                                      true,
                                  child: Obx(
                                    () => Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            controller.selectedPaymentMethod
                                                    .value =
                                                controller.paymentModel.value
                                                    .strip!.name
                                                    .toString();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              border: Border.all(
                                                  color: controller
                                                              .selectedPaymentMethod
                                                              .value ==
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .strip!
                                                              .name
                                                              .toString()
                                                      ? themeChange.getThem()
                                                          ? AppColors
                                                              .darksecondprimary
                                                          : AppColors
                                                              .lightsecondprimary
                                                      : AppColors
                                                          .textFieldBorder,
                                                  width: 1),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 80,
                                                    decoration:
                                                        const BoxDecoration(
                                                            color: AppColors
                                                                .lightGray,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5))),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Image.asset(
                                                          'assets/images/stripe.png'),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.paymentModel
                                                          .value.strip!.name
                                                          .toString(),
                                                      style:
                                                          GoogleFonts.outfit(),
                                                    ),
                                                  ),
                                                  Radio(
                                                    value: controller
                                                        .paymentModel
                                                        .value
                                                        .strip!
                                                        .name
                                                        .toString(),
                                                    groupValue: controller
                                                        .selectedPaymentMethod
                                                        .value,
                                                    activeColor: themeChange
                                                            .getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary,
                                                    onChanged: (value) {
                                                      controller
                                                              .selectedPaymentMethod
                                                              .value =
                                                          controller
                                                              .paymentModel
                                                              .value
                                                              .strip!
                                                              .name
                                                              .toString();
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
                                  visible: controller
                                          .paymentModel.value.paypal!.enable ==
                                      true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .paypal!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: controller
                                                            .selectedPaymentMethod
                                                            .value ==
                                                        controller.paymentModel
                                                            .value.paypal!.name
                                                            .toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'assets/images/paypal.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.paypal!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.paypal!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor: themeChange
                                                          .getThem()
                                                      ? AppColors
                                                          .darksecondprimary
                                                      : AppColors
                                                          .lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.paypal!.name
                                                            .toString();
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
                                  visible: controller.paymentModel.value
                                          .payStack!.enable ==
                                      true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .payStack!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: controller
                                                            .selectedPaymentMethod
                                                            .value ==
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .payStack!
                                                            .name
                                                            .toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'assets/images/paystack.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.payStack!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.payStack!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor: themeChange
                                                          .getThem()
                                                      ? AppColors
                                                          .darksecondprimary
                                                      : AppColors
                                                          .lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .payStack!
                                                            .name
                                                            .toString();
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
                                  visible: controller.paymentModel.value
                                          .mercadoPago!.enable ==
                                      true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .mercadoPago!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: controller
                                                            .selectedPaymentMethod
                                                            .value ==
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .mercadoPago!
                                                            .name
                                                            .toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'assets/images/mercadopago.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.mercadoPago!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.mercadoPago!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor: themeChange
                                                          .getThem()
                                                      ? AppColors
                                                          .darksecondprimary
                                                      : AppColors
                                                          .lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .mercadoPago!
                                                            .name
                                                            .toString();
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
                                  visible: controller.paymentModel.value
                                          .flutterWave!.enable ==
                                      true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .flutterWave!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: controller
                                                            .selectedPaymentMethod
                                                            .value ==
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .flutterWave!
                                                            .name
                                                            .toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'assets/images/flutterwave.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.flutterWave!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.flutterWave!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor: themeChange
                                                          .getThem()
                                                      ? AppColors
                                                          .darksecondprimary
                                                      : AppColors
                                                          .lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .flutterWave!
                                                            .name
                                                            .toString();
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
                                  visible: controller
                                          .paymentModel.value.payfast!.enable ==
                                      true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .payfast!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: controller
                                                            .selectedPaymentMethod
                                                            .value ==
                                                        controller.paymentModel
                                                            .value.payfast!.name
                                                            .toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'assets/images/payfast.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.payfast!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.payfast!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor: themeChange
                                                          .getThem()
                                                      ? AppColors
                                                          .darksecondprimary
                                                      : AppColors
                                                          .lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.payfast!.name
                                                            .toString();
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
                                  visible: controller
                                          .paymentModel.value.paytm!.enable ==
                                      true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .paytm!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: controller
                                                            .selectedPaymentMethod
                                                            .value ==
                                                        controller.paymentModel
                                                            .value.paytm!.name
                                                            .toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'assets/images/paytam.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.paytm!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.paytm!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor: themeChange
                                                          .getThem()
                                                      ? AppColors
                                                          .darksecondprimary
                                                      : AppColors
                                                          .lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller.paymentModel
                                                            .value.paytm!.name
                                                            .toString();
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
                                  visible: controller.paymentModel.value
                                          .razorpay!.enable ==
                                      true,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          controller
                                                  .selectedPaymentMethod.value =
                                              controller.paymentModel.value
                                                  .razorpay!.name
                                                  .toString();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10)),
                                            border: Border.all(
                                                color: controller
                                                            .selectedPaymentMethod
                                                            .value ==
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .razorpay!
                                                            .name
                                                            .toString()
                                                    ? themeChange.getThem()
                                                        ? AppColors
                                                            .darksecondprimary
                                                        : AppColors
                                                            .lightsecondprimary
                                                    : AppColors.textFieldBorder,
                                                width: 1),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 10),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: 80,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                        'assets/images/razorpay.png'),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    controller.paymentModel
                                                        .value.razorpay!.name
                                                        .toString(),
                                                    style: GoogleFonts.outfit(),
                                                  ),
                                                ),
                                                Radio(
                                                  value: controller.paymentModel
                                                      .value.razorpay!.name
                                                      .toString(),
                                                  groupValue: controller
                                                      .selectedPaymentMethod
                                                      .value,
                                                  activeColor: themeChange
                                                          .getThem()
                                                      ? AppColors
                                                          .darksecondprimary
                                                      : AppColors
                                                          .lightsecondprimary,
                                                  onChanged: (value) {
                                                    controller
                                                            .selectedPaymentMethod
                                                            .value =
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .razorpay!
                                                            .name
                                                            .toString();
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
                                controller.paymentModel.value.midtrans !=
                                            null &&
                                        controller.paymentModel.value.midtrans!
                                                .enable ==
                                            true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod
                                                      .value =
                                                  controller.paymentModel.value
                                                      .midtrans!.name
                                                      .toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller
                                                                .selectedPaymentMethod
                                                                .value ==
                                                            controller
                                                                .paymentModel
                                                                .value
                                                                .midtrans!
                                                                .name
                                                                .toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors
                                                                .darksecondprimary
                                                            : AppColors
                                                                .lightsecondprimary
                                                        : AppColors
                                                            .textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.asset(
                                                            'assets/images/midtrans.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .midtrans!
                                                            .name
                                                            .toString(),
                                                        style: GoogleFonts
                                                            .poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller
                                                          .paymentModel
                                                          .value
                                                          .midtrans!
                                                          .name
                                                          .toString(),
                                                      groupValue: controller
                                                          .selectedPaymentMethod
                                                          .value,
                                                      activeColor: themeChange
                                                              .getThem()
                                                          ? AppColors
                                                              .darksecondprimary
                                                          : AppColors
                                                              .lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller
                                                                .selectedPaymentMethod
                                                                .value =
                                                            controller
                                                                .paymentModel
                                                                .value
                                                                .midtrans!
                                                                .name
                                                                .toString();
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
                                controller.paymentModel.value.xendit != null &&
                                        controller.paymentModel.value.xendit!
                                                .enable ==
                                            true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod
                                                      .value =
                                                  controller.paymentModel.value
                                                      .xendit!.name
                                                      .toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller
                                                                .selectedPaymentMethod
                                                                .value ==
                                                            controller
                                                                .paymentModel
                                                                .value
                                                                .xendit!
                                                                .name
                                                                .toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors
                                                                .darksecondprimary
                                                            : AppColors
                                                                .lightsecondprimary
                                                        : AppColors
                                                            .textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.asset(
                                                            'assets/images/xendit.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller.paymentModel
                                                            .value.xendit!.name
                                                            .toString(),
                                                        style: GoogleFonts
                                                            .poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller
                                                          .paymentModel
                                                          .value
                                                          .xendit!
                                                          .name
                                                          .toString(),
                                                      groupValue: controller
                                                          .selectedPaymentMethod
                                                          .value,
                                                      activeColor: themeChange
                                                              .getThem()
                                                          ? AppColors
                                                              .darksecondprimary
                                                          : AppColors
                                                              .lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller
                                                                .selectedPaymentMethod
                                                                .value =
                                                            controller
                                                                .paymentModel
                                                                .value
                                                                .xendit!
                                                                .name
                                                                .toString();
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
                                controller.paymentModel.value.orangePay !=
                                            null &&
                                        controller.paymentModel.value.orangePay!
                                                .enable ==
                                            true
                                    ? Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              controller.selectedPaymentMethod
                                                      .value =
                                                  controller.paymentModel.value
                                                      .orangePay!.name
                                                      .toString();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                                border: Border.all(
                                                    color: controller
                                                                .selectedPaymentMethod
                                                                .value ==
                                                            controller
                                                                .paymentModel
                                                                .value
                                                                .orangePay!
                                                                .name
                                                                .toString()
                                                        ? themeChange.getThem()
                                                            ? AppColors
                                                                .darksecondprimary
                                                            : AppColors
                                                                .lightsecondprimary
                                                        : AppColors
                                                            .textFieldBorder,
                                                    width: 1),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      width: 80,
                                                      decoration: const BoxDecoration(
                                                          color: AppColors
                                                              .lightGray,
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          5))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Image.asset(
                                                            'assets/images/orange_money.png'),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        controller
                                                            .paymentModel
                                                            .value
                                                            .orangePay!
                                                            .name
                                                            .toString(),
                                                        style: GoogleFonts
                                                            .poppins(),
                                                      ),
                                                    ),
                                                    Radio(
                                                      value: controller
                                                          .paymentModel
                                                          .value
                                                          .orangePay!
                                                          .name
                                                          .toString(),
                                                      groupValue: controller
                                                          .selectedPaymentMethod
                                                          .value,
                                                      activeColor: themeChange
                                                              .getThem()
                                                          ? AppColors
                                                              .darksecondprimary
                                                          : AppColors
                                                              .lightsecondprimary,
                                                      onChanged: (value) {
                                                        controller
                                                                .selectedPaymentMethod
                                                                .value =
                                                            controller
                                                                .paymentModel
                                                                .value
                                                                .orangePay!
                                                                .name
                                                                .toString();
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
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ButtonThem.buildButton(context, title: "Pay Now".tr,
                          onPress: () {
                        if (controller.selectedPaymentMethod.value == '') {
                          ShowToastDialog.showToast(
                              "Please Select Payment Method.".tr);
                        } else {
                          if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.wallet!.name) {
                            if (double.parse(controller
                                    .driverUserModel.value.walletAmount
                                    .toString()) >=
                                controller.totalAmount.value) {
                              Get.back();
                              controller.placeOrder();
                            } else {
                              ShowToastDialog.showToast(
                                  "Wallet Amount Insufficient".tr);
                            }
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.strip!.name) {
                            Get.back();
                            controller.stripeMakePayment(
                                amount:
                                    controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.paypal!.name) {
                            Get.back();
                            controller.paypalPaymentSheet(
                                controller.totalAmount.value.toString(),
                                context1);
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.payStack!.name) {
                            Get.back();
                            controller.payStackPayment(
                                controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.mercadoPago!.name) {
                            Get.back();
                            controller.mercadoPagoMakePayment(
                                context: context,
                                amount:
                                    controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.flutterWave!.name) {
                            Get.back();
                            controller.flutterWaveInitiatePayment(
                                context: context,
                                amount:
                                    controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.payfast!.name) {
                            Get.back();
                            controller.payFastPayment(
                                context: context,
                                amount:
                                    controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.paytm!.name) {
                            Get.back();
                            controller.getPaytmCheckSum(context,
                                amount: double.parse(
                                    controller.totalAmount.value.toString()));
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.razorpay!.name) {
                            RazorPayController()
                                .createOrderRazorPay(
                                    amount: int.parse(controller
                                        .totalAmount.value
                                        .toString()),
                                    razorpayModel:
                                        controller.paymentModel.value.razorpay)
                                .then((value) {
                              if (value == null) {
                                Get.back();
                                ShowToastDialog.showToast(
                                    "Something went wrong, please contact admin."
                                        .tr);
                              } else {
                                CreateRazorPayOrderModel result = value;
                                controller.openCheckout(
                                    amount:
                                        controller.totalAmount.value.toString(),
                                    orderId: result.id);
                              }
                            });
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.midtrans!.name) {
                            Get.back();
                            controller.midtransMakePayment(
                                context: context,
                                amount:
                                    controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.orangePay!.name) {
                            Get.back();
                            controller.orangeMakePayment(
                                context: context,
                                amount:
                                    controller.totalAmount.value.toString());
                          } else if (controller.selectedPaymentMethod.value ==
                              controller.paymentModel.value.xendit!.name) {
                            Get.back();
                            controller.xenditPayment(context,
                                controller.totalAmount.value.toString());
                          } else {
                            ShowToastDialog.showToast(
                                "Please select payment method".tr);
                          }
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
}

class SubscriptionPlanWidget extends StatelessWidget {
  final VoidCallback onClick;
  final VoidCallback onContainClick;
  final SubscriptionPlanModel subscriptionPlanModel;

  const SubscriptionPlanWidget({
    super.key,
    required this.onClick,
    required this.subscriptionPlanModel,
    required this.onContainClick,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = !themeChange.getThem();

    final controller = Get.find<SubscriptionController>();
    return Obx(() {
      bool isSelected = controller.selectedSubscriptionPlan.value.id != null &&
          controller.selectedSubscriptionPlan.value.id ==
              subscriptionPlanModel.id;
      bool isActive =
          controller.driverUserModel.value.subscriptionPlanId != null &&
              controller.driverUserModel.value.subscriptionPlanId ==
                  subscriptionPlanModel.id;

      return GestureDetector(
        onTap: onContainClick,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: isSelected
                  ? AppColors.moroccoGreen
                  : (isDark
                      ? Colors.white12
                      : AppColors.moroccoGreen.withOpacity(0.2)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: isSelected ? 40 : 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.moroccoRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: NetworkImageWidget(
                      imageUrl: subscriptionPlanModel.image ?? '',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscriptionPlanModel.name ?? '',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.2)),
                            ),
                            child: Text(
                              "Currently Active".tr,
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        subscriptionPlanModel.type == "free"
                            ? "Free".tr
                            : Constant.amountShow(
                                amount: double.parse(
                                        subscriptionPlanModel.price ?? '0.0')
                                    .toString()),
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.moroccoRed,
                        ),
                      ),
                      Text(
                        subscriptionPlanModel.expiryDay == "-1"
                            ? "LifeTime".tr
                            : "${subscriptionPlanModel.expiryDay} ${'Days'.tr}",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                subscriptionPlanModel.description ?? '',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Plan Points
              if (subscriptionPlanModel.id == Constant.commissionSubscriptionID)
                _buildPointItem(
                  '${'Pay a commission of'.tr} ${Constant.adminCommission?.type == 'percentage' ? "${Constant.adminCommission?.amount}%" : "${Constant.amountShow(amount: Constant.adminCommission?.amount)} ${'Flat'.tr}"} ${'on each order.'.tr}',
                  isDark,
                ),

              if (subscriptionPlanModel.planPoints != null)
                ...subscriptionPlanModel.planPoints!
                    .map((point) => _buildPointItem(point, isDark))
                    .toList(),

              _buildPointItem(
                '${'Accept booking limits :'.tr} ${subscriptionPlanModel.bookingLimit == '-1' ? 'Unlimited'.tr : subscriptionPlanModel.bookingLimit ?? '0'}',
                isDark,
              ),

              const SizedBox(height: 24),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? AppColors.moroccoRed
                        : (isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1)),
                    foregroundColor: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white70 : Colors.black87),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    isActive
                        ? "Renew".tr
                        : (isSelected ? "Subscribe Now".tr : "Select Plan".tr),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildPointItem(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.moroccoGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check,
                size: 12, color: AppColors.moroccoGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
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
      ..color = AppColors.moroccoRed.withOpacity(0.01)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintGreen = Paint()
      ..color = AppColors.moroccoGreen.withOpacity(0.01)
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
