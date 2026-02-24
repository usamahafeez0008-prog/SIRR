import 'dart:io';

import 'package:driver/themes/app_colors.dart';
import 'package:driver/themes/button_them.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:driver/widget/osm_map/map_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapPickerPage extends StatelessWidget {
  final OSMMapController controller = Get.put(OSMMapController());
  final TextEditingController searchController = TextEditingController();

  MapPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      body: Stack(
        children: [
          Obx(
            () => FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: controller.pickedPlace.value?.coordinates ??
                    LatLng(20.5937, 78.9629), // Default India center
                initialZoom: 13,
                onTap: (tapPos, latlng) {
                  controller.addLatLngOnly(latlng);
                  controller.mapController
                      .move(latlng, controller.mapController.camera.zoom);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: Platform.isAndroid
                      ? 'com.codesteem.driver'
                      : 'com.codesteem.driver',
                ),
                MarkerLayer(
                  markers: controller.pickedPlace.value != null
                      ? [
                          Marker(
                              point: controller.pickedPlace.value!.coordinates,
                              width: 60,
                              height: 60,
                              child: SvgPicture.asset(
                                'assets/icons/ic_destination.svg',
                                width: 60,
                                height: 60,
                                fit: BoxFit.fill,
                                color: AppColors.darkBackground,
                              )),
                        ]
                      : [],
                ),
              ],
            ),
          ),
          Positioned(
            top: 32,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.darkContainerBackground,
                    ),
                  ),
                ),
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: searchController,
                    cursorColor: themeChange.getThem()
                        ? AppColors.darksecondprimary
                        : AppColors.lightsecondprimary,
                    decoration: InputDecoration(
                      hintText: 'Search location...'.tr,
                      fillColor: themeChange.getThem()
                          ? AppColors.darkContainerBackground
                          : AppColors.containerBackground,
                      contentPadding: EdgeInsets.all(12),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search,
                          color: themeChange.getThem()
                              ? AppColors.darksecondprimary
                              : AppColors.lightsecondprimary),
                    ),
                    onChanged: controller.searchPlace,
                  ),
                ),
                Obx(() {
                  if (controller.searchResults.isEmpty)
                    return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: themeChange.getThem()
                          ? AppColors.darkContainerBackground
                          : AppColors.containerBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final place = controller.searchResults[index];
                        return ListTile(
                          title: Text(place['display_name']),
                          onTap: () {
                            controller.selectSearchResult(place);
                            final lat = double.parse(place['lat']);
                            final lon = double.parse(place['lon']);
                            final pos = LatLng(lat, lon);
                            controller.mapController.move(pos, 15);
                            searchController.text = place['display_name'];
                          },
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return Container(
          padding: const EdgeInsets.all(16),
          color: themeChange.getThem()
              ? AppColors.darkBackground
              : AppColors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.pickedPlace.value != null
                    ? "Picked Location:".tr
                    : "No Location Picked".tr,
                style: TextStyle(
                  color: themeChange.getThem()
                      ? AppColors.background
                      : AppColors.darkBackground,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (controller.pickedPlace.value != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    "${controller.pickedPlace.value!.address}\n(${controller.pickedPlace.value!.coordinates.latitude.toStringAsFixed(5)}, ${controller.pickedPlace.value!.coordinates.longitude.toStringAsFixed(5)})",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ButtonThem.buildButton(
                      context,
                      title: "Confirm Location".tr,
                      onPress: () async {
                        final selected = controller.pickedPlace.value;
                        if (selected != null) {
                          Get.back(
                              result: selected); // ✅ Return the selected place
                          print("Selected location: $selected");
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: controller.clearAll,
                  )
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
