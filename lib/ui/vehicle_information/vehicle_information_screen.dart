import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/vehicle_information_controller.dart';
import 'package:driver/controller/dash_board_controller.dart';
import 'package:driver/model/service_model.dart';
import 'package:driver/model/zone_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VehicleInformationScreen extends StatefulWidget {
  const VehicleInformationScreen({super.key});

  @override
  State<VehicleInformationScreen> createState() =>
      _VehicleInformationScreenState();
}

class _VehicleInformationScreenState extends State<VehicleInformationScreen>
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

    return GetX<VehicleInformationController>(
      init: VehicleInformationController(),
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
                    _buildHeader(context, isDark),
                    Expanded(
                      child: controller.isLoading.value
                          ? Center(
                              child: Constant.loader(isDarkTheme: isDark),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Vehicle Information ────────────────
                                  _buildSectionHeader(
                                    "Vehicle Information".tr,
                                    Icons.directions_car_rounded,
                                    isDark,
                                  ),
                                  const SizedBox(height: 12),

                                  // Vehicle Number
                                  _buildFieldLabel("Vehicle Number".tr, isDark),
                                  const SizedBox(height: 6),
                                  _buildStyledTextField(
                                    context,
                                    controller: controller
                                        .vehicleNumberController.value,
                                    hintText: "e.g. ABC-1234".tr,
                                    isDark: isDark,
                                    enabled:
                                        controller.driverModel.value.ownerId ==
                                            null,
                                    prefixIcon: Icons.pin_rounded,
                                  ),
                                  const SizedBox(height: 14),

                                  // Registration Date
                                  _buildFieldLabel(
                                      "Registration Date".tr, isDark),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () async {
                                      if (controller
                                              .driverModel.value.ownerId ==
                                          null) {
                                        await Constant.selectDate(context)
                                            .then((value) {
                                          if (value != null) {
                                            controller.selectedDate.value =
                                                value;
                                            controller
                                                    .registrationDateController
                                                    .value
                                                    .text =
                                                DateFormat("dd-MM-yyyy")
                                                    .format(value);
                                          }
                                        });
                                      }
                                    },
                                    child: _buildStyledTextField(
                                      context,
                                      controller: controller
                                          .registrationDateController.value,
                                      hintText: "dd-MM-yyyy".tr,
                                      isDark: isDark,
                                      enabled: false,
                                      prefixIcon: Icons.calendar_today_rounded,
                                      suffixIcon: Icon(
                                        Icons.calendar_month_rounded,
                                        color: AppColors.moroccoRed,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Vehicle Color
                                  _buildFieldLabel("Vehicle Color".tr, isDark),
                                  const SizedBox(height: 6),
                                  AbsorbPointer(
                                    absorbing:
                                        controller.driverModel.value.ownerId !=
                                            null,
                                    child: _buildStyledDropdown<String>(
                                      context,
                                      isDark: isDark,
                                      value:
                                          controller.selectedColor.value.isEmpty
                                              ? null
                                              : controller.selectedColor.value,
                                      hint: "Select vehicle color".tr,
                                      prefixIcon: Icons.palette_rounded,
                                      items: controller.carColorList
                                          .map((item) => DropdownMenuItem(
                                                value: item,
                                                child: Text(item.toString()),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        controller.selectedColor.value = value!;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Seats
                                  _buildFieldLabel(
                                      "Number of Seats".tr, isDark),
                                  const SizedBox(height: 6),
                                  AbsorbPointer(
                                    absorbing:
                                        controller.driverModel.value.ownerId !=
                                            null,
                                    child: _buildStyledDropdown<String>(
                                      context,
                                      isDark: isDark,
                                      value: controller.seatsController.value
                                              .text.isEmpty
                                          ? null
                                          : controller
                                              .seatsController.value.text,
                                      hint: "How Many Seats".tr,
                                      prefixIcon: Icons
                                          .airline_seat_recline_extra_rounded,
                                      items: controller.sheetList
                                          .map((item) => DropdownMenuItem(
                                                value: item,
                                                child: Text(item.toString()),
                                              ))
                                          .toList(),
                                      onChanged: (value) {
                                        controller.seatsController.value.text =
                                            value!;
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Zone
                                  _buildFieldLabel("Select Zone".tr, isDark),
                                  const SizedBox(height: 6),
                                  InkWell(
                                    onTap: () {
                                      if (controller
                                              .driverModel.value.ownerId ==
                                          null) {
                                        controller.selectedTempZone.clear();
                                        controller.selectedTempZone
                                            .addAll(controller.selectedZone);
                                        zoneDialog(context, controller);
                                      }
                                    },
                                    child: _buildStyledTextField(
                                      context,
                                      controller:
                                          controller.zoneNameController.value,
                                      hintText: "Tap to select zone".tr,
                                      isDark: isDark,
                                      enabled: false,
                                      prefixIcon: Icons.map_rounded,
                                      suffixIcon: Icon(
                                        Icons.chevron_right_rounded,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                        size: 22,
                                      ),
                                    ),
                                  ),

                                  // Price Rates (zone-based tab view)
                                  if (controller.selectedPrices.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    _buildFieldLabel(
                                        "Rate Configuration".tr, isDark),
                                    const SizedBox(height: 6),
                                    Obx(
                                      () => _buildRateTabCard(
                                          context, controller, isDark),
                                    ),
                                  ],

                                  const SizedBox(height: 24),

                                  // ── Service Types ──────────────────────
                                  _buildSectionHeader(
                                    "Service Type".tr,
                                    Icons.local_taxi_rounded,
                                    isDark,
                                  ),
                                  const SizedBox(height: 12),

                                  // Service horizontal list
                                  SizedBox(
                                    height: Responsive.height(28, context),
                                    child: ListView.builder(
                                      itemCount: controller.serviceList.length,
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.only(
                                          bottom: 12, top: 6, left: 12),
                                      itemBuilder: (context, index) {
                                        ServiceModel serviceModel =
                                            controller.serviceList[index];
                                        return Obx(
                                          () => _buildServiceCard(
                                            context,
                                            controller,
                                            serviceModel,
                                            index,
                                            isDark,
                                            themeChange,
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  if (controller.driverModel.value.ownerId ==
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        "You can not change once you select one service type if you want to change please contact to administrator",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white38
                                              : Colors.black38,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  // ── Rules Body ─────────────────────────
                                  _buildSectionHeader(
                                    "Select Your Rules".tr,
                                    Icons.rule_rounded,
                                    isDark,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildRulesCard(
                                      context, controller, isDark, themeChange),

                                  const SizedBox(height: 24),

                                  // ── Save Button ────────────────────────
                                  controller.driverModel.value.ownerId == null
                                      ? _buildSaveButton(
                                          context, controller, isDark)
                                      : const SizedBox(height: 10),

                                  const SizedBox(height: 20),
                                ],
                              ),
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

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Get.back();
                  } else if (Get.isRegistered<DashBoardController>()) {
                    Get.find<DashBoardController>().selectedDrawerIndex.value =
                        0;
                  }
                },
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
                width: 170,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              const SizedBox(width: 40), // Placeholder to center logo
            ],
          ),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.moroccoRed, AppColors.moroccoGreen],
            ).createShader(bounds),
            child: Text(
              "Vehicle Information".tr,
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
            "Set up your vehicle and service details".tr,
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

  // ─── Section Header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.moroccoRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.moroccoRed),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.moroccoRed.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Field Label ───────────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white60 : Colors.black54,
      ),
    );
  }

  // ─── Styled Text Field ─────────────────────────────────────────────────────

  Widget _buildStyledTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    bool enabled = true,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
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
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  size: 18, color: isDark ? Colors.white38 : Colors.black38)
              : null,
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.moroccoRed, width: 1.5),
          ),
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  // ─── Styled Dropdown ───────────────────────────────────────────────────────

  Widget _buildStyledDropdown<T>(
    BuildContext context, {
    required bool isDark,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    IconData? prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<T>(
        menuMaxHeight: 300,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.moroccoRed, width: 1.5),
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon,
                  size: 18, color: isDark ? Colors.white38 : Colors.black38)
              : null,
        ),
        dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        style: GoogleFonts.outfit(
          fontSize: 15,
          color: isDark ? Colors.white : Colors.black87,
        ),
        hint: Text(
          hint,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
        value: value,
        validator: (v) => v == null ? 'field required' : null,
        onChanged: onChanged,
        items: items,
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: isDark ? Colors.white38 : Colors.black38),
      ),
    );
  }

  // ─── Rate Tab Card ─────────────────────────────────────────────────────────

  Widget _buildRateTabCard(BuildContext context,
      VehicleInformationController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.moroccoRed.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DefaultTabController(
        length: controller.selectedPrices.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab bar
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: TabBar(
                onTap: (value) {
                  controller.tabBarheight.value =
                      controller.selectedPrices[value].isAcNonAc == true
                          ? 200
                          : 100;
                  controller.update();
                },
                indicatorColor: AppColors.moroccoRed,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: EdgeInsets.zero,
                isScrollable: true,
                labelColor: AppColors.moroccoRed,
                unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
                labelStyle: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.outfit(fontSize: 13),
                tabs: controller.selectedPrices.map((price) {
                  final zoneName = Constant.localizationName(
                    controller.zoneAllList
                        .firstWhere(
                          (zone) => zone.id == price.zoneId,
                          orElse: () => ZoneModel(),
                        )
                        .name,
                  );
                  return Tab(text: zoneName);
                }).toList(),
              ),
            ),
            Divider(
              height: 1,
              color: AppColors.moroccoRed.withOpacity(0.15),
            ),
            SizedBox(
              height: controller.tabBarheight.value,
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: controller.selectedPrices.map((price) {
                  int index = controller.selectedPrices.indexOf(price);
                  if (price.isAcNonAc == true) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "A/C Per ${Constant.distanceType} Rate",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            _buildRateField(
                              context,
                              controller: controller.acPerKmRate[index],
                              hintText:
                                  'A/C Per ${Constant.distanceType} Rate'.tr,
                              isDark: isDark,
                              enabled:
                                  controller.driverModel.value.ownerId == null,
                              symbol:
                                  Constant.currencyModel?.symbol.toString() ??
                                      'MAD',
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "Non A/C Per ${Constant.distanceType} Rate",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            _buildRateField(
                              context,
                              controller: controller.nonAcPerKmRate[index],
                              hintText:
                                  'Non A/C Per ${Constant.distanceType} Rate'
                                      .tr,
                              isDark: isDark,
                              enabled:
                                  controller.driverModel.value.ownerId == null,
                              symbol:
                                  Constant.currencyModel?.symbol.toString() ??
                                      'MAD',
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Per ${Constant.distanceType} Rate",
                              style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            _buildRateField(
                              context,
                              controller:
                                  controller.acNonAcWithoutPerKmRate[index],
                              hintText: 'Per ${Constant.distanceType} Rate'.tr,
                              isDark: isDark,
                              enabled:
                                  controller.driverModel.value.ownerId == null,
                              symbol:
                                  Constant.currencyModel?.symbol.toString() ??
                                      'MAD',
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required bool isDark,
    required bool enabled,
    required String symbol,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.moroccoRed.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            child: Text(
              symbol,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.moroccoRed,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.outfit(
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Service Card ──────────────────────────────────────────────────────────

  Widget _buildServiceCard(
    BuildContext context,
    VehicleInformationController controller,
    ServiceModel serviceModel,
    int index,
    bool isDark,
    DarkThemeProvider themeChange,
  ) {
    final bool isSelected =
        controller.selectedServiceType.value.id == serviceModel.id;

    // Unique "Moroccan Spotlight" card
    // – Selected   → full color, scale up slightly, glowing halo + flared top arch
    // – Unselected → grayscale wash, smaller, no glow
    final double cardW = Responsive.width(38, context);

    return GestureDetector(
      onTap: () async {
        if (controller.driverModel.value.serviceId == null) {
          controller.selectedServiceType.value = serviceModel;
          controller.getZone();
          controller.update();
        }
      },
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 0.94,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        child: Container(
          // Gradient border wrapper — only renders when selected.
          // 2.5px outer gradient shell that wraps the card WITHOUT covering content.
          width: cardW,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.moroccoRed,
                      AppColors.moroccoGreen,
                      AppColors.moroccoRed,
                    ],
                  )
                : null,
            // Subtle border for unselected state
            border: !isSelected
                ? Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.withOpacity(0.15),
                    width: 1,
                  )
                : null,
          ),
          // Inner padding creates the visible 2.5px gradient border ring
          padding: isSelected ? const EdgeInsets.all(2.5) : EdgeInsets.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isSelected ? 23.5 : 26),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Card body ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: ColorFiltered(
                    // Keep full color when selected, greyscale when not
                    colorFilter: isSelected
                        ? const ColorFilter.matrix(<double>[
                            // Identity matrix – no colour change
                            1, 0, 0, 0, 0,
                            0, 1, 0, 0, 0,
                            0, 0, 1, 0, 0,
                            0, 0, 0, 1, 0,
                          ])
                        : const ColorFilter.matrix(<double>[
                            // Greyscale matrix
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0.2126, 0.7152, 0.0722, 0, 0,
                            0, 0, 0, 1, 0,
                          ]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1C1C)
                            : const Color(0xFFF8F7F5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Top arch image tray ──
                          Expanded(
                            flex: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.moroccoRed.withOpacity(0.85),
                                    AppColors.moroccoGreen.withOpacity(0.75),
                                  ],
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Moroccan geometric background dots
                                  CustomPaint(
                                    painter: _ServiceCardPatternPainter(),
                                    child: const SizedBox.expand(),
                                  ),
                                  // Vehicle image
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: CachedNetworkImage(
                                      imageUrl: serviceModel.image.toString(),
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Center(
                                        child:
                                            Constant.loader(isDarkTheme: true),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.network(
                                        'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Bottom info strip ──
                          Expanded(
                            flex: 40,
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 10, 14, 12),
                              color: isDark
                                  ? const Color(0xFF1C1C1C)
                                  : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    Constant.localizationTitle(
                                        serviceModel.title),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A1A),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Status row
                                  Row(
                                    children: [
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? AppColors.moroccoGreen
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        isSelected
                                            ? 'Active'.tr
                                            : 'Available'.tr,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? AppColors.moroccoGreen
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Tap hint arrow
                                      if (!isSelected)
                                        Icon(
                                          Icons.touch_app_rounded,
                                          size: 15,
                                          color: isDark
                                              ? Colors.white24
                                              : Colors.black26,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Gradient border ring via ForgroundDecoration (selected only) ──
                // Note: achieved by AnimatedContainer.decoration gradient at parent level;
                // no overlay needed here — overlay was covering card content.

                // ── "Selected" crown badge (top-right) ──
                if (isSelected)
                  Positioned(
                    top: -6,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.moroccoGreen,
                            Color(0xFF2A9D5C),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.moroccoGreen.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MY RIDE'.tr,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ), // closes Stack
          ), // closes AnimatedContainer (inner card)
        ), // closes Container (gradient border wrapper)
      ), // closes AnimatedScale
    ); // closes GestureDetector + return
  }

  // ─── Rules Card ────────────────────────────────────────────────────────────

  Widget _buildRulesCard(
    BuildContext context,
    VehicleInformationController controller,
    bool isDark,
    DarkThemeProvider themeChange,
  ) {
    if (controller.driverRulesList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          "No rules available".tr,
          style: GoogleFonts.outfit(
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.12 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListBody(
          children: controller.driverRulesList
              .map(
                (item) => CheckboxListTile(
                  checkColor: Colors.white,
                  activeColor: AppColors.moroccoGreen,
                  value: controller.selectedDriverRulesList
                              .indexWhere((element) => element.id == item.id) ==
                          -1
                      ? false
                      : true,
                  title: Text(
                    Constant.localizationName(item.name),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  enabled: controller.driverModel.value.ownerId == null,
                  onChanged: (value) {
                    if (value == true) {
                      controller.selectedDriverRulesList.add(item);
                    } else {
                      controller.selectedDriverRulesList.removeAt(controller
                          .selectedDriverRulesList
                          .indexWhere((element) => element.id == item.id));
                    }
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ─── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton(BuildContext context,
      VehicleInformationController controller, bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          ShowToastDialog.showLoader("Please wait".tr);

          if (controller.selectedServiceType.value.id == null ||
              controller.selectedServiceType.value.id!.isEmpty) {
            ShowToastDialog.showToast("Please select service".tr);
            return;
          }

          if (controller.vehicleNumberController.value.text.isEmpty) {
            ShowToastDialog.showToast("Please enter Vehicle number".tr);
          } else if (controller.registrationDateController.value.text.isEmpty) {
            ShowToastDialog.showToast("Please select registration date".tr);
          } else if (controller.selectedColor.value.isEmpty) {
            ShowToastDialog.showToast("Please enter Vehicle color".tr);
          } else if (controller.seatsController.value.text.isEmpty) {
            ShowToastDialog.showToast("Please enter seats".tr);
          } else if (controller.selectedZone.isEmpty) {
            ShowToastDialog.showToast("Please select Zone".tr);
          } else {
            for (int index = 0;
                index < controller.selectedPrices.length;
                index++) {
              ZoneModel zoneModel = await FireStoreUtils.getZoneById(
                  zoneId: controller.selectedPrices[index].zoneId!);
              if (controller.selectedPrices[index].isAcNonAc == true) {
                if (controller.acPerKmRate[index].text.isEmpty) {
                  ShowToastDialog.showToast(
                    "${'Please enter A/C Per'.tr} ${Constant.distanceType} ${'Rate for'.tr} ${Constant.localizationName(zoneModel.name)} ${'Zone'.tr}."
                        .tr,
                  );
                  return;
                } else if (double.parse(
                        controller.selectedPrices[index].acCharge.toString()) <
                    double.parse(controller.acPerKmRate[index].text)) {
                  ShowToastDialog.showToast(
                    "${"Maximum allowed value is".tr} ${controller.selectedPrices[index].acCharge.toString()} ${"Please enter a lower A/c value for".tr} ${Constant.localizationName(zoneModel.name)} ${'Zone'.tr}."
                        .tr,
                  );
                  return;
                } else if (controller.nonAcPerKmRate[index].text.isEmpty) {
                  ShowToastDialog.showToast(
                    "${"Please enter Non A/C Per".tr} ${Constant.distanceType} ${'Rate for'} ${Constant.localizationName(zoneModel.name)} ${'Zone'.tr}."
                        .tr,
                  );
                  return;
                } else if (double.parse(controller
                        .selectedPrices[index].nonAcCharge
                        .toString()) <
                    double.parse(controller.nonAcPerKmRate[index].text)) {
                  ShowToastDialog.showToast(
                    "${"Maximum allowed value is".tr} ${controller.selectedPrices[index].nonAcCharge.toString()} ${"Please enter a lower Non A/c value for".tr} ${Constant.localizationName(zoneModel.name)} ${'Zone'.tr}."
                        .tr,
                  );
                  return;
                }
              } else if (controller.selectedPrices[index].isAcNonAc == false) {
                ZoneModel zoneData = await FireStoreUtils.getZoneById(
                    zoneId: controller.selectedPrices[index].zoneId!);
                if (controller.acNonAcWithoutPerKmRate[index].text.isEmpty) {
                  ShowToastDialog.showToast(
                    "${"Please enter Per".tr} ${Constant.distanceType} ${"Rate for".tr} ${Constant.localizationName(zoneData.name)} ${'Zone'.tr}."
                        .tr,
                  );
                  return;
                } else if (double.parse(
                        controller.selectedPrices[index].kmCharge.toString()) <
                    double.parse(
                        controller.acNonAcWithoutPerKmRate[index].text)) {
                  ShowToastDialog.showToast(
                    "${"Maximum allowed value is".tr} ${controller.selectedPrices[index].kmCharge.toString()} ${"Please enter a lower price for".tr} ${Constant.localizationName(zoneData.name)} ${'Zone'.tr}."
                        .tr,
                  );
                  return;
                }
              }
            }
            controller.saveDetails();
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
            const Icon(Icons.save_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              "Save".tr,
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

  // ─── Zone Dialog ───────────────────────────────────────────────────────────

  void zoneDialog(
      BuildContext context, VehicleInformationController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Zone list'.tr),
          content: SizedBox(
            width: Responsive.width(90, context),
            // Change as per your requirement
            child: controller.zoneList.isEmpty
                ? Container()
                : Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.zoneList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Obx(
                          () => CheckboxListTile(
                            value: controller.selectedTempZone
                                .contains(controller.zoneList[index].id),
                            onChanged: (value) {
                              if (controller.selectedTempZone
                                  .contains(controller.zoneList[index].id)) {
                                controller.selectedTempZone.remove(
                                    controller.zoneList[index].id); // unselect
                              } else {
                                controller.selectedTempZone.add(
                                    controller.zoneList[index].id); // select
                              }
                            },
                            activeColor: AppColors.lightprimary,
                            title: Text(Constant.localizationName(
                                controller.zoneList[index].name)),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          actions: [
            TextButton(
              child: Text(
                "Cancel".tr,
                style: const TextStyle(),
              ),
              onPressed: () {
                controller.selectedTempZone.value = controller.selectedZone;
                Get.back();
              },
            ),
            TextButton(
              child: Text("Continue".tr),
              onPressed: () {
                controller.selectedZone.clear();
                controller.selectedZone.addAll(controller.selectedTempZone);
                if (controller.selectedTempZone.isEmpty) {
                  ShowToastDialog.showToast("Please select zone".tr);
                } else {
                  controller.selectedPrices.value = controller
                          .selectedServiceType.value.prices
                          ?.where((price) =>
                              controller.selectedZone.contains(price.zoneId))
                          .toList() ??
                      <Price>[];
                  controller.acPerKmRate.value = List.generate(
                      controller.selectedPrices.length,
                      (index) => TextEditingController());
                  controller.nonAcPerKmRate.value = List.generate(
                      controller.selectedPrices.length,
                      (index) => TextEditingController());
                  controller.acNonAcWithoutPerKmRate.value = List.generate(
                      controller.selectedPrices.length,
                      (index) => TextEditingController());
                  final hasAcNonAc =
                      controller.selectedPrices.any((e) => e.isAcNonAc == true);
                  controller.tabBarheight.value = hasAcNonAc ? 200 : 100;
                  String nameValue = "";
                  for (var element in controller.selectedZone) {
                    List<ZoneModel> list = controller.zoneList
                        .where((p0) => p0.id == element)
                        .toList();
                    if (list.isNotEmpty) {
                      nameValue =
                          "$nameValue${nameValue.isEmpty ? "" : ","} ${Constant.localizationName(list.first.name)}";
                    }
                  }
                  controller.zoneNameController.value.text = nameValue;
                  controller.update();
                  Get.back();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

// ─── Service Card Pattern Painter ────────────────────────────────────────────

class _ServiceCardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double step = 28.0;
    // Draw a subtle diamond/cross grid
    for (double x = 0; x < size.width + step; x += step) {
      for (double y = 0; y < size.height + step; y += step) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
    // Draw diagonal lines for a Moroccan lattice feel
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.8;
    for (double d = -size.height; d < size.width + size.height; d += step * 2) {
      canvas.drawLine(
        Offset(d, 0),
        Offset(d + size.height, size.height),
        linePaint,
      );
      canvas.drawLine(
        Offset(d + size.height, 0),
        Offset(d, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ServiceCardPatternPainter oldDelegate) => false;
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
