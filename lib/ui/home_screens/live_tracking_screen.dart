import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver/constant/constant.dart';
import 'package:driver/controller/live_tracking_controller.dart';
import 'package:driver/themes/app_colors.dart';
import 'package:driver/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutterMap;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as location;
import 'package:provider/provider.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<LiveTrackingController>(
      init: LiveTrackingController(),
      builder: (controller) {
        log("controller.serviceMarkerIcon.value  :: ${controller.serviceMarkerIcon.value}");
        return Scaffold(
          appBar: AppBar(
            elevation: 2,
            backgroundColor: AppColors.lightprimary,
            title: Text(controller.title.value.tr),
            leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: const Icon(
                  Icons.arrow_back,
                )),
          ),
          body: controller.isLoading.value == true
              ? Constant.loader(isDarkTheme: themeChange.getThem())
              : Constant.selectedMapType == 'osm'
                  ? flutterMap.FlutterMap(
                      mapController: controller.osmMapController,
                      options: flutterMap.MapOptions(
                        initialCenter: location.LatLng(
                            Constant.currentLocation!.latitude ?? 45.521563,
                            Constant.currentLocation!.longitude ?? -122.677433),
                        initialZoom: 10,
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
                              child: CachedNetworkImage(
                                width: 50,
                                height: 50,
                                imageUrl: controller.serviceMarkerIcon.value,
                                placeholder: (context, url) => Constant.loader(
                                    isDarkTheme: themeChange.getThem()),
                                errorWidget: (context, url, error) => SizedBox(
                                  width: 30,
                                  height: 30,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            flutterMap.Marker(
                              point: controller.destination.value,
                              width: 50,
                              height: 50,
                              child: Image.asset('assets/images/dropoff.png'),
                            ),
                          ],
                        ),
                        if (controller.routePoints.isNotEmpty)
                          flutterMap.PolylineLayer(
                            polylines: [
                              flutterMap.Polyline(
                                points: controller.routePoints,
                                strokeWidth: 5.0,
                                color: themeChange.getThem()
                                    ? AppColors.darksecondprimary
                                    : AppColors.lightsecondprimary,
                              ),
                            ],
                          ),
                      ],
                    )
                  : Obx(
                      () => GoogleMap(
                        myLocationEnabled: false,
                        myLocationButtonEnabled: true,
                        mapType: MapType.terrain,
                        zoomControlsEnabled: false,
                        polylines:
                            Set<Polyline>.of(controller.polyLines.values),
                        padding: const EdgeInsets.only(
                          top: 22.0,
                        ),
                        markers: Set<Marker>.of(controller.markers.values),
                        onMapCreated: (GoogleMapController mapController) {
                          controller.mapController = mapController;
                        },
                        initialCameraPosition: CameraPosition(
                          zoom: 15,
                          target: LatLng(
                              Constant.currentLocation != null
                                  ? Constant.currentLocation!.latitude!
                                  : 45.521563,
                              Constant.currentLocation != null
                                  ? Constant.currentLocation!.longitude!
                                  : -122.677433),
                        ),
                      ),
                    ),
        );
      },
    );
  }
}
