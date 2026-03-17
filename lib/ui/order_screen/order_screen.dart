import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/order_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/model/wallet_transaction_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/ui/chat_screen/chat_screen.dart';
import 'package:driver/ui/order_screen/complete_order_screen.dart';
import 'package:driver/ui/review/review_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetX<OrderController>(
        init: OrderController(),
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader(isDarkTheme: isDark)
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(CollectionName.orders)
                      .where('driverId',
                          isEqualTo: FireStoreUtils.getCurrentUid())
                      .orderBy("createdDate", descending: true)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Something went wrong'.tr));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Constant.loader(isDarkTheme: isDark);
                    }

                    return snapshot.data!.docs.isEmpty
                        ? Center(
                            child: Text("No Ride found".tr),
                          )
                        : ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(left: 0, right: 0, top: 0, bottom:40),
                            itemBuilder: (context, index) {
                              OrderModel orderModel = OrderModel.fromJson(
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>);
                              return _buildRideHistoryCard(
                                  context, orderModel, isDark, controller);
                            });
                  },
                );
        });
  }

  Widget _buildRideHistoryCard(BuildContext context, OrderModel orderModel,
      bool isDark, OrderController controller) {
    return FutureBuilder<UserModel?>(
      future: FireStoreUtils.getCustomer(orderModel.userId.toString()),
      builder: (context, snapshot) {
        UserModel? customer = snapshot.data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkContainerBackground : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
              border: Border.all(
                color: isDark
                    ? AppColors.darkContainerBorder.withOpacity(0.5)
                    : AppColors.containerBorder.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                Get.to(const CompleteOrderScreen(), arguments: {
                  "orderModel": orderModel,
                });
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
                              Row(
                                children: [
                                  _buildStatusBadge(
                                      orderModel.status.toString(), isDark),
                                  const Spacer(),
                                  Text(
                                    Constant().formatTimestamp(
                                        orderModel.createdDate),
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                customer?.fullName ?? 'Loading...'.tr,
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
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
                            height: 70,
                            width: 70,
                            imageUrl: customer?.profilePic ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDark ? Colors.white10 : Colors.grey[100],
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) => Image.network(
                              Constant.userPlaceHolder,
                              height: 70,
                              width: 70,
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
                          Icons.circle,
                          AppColors.moroccoGreen,
                          orderModel.sourceLocationName.toString(),
                          isDark,
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                              children: List.generate(
                                2,
                                (index) => Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
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
                        _buildLocationItem(
                          Icons.location_on_rounded,
                          AppColors.moroccoRed,
                          orderModel.destinationLocationName.toString(),
                          isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Bottom Section: Actions
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ButtonThem.buildBorderButton(
                                context,
                                title: "Review".tr,
                                btnHeight: 44,
                                iconVisibility: false,
                                onPress: () async {
                                  Get.to(const ReviewScreen(), arguments: {
                                    "type": "orderModel",
                                    "orderModel": orderModel,
                                  });
                                },
                              ),
                            ),
                            if (orderModel.status != Constant.rideComplete) ...[
                              const SizedBox(width: 10),
                              _buildActionButton(
                                onTap: () async {
                                  UserModel? customer =
                                      await FireStoreUtils.getCustomer(
                                          orderModel.userId.toString());
                                  DriverUserModel? driver =
                                      await FireStoreUtils.getDriverProfile(
                                          orderModel.driverId.toString());

                                  Get.to(ChatScreens(
                                    driverId: driver!.id,
                                    customerId: customer!.id,
                                    customerName: customer.fullName,
                                    customerProfileImage: customer.profilePic,
                                    driverName: driver.fullName,
                                    driverProfileImage: driver.profilePic,
                                    orderId: orderModel.id,
                                    token: customer.fcmToken,
                                  ));
                                },
                                icon: Icons.chat_rounded,
                                color: isDark
                                    ? AppColors.moroccoRed
                                    : AppColors.moroccoRed,
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
                                color: Colors.blueAccent,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Payment Status / Confirm Cash
                        if (controller.paymentModel.value.cash?.name ==
                                orderModel.paymentType.toString() &&
                            orderModel.paymentStatus == false)
                          ButtonThem.buildButton(
                            context,
                            title: "Confirm cash payment".tr,
                            btnHeight: 44,
                            bgColors: AppColors.moroccoGreen,
                            textColor: Colors.white,
                            onPress: () async {
                              ShowToastDialog.showLoader("Please wait..".tr);
                              orderModel.paymentStatus = true;
                              orderModel.status = Constant.rideComplete;
                              orderModel.updateDate = Timestamp.now();

                              String? couponAmount = "0.0";
                              if (orderModel.coupon != null) {
                                if (orderModel.coupon?.code != null) {
                                  if (orderModel.coupon!.type == "fix") {
                                    couponAmount =
                                        orderModel.coupon!.amount.toString();
                                  } else {
                                    couponAmount = ((double.parse(orderModel
                                                    .finalRate
                                                    .toString()) *
                                                double.parse(orderModel
                                                    .coupon!.amount
                                                    .toString())) /
                                            100)
                                        .toString();
                                  }
                                }
                              }

                              await FireStoreUtils.getDriverFirstOrderOrNot(
                                      driverId: orderModel.driverId!,
                                      orderType: 'order')
                                  .then((value) async {
                                if (value == true) {
                                  await FireStoreUtils
                                      .updateDriverReferralAmount(orderModel);
                                }
                              });

                              await FireStoreUtils.getCustomerFirstOrderOrNot(
                                      customerId: orderModel.userId!,
                                      orderType: 'order')
                                  .then((value) async {
                                if (value == true) {
                                  await FireStoreUtils.updateReferralAmount(
                                      orderModel);
                                }
                              });

                              await FireStoreUtils.getCustomer(
                                      orderModel.userId.toString())
                                  .then((value) async {
                                if (value != null) {
                                  await SendNotification.sendOneNotification(
                                      token: value.fcmToken.toString(),
                                      title: 'Cash Payment confirmed'.tr,
                                      body:
                                          'Driver has confirmed your cash payment'
                                              .tr,
                                      payload: {});
                                }
                              });

                              if (orderModel.adminCommission?.amount != '0' &&
                                  orderModel.adminCommission?.amount != '0.0' &&
                                  orderModel.adminCommission?.amount != null) {
                                WalletTransactionModel adminCommissionWallet =
                                    WalletTransactionModel(
                                        id: Constant.getUuid(),
                                        amount:
                                            "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.finalRate.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}",
                                        createdDate: Timestamp.now(),
                                        paymentType: "wallet".tr,
                                        transactionId: orderModel.id,
                                        orderType: "city",
                                        userType: orderModel.ownerId == null
                                            ? "driver"
                                            : 'owner',
                                        userId: orderModel.ownerId == null
                                            ? orderModel.driverId.toString()
                                            : orderModel.ownerId.toString(),
                                        note: "Admin commission debited".tr);

                                await FireStoreUtils.setWalletTransaction(
                                    adminCommissionWallet);
                                if (orderModel.ownerId == null) {
                                  await FireStoreUtils.updatedDriverWallet(
                                      amount:
                                          "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.finalRate.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}");
                                } else {
                                  await FireStoreUtils.updatedOwnerWallet(
                                      ownerId: orderModel.ownerId!,
                                      amount:
                                          "-${Constant.calculateAdminCommission(amount: (double.parse(orderModel.finalRate.toString()) - double.parse(couponAmount.toString())).toString(), adminCommission: orderModel.adminCommission)}");
                                }
                              }
                              await FireStoreUtils.setOrder(orderModel)
                                  .then((value) async {
                                ShowToastDialog.closeLoader();
                                if (value == true) {
                                  ShowToastDialog.showToast(
                                      "Payment Confirm successfully".tr);
                                }
                              });
                            },
                          )
                        else
                          _buildPaymentStatusIndicator(
                              orderModel.paymentStatus == true, isDark),


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

  Widget _buildStatusBadge(String status, bool isDark) {
    Color color;
    switch (status) {
      case Constant.rideComplete:
        color = AppColors.moroccoGreen;
        break;
      case Constant.rideInProgress:
        color = Colors.orange;
        break;
      default:
        color = AppColors.moroccoRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.tr,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusIndicator(bool isCompleted, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.moroccoGreen.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: 18,
            color: isCompleted ? AppColors.moroccoGreen : Colors.orange,
          ),
          const SizedBox(width: 8),
          Text(
            isCompleted ? "Payment completed".tr : "Payment Pending".tr,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCompleted ? AppColors.moroccoGreen : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
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

  Widget _buildLocationItem(
      IconData icon, Color color, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
