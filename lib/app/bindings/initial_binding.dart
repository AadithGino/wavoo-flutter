import 'package:get/get.dart';

import '../controllers/navigation_controller.dart';
import '../controllers/scheme_controller.dart';
import '../controllers/shop_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavigationController(), permanent: true);
    Get.put(ShopController(), permanent: true);
    Get.put(SchemeController(), permanent: true);
  }
}
