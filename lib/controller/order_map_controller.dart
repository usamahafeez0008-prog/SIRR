import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart' as cloudFirestore;
import 'package:driver/constant/collection_name.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/send_notification.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/order/driverId_accept_reject.dart';
import 'package:driver/model/order_model.dart';
import 'package:driver/model/owner_user_model.dart';
import 'package:driver/model/user_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart' as prefix;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as location;
import 'package:http/http.dart' as http;

class OrderMapController extends GetxController {
  RxBool isHideButtomSheet = false.obs;
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  final flutterMap.MapController osmMapController = flutterMap.MapController();
  Rx<TextEditingController> enterOfferRateController = TextEditingController().obs;

  RxBool isLoading = true.obs;
  DateTime currentTime = DateTime.now();
  DateTime currentDate = DateTime.now();
  DateTime startNightTimeString = DateTime.now();
  DateTime endNightTimeString = DateTime.now();

  @override
  void onInit() {
    addMarkerSetup();
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {
    ShowToastDialog.closeLoader();
    super.onClose();
  }

  Future<void> acceptOrder() async {
    if ((driverModel.value.ownerId == null && double.parse(driverModel.value.walletAmount.toString()) >= double.parse(Constant.minimumDepositToRideAccept)) || (driverModel.value.ownerId != null)) {
      ShowToastDialog.showLoader("Please wait".tr);
      List<dynamic> newAcceptedDriverId = [];
      if (orderModel.value.acceptedDriverId != null) {
        newAcceptedDriverId = orderModel.value.acceptedDriverId!;
      } else {
        newAcceptedDriverId = [];
      }
      newAcceptedDriverId.add(FireStoreUtils.getCurrentUid());
      orderModel.value.acceptedDriverId = newAcceptedDriverId;
      if (orderModel.value.isAcSelected == true) {
        String acPerKmRateData = driverModel.value.vehicleInformation?.rates
                ?.firstWhere(
                  (prices) => prices.zoneId == orderModel.value.zoneId && prices.acPerKmRate != null,
                  orElse: () => RateModel(),
                )
                .acPerKmRate ??
            '0.0';
        orderModel.value.acNonAcCharges = acPerKmRateData;
      } else {
        String nonAcPerKmRateData = driverModel.value.vehicleInformation?.rates
                ?.firstWhere(
                  (prices) => prices.zoneId == orderModel.value.zoneId && prices.nonAcPerKmRate != null,
                  orElse: () => RateModel(),
                )
                .nonAcPerKmRate ??
            '0.0';
        orderModel.value.acNonAcCharges = nonAcPerKmRateData;
      }
      if (driverModel.value.ownerId != null) {
        orderModel.value.ownerId = driverModel.value.ownerId;
      }
      await FireStoreUtils.setOrder(orderModel.value);

      await FireStoreUtils.getCustomer(orderModel.value.userId.toString()).then((value) async {
        if (value != null) {
          await SendNotification.sendOneNotification(
              token: value.fcmToken.toString(),
              title: 'New Driver Bid'.tr,
              body: 'Driver has offered ${Constant.amountShow(amount: finalAmount.value.toString())} for your journey.🚗'.tr,
              payload: {});
        }
      });

      DriverIdAcceptReject driverIdAcceptReject =
          DriverIdAcceptReject(driverId: FireStoreUtils.getCurrentUid(), acceptedRejectTime: cloudFirestore.Timestamp.now(), offerAmount: finalAmount.value.toString());
      FireStoreUtils.acceptRide(orderModel.value, driverIdAcceptReject).then((value) async {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Ride Accepted".tr);
        if (driverModel.value.ownerId == null) {
          if (driverModel.value.subscriptionTotalOrders != "-1") {
            driverModel.value.subscriptionTotalOrders = (int.parse(driverModel.value.subscriptionTotalOrders.toString()) - 1).toString();
            await FireStoreUtils.updateDriverUser(driverModel.value);
          }
        } else {
          OwnerUserModel? ownerUserModel = await FireStoreUtils.getOwnerProfile(driverModel.value.ownerId!);
          if (ownerUserModel?.subscriptionTotalOrders != "-1") {
            ownerUserModel?.subscriptionTotalOrders = (int.parse(ownerUserModel.subscriptionTotalOrders.toString()) - 1).toString();
            await FireStoreUtils.updateOwnerUser(ownerUserModel!);
          }
        }
        Get.back(result: true);
      });
    } else {
      ShowToastDialog.showToast("You have to minimum ${Constant.amountShow(amount: Constant.minimumDepositToRideAccept)} wallet amount to Accept Order and place a bid".tr);
    }
  }

  Rx<OrderModel> orderModel = OrderModel().obs;
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  Rx<UserModel> usermodel = UserModel().obs;

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      String orderId = argumentData['orderModel'];
      await getData(orderId);
      if (Constant.selectedMapType == 'google') {
        getPolyline();
      }
    }

