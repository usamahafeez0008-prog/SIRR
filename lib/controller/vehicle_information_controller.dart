import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/model/driver_rules_model.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/model/service_model.dart';
import 'package:driver/model/zone_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class VehicleInformationController extends GetxController {
  Rx<TextEditingController> vehicleNumberController = TextEditingController().obs;
  Rx<TextEditingController> seatsController = TextEditingController().obs;
  Rx<TextEditingController> registrationDateController = TextEditingController().obs;
  Rx<TextEditingController> driverRulesController = TextEditingController().obs;
  Rx<TextEditingController> zoneNameController = TextEditingController().obs;
  RxList<TextEditingController> acPerKmRate = <TextEditingController>[].obs;
  RxList<TextEditingController> nonAcPerKmRate = <TextEditingController>[].obs;
  RxList<TextEditingController> acNonAcWithoutPerKmRate = <TextEditingController>[].obs;
  Rx<DateTime?> selectedDate = DateTime.now().obs;

  RxBool isLoading = true.obs;

  Rx<String> selectedColor = "".obs;
  List<String> carColorList = <String>['Red', 'Black', 'White', 'Blue', 'Green', 'Orange', 'Silver', 'Gray', 'Yellow', 'Brown', 'Gold', 'Beige', 'Purple'].obs;
  List<String> sheetList = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15'].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getVehicleTye();
    super.onInit();
  }

  var colors = [
    AppColors.serviceColor1,
    AppColors.serviceColor2,
    AppColors.serviceColor3,
  ];
  Rx<DriverUserModel> driverModel = DriverUserModel().obs;
  RxList<DriverRulesModel> driverRulesList = <DriverRulesModel>[].obs;
  RxList<DriverRulesModel> selectedDriverRulesList = <DriverRulesModel>[].obs;

  RxList<ServiceModel> serviceList = <ServiceModel>[].obs;
  Rx<ServiceModel> selectedServiceType = ServiceModel().obs;
  RxList<ZoneModel> zoneAllList = <ZoneModel>[].obs;
  RxList<ZoneModel> zoneList = <ZoneModel>[].obs;
  RxList selectedTempZone = <String>[].obs;
  RxList selectedZone = <String>[].obs;
  RxString zoneString = "".obs;
  RxList<Price> selectedPrices = <Price>[].obs;

  Future<void> getVehicleTye() async {
    await FireStoreUtils.getService().then((value) {
      serviceList.value = value;
    });

    await FireStoreUtils.getZone().then((value) {
      if (value != null) {
        zoneAllList.value = value;
      }
    });

    await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid()).then((value) async {
      if (value != null) {
        driverModel.value = value;
        if (driverModel.value.vehicleInformation != null) {
          vehicleNumberController.value.text = driverModel.value.vehicleInformation!.vehicleNumber.toString();
          selectedDate.value = driverModel.value.vehicleInformation!.registrationDate!.toDate();
          registrationDateController.value.text = DateFormat("dd-MM-yyyy").format(selectedDate.value!);
          selectedColor.value = driverModel.value.vehicleInformation!.vehicleColor.toString();
          seatsController.value.text = driverModel.value.vehicleInformation!.seats ?? "2";
          selectedServiceType.value = await FireStoreUtils.getServiceById(driverModel.value.serviceId);
          zoneList.clear();
          final priceIds = selectedServiceType.value.prices!.map((p) => p.zoneId).toSet();
          zoneList.addAll(zoneAllList.where((z) => priceIds.contains(z.id)));
          if (driverModel.value.zoneIds != null) {
            if (zoneList.isNotEmpty) {
              for (var element in zoneList) {
                if (driverModel.value.zoneIds?.contains(element.id.toString()) == true) {
                  zoneString.value = "${zoneString.value}${zoneString.value.isEmpty ? "" : ","} ${Constant.localizationName(element.name)}";
                  selectedZone.add(element.id);
                }
              }
            }
            zoneNameController.value.text = zoneString.value;
            selectedPrices.value = selectedServiceType.value.prices?.where((price) => selectedZone.contains(price.zoneId)).toList() ?? <Price>[];
            acPerKmRate.value = List.generate(selectedPrices.length, (index) => TextEditingController());
            nonAcPerKmRate.value = List.generate(selectedPrices.length, (index) => TextEditingController());
            acNonAcWithoutPerKmRate.value = List.generate(selectedPrices.length, (index) => TextEditingController());

            for (int index = 0; index < driverModel.value.vehicleInformation!.rates!.length; index++) {
              if (driverModel.value.vehicleInformation!.rates?[index].acPerKmRate != null) {
                acPerKmRate[index].text = driverModel.value.vehicleInformation!.rates?[index].acPerKmRate ?? '';
                acNonAcWithoutPerKmRate[index].text = driverModel.value.vehicleInformation!.rates?[index].perKmRate ?? '';
                nonAcPerKmRate[index].text = driverModel.value.vehicleInformation!.rates?[index].nonAcPerKmRate ?? '';
              } else {
                nonAcPerKmRate[index].text = driverModel.value.vehicleInformation!.rates?[index].nonAcPerKmRate ?? '';
                acNonAcWithoutPerKmRate[index].text = driverModel.value.vehicleInformation!.rates?[index].perKmRate ?? '';
              }
            }
          }
          tabBarheight.value = selectedPrices.first.isAcNonAc == true ? 200 : 100;
        }
        if (driverModel.value.zoneIds == null) {
          selectedServiceType.value = serviceList.first;
          getZone();
        }
      }
    });

    await FireStoreUtils.getDriverRules().then((value) {
      if (value != null) {
        driverRulesList.value = value;
        if (driverModel.value.vehicleInformation != null) {
          if (driverModel.value.vehicleInformation!.driverRules != null) {
            for (var element in driverModel.value.vehicleInformation!.driverRules!) {
              selectedDriverRulesList.add(element);
            }
          }
        }
      }
    });
    isLoading.value = false;
    update();
  }

  void getZone() {
    selectedZone.value = <String>[];
    zoneNameController.value.text = '';
    selectedPrices.clear();
    zoneList.clear();
    final priceIds = selectedServiceType.value.prices!.map((p) => p.zoneId).toSet();
    zoneList.addAll(zoneAllList.where((z) => priceIds.contains(z.id)));
  }

  void setVehicleDetails() {
    if (driverModel.value.serviceId == null) {
      driverModel.value.serviceId = selectedServiceType.value.id;
      driverModel.value.serviceName = selectedServiceType.value.title;
    }
    driverModel.value.zoneIds = selectedZone;
    List<RateModel>? rates = <RateModel>[];
    for (int index = 0; index < selectedPrices.length; index++) {
      rates.add(RateModel(
        acPerKmRate: acPerKmRate[index].value.text,
        nonAcPerKmRate: nonAcPerKmRate[index].text,
        perKmRate: acNonAcWithoutPerKmRate[index].text,
        zoneId: selectedPrices[index].zoneId,
      ));
    }

    driverModel.value.vehicleInformation = VehicleInformation(
        registrationDate: Timestamp.fromDate(selectedDate.value!),
        vehicleColor: selectedColor.value,
        vehicleNumber: vehicleNumberController.value.text,
        seats: seatsController.value.text,
        driverRules: selectedDriverRulesList,
        rates: rates);
  }

  Future<void> saveDetails() async {
    setVehicleDetails();
    await FireStoreUtils.updateDriverUser(driverModel.value).then((value) {
      ShowToastDialog.closeLoader();
      if (value == true) {
        ShowToastDialog.showToast(
          "Information update successfully".tr,
        );
      }
    });
  }

  RxDouble tabBarheight = 200.0.obs;
}
