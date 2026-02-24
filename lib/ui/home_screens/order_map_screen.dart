import 'dart:io';

import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/order_map_controller.dart';
import 'package:driver/model/owner_user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/widget/location_view.dart';
import 'package:driver/widget/user_view.dart';
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
            appBar: AppBar(
              backgroundColor: AppColors.lightprimary,
              leading: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: const Icon(
                    Icons.arrow_back,
                  )),
            ),
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : Column(
                    children: [
                      Container(
                        height: Responsive.width(10, context),
                        width: Responsive.width(100, context),
                        color: AppColors.lightprimary,
                      ),
                      Expanded(
                        child: Container(
                          transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.background,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(25),
                                  topRight: Radius.circular(25))),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30)),
                            child: Stack(
                              children: [
                                Constant.selectedMapType == 'osm'
                                    ? flutterMap.FlutterMap(
                                        mapController:
                                            controller.osmMapController,
                                        options: flutterMap.MapOptions(
                                          initialCenter: location.LatLng(
                                              Constant.currentLocation
                                                      ?.latitude ??
                                                  45.521563,
                                              Constant.currentLocation
                                                      ?.longitude ??
                                                  -122.677433),
                                          initialZoom: 10,
                                        ),
                                        children: [
                                          flutterMap.TileLayer(
                                            urlTemplate:
                                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            userAgentPackageName:
                                                Platform.isAndroid
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
                                                point: controller
                                                    .destination.value,
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
                                                  points:
                                                      controller.routePoints,
                                                  strokeWidth: 5.0,
                                                  color: themeChange.getThem()
                                                      ? AppColors
                                                          .darksecondprimary
                                                      : AppColors
                                                          .lightsecondprimary,
                                                ),
                                              ],
                                            ),
                                        ],
                                      )
                                    : GoogleMap(
                                        myLocationEnabled: true,
                                        myLocationButtonEnabled: true,
                                        mapType: MapType.terrain,
                                        zoomControlsEnabled: false,
                                        polylines: Set<Polyline>.of(
                                            controller.polyLines.values),
                                        padding: const EdgeInsets.only(
                                          top: 22.0,
                                        ),
                                        markers: Set<Marker>.of(
                                            controller.markers.values),
                                        onMapCreated: (GoogleMapController
                                            mapController) {
                                          controller.mapController
                                              .complete(mapController);
                                        },
                                        initialCameraPosition: CameraPosition(
                                          zoom: 15,
                                          target: LatLng(
                                              Constant.currentLocation!
                                                      .latitude ??
                                                  45.521563,
                                              Constant.currentLocation!
                                                      .longitude ??
                                                  -122.677433),
                                        ),
                                      ),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: animation,
                                      child: child,
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    switchInCurve: Curves.easeInOut,
                                    switchOutCurve: Curves.easeInOut,
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(
                                                0, 1), // start from bottom
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child:
                                        controller.isHideButtomSheet.value ==
                                                false
                                            ? Align(
                                                key: const ValueKey(
                                                    "BottomSheet"),
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppColors
                                                              .darkContainerBackground
                                                          : AppColors
                                                              .containerBackground,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)),
                                                      border: Border.all(
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppColors
                                                                .darkContainerBorder
                                                            : AppColors
                                                                .containerBorder,
                                                        width: 0.5,
                                                      ),
                                                      boxShadow: themeChange
                                                              .getThem()
                                                          ? null
                                                          : [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .grey
                                                                    .withOpacity(
                                                                        0.5),
                                                                blurRadius: 8,
                                                                offset:
                                                                    const Offset(
                                                                        0, 2),
                                                              ),
                                                            ],
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: UserView(
                                                                  userModel:
                                                                      controller
                                                                          .usermodel
                                                                          .value,
                                                                  userId: controller
                                                                      .orderModel
                                                                      .value
                                                                      .userId,
                                                                  amount: controller
                                                                      .orderModel
                                                                      .value
                                                                      .offerRate,
                                                                  distance: controller
                                                                      .orderModel
                                                                      .value
                                                                      .distance,
                                                                  distanceType:
                                                                      controller
                                                                          .orderModel
                                                                          .value
                                                                          .distanceType,
                                                                  isAcOrNonAc: controller
                                                                              .orderModel
                                                                              .value
                                                                              .service
                                                                              ?.prices
                                                                              ?.first
                                                                              .isAcNonAc ==
                                                                          false
                                                                      ? null
                                                                      : controller
                                                                          .orderModel
                                                                          .value
                                                                          .isAcSelected,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  controller
                                                                      .isHideButtomSheet
                                                                      .value = true;
                                                                },
                                                                icon: Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border: Border.all(
                                                                        color: AppColors
                                                                            .textFieldBorder),
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(30)),
                                                                  ),
                                                                  child: Icon(Icons
                                                                      .keyboard_arrow_down_sharp),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        5),
                                                            child: Divider(),
                                                          ),
                                                          LocationView(
                                                            sourceLocation:
                                                                controller
                                                                    .orderModel
                                                                    .value
                                                                    .sourceLocationName
                                                                    .toString(),
                                                            destinationLocation:
                                                                controller
                                                                    .orderModel
                                                                    .value
                                                                    .destinationLocationName
                                                                    .toString(),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Visibility(
                                                            visible: controller
                                                                        .orderModel
                                                                        .value
                                                                        .service !=
                                                                    null &&
                                                                controller
                                                                        .orderModel
                                                                        .value
                                                                        .service!
                                                                        .offerRate ==
                                                                    true,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      // if (controller.baseAmount.value >= 10) {
                                                                      //   controller.baseAmount.value -= 10;
                                                                      //   controller.newAmount.value = (controller.baseAmount.value + controller.totalPerMinutesRateCharges.value)
                                                                      //       .toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                                                                      // } else {
                                                                      //   controller.baseAmount.value = 0;
                                                                      //   controller.newAmount.value =
                                                                      //       controller.totalPerMinutesRateCharges.value.toStringAsFixed(Constant.currencyModel!.decimalDigits!);
                                                                      // }
                                                                      controller
                                                                          .amount
                                                                          .value = controller
                                                                              .amount
                                                                              .value -
                                                                          10;
                                                                      controller
                                                                          .finalAmount
                                                                          .value = controller
                                                                              .finalAmount
                                                                              .value -
                                                                          10;
                                                                      controller.enterOfferRateController.value.text = controller
                                                                          .amount
                                                                          .value
                                                                          .toStringAsFixed(Constant
                                                                              .currencyModel!
                                                                              .decimalDigits!);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border: Border.all(
                                                                            color:
                                                                                AppColors.textFieldBorder),
                                                                        borderRadius: const BorderRadius
                                                                            .all(
                                                                            Radius.circular(30)),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                30,
                                                                            vertical:
                                                                                10),
                                                                        child: Text(
                                                                            "- 10",
                                                                            style:
                                                                                GoogleFonts.poppins()),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          20),
                                                                  Text(
                                                                    Constant.amountShow(
                                                                        amount: controller
                                                                            .amount
                                                                            .value
                                                                            .toString()),
                                                                    style: GoogleFonts
                                                                        .poppins(),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          20),
                                                                  ButtonThem
                                                                      .roundButton(
                                                                    context,
                                                                    title:
                                                                        "+ 10",
                                                                    btnWidthRatio:
                                                                        0.22,
                                                                    onPress:
                                                                        () {
                                                                      controller
                                                                          .amount
                                                                          .value = controller
                                                                              .amount
                                                                              .value +
                                                                          10;
                                                                      controller
                                                                          .finalAmount
                                                                          .value = controller
                                                                              .finalAmount
                                                                              .value +
                                                                          10;
                                                                      controller.enterOfferRateController.value.text = controller
                                                                          .amount
                                                                          .value
                                                                          .toStringAsFixed(Constant
                                                                              .currencyModel!
                                                                              .decimalDigits!);
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Visibility(
                                                            visible: controller
                                                                        .orderModel
                                                                        .value
                                                                        .service !=
                                                                    null &&
                                                                controller
                                                                        .orderModel
                                                                        .value
                                                                        .service!
                                                                        .offerRate ==
                                                                    true,
                                                            child: TextFieldThem
                                                                .buildTextFiledWithPrefixIcon(
                                                              context,
                                                              hintText:
                                                                  "Enter Fare rate",
                                                              controller: controller
                                                                  .enterOfferRateController
                                                                  .value,
                                                              keyBoardType:
                                                                  const TextInputType
                                                                      .numberWithOptions(
                                                                      decimal:
                                                                          true,
                                                                      signed:
                                                                          false),
                                                              onChanged:
                                                                  (value) {
                                                                if (value
                                                                    .isEmpty) {
                                                                  controller
                                                                      .amount
                                                                      .value = 0.0;
                                                                } else {
                                                                  controller
                                                                          .amount
                                                                          .value =
                                                                      double.tryParse(
                                                                              value) ??
                                                                          0.0;
                                                                  controller
                                                                      .finalAmount
                                                                      .value = double
                                                                          .parse(
                                                                              value) +
                                                                      controller
                                                                          .totalChargeOfMinute
                                                                          .value +
                                                                      (double.parse(controller
                                                                              .orderModel
                                                                              .value
                                                                              .service
                                                                              ?.prices
                                                                              ?.first
                                                                              .basicFareCharge ??
                                                                          '0.0'));
                                                                }
                                                              },
                                                              prefix: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10),
                                                                child: Text(Constant
                                                                    .currencyModel!
                                                                    .symbol
                                                                    .toString()),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          Text(
                                                              "ETA: ${controller.convertToMinutes(controller.orderModel.value.duration.toString())} Minutes / Minutes charges (${Constant.amountShow(amount: controller.totalChargeOfMinute.value.toString())})",
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                          Text(
                                                              "${controller.orderModel.value.service?.prices?.first.basicFare} ${Constant.distanceType} - Base Fare (${Constant.amountShow(amount: controller.basicFare.value.toString())})",
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500)),
                                                          const SizedBox(
                                                            height: 20,
                                                          ),
                                                          ButtonThem
                                                              .buildButton(
                                                            context,
                                                            title:
                                                                "Accept fare on ${Constant.amountShow(amount: controller.finalAmount.value.toString())}"
                                                                    .tr,
                                                            onPress: () async {
                                                              if (controller
                                                                      .driverModel
                                                                      .value
                                                                      .ownerId ==
                                                                  null) {
                                                                if (double.parse(controller
                                                                        .amount
                                                                        .value
                                                                        .toString()) >
                                                                    0) {
                                                                  if (controller
                                                                          .driverModel
                                                                          .value
                                                                          .subscriptionTotalOrders ==
                                                                      "-1") {
                                                                    controller
                                                                        .acceptOrder();
                                                                  } else {
                                                                    if (Constant.isSubscriptionModelApplied ==
                                                                            false &&
                                                                        Constant.adminCommission!.isEnabled ==
                                                                            false) {
                                                                      controller
                                                                          .acceptOrder();
                                                                    } else {
                                                                      if ((controller.driverModel.value.subscriptionExpiryDate != null &&
                                                                              controller.driverModel.value.subscriptionExpiryDate!.toDate().isBefore(DateTime.now()) ==
                                                                                  false) ||
                                                                          controller.driverModel.value.subscriptionPlan?.expiryDay ==
                                                                              '-1') {
                                                                        if (controller.driverModel.value.subscriptionTotalOrders !=
                                                                            '0') {
                                                                          controller
                                                                              .acceptOrder();
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
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Please enter valid offer rate"
                                                                              .tr);
                                                                }
                                                              } else {
                                                                OwnerUserModel?
                                                                    ownerUserModel =
                                                                    await FireStoreUtils.getOwnerProfile(controller
                                                                        .driverModel
                                                                        .value
                                                                        .ownerId!);
                                                                if (double.parse(controller
                                                                        .amount
                                                                        .value
                                                                        .toString()) >
                                                                    0) {
                                                                  if (ownerUserModel
                                                                          ?.subscriptionTotalOrders ==
                                                                      "-1") {
                                                                    controller
                                                                        .acceptOrder();
                                                                  } else {
                                                                    if (Constant.isSubscriptionModelApplied ==
                                                                            false &&
                                                                        Constant.adminCommission!.isEnabled ==
                                                                            false) {
                                                                      controller
                                                                          .acceptOrder();
                                                                    } else {
                                                                      if ((ownerUserModel?.subscriptionExpiryDate != null &&
                                                                              ownerUserModel?.subscriptionExpiryDate!.toDate().isBefore(DateTime.now()) ==
                                                                                  false) ||
                                                                          ownerUserModel?.subscriptionPlan?.expiryDay ==
                                                                              '-1') {
                                                                        if (ownerUserModel?.subscriptionTotalOrders !=
                                                                            '0') {
                                                                          controller
                                                                              .acceptOrder();
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
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Please enter valid offer rate"
                                                                              .tr);
                                                                }
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Align(
                                                key: const ValueKey(
                                                    "ViewButton"),
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 16,
                                                          bottom: 30),
                                                  child: ButtonThem.roundButton(
                                                    bgColors:
                                                        AppColors.lightprimary,
                                                    textColor:
                                                        AppColors.background,
                                                    context,
                                                    title: "View",
                                                    btnWidthRatio: 0.25,
                                                    onPress: () {
                                                      controller
                                                          .isHideButtomSheet
                                                          .value = false;
                                                    },
                                                  ),
                                                ),
                                              ),
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
}
