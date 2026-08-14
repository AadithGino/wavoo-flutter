import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/scheme_controller.dart';
import '../controllers/shop_controller.dart';
import '../core/network/api_client.dart';
import '../data/local/local_shop_store.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/scheme_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final apiClient = ApiClient(
      onSessionExpired: () {
        if (Get.isRegistered<AuthController>()) {
          Get.find<AuthController>().handleSessionExpired();
        }
      },
    );
    Get.put<ApiClient>(apiClient, permanent: true);

    final authRepo = AuthRepository(apiClient);
    final profileRepo = ProfileRepository(apiClient);
    final catalogRepo = CatalogRepository(apiClient);
    final schemeRepo = SchemeRepository(apiClient);

    Get.put(authRepo, permanent: true);
    Get.put(profileRepo, permanent: true);
    Get.put(catalogRepo, permanent: true);
    Get.put(schemeRepo, permanent: true);
    Get.put(LocalShopStore(), permanent: true);

    Get.put(
      AuthController(
        authRepository: authRepo,
        profileRepository: profileRepo,
      ),
      permanent: true,
    );
    Get.put(NavigationController(), permanent: true);
    Get.put(HomeController(repository: profileRepo), permanent: true);
    Get.put(
      ShopController(
        repository: catalogRepo,
        store: Get.find<LocalShopStore>(),
      ),
      permanent: true,
    );
    Get.put(SchemeController(repository: schemeRepo), permanent: true);
  }
}
