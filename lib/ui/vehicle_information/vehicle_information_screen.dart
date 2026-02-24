import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/constant/show_toast_dialog.dart';
import 'package:driver/controller/vehicle_information_controller.dart';
import 'package:driver/model/service_model.dart';
import 'package:driver/model/zone_model.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/themes/responsive.dart';
import 'package:driver/themes/text_field_them.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class VehicleInformationScreen extends StatelessWidget {
  const VehicleInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    return GetX<VehicleInformationController>(
      init: VehicleInformationController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.lightprimary,
          body: Column(
            children: [
              SizedBox(
                height: Responsive.width(10, context),
                width: Responsive.width(100, context),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))),
                  child: controller.isLoading.value
                      ? Constant.loader(isDarkTheme: themeChange.getThem())
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: Responsive.height(18, context),
                                  child: ListView.builder(
                                    itemCount: controller.serviceList.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      ServiceModel serviceModel = controller.serviceList[index];
                                      return Obx(
                                        () => InkWell(
                                          onTap: () async {
                                            if (controller.driverModel.value.serviceId == null) {
                                              controller.selectedServiceType.value = serviceModel;
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Container(
                                              width: Responsive.width(28, context),
                                              decoration: BoxDecoration(
                                                  color: controller.selectedServiceType.value.id == serviceModel.id
                                                      ? themeChange.getThem()
                                                          ? AppColors.darksecondprimary
                                                          : AppColors.lightsecondprimary
                                                      : themeChange.getThem()
                                                          ? AppColors.darkService
                                                          : controller.colors[index % controller.colors.length],
                                                  borderRadius: const BorderRadius.all(
                                                    Radius.circular(20),
                                                  )),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    decoration: const BoxDecoration(
                                                        color: AppColors.background,
                                                        borderRadius: BorderRadius.all(
                                                          Radius.circular(20),
                                                        )),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: CachedNetworkImage(
                                                        imageUrl: serviceModel.image.toString(),
                                                        fit: BoxFit.contain,
                                                        height: Responsive.height(8, context),
                                                        width: Responsive.width(18, context),
                                                        placeholder: (context, url) => Constant.loader(isDarkTheme: themeChange.getThem()),
                                                        errorWidget: (context, url, error) => Image.network(
                                                            'https://firebasestorage.googleapis.com/v0/b/goride-1a752.appspot.com/o/placeholderImages%2Fuser-placeholder.jpeg?alt=media&token=34a73d67-ba1d-4fe4-a29f-271d3e3ca115'),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(Constant.localizationTitle(serviceModel.title),
                                                      style: GoogleFonts.poppins(
                                                          color: controller.selectedServiceType.value.id == serviceModel.id
                                                              ? themeChange.getThem()
                                                                  ? Colors.black
                                                                  : Colors.white
                                                              : themeChange.getThem()
                                                                  ? Colors.white
                                                                  : Colors.black)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                TextFieldThem.buildTextFiled(context,
                                    enable: controller.driverModel.value.ownerId == null, hintText: 'Vehicle Number'.tr, controller: controller.vehicleNumberController.value),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () async {
                                    if (controller.driverModel.value.ownerId == null) {
                                      await Constant.selectDate(context).then((value) {
                                        if (value != null) {
                                          controller.selectedDate.value = value;
                                          controller.registrationDateController.value.text = DateFormat("dd-MM-yyyy").format(value);
                                        }
                                      });
                                    }
                                  },
                                  child: TextFieldThem.buildTextFiled(context, hintText: 'Registration Date'.tr, controller: controller.registrationDateController.value, enable: false),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                AbsorbPointer(
                                  absorbing: controller.driverModel.value.ownerId != null,
                                  child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                                        contentPadding: const EdgeInsets.only(left: 10, right: 10),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                      ),
                                      validator: (value) => value == null ? 'field required' : null,
                                      value: controller.selectedColor.value.isEmpty ? null : controller.selectedColor.value,
                                      onChanged: (value) {
                                        controller.selectedColor.value = value!;
                                      },
                                      hint: Text("Select vehicle color".tr),
                                      items: controller.carColorList.map((item) {
                                        return DropdownMenuItem(
                                          value: item,
                                          child: Text(item.toString()),
                                        );
                                      }).toList()),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                AbsorbPointer(
                                  absorbing: controller.driverModel.value.ownerId != null,
                                  child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: themeChange.getThem() ? AppColors.darkTextField : AppColors.textField,
                                        contentPadding: const EdgeInsets.only(left: 10, right: 10),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                                          borderSide: BorderSide(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                        ),
                                      ),
                                      validator: (value) => value == null ? 'field required' : null,
                                      value: controller.seatsController.value.text.isEmpty ? null : controller.seatsController.value.text,
                                      onChanged: (value) {
                                        controller.seatsController.value.text = value!;
                                      },
                                      hint: Text("How Many Seats".tr),
                                      items: controller.sheetList.map((item) {
                                        return DropdownMenuItem(
                                          value: item,
                                          child: Text(item.toString()),
                                        );
                                      }).toList()),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (controller.driverModel.value.ownerId == null) {
                                      controller.selectedTempZone.clear();
                                      controller.selectedTempZone.addAll(controller.selectedZone);
                                      zoneDialog(context, controller);
                                    }
                                  },
                                  child: TextFieldThem.buildTextFiled(
                                    context,
                                    hintText: 'Select Zone'.tr,
                                    controller: controller.zoneNameController.value,
                                    enable: false,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                if (controller.selectedPrices.isNotEmpty)
                                  Obx(
                                    () => Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        border: Border.all(color: themeChange.getThem() ? AppColors.darkTextFieldBorder : AppColors.textFieldBorder, width: 1),
                                      ),
                                      width: Responsive.width(100, context),
                                      child: DefaultTabController(
                                        length: controller.selectedPrices.length,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TabBar(
                                              onTap: (value) {
                                                controller.tabBarheight.value = controller.selectedPrices[value].isAcNonAc == true ? 200 : 100;
                                                controller.update();
                                              },
                                              indicatorColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                              padding: EdgeInsets.zero,
                                              isScrollable: true,
                                              labelColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                              unselectedLabelColor: themeChange.getThem() ? AppColors.gray : AppColors.darkGray,
                                              labelStyle: GoogleFonts.poppins(fontSize: 14),
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
                                            SizedBox(
                                              height: controller.tabBarheight.value,
                                              child: TabBarView(
                                                physics: const NeverScrollableScrollPhysics(),
                                                children: controller.selectedPrices.map((price) {
                                                  int index = controller.selectedPrices.indexOf(price);

                                                  if (price.isAcNonAc == true) {
                                                    return Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                      child: SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("A/C Per ${Constant.distanceType} Rate", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15)),
                                                            const SizedBox(height: 5),
                                                            TextFieldThem.buildTextFiledWithPrefixIcon(
                                                              context,
                                                              hintText: 'A/C Per ${Constant.distanceType} Rate'.tr,
                                                              enable: controller.driverModel.value.ownerId == null,
                                                              keyBoardType: const TextInputType.numberWithOptions(decimal: true),
                                                              controller: controller.acPerKmRate[index],
                                                              prefix: Padding(
                                                                padding: const EdgeInsets.only(right: 10),
                                                                child: Text(Constant.currencyModel!.symbol.toString()),
                                                              ),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            Text("Non A/C Per ${Constant.distanceType} Rate", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15)),
                                                            const SizedBox(height: 5),
                                                            TextFieldThem.buildTextFiledWithPrefixIcon(
                                                              context,
                                                              hintText: 'Non A/C Per ${Constant.distanceType} Rate'.tr,
                                                              enable: controller.driverModel.value.ownerId == null,
                                                              keyBoardType: const TextInputType.numberWithOptions(decimal: true),
                                                              controller: controller.nonAcPerKmRate[index],
                                                              prefix: Padding(
                                                                padding: const EdgeInsets.only(right: 10),
                                                                child: Text(Constant.currencyModel!.symbol.toString()),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    return SingleChildScrollView(
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text("Per ${Constant.distanceType} Rate", style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15)),
                                                            const SizedBox(height: 5),
                                                            TextFieldThem.buildTextFiledWithPrefixIcon(
                                                              context,
                                                              enable: controller.driverModel.value.ownerId == null,
                                                              hintText: 'Per ${Constant.distanceType} Rate'.tr,
                                                              keyBoardType: const TextInputType.numberWithOptions(decimal: true),
                                                              controller: controller.acNonAcWithoutPerKmRate[index],
                                                              prefix: Padding(
                                                                padding: const EdgeInsets.only(right: 10),
                                                                child: Text(Constant.currencyModel!.symbol.toString()),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                }).toList(),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text("Select Your Rules".tr, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                                ListBody(
                                  children: controller.driverRulesList
                                      .map((item) => CheckboxListTile(
                                            checkColor: themeChange.getThem() ? AppColors.darksecondprimary : AppColors.lightsecondprimary,
                                            value: controller.selectedDriverRulesList.indexWhere((element) => element.id == item.id) == -1 ? false : true,
                                            title: Text(Constant.localizationName(item.name), style: GoogleFonts.poppins(fontWeight: FontWeight.w400)),
                                            enabled: controller.driverModel.value.ownerId == null,
                                            onChanged: (value) {
                                              if (value == true) {
                                                controller.selectedDriverRulesList.add(item);
                                              } else {
                                                controller.selectedDriverRulesList.removeAt(controller.selectedDriverRulesList.indexWhere((element) => element.id == item.id));
                                              }
                                            },
                                          ))
                                      .toList(),
                                ),
                                controller.driverModel.value.ownerId == null
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: ButtonThem.buildButton(
                                              context,
                                              title: "Save".tr,
                                              onPress: () async {
                                                ShowToastDialog.showLoader("Please wait".tr);

                                                if (controller.selectedServiceType.value.id == null || controller.selectedServiceType.value.id!.isEmpty) {
                                                  ShowToastDialog.showToast("Please select service".tr);
                                                  return;
                                                }

                                                if (controller.vehicleNumberController.value.text.isEmpty) {
                                                  ShowToastDialog.showToast(
                                                    "Please enter Vehicle number".tr,
                                                  );
                                                } else if (controller.registrationDateController.value.text.isEmpty) {
                                                  ShowToastDialog.showToast(
                                                    "Please select registration date".tr,
                                                  );
                                                } else if (controller.selectedColor.value.isEmpty) {
                                                  ShowToastDialog.showToast(
                                                    "Please enter Vehicle color".tr,
                                                  );
                                                } else if (controller.seatsController.value.text.isEmpty) {
                                                  ShowToastDialog.showToast(
                                                    "Please enter seats".tr,
                                                  );
                                                } else if (controller.selectedZone.isEmpty) {
                                                  ShowToastDialog.showToast(
                                                    "Please select Zone".tr,
                                                  );
                                                } else {
                                                  for (int index = 0; index < controller.selectedPrices.length; index++) {
                                                    ZoneModel zoneModel = await FireStoreUtils.getZoneById(zoneId: controller.selectedPrices[index].zoneId!);
                                                    if (controller.selectedPrices[index].isAcNonAc == true) {
                                                      if (controller.acPerKmRate[index].text.isEmpty) {
                                                        ShowToastDialog.showToast(
                                                          "${'Please enter A/C Per'.tr} ${Constant.distanceType} ${'Rate for'.tr} ${Constant.localizationName(zoneModel.name)} ${'Zone'.tr}.".tr,
                                                        );
                                                        return;
                                                      } else if (double.parse(controller.selectedPrices[index].acCharge.toString()) < double.parse(controller.acPerKmRate[index].text)) {
                                                        ShowToastDialog.showToast(
                                                          "${"Maximum allowed value is".tr} ${controller.selectedPrices[index].acCharge.toString()} ${"Please enter a lower A/c value for".tr} ${Constant.localizationName(zoneModel.name)} ${'Zone'.tr}."
                                                              .tr,
                                                        );
                                                        return;
                                                      } else if (controller.nonAcPerKmRate[index].text.isEmpty) {
                                                        ShowToastDialog.showToast(
                                                          "${"Please enter Non A/C Per".tr} ${Constant.distanceType} ${'Rate for'} ${Constant.localizationName(zoneModel.name)} ${'Zone'.tr}.".tr,
                                                        );
                                                        return;
                                                      } else if (double.parse(controller.selectedPrices[index].nonAcCharge.toString()) < double.parse(controller.nonAcPerKmRate[index].text)) {
                                                        ShowToastDialog.showToast(
                                                          "${"Maximum allowed value is".tr} ${controller.selectedPrices[index].nonAcCharge.toString()} ${"Please enter a lower Non A/c value for".tr} ${Constant.localizationName(zoneModel.name)} ${'Zone'.tr}."
                                                              .tr,
                                                        );
                                                        return;
                                                      }
                                                    } else if (controller.selectedPrices[index].isAcNonAc == false) {
                                                      ZoneModel zoneData = await FireStoreUtils.getZoneById(zoneId: controller.selectedPrices[index].zoneId!);
                                                      if (controller.acNonAcWithoutPerKmRate[index].text.isEmpty) {
                                                        ShowToastDialog.showToast(
                                                          "${"Please enter Per".tr} ${Constant.distanceType} ${"Rate for".tr} ${Constant.localizationName(zoneData.name)} ${'Zone'.tr}.".tr,
                                                        );
                                                        return;
                                                      } else if (double.parse(controller.selectedPrices[index].kmCharge.toString()) < double.parse(controller.acNonAcWithoutPerKmRate[index].text)) {
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
                                            ),
                                          ),
                                          if (controller.driverModel.value.ownerId == null)
                                            const SizedBox(
                                              height: 20,
                                            ),
                                        ],
                                      )
                                    : const SizedBox(
                                        height: 10,
                                      ),
                                if (controller.driverModel.value.ownerId == null)
                                  Text("You can not change once you select one service type if you want to change please contact to administrator",
                                      textAlign: TextAlign.center, style: GoogleFonts.poppins()),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void zoneDialog(BuildContext context, VehicleInformationController controller) {
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
                              value: controller.selectedTempZone.contains(controller.zoneList[index].id),
                              onChanged: (value) {
                                if (controller.selectedTempZone.contains(controller.zoneList[index].id)) {
                                  controller.selectedTempZone.remove(controller.zoneList[index].id); // unselect
                                } else {
                                  controller.selectedTempZone.add(controller.zoneList[index].id); // select
                                }
                              },
                              activeColor: AppColors.lightprimary,
                              title: Text(Constant.localizationName(controller.zoneList[index].name)),
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
                  style: TextStyle(),
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
                    controller.selectedPrices.value = controller.selectedServiceType.value.prices?.where((price) => controller.selectedZone.contains(price.zoneId)).toList() ?? <Price>[];
                    controller.acPerKmRate.value = List.generate(controller.selectedPrices.length, (index) => TextEditingController());
                    controller.nonAcPerKmRate.value = List.generate(controller.selectedPrices.length, (index) => TextEditingController());
                    controller.acNonAcWithoutPerKmRate.value = List.generate(controller.selectedPrices.length, (index) => TextEditingController());
                    final hasAcNonAc = controller.selectedPrices.any((e) => e.isAcNonAc == true);
                    controller.tabBarheight.value = hasAcNonAc ? 200 : 100;
                    String nameValue = "";
                    for (var element in controller.selectedZone) {
                      List<ZoneModel> list = controller.zoneList.where((p0) => p0.id == element).toList();
                      if (list.isNotEmpty) {
                        nameValue = "$nameValue${nameValue.isEmpty ? "" : ","} ${Constant.localizationName(list.first.name)}";
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
        });
  }
}
