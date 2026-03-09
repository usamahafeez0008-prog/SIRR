import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/order_map_controller.dart';
import 'package:driver/model/owner_user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' as location;

class OrderMapScreen extends StatelessWidget {
  const OrderMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<OrderMapController>(
        init: OrderMapController(),
        builder: (controller) {
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Trip Details".tr,
                style: GoogleFonts.outfit(
                  color: AppColors.moroccoRed,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.moroccoRed,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : Stack(
                    children: [
                      // Map Background
                      Positioned.fill(
                        child: Constant.selectedMapType == 'osm'
                            ? flutterMap.FlutterMap(
                                mapController: controller.osmMapController,
                                options: flutterMap.MapOptions(
                                  initialCenter: location.LatLng(
                                      Constant.currentLocation?.latitude ??
                                          45.521563,
                                      Constant.currentLocation?.longitude ??
                                          -122.677433),
                                  initialZoom: 14,
                                ),
                                children: [
                                  flutterMap.TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: Platform.isAndroid
                                        ? 'com.codesteem.driver'
                                        : 'com.codesteem.driver',
                                  ),
                                  flutterMap.MarkerLayer(
                                    markers: [
                                      flutterMap.Marker(
                                        point: controller.source.value,
                                        width: 50,
                                        height: 50,
                                        child: Image.asset(
                                            'assets/images/pickup.png'),
                                      ),
                                      flutterMap.Marker(
                                        point: controller.destination.value,
                                        width: 50,
                                        height: 50,
                                        child: Image.asset(
                                            'assets/images/dropoff.png'),
                                      ),
                                    ],
                                  ),
                                  if (controller.routePoints.isNotEmpty)
                                    flutterMap.PolylineLayer(
                                      polylines: [
                                        flutterMap.Polyline(
                                          points: controller.routePoints,
                                          strokeWidth: 5.0,
                                          color: AppColors.moroccoGreen,
                                        ),
                                      ],
                                    ),
                                ],
                              )
                            : GoogleMap(
                                myLocationEnabled: true,
                                myLocationButtonEnabled: false,
                                mapType: MapType.normal,
                                zoomControlsEnabled: false,
                                polylines: Set<Polyline>.of(
                                    controller.polyLines.values),
                                markers:
                                    Set<Marker>.of(controller.markers.values),
                                onMapCreated:
                                    (GoogleMapController mapController) {
                                  controller.mapController
                                      .complete(mapController);
                                },
                                initialCameraPosition: CameraPosition(
                                  zoom: 14,
                                  target: LatLng(
                                      Constant.currentLocation!.latitude ??
                                          45.521563,
                                      Constant.currentLocation!.longitude ??
                                          -122.677433),
                                ),
                              ),
                      ),

                      // Floating Bottom Sheet View
                      _buildFloatingBottomSheet(
                          context, controller, themeChange),

                      // View Button (appears when sheet is hidden)
                      if (controller.isHideButtomSheet.value)
                        Positioned(
                          bottom: 50 + MediaQuery.of(context).padding.bottom,
                          right: 16,
                          child: InkWell(
                            onTap: () {
                              controller.isHideButtomSheet.value = false;
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: const BoxDecoration(
                                color: AppColors.moroccoRed,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility_rounded,
                                      color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "View Details".tr,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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

  Widget _buildFloatingBottomSheet(BuildContext context,
      OrderMapController controller, DarkThemeProvider themeChange) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
      bottom: controller.isHideButtomSheet.value
          ? -1000
          : 50 + MediaQuery.of(context).padding.bottom,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeChange.getThem()
              ? AppColors.darkContainerBackground
              : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                      controller.usermodel.value.profilePic ??
                          Constant.userPlaceHolder),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.usermodel.value.fullName ?? "Customer".tr,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: themeChange.getThem()
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            "4.5", // Mocking rating as in screenshot
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Icon(Icons.directions_car_rounded, color: AppColors.moroccoGreen, size: 40),
                controller.orderModel.value.service?.image == null ||
                        controller.orderModel.value.service!.image!.isEmpty
                    ? Image.asset('assets/images/car_top.png',
                        height: 40,
                        errorBuilder: (c, e, s) => const Icon(
                            Icons.directions_car_rounded,
                            size: 60,
                            color: Colors.grey))
                    : CachedNetworkImage(
                        height: 60,
                        width: 60,
                        imageUrl: controller.orderModel.value.service!.image!,
                        fit: BoxFit.contain,
                        placeholder: (context, url) =>
                            Constant.loader(isDarkTheme: themeChange.getThem()),
                        errorWidget: (c, e, s) => const Icon(
                            Icons.directions_car_rounded,
                            size: 40,
                            color: Colors.grey),
                      ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1),
            ),

            // Source and Destination
            _buildTripPoint(
              icon: Icons.circle,
              iconColor: AppColors.moroccoGreen,
              label: "Pickup Point".tr,
              address:
                  controller.orderModel.value.sourceLocationName.toString(),
              time: Constant.dateAndTimeFormatTimestamp(
                  controller.orderModel.value.createdDate!),
              showLine: true,
              themeChange: themeChange,
            ),
            _buildTripPoint(
              icon: Icons.location_on_rounded,
              iconColor: AppColors.moroccoRed,
              label: "Destination".tr,
              address: controller.orderModel.value.destinationLocationName
                  .toString(),
              time: "", // Add time logic if needed
              showLine: false,
              themeChange: themeChange,
            ),

            const SizedBox(height: 25),

            // Statistics Row
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                      "Total Price".tr,
                      Constant.amountShow(
                          amount: controller.finalAmount.value.toString()),
                      Icons.payments_rounded,
                      themeChange),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatItem(
                      "Distance".tr,
                      "${controller.orderModel.value.distance} ${Constant.distanceType}",
                      Icons.route_rounded,
                      themeChange),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildStatItem(
                      "Time".tr,
                      "${controller.convertToMinutes(controller.orderModel.value.duration.toString())} MIN",
                      Icons.timer_rounded,
                      themeChange),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Bidding Section
            if (controller.orderModel.value.service != null &&
                controller.orderModel.value.service!.offerRate == true)
              _buildBiddingArea(controller, themeChange),

            const SizedBox(height: 20),

            // Accept Button
            ButtonThem.buildButton(
              context,
              title: "Accept Ride".tr,
              bgColors: AppColors.moroccoRed,
              textColor: Colors.white,
              onPress: () async {
                // Implementation preserved from original code
                if (controller.driverModel.value.ownerId == null) {
                  if (double.parse(controller.amount.value.toString()) > 0) {
                    if (controller.driverModel.value.subscriptionTotalOrders ==
                        "-1") {
                      controller.acceptOrder();
                    } else {
                      if (Constant.isSubscriptionModelApplied == false &&
                          Constant.adminCommission!.isEnabled == false) {
                        controller.acceptOrder();
                      } else {
                        if ((controller.driverModel.value
                                        .subscriptionExpiryDate !=
                                    null &&
                                controller.driverModel.value
                                        .subscriptionExpiryDate!
                                        .toDate()
                                        .isBefore(DateTime.now()) ==
                                    false) ||
                            controller.driverModel.value.subscriptionPlan
                                    ?.expiryDay ==
                                '-1') {
                          if (controller
                                  .driverModel.value.subscriptionTotalOrders !=
                              '0') {
                            controller.acceptOrder();
                          } else {
                            ShowToastDialog.showToast(
                                "Your order limit has reached their maximum order capacity. Please subscribe another subscription");
                          }
                        } else {
                          ShowToastDialog.showToast(
                              "Your order limit has reached their maximum order capacity. Please subscribe another subscription");
                        }
                      }
                    }
                  } else {
                    ShowToastDialog.showToast(
                        "Please enter valid offer rate".tr);
                  }
                } else {
                  OwnerUserModel? ownerUserModel =
                      await FireStoreUtils.getOwnerProfile(
                          controller.driverModel.value.ownerId!);
                  if (double.parse(controller.amount.value.toString()) > 0) {
                    if (ownerUserModel?.subscriptionTotalOrders == "-1") {
                      controller.acceptOrder();
                    } else {
                      if (Constant.isSubscriptionModelApplied == false &&
                          Constant.adminCommission!.isEnabled == false) {
                        controller.acceptOrder();
                      } else {
                        if ((ownerUserModel?.subscriptionExpiryDate != null &&
                                ownerUserModel?.subscriptionExpiryDate!
                                        .toDate()
                                        .isBefore(DateTime.now()) ==
                                    false) ||
                            ownerUserModel?.subscriptionPlan?.expiryDay ==
                                '-1') {
                          if (ownerUserModel?.subscriptionTotalOrders != '0') {
                            controller.acceptOrder();
                          } else {
                            ShowToastDialog.showToast(
                                "Your order limit has reached their maximum order capacity. Please reach out to the owner.");
                          }
                        } else {
                          ShowToastDialog.showToast(
                              "Your order limit has reached their maximum order capacity. Please reach out to the owner.");
                        }
                      }
                    }
                  } else {
                    ShowToastDialog.showToast(
                        "Please enter valid offer rate".tr);
                  }
                }
              },
            ),

            // Hide Handle
            Center(
              child: IconButton(
                onPressed: () {
                  controller.isHideButtomSheet.value = true;
                },
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 30, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripPoint({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
    required String time,
    required bool showLine,
    required DarkThemeProvider themeChange,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(icon, color: iconColor, size: 24),
              if (showLine)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        themeChange.getThem() ? Colors.white70 : Colors.black87,
                  ),
                ),
                if (showLine) const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      DarkThemeProvider themeChange) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: themeChange.getThem()
            ? Colors.white.withOpacity(0.05)
            : AppColors.moroccoGreen.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: themeChange.getThem()
              ? Colors.white.withOpacity(0.1)
              : AppColors.moroccoGreen.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.moroccoGreen),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: themeChange.getThem() ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiddingArea(
      OrderMapController controller, DarkThemeProvider themeChange) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minus Button
            GestureDetector(
              onTap: () {
                controller.amount.value = controller.amount.value - 10;
                controller.finalAmount.value =
                    controller.finalAmount.value - 10;
                controller.enterOfferRateController.value.text = controller
                    .amount.value
                    .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.moroccoGreen.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  "- 10",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: AppColors.moroccoGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 25),
            Text(
              Constant.amountShow(amount: controller.amount.value.toString()),
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: themeChange.getThem() ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 25),
            // Plus Button
            GestureDetector(
              onTap: () {
                controller.amount.value = controller.amount.value + 10;
                controller.finalAmount.value =
                    controller.finalAmount.value + 10;
                controller.enterOfferRateController.value.text = controller
                    .amount.value
                    .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.moroccoGreen,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.moroccoGreen.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  "+ 10",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        TextFieldThem.buildTextFiledWithPrefixIcon(
          Get.context!,
          hintText: "Enter your bid...".tr,
          controller: controller.enterOfferRateController.value,
          borderRadius: 30.0,
          borderColor: AppColors.moroccoRed,
          keyBoardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          onChanged: (value) {
            if (value.isEmpty) {
              controller.amount.value = 0.0;
            } else {
              controller.amount.value = double.tryParse(value) ?? 0.0;
              controller.finalAmount.value = double.parse(value) +
                  controller.totalChargeOfMinute.value +
                  (double.parse(controller.orderModel.value.service?.prices
                          ?.first.basicFareCharge ??
                      '0.0'));
            }
          },
          prefix: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(Constant.currencyModel!.symbol.toString(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
