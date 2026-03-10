import 'package:driver/controller/home_controller.dart';
import 'package:driver/model/driver_user_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ActiveOrderController extends GetxController {
  HomeController homeController = Get.put(HomeController());
  Rx<DriverUserModel?> drivermodel = DriverUserModel().obs;

  @override
  Future<void> onInit() async {
    drivermodel.value =
        await FireStoreUtils.getDriverProfile(FireStoreUtils.getCurrentUid());
    super.onInit();
  }
}