    FireStoreUtils.fireStore.collection(CollectionName.driverUsers).doc(FireStoreUtils.getCurrentUid()).snapshots().listen((event) async {
      if (event.exists) {
        driverModel.value = DriverUserModel.fromJson(event.data()!);
        calculateAmount();
      }
    });

    isLoading.value = false;
    if (Constant.selectedMapType == 'osm') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getOSMPolyline();
      });
    }
  }

  Future<void> getData(String id) async {
    await FireStoreUtils.getOrder(id).then((value) {
      if (value != null) {
        orderModel.value = value;
      }
    });
    await FireStoreUtils.getCustomer(orderModel.value.userId ?? '').then((value) {
      if (value != null) {
        usermodel.value = value;
      }
    });
  }

  RxDouble amount = 0.0.obs;
  RxDouble finalAmount = 0.0.obs;
  RxString startNightTime = "".obs;
  RxString endNightTime = "".obs;
  RxDouble totalNightFare = 0.0.obs;
  RxDouble totalChargeOfMinute = 0.0.obs;
  RxDouble basicFare = 0.0.obs;

  Future<void> calculateAmount() async {
    String formatTime(String? time) {
      if (time == null || !time.contains(":")) {
        return "00:00";
      }
      List<String> parts = time.split(':');
      if (parts.length != 2) return "00:00";
      return "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
    }

    startNightTime.value = formatTime(orderModel.value.service?.prices?.first.startNightTime);
    endNightTime.value = formatTime(orderModel.value.service?.prices?.first.endNightTime);

    List<String> startParts = startNightTime.split(':');
    List<String> endParts = endNightTime.split(':');

    startNightTimeString = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(startParts[0]), int.parse(startParts[1]));
    endNightTimeString = DateTime(currentDate.year, currentDate.month, currentDate.day, int.parse(endParts[0]), int.parse(endParts[1]));

    double durationValueInMinutes = convertToMinutes(orderModel.value.duration.toString());
    double distance = double.tryParse(orderModel.value.distance.toString()) ?? 0.0;
    String nonAcPerKmRateData = driverModel.value.vehicleInformation?.rates
            ?.firstWhere(
              (prices) => prices.zoneId == orderModel.value.zoneId && prices.nonAcPerKmRate != null,
              orElse: () => RateModel(),
            )
            .nonAcPerKmRate ??
        '0.0';
    String acPerKmRateData = driverModel.value.vehicleInformation?.rates
            ?.firstWhere(
              (prices) => prices.zoneId == orderModel.value.zoneId && prices.acPerKmRate != null,
              orElse: () => RateModel(),
            )
            .acPerKmRate ??
        '0.0';
    String perKmRateData = driverModel.value.vehicleInformation?.rates
            ?.firstWhere(
              (prices) => prices.zoneId == orderModel.value.zoneId && prices.perKmRate != null,
              orElse: () => RateModel(),
            )
            .perKmRate ??
        '0.0';
    double nonAcChargeValue = double.tryParse(nonAcPerKmRateData) ?? 0.0;
    double acChargeValue = double.tryParse(acPerKmRateData) ?? 0.0;
    double kmCharge = double.tryParse(perKmRateData) ?? 0.0;

    totalChargeOfMinute.value = double.parse(durationValueInMinutes.toString()) * double.parse(orderModel.value.service?.prices?.first.perMinuteCharge ?? '0.0');
    basicFare.value = double.parse(orderModel.value.service?.prices?.first.basicFareCharge ?? '0.0');

    if (distance <= double.parse(orderModel.value.service?.prices?.first.basicFare ?? '0.0')) {
      if (currentTime.isAfter(startNightTimeString) && currentTime.isBefore(endNightTimeString)) {
        amount.value = amount.value * double.parse(orderModel.value.service?.prices?.first.nightCharge ?? '0.0');
      } else {
        amount.value = double.parse(orderModel.value.service?.prices?.first.basicFareCharge ?? '0.0');
      }
    } else {
      double distanceValue = double.tryParse(orderModel.value.distance.toString()) ?? 0.0;
      double basicFareValue = double.parse(orderModel.value.service?.prices?.first.basicFare ?? '0.0');
      double extraDist = distanceValue - basicFareValue;

      double perKmCharge = orderModel.value.service?.prices?.first.isAcNonAc == true
          ? orderModel.value.isAcSelected == false
              ? nonAcChargeValue
              : acChargeValue
          : kmCharge;
      amount.value = (perKmCharge * extraDist);

      if (currentTime.isAfter(startNightTimeString) && currentTime.isBefore(endNightTimeString)) {
        amount.value = amount.value * double.parse(orderModel.value.service?.prices?.first.nightCharge ?? '0.0');
        totalChargeOfMinute.value = totalChargeOfMinute.value * double.parse(orderModel.value.service?.prices?.first.nightCharge ?? '0.0');
        basicFare.value = basicFare.value * double.parse(orderModel.value.service?.prices?.first.nightCharge ?? '0.0');
      }
    }

    finalAmount.value = amount.value + basicFare.value + totalChargeOfMinute.value;
    enterOfferRateController.value.text = amount.value.toStringAsFixed(2);
  }

  BitmapDescriptor? departureIcon;
  BitmapDescriptor? destinationIcon;

  Future<void> addMarkerSetup() async {
    if (Constant.selectedMapType == 'google') {
      final Uint8List departure = await Constant().getBytesFromAsset('assets/images/pickup.png', 100);
      final Uint8List destination = await Constant().getBytesFromAsset('assets/images/dropoff.png', 100);
      departureIcon = BitmapDescriptor.fromBytes(departure);
      destinationIcon = BitmapDescriptor.fromBytes(destination);
    }
  }

  RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
  RxMap<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{}.obs;
  PolylinePoints polylinePoints = PolylinePoints(
    apiKey: Constant.mapAPIKey,
  );

  void getOSMPolyline() async {
    if (orderModel.value.sourceLocationLAtLng != null && orderModel.value.destinationLocationLAtLng != null) {
      source.value = location.LatLng(orderModel.value.sourceLocationLAtLng!.latitude ?? 0.0, orderModel.value.sourceLocationLAtLng!.longitude ?? 0.0);
      destination.value = location.LatLng(orderModel.value.destinationLocationLAtLng!.latitude ?? 0.0, orderModel.value.destinationLocationLAtLng!.longitude ?? 0.0);
      fetchRoute(source.value, destination.value);
      animateToSource();
    }
  }

  void getPolyline() async {
    if (orderModel.value.sourceLocationLAtLng != null && orderModel.value.destinationLocationLAtLng != null) {
      movePosition();
      List<LatLng> polylineCoordinates = [];
      PolylineRequest polylineRequest = PolylineRequest(
        origin: PointLatLng(orderModel.value.sourceLocationLAtLng!.latitude ?? 0.0, orderModel.value.sourceLocationLAtLng!.longitude ?? 0.0),
        destination: PointLatLng(orderModel.value.destinationLocationLAtLng!.latitude ?? 0.0, orderModel.value.destinationLocationLAtLng!.longitude ?? 0.0),
        mode: TravelMode.driving,
      );
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: polylineRequest,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print(result.errorMessage.toString());
      }
      _addPolyLine(polylineCoordinates);
      addMarker(LatLng(orderModel.value.sourceLocationLAtLng!.latitude ?? 0.0, orderModel.value.sourceLocationLAtLng!.longitude ?? 0.0), "Source", departureIcon);
      addMarker(LatLng(orderModel.value.destinationLocationLAtLng!.latitude ?? 0.0, orderModel.value.destinationLocationLAtLng!.longitude ?? 0.0), "Destination", destinationIcon);
    }
  }

  double zoomLevel = 0;

  Future<void> movePosition() async {
    double distance = double.parse((prefix.Geolocator.distanceBetween(
              orderModel.value.sourceLocationLAtLng!.latitude ?? 0.0,
              orderModel.value.sourceLocationLAtLng!.longitude ?? 0.0,
              orderModel.value.destinationLocationLAtLng!.latitude ?? 0.0,
              orderModel.value.destinationLocationLAtLng!.longitude ?? 0.0,
            ) /
            1609.32)
        .toString());
    LatLng center = LatLng(
      (orderModel.value.sourceLocationLAtLng!.latitude! + orderModel.value.destinationLocationLAtLng!.latitude!) / 2,
      (orderModel.value.sourceLocationLAtLng!.longitude! + orderModel.value.destinationLocationLAtLng!.longitude!) / 2,
    );

    double radiusElevated = (distance / 2) + ((distance / 2) / 2);
    double scale = radiusElevated / 500;

    zoomLevel = 5 - log(scale) / log(2);

    final GoogleMapController controller = await mapController.future;
    controller.moveCamera(CameraUpdate.newLatLngZoom(center, zoomLevel));
  }

  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      points: polylineCoordinates,
      width: 6,
    );
    polyLines[id] = polyline;
  }

  void addMarker(LatLng? position, String id, BitmapDescriptor? descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor!, position: position!);
    markers[markerId] = marker;
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

  Rx<location.LatLng> current = location.LatLng(21.1800, 72.8400).obs;
  Rx<location.LatLng> source = location.LatLng(21.1702, 72.8311).obs; // Start (e.g., Surat)
  Rx<location.LatLng> destination = location.LatLng(21.2000, 72.8600).obs; // Destination

  RxList<location.LatLng> routePoints = <location.LatLng>[].obs;

  Future<void> fetchRoute(location.LatLng source, location.LatLng destination) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/${source.longitude},${source.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final geometry = decoded['routes'][0]['geometry']['coordinates'];

      routePoints.clear();
      for (var coord in geometry) {
        final lon = coord[0];
        final lat = coord[1];
        routePoints.add(location.LatLng(lat, lon));
      }
    } else {
      print("Failed to get route: ${response.body}");
    }
  }

  Future<void> animateToSource() async {
    await calculateZoomLevel(
      source: source.value,
      destination: destination.value,
    );
  }

  Future<void> calculateZoomLevel({required location.LatLng source, required location.LatLng destination, double paddingFraction = 0.001}) async {
    final bounds = flutterMap.LatLngBounds.fromPoints([source, destination]);
    final screenSize = Size(Get.width, Get.height * 0.5);
    const double worldDimension = 256.0;
    const double maxZoom = 22.0;

    double latToRad(double lat) => math.log((1 + math.sin(lat * math.pi / 180)) / (1 - math.sin(lat * math.pi / 180))) / 2;

    double computeZoom(double screenPx, double worldPx, double fraction) => math.log(screenPx / worldPx / fraction) / math.ln2;

    final north = bounds.northEast.latitude;
    final south = bounds.southWest.latitude;
    final east = bounds.northEast.longitude;
    final west = bounds.southWest.longitude;

    final latDelta = (north - south).abs();
    final lngDelta = (east - west).abs();

    final center = bounds.center;

    if (latDelta < 1e-6 || lngDelta < 1e-6) {
      osmMapController.move(center, maxZoom);
    } else {
      final latFraction = (latToRad(north) - latToRad(south)) / math.pi;
      final lngFraction = ((east - west + 360) % 360) / 360;

      final latZoom = computeZoom(screenSize.height, worldDimension, latFraction + paddingFraction);
      final lngZoom = computeZoom(screenSize.width, worldDimension, lngFraction + paddingFraction);

      final zoomLevel = math.min(latZoom, lngZoom).clamp(0.0, maxZoom);
      const centerOffsetFactor = 1.0; // increase for higher upward push
      final offsetLat = center.latitude - latDelta * centerOffsetFactor;
      final centerdata = location.LatLng(offsetLat, center.longitude);
      osmMapController.move(centerdata, zoomLevel);
    }
  }
}
