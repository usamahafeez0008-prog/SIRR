import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver/constant/collection_name.dart';
import 'package:driver/model/payment_model.dart';
import 'package:driver/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit\
    getPayment();
    super.onInit();
  }

  Rx<PaymentModel> paymentModel = PaymentModel().obs;
  RxBool isLoading = true.obs;

  getPayment() async {
    await FireStoreUtils().getPayment().then((value) {
      if (value != null) {
        paymentModel.value = value;
        isLoading.value = false;
      }
    });
  }

  Stream<QuerySnapshot> getDriverOrdersStream() {
    return FireStoreUtils.fireStore.collection(CollectionName.orders).where('driverId', isEqualTo: FireStoreUtils.getCurrentUid()).orderBy("createdDate", descending: true).snapshots();
  }
}
