import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/active_order_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/ui/chat_screen/chat_screen.dart';
import 'package:driver/ui/home_screens/live_tracking_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class ActiveOrderScreen extends StatelessWidget {
  const ActiveOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<ActiveOrderController>(
        init: ActiveOrderController(),
        global: true, // Ensuring it's globally accessible and stable
        builder: (controller) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(CollectionName.orders)
                .where('driverId', isEqualTo: FireStoreUtils.getCurrentUid())
                .where('status', whereIn: [
              Constant.rideInProgress,
              Constant.rideActive,
              Constant.rideHoldAccepted,
              Constant.rideHold,
            ]).snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong'.tr);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Constant.loader(isDarkTheme: themeChange.getThem());
              }
              return snapshot.data!.docs.isEmpty
                  ? Center(
                      child: Text("No active rides Found".tr),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        OrderModel orderModel = OrderModel.fromJson(
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>);
                        return _buildActiveOrderCard(
                            context, orderModel, themeChange, controller);
                      });
            },
          );
        });
  }

  Widget _buildActiveOrderCard(BuildContext context, OrderModel orderModel,
      DarkThemeProvider themeChange, ActiveOrderController controller) {
    return FutureBuilder<UserModel?>(
      future: FireStoreUtils.getCustomer(orderModel.userId.toString()),
      builder: (context, snapshot) {
        UserModel? customer = snapshot.data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: themeChange.getThem()
                  ? AppColors.darkContainerBackground
                  : AppColors.containerBackground,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: themeChange.getThem()
                    ? AppColors.darkContainerBorder.withOpacity(0.5)
                    : AppColors.containerBorder.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                if (Constant.mapType == "inappmap") {
                  if (orderModel.status == Constant.rideActive ||
                      orderModel.status == Constant.rideInProgress) {
                    Get.to(const LiveTrackingScreen(), arguments: {
                      "orderModel": orderModel,
                      "type": "orderModel",
                    });
                  }
                } else {
                  if (orderModel.status == Constant.rideInProgress) {
                    Utils.redirectMap(
                        latitude:
                            orderModel.destinationLocationLAtLng!.latitude!,
                        longLatitude:
                            orderModel.destinationLocationLAtLng!.longitude!,
                        name: orderModel.destinationLocationName.toString());
                  } else {
                    Utils.redirectMap(
                        latitude: orderModel.sourceLocationLAtLng!.latitude!,
                        longLatitude:
                            orderModel.sourceLocationLAtLng!.longitude!,
                        name: orderModel.destinationLocationName.toString());
                  }
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // Top Section: Info & Image
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Constant.dateAndTimeFormatTimestamp(
                                    orderModel.createdDate!),
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: themeChange.getThem()
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                customer?.fullName ?? 'Loading...'.tr,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: themeChange.getThem()
                                      ? Colors.white
                                      : AppColors.moroccoText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildInfoRow(
                                    Icons.payments_rounded,
                                    Constant.amountShow(
                                        amount:
                                            orderModel.finalRate.toString()),
                                    AppColors.moroccoGreen,
                                  ),
                                  const SizedBox(width: 15),
                                  _buildInfoRow(
                                    Icons.straighten_rounded,
                                    "${double.parse(orderModel.distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}",
                                    Colors.blueGrey,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            height: 80,
                            width: 80,
                            imageUrl: customer?.profilePic ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) => Image.network(
                              Constant.userPlaceHolder,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Middle Section: Locations
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildLocationItem(
                          context,
                          Icons.circle,
                          AppColors.moroccoGreen,
                          orderModel.sourceLocationName.toString(),
                          themeChange,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              children: List.generate(
                                3,
                                (index) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  width: 2,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildLocationItem(
                          context,
                          Icons.location_on_rounded,
                          AppColors.moroccoRed,
                          orderModel.destinationLocationName.toString(),
                          themeChange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Bottom Section: Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Action Button (Complete/Pickup)
                        Row(
                          children: [
                            Expanded(
                              child: orderModel.status ==
                                      Constant.rideInProgress
                                  ? ButtonThem.buildButton(
                                      context,
                                      title: "Complete Ride".tr,
                                      btnHeight: 48,
                                      bgColors: AppColors.moroccoGreen,
                                      textColor: Colors.white,
                                      onPress: () async {
                                        orderModel.status =
                                            Constant.rideComplete;
                                        ShowToastDialog.showLoader(
                                            "Please wait".tr);
                                        await FireStoreUtils.getCustomer(
                                                orderModel.userId.toString())
                                            .then((value) async {
                                          if (value != null) {
                                            if (value.fcmToken != null) {
                                              Map<String, dynamic> playLoad =
                                                  <String, dynamic>{
                                                "type": "city_order_complete",
                                                "orderId": orderModel.id
                                              };

                                              await SendNotification
                                                  .sendOneNotification(
                                                      token: value.fcmToken
                                                          .toString(),
                                                      title:
                                                          'Ride complete!'.tr,
                                                      body:
                                                          'Please complete your payment.'
                                                              .tr,
                                                      payload: playLoad);
                                            }
                                          }
                                        });

                                        await FireStoreUtils.setOrder(
                                                orderModel)
                                            .then((value) {
                                          if (value == true) {
                                            ShowToastDialog.showToast(
                                                "Ride Complete successfully"
                                                    .tr);
                                            controller.homeController
                                                .selectedIndex.value = 3;
                                          }
                                        });
                                        ShowToastDialog.closeLoader();
                                      },
                                    )
                                  : orderModel.status == Constant.rideHold ||
                                          orderModel.status ==
                                              Constant.rideHoldAccepted
                                      ? const SizedBox.shrink()
                                      : ButtonThem.buildButton(
                                          context,
                                          title: "Pickup Customer".tr,
                                          btnHeight: 48,
                                          bgColors: AppColors.moroccoRed,
                                          textColor: Colors.white,
                                          onPress: () async {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  OtpDialog(
                                                orderModel: orderModel,
                                                driverModel: controller
                                                    .drivermodel.value,
                                                onSuccess: () {
                                                  controller.homeController
                                                      .selectedIndex.value = 3;
                                                },
                                              ),
                                            );
                                          },
                                        ),
                            ),
                            if (orderModel.status != Constant.rideHold &&
                                orderModel.status != Constant.rideHoldAccepted)
                              const SizedBox(width: 12),
                            if (orderModel.status != Constant.rideHold &&
                                orderModel.status != Constant.rideHoldAccepted)
                              Row(
                                children: [
                                  _buildActionButton(
                                    onTap: () async {
                                      UserModel? customer =
                                          await FireStoreUtils.getCustomer(
                                              orderModel.userId.toString());

                                      Get.to(ChatScreens(
                                        driverId:
                                            controller.drivermodel.value?.id,
                                        customerId: customer!.id,
                                        customerName: customer.fullName,
                                        customerProfileImage:
                                            customer.profilePic,
                                        driverName: controller
                                            .drivermodel.value?.fullName,
                                        driverProfileImage: controller
                                            .drivermodel.value?.profilePic,
                                        orderId: orderModel.id,
                                        token: customer.fcmToken,
                                      ));
                                    },
                                    icon: Icons.chat_bubble_outline_outlined,
                                    color: themeChange.getThem()
                                        ? AppColors.moroccoGreen
                                        : AppColors.moroccoGreen,
                                    isDark: themeChange.getThem(),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildActionButton(
                                    onTap: () async {
                                      UserModel? customer =
                                          await FireStoreUtils.getCustomer(
                                              orderModel.userId.toString());
                                      Constant.makePhoneCall(
                                          "${customer!.countryCode}${customer.phoneNumber}");
                                    },
                                    icon: Icons.call_rounded,
                                    color: AppColors.moroccoGreen,
                                    isDark: themeChange.getThem(),
                                  ),
                                ],
                              ),
                          ],
                        ),

                        // Hold Logic Section
                        if (orderModel.status.toString() ==
                            Constant.rideHold) ...[
                          const SizedBox(height: 15),
                          Text(
                            "Do you want to Accept or Reject the Hold request?"
                                .tr,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: themeChange.getThem()
                                  ? Colors.grey[300]
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ButtonThem.buildBorderButton(
                                  context,
                                  title: "Reject".tr,
                                  btnHeight: 45,
                                  iconVisibility: false,
                                  onPress: () async {
                                    ShowToastDialog.showLoader(
                                        "Please wait...".tr);
                                    orderModel.status = Constant.rideInProgress;

                                    await FireStoreUtils.setOrder(orderModel)
                                        .then((value) {
                                      if (value == true) {
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast(
                                            "Ride hold request has been rejected."
                                                .tr);
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ButtonThem.buildButton(
                                  context,
                                  title: "Accept".tr,
                                  btnHeight: 45,
                                  bgColors: AppColors.moroccoRed,
                                  onPress: () async {
                                    ShowToastDialog.showLoader(
                                        "Please wait...".tr);
                                    orderModel.status =
                                        Constant.rideHoldAccepted;
                                    orderModel.acceptHoldTime = Timestamp.now();

                                    await FireStoreUtils.setOrder(orderModel)
                                        .then((value) {
                                      if (value == true) {
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast(
                                            "Ride has been put on hold.".tr);
                                      }
                                    });
                                    await FireStoreUtils.getCustomer(
                                            orderModel.userId.toString())
                                        .then((value) async {
                                      if (value != null) {
                                        await SendNotification.sendOneNotification(
                                            token: value.fcmToken.toString(),
                                            title: 'Ride Hold Accepted'.tr,
                                            body:
                                                'Driver has accepted your ride hold request'
                                                    .tr,
                                            payload: {});
                                      }
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        ],

                        if (orderModel.status.toString() ==
                            Constant.rideHoldAccepted) ...[
                          const SizedBox(height: 15),
                          ButtonThem.buildButton(
                            context,
                            title: "End Hold".tr,
                            btnHeight: 45,
                            bgColors: Colors.orange,
                            onPress: () async {
                              ShowToastDialog.showLoader("Please wait...".tr);
                              orderModel.status = Constant.rideInProgress;
                              DateTime acceptTime =
                                  orderModel.acceptHoldTime!.toDate();
                              int rideHoldTimeInSeconds = DateTime.now()
                                  .difference(acceptTime)
                                  .inSeconds;
                              int rideHoldTimeInMinutes =
                                  (rideHoldTimeInSeconds / 60).ceil();

                              int chargePerInterval = int.parse(orderModel
                                      .service
                                      ?.prices
                                      ?.first
                                      .holdingMinuteCharge ??
                                  '0.0');
                              int holdingInterval = int.parse(orderModel
                                      .service?.prices?.first.holdingMinute ??
                                  '0.0');

                              int intervals =
                                  rideHoldTimeInMinutes ~/ holdingInterval;
                              int extraTime =
                                  rideHoldTimeInMinutes % holdingInterval;

                              int totalHoldingCharges =
                                  intervals * chargePerInterval;

                              if (extraTime > 0 ||
                                  rideHoldTimeInSeconds % 60 > 0) {
                                totalHoldingCharges += chargePerInterval;
                              }
                              orderModel.acceptHoldTime = null;
                              orderModel.rideHoldTimeMinutes =
                                  rideHoldTimeInMinutes.toString();
                              orderModel.totalHoldingCharges =
                                  totalHoldingCharges.toString();

                              await FireStoreUtils.setOrder(orderModel)
                                  .then((value) {
                                if (value == true) {
                                  ShowToastDialog.closeLoader();
                                  ShowToastDialog.showToast(
                                      "Ride hold has ended".tr);
                                }
                              });
                              await FireStoreUtils.getCustomer(
                                      orderModel.userId.toString())
                                  .then((value) async {
                                if (value != null) {
                                  await SendNotification.sendOneNotification(
                                      token: value.fcmToken.toString(),
                                      title: 'Ride Hold Ended'.tr,
                                      body:
                                          'Driver has ended the ride hold.'.tr,
                                      payload: {});
                                }
                              });
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationItem(BuildContext context, IconData icon, Color color,
      String text, DarkThemeProvider themeChange) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: themeChange.getThem() ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}

class OtpDialog extends StatefulWidget {
  final OrderModel orderModel;
  final DriverUserModel? driverModel;
  final VoidCallback onSuccess;

  const OtpDialog({
    super.key,
    required this.orderModel,
    required this.driverModel,
    required this.onSuccess,
  });

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color:
                isDark ? Colors.white10 : AppColors.moroccoRed.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative Header Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.moroccoRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                color: AppColors.moroccoRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "OTP Verification".tr,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Get 6-digit OTP form the customer to start the ride.".tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            PinCodeTextField(
              length: 6,
              appContext: context,
              keyboardType: TextInputType.phone,
              textStyle: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              pinTheme: PinTheme(
                fieldHeight: 48,
                fieldWidth: 40,
                activeColor: AppColors.moroccoRed,
                selectedColor: AppColors.moroccoRed,
                inactiveColor:
                    isDark ? Colors.white12 : Colors.grey.withOpacity(0.2),
                activeFillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                inactiveFillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.05),
                selectedFillColor: AppColors.moroccoRed.withOpacity(0.05),
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(12),
                borderWidth: 1.5,
              ),
              enableActiveFill: true,
              cursorColor: AppColors.moroccoRed,
              controller: _otpController,
              animationType: AnimationType.fade,
              onChanged: (value) {},
            ),
            const SizedBox(height: 30),
            ButtonThem.buildButton(
              context,
              title: "Verify & Start Ride".tr,
              bgColors: AppColors.moroccoRed,
              textColor: Colors.white,
              onPress: () async {
                if (widget.orderModel.otp.toString() == _otpController.text) {
                  Get.back();
                  ShowToastDialog.showLoader("Please wait...".tr);
                  widget.orderModel.status = Constant.rideInProgress;

                  await FireStoreUtils.getCustomer(
                          widget.orderModel.userId.toString())
                      .then((value) async {
                    if (value != null && value.fcmToken != null) {
                      await SendNotification.sendOneNotification(
                          token: value.fcmToken.toString(),
                          title: 'Ride Started'.tr,
                          body:
                              'Your ride has officially started. Have a safe journey!'
                                  .tr,
                          payload: {});
                    }
                  });

                  if (widget.driverModel?.ownerId != null) {
                    widget.orderModel.ownerId = widget.driverModel?.ownerId;
                  }

                  await FireStoreUtils.setOrder(widget.orderModel)
                      .then((value) {
                    if (value == true) {
                      ShowToastDialog.closeLoader();
                      ShowToastDialog.showToast(
                          "Customer pickup recognized successfully".tr);
                      widget.onSuccess();
                    }
                  });
                } else {
                  ShowToastDialog.showToast(
                      "Invalid OTP. Please try again.".tr);
                }
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel".tr,
                style: GoogleFonts.outfit(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
