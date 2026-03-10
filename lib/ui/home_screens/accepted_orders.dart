import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/accepted_orders_controller.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/home_screens/order_map_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AcceptedOrders extends StatelessWidget {
  const AcceptedOrders({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetBuilder<AcceptedOrdersController>(
        init: AcceptedOrdersController(),
        dispose: (state) {
          FireStoreUtils().closeStream();
        },
        builder: (controller) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(CollectionName.orders)
                .where('acceptedDriverId',
                    arrayContains: FireStoreUtils.getCurrentUid())
                .snapshots(),
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
                      child: Text("No accepted ride found".tr),
                    )
                  : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        OrderModel orderModel = OrderModel.fromJson(
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>);
                        return _buildAcceptedOrderCard(
                            context, orderModel, themeChange);
                      });
            },
          );
        });
  }

  Widget _buildAcceptedOrderCard(BuildContext context, OrderModel orderModel,
      DarkThemeProvider themeChange) {
    return FutureBuilder<UserModel?>(
      future: FireStoreUtils.getCustomer(orderModel.userId.toString()),
      builder: (context, snapshot) {
        UserModel? customer = snapshot.data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: InkWell(
            onTap: () {
              Get.to(const OrderMapScreen(),
                  arguments: {"orderModel": orderModel.id.toString()});
            },
            borderRadius: BorderRadius.circular(20),
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
                              // Specific Bid Offer for Accepted Orders
                              FutureBuilder<DriverIdAcceptReject?>(
                                future: FireStoreUtils.getAcceptedOrders(
                                    orderModel.id.toString(),
                                    FireStoreUtils.getCurrentUid()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2));
                                  }
                                  String amountText = snapshot.hasData
                                      ? Constant.amountShow(
                                          amount: snapshot.data!.offerAmount
                                              .toString())
                                      : Constant.amountShow(
                                          amount:
                                              orderModel.offerRate.toString());

                                  return Row(
                                    children: [
                                      _buildInfoRow(
                                        Icons.payments_rounded,
                                        amountText,
                                        AppColors.moroccoGreen,
                                      ),
                                      const SizedBox(width: 15),
                                      _buildInfoRow(
                                        Icons.straighten_rounded,
                                        "${double.parse(orderModel.distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}",
                                        Colors.blueGrey,
                                      ),
                                    ],
                                  );
                                },
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

                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        );
      },
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
