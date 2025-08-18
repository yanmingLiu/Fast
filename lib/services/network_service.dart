import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

import 'app_service.dart';

class NetworkService extends GetxService {
  static NetworkService get to => Get.find();

  var isConnected = false.obs;

  Future<NetworkService> init() async {
    Connectivity().onConnectivityChanged.listen((status) {
      log.i('网络状态：$status');
      if (status.where((element) => element != ConnectivityResult.none).isNotEmpty) {
        isConnected.value = true;
      } else {
        isConnected.value = false;
      }
      log.i('网络状态：$isConnected');
    });
    return this;
  }
}
