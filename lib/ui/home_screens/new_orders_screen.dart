import 'package:driver/constant/constant.dart';
import 'package:driver/controller/home_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/service_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/ui/home_screens/order_map_screen.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:driver/model/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<HomeController>(
        init: HomeController(),
        dispose: (state) {
          FireStoreUtils().closeStream();
        },
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader(isDarkTheme: themeChange.getThem())
              : controller.driverModel.value.isOnline == false
                  ? Center(
                      child: Text(
                          "You are Now offline so you can't get nearest order."
                              .tr),
                    )
                  : StreamBuilder<List<OrderModel>>(
                      stream: FireStoreUtils().getOrders(
                          controller.driverModel.value,
                          Constant.currentLocation?.latitude,
                          Constant.currentLocation?.longitude),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Constant.loader(
                              isDarkTheme: themeChange.getThem());
                        }
                        if (!snapshot.hasData ||
                            (snapshot.data?.isEmpty ?? true)) {
                          return Center(
                            child: Text("New Rides Not found".tr),
                          );
                        } else {
                          // ordersList = snapshot.data!;
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              OrderModel orderModel = snapshot.data![index];

                              DateTime currentTime = DateTime.now();
                              DateTime currentDate = DateTime.now();
                              DateTime startNightTimeString = DateTime.now();
                              DateTime endNightTimeString = DateTime.now();

                              double amount = 0.0;
                              double finalAmount = 0.0;
                              String startNightTime = "";
                              String endNightTime = "";
                              // double totalNightFare = 0.0;
                              double totalChargeOfMinute = 0.0;
                              double basicFare = 0.0;

                              String formatTime(String? time) {
                                if (time == null || !time.contains(":")) {
                                  return "00:00";
                                }
                                List<String> parts = time.split(':');
                                if (parts.length != 2) return "00:00";
                                return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
                              }

                              String startNightTimeData =
                                  orderModel.service?.prices
                                          ?.firstWhere(
                                            (prices) =>
                                                prices.zoneId ==
                                                    orderModel.zoneId &&
                                                prices.startNightTime != null,
                                            orElse: () => Price(),
                                          )
                                          .startNightTime ??
                                      '0.0';
                              String endNightTimeData =
                                  orderModel.service?.prices
                                          ?.firstWhere(
                                            (prices) =>
                                                prices.zoneId ==
                                                    orderModel.zoneId &&
                                                prices.endNightTime != null,
                                            orElse: () => Price(),
                                          )
                                          .endNightTime ??
                                      '0.0';
                              startNightTime = formatTime(startNightTimeData);
                              endNightTime = formatTime(endNightTimeData);

                              List<String> startParts =
                                  startNightTime.split(':');
                              List<String> endParts = endNightTime.split(':');

                              startNightTimeString = DateTime(
                                  currentDate.year,
                                  currentDate.month,
                                  currentDate.day,
                                  int.parse(startParts[0]),
                                  int.parse(startParts[1]));
                              endNightTimeString = DateTime(
                                  currentDate.year,
                                  currentDate.month,
                                  currentDate.day,
                                  int.parse(endParts[0]),
                                  int.parse(endParts[1]));

                              double durationValueInMinutes = convertToMinutes(
                                  orderModel.duration.toString());
                              double distance = double.tryParse(
                                      orderModel.distance.toString()) ??
                                  0.0;
                              String onAcPerKmRateData = controller.driverModel
                                      .value.vehicleInformation?.rates
                                      ?.firstWhere(
                                        (prices) =>
                                            prices.zoneId ==
                                                orderModel.zoneId &&
                                            prices.nonAcPerKmRate != null,
                                        orElse: () => RateModel(),
                                      )
                                      .nonAcPerKmRate ??
                                  '0.0';
                              String acPerKmRateData = controller.driverModel
                                      .value.vehicleInformation?.rates
                                      ?.firstWhere(
                                        (prices) =>
                                            prices.zoneId ==
                                                orderModel.zoneId &&
                                            prices.acPerKmRate != null,
                                        orElse: () => RateModel(),
                                      )
                                      .acPerKmRate ??
                                  '0.0';
                              String perKmRateData = controller.driverModel
                                      .value.vehicleInformation?.rates
                                      ?.firstWhere(
                                        (prices) =>
                                            prices.zoneId ==
                                                orderModel.zoneId &&
                                            prices.perKmRate != null,
                                        orElse: () => RateModel(),
                                      )
                                      .perKmRate ??
                                  '0.0';
                              double nonAcChargeValue =
                                  double.tryParse(onAcPerKmRateData) ?? 0.0;
                              double acChargeValue =
                                  double.tryParse(acPerKmRateData) ?? 0.0;
                              double kmCharge =
                                  double.tryParse(perKmRateData) ?? 0.0;

                              totalChargeOfMinute = double.parse(
                                      durationValueInMinutes.toString()) *
                                  double.parse(orderModel.service?.prices?.first
                                          .perMinuteCharge ??
                                      '0.0');
                              basicFare = double.parse(orderModel
                                      .service?.prices?.first.basicFareCharge ??
                                  '0.0');

                              if (distance <=
                                  double.parse(orderModel
                                          .service?.prices?.first.basicFare ??
                                      '0.0')) {
                                if (currentTime.isAfter(startNightTimeString) &&
                                    currentTime.isBefore(endNightTimeString)) {
                                  amount = amount *
                                      double.parse(orderModel.service?.prices
                                              ?.first.nightCharge ??
                                          '0.0');
                                } else {
                                  amount = double.parse(orderModel.service
                                          ?.prices?.first.basicFareCharge ??
                                      '0.0');
                                }
                              } else {
                                double distanceValue = double.tryParse(
                                        orderModel.distance.toString()) ??
                                    0.0;
                                double basicFareValue = double.parse(orderModel
                                        .service?.prices?.first.basicFare ??
                                    '0.0');
                                double extraDist =
                                    distanceValue - basicFareValue;

                                double perKmCharge = orderModel
                                            .service?.prices?.first.isAcNonAc ==
                                        true
                                    ? orderModel.isAcSelected == false
                                        ? nonAcChargeValue
                                        : acChargeValue
                                    : kmCharge;
                                amount = (perKmCharge * extraDist);

                                if (currentTime.isAfter(startNightTimeString) &&
                                    currentTime.isBefore(endNightTimeString)) {
                                  amount = amount *
                                      double.parse(orderModel.service?.prices
                                              ?.first.nightCharge ??
                                          '0.0');
                                  totalChargeOfMinute = totalChargeOfMinute *
                                      double.parse(orderModel.service?.prices
                                              ?.first.nightCharge ??
                                          '0.0');
                                  basicFare = basicFare *
                                      double.parse(orderModel.service?.prices
                                              ?.first.nightCharge ??
                                          '0.0');
                                }
                              }

                              finalAmount =
                                  amount + basicFare + totalChargeOfMinute;

                              return _buildOrderCard(context, orderModel,
                                  themeChange, finalAmount, controller);
                            },
                          );
                        }
                      });
        });
  }

  Widget _buildOrderCard(
      BuildContext context,
      OrderModel orderModel,
      DarkThemeProvider themeChange,
      double finalAmount,
      HomeController controller) {
    return FutureBuilder<UserModel?>(
      future: FireStoreUtils.getCustomer(orderModel.userId.toString()),
      builder: (context, snapshot) {
        UserModel? customer = snapshot.data;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: InkWell(
            onTap: () {
              Get.to(const OrderMapScreen(),
                      arguments: {"orderModel": orderModel.id.toString()})!
                  .then((value) {
                if (value != null && value == true) {
                  controller.selectedIndex.value = 1;
                }
              });
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
                              _buildInfoRow(
                                Icons.payments_rounded,
                                Constant.amountShow(
                                    amount:
                                        (orderModel.service!.offerRate == true
                                                ? finalAmount
                                                : double.tryParse(orderModel
                                                        .offerRate
                                                        .toString()) ??
                                                    0.0)
                                            .toString()),
                                AppColors.moroccoGreen,
                              ),
                              const SizedBox(height: 4),
                              _buildInfoRow(
                                Icons.straighten_rounded,
                                "${double.parse(orderModel.distance.toString()).toStringAsFixed(Constant.currencyModel!.decimalDigits!)} ${Constant.distanceType}",
                                Colors.blueGrey,
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

                  // Bottom Section: Map Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(const OrderMapScreen(), arguments: {
                              "orderModel": orderModel.id.toString()
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.moroccoGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.map_rounded,
                                    size: 18, color: AppColors.moroccoRed),
                                const SizedBox(width: 6),
                                Text(
                                  "Map".tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.moroccoRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (orderModel.isAcSelected == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.moroccoGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.ac_unit,
                                    size: 14, color: AppColors.moroccoGreen),
                                const SizedBox(width: 4),
                                Text(
                                  "AC".tr,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.moroccoGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  double convertToMinutes(String duration) {
    double durationValue = 0.0;

    try {
      final RegExp hoursRegex = RegExp(r"(\d+)\s*hour");
      final RegExp minutesRegex = RegExp(r"(\d+)\s*min");

      final Match? hoursMatch = hoursRegex.firstMatch(duration);
      if (hoursMatch != null) {
        int hours = int.parse(hoursMatch.group(1)!.trim());
        durationValue += hours * 60;
      }

      final Match? minutesMatch = minutesRegex.firstMatch(duration);
      if (minutesMatch != null) {
        int minutes = int.parse(minutesMatch.group(1)!.trim());
        durationValue += minutes;
      }
    } catch (e) {
      print("Exception: $e");
      throw FormatException("Invalid duration format: $duration");
    }

    return durationValue;
  }
}
